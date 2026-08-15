#!/usr/bin/env python

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer

NUMBER_OF_LED_BITS = 4
NUMBER_OF_COUNTER_BITS = 16
MAX_LED_VALUE = 2 ** NUMBER_OF_LED_BITS
MAX_COUNTER_VALUE = 2 ** NUMBER_OF_COUNTER_BITS

PRIMARY_CONTER_START_VALUE = 37
SECONDARY_CONTER_START_VALUE = 42
OFFSET = 1

def calculate_led_value(iteration = 0):
    primary_counter_value = (PRIMARY_CONTER_START_VALUE + iteration) % MAX_COUNTER_VALUE
    secondary_counter_value = (SECONDARY_CONTER_START_VALUE + iteration) % MAX_COUNTER_VALUE
    led_value = (primary_counter_value * secondary_counter_value + OFFSET) % MAX_LED_VALUE
    return led_value

async def reset_dut(reset, duration_ns):
    reset.value = 1
    await Timer(duration_ns, unit = "ns")
    reset.value = 0

@cocotb.test()
async def test_tb_basic_scenario(dut):
    """Test that led output is equal to four LSBs of a product of two internal 16-bit counters,
    with an additional offset added"""

    cocotb.log.debug("Applying reset")

    await reset_dut(dut.rst, 10)

    cocotb.log.debug("Reset completed")

    # Initially, after reset is applied, but clk is not enabled, all values should be set to 0
    assert dut.led.value == calculate_led_value()

    clock = Clock(dut.clk, 10, unit = "ns") #Create a 10us period clock on port clk
    cocotb.start_soon(clock.start(start_high = False))

    cocotb.log.debug("Starting the actual test case")

    # Synchronise with the clock
    await ClockCycles(dut.clk, 1)
    # As soon as the first rising edge of the clock arrives, led is increased by one.
    # Therefore we start iterating from 1, not 0
    for idx in range(1, 2 ** NUMBER_OF_COUNTER_BITS):
        await ClockCycles(dut.clk, 1)
        expected_value = calculate_led_value(idx)
        cocotb.log.debug(f"idx = {idx}, dut.led.value = {dut.led.value}, \
                           expected_value = {expected_value}")
        assert dut.led.value == expected_value, \
               f"output led value was incorrect on the {idx}th cycle"

    # Check the final input on next clock
    await ClockCycles(dut.clk, 1)
    expected_value = calculate_led_value(2 ** NUMBER_OF_COUNTER_BITS)
    assert dut.led.value == expected_value, \
           f"output led was incorrect on the last cycle \
           dut.led.value = {dut.led.value}, expected_value = {expected_value}"
