#!/usr/bin/env python

import cocotb
from cocotb.triggers import Timer

from tb.signed_multiplier_config import signed_multiplier_parameters


@cocotb.test
async def test_signed_multiplier(dut) -> None:
    x_length = signed_multiplier_parameters["X_LENGTH"]
    x_upper_limit = (1 << (x_length - 1)) - 1
    x_lower_limit = -(1 << (x_length - 1))
    y_length = signed_multiplier_parameters["Y_LENGTH"]
    y_upper_limit = (1 << (y_length - 1)) - 1
    y_lower_limit = -(1 << (y_length - 1))
    values = (f'X_LENGTH = {x_length}, '
              f'x_lower_limit = {x_lower_limit}, '
              f'x_upper_limit = {x_upper_limit}, '
              f'Y_LENGTH = {y_length}, '
              f'y_lower_limit = {y_lower_limit}, '
              f'y_upper_limit = {y_upper_limit}')
    cocotb.log.info(values)

    for x in range(x_lower_limit, x_upper_limit + 1):
        for y in range(y_lower_limit, y_upper_limit + 1):
            dut.x.value = x
            dut.y.value = y
            await Timer(1, unit = "ns")
            assert dut.z.value.to_signed() == x * y, \
            f'Expected value = {x * y}, actual value = {dut.z.value.to_signed()}'
