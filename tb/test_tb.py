#!/usr/bin/env python

import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb.types import LogicArray

number_of_led_bits = 4
number_of_counter_bits = 16
led_mask = (1 << (number_of_led_bits)) - 1

async def reset_dut(reset, duration_ns):
    reset.value = 1;
    await Timer(duration_ns, units = "ns")
    reset.value = 0;

@cocotb.test()
async def test_tb_basic_scenario(dut):
    """Test that led is set to four LSBs of the internal 16 bit counter"""

    cocotb.log.debug("Applying reset")

    await reset_dut(dut.rst, 10)

    cocotb.log.debug("Reset completed")

    # Initially, after reset is applied, but clk is not enabled, all values should be set to 0
    assert LogicArray(dut.led.value) == LogicArray(number_of_led_bits * '0')

    clock = Clock(dut.clk, 10, units="ns") #Create a 10us period clock on port clk
    cocotb.start_soon(clock.start(start_high = False))

    cocotb.log.debug("Starting the actual test case")

    # Synchronise with the clock
    await RisingEdge(dut.clk)
    for i in range(1, 2 ** number_of_counter_bits): # As soon as the first rising edge of the clock arrives, led is increased by one. Therefore we start iterating from 1, not 0
        await RisingEdge(dut.clk)
        expected_value = i & led_mask
        cocotb.log.debug(f"i = {i}, dut.led.value = {dut.led.value}")
        assert dut.led.value == expected_value, f"output led value was incorrect on the {i}th cycle"

    # Check the final input on next clock
    await RisingEdge(dut.clk)
    assert dut.led.value == ((2 ** number_of_counter_bits) & led_mask), f"output led was incorrect on the last cycle"
