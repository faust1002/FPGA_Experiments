#!/usr/bin/env python

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray

number_of_led_bits = 4
number_of_counter_bits = 16
max_led_value = 2 ** number_of_led_bits
max_counter_value = 2 ** number_of_counter_bits

primary_counter_starting_value = 37;
secondary_counter_starting_value = 42;
additional_offset = 1;

def calculate_led_value(iteration = 0):
    primary_counter_value = (primary_counter_starting_value + iteration) % max_counter_value
    secondary_counter_value = (secondary_counter_starting_value + iteration) % max_counter_value
    led_value = (primary_counter_value * secondary_counter_value + additional_offset) % max_led_value
    return led_value

async def reset_dut(reset, duration_ns):
    reset.value = 1;
    await Timer(duration_ns, units = "ns")
    reset.value = 0;

@cocotb.test()
async def test_tb_basic_scenario(dut):
    """Test that led output is equal to four LSBs of a product of two internal 16-bit counters, with an additional offset added"""

    cocotb.log.debug("Applying reset")

    await reset_dut(dut.rst, 10)

    cocotb.log.debug("Reset completed")

    # Initially, after reset is applied, but clk is not enabled, all values should be set to 0
    assert dut.led.value == calculate_led_value()

    clock = Clock(dut.clk, 10, units="ns") #Create a 10us period clock on port clk
    cocotb.start_soon(clock.start(start_high = False))

    cocotb.log.debug("Starting the actual test case")

    # Synchronise with the clock
    await RisingEdge(dut.clk)
    for idx in range(1, 2 ** number_of_counter_bits): # As soon as the first rising edge of the clock arrives, led is increased by one. Therefore we start iterating from 1, not 0
        await RisingEdge(dut.clk)
        expected_value = calculate_led_value(idx)
        cocotb.log.debug(f"idx = {idx}, dut.led.value = {dut.led.value}, expected_value = {expected_value}")
        assert dut.led.value == expected_value, f"output led value was incorrect on the {idx}th cycle"

    # Check the final input on next clock
    await RisingEdge(dut.clk)
    expected_value = calculate_led_value(2 ** number_of_counter_bits)
    assert dut.led.value == expected_value, f"output led was incorrect on the last cycle"
