#!/usr/bin/env python

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer


async def reset_dut(dut, reset_duration_ns : int):
    dut.rst_n.value = 0
    await Timer(reset_duration_ns, "ns")
    dut.rst_n.value = 1

@cocotb.test()
async def test_fir(dut) -> None:
    clock = Clock(dut.clk, 10, unit = "ns") #Create a 10us period clock on port clk
    cocotb.start_soon(clock.start(start_high = False))

    await reset_dut(dut, 10)

    assert False, "TB not implemented yet"
