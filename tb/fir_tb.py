#!/usr/bin/env python

import cocotb
import numpy as np
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, Timer
from fxpmath import Fxp
from scipy.signal import lfilter

from tb import fir_config


def generate_input_samples() -> Fxp:
    # Generate multi-tone waveform, with two tones above the cut-off frequency
    number_of_samples = 128
    amplitude = np.array([[2, 3, 5]])
    f = np.array([[fir_config.CUTOFF_FREQ / 2,
                   fir_config.CUTOFF_FREQ * 1.2,
                   fir_config.CUTOFF_FREQ * 2]])
    fs = fir_config.SAMPLING_FREQ
    t = np.arange(0, number_of_samples) / fs
    x = 2 * np.pi * np.transpose(f).dot(np.array([t]))
    x = np.transpose(amplitude) * x
    y = np.sin(x)
    y = np.sum(y, axis = 0)
    # Normalise to handle cases where there is only one integer bit correctly
    normalise_factor = np.max(np.abs(([np.max(y), np.min(y)])))
    y /= normalise_factor
    y = Fxp(y,
            signed = fir_config.SIGNED,
            n_word = fir_config.N_WORD,
            n_frac = fir_config.N_FRAC,
            overflow = fir_config.OVERFLOW)
    return y

def generate_expected_output_samples(input_samples : Fxp) -> Fxp:
    expected = lfilter(fir_config.fir_coeffs, 1, input_samples)
    n_word = fir_config.fir_coeffs.n_word + input_samples.n_word
    n_frac = fir_config.fir_coeffs.n_frac + input_samples.n_frac
    # Since filtering involves multiplying, the output length is equal to
    # input sample length + FIR coefficient length
    expected = Fxp(expected,
                   signed = fir_config.SIGNED,
                   n_word = n_word,
                   n_frac = n_frac,
                   overflow = fir_config.OVERFLOW)
    return expected

async def reset_dut(dut, reset_duration_ns : int) -> None:
    dut.rst_n.value = 0
    await Timer(reset_duration_ns, "ns")
    dut.rst_n.value = 1

@cocotb.test()
async def test_fir(dut) -> None:
    input_samples           = generate_input_samples()
    expected_output_samples = generate_expected_output_samples(input_samples)

    clock = Clock(dut.clk, 10, unit = "ns")
    cocotb.start_soon(clock.start(start_high = False))

    await reset_dut(dut, 10)
    await ClockCycles(dut.clk, 1)

    number_of_pipelining_steps = 2
    for idx, sample in enumerate(input_samples):
        dut.x.value = int(sample.val)
        await ClockCycles(dut.clk, 1)
        if idx >= number_of_pipelining_steps:
            expected_output_sample = expected_output_samples[idx - number_of_pipelining_steps]
            shift = expected_output_sample.n_word - fir_config.fir_parameters['DATA_WIDTH']
            expected_value = expected_output_sample.val >> shift
            actual_value = dut.y.value.to_signed()
            cocotb.log.debug(f"expected_output_samples[{idx - number_of_pipelining_steps}] = \
                             {expected_value:X}, dut.y.value.to_signed = {actual_value:X}")
            assert expected_value == actual_value, \
                   f"Expected value: {expected_value:#x} does not match \
                   actual value {actual_value:#x} for idx = {idx}"
