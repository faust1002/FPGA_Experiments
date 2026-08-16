#!/usr/bin/env python

import math
from pathlib import Path

from fxpmath import Fxp
from scipy.signal import firwin

N_WORD = 18
N_FRAC = N_WORD - 2
SIGNED = True

fir_parameters = {"DATA_WIDTH":  N_WORD,
                  "COEFF_WIDTH": N_WORD,
                  "NUM_TAPS":    43}

SAMPLING_FREQ = 122.88e6
CUTOFF_FREQ   = 30.72e6

fir_coeffs = firwin(fir_parameters["NUM_TAPS"], CUTOFF_FREQ, fs = SAMPLING_FREQ)
fir_coeffs = Fxp(fir_coeffs, signed = SIGNED, n_word = N_WORD, n_frac = N_FRAC)

def main():
    print("Hello")

    proj_path = Path(__file__).resolve().parent.parent
    coeff_path = proj_path / "rtl/fir_coeffs.txt"
    n_digits = int(math.ceil(N_WORD / 4))

    print(f"N_WORD = {N_WORD}, N_FRAC = {N_FRAC}, SIGNED = {SIGNED}")
    print(f"SAMPLING_FREQ = {SAMPLING_FREQ / 1e6}MHz, CUTOFF_FREQ = {CUTOFF_FREQ / 1e6}MHz")
    print(f"Number of tags = {fir_parameters['NUM_TAPS']}")
    print(fir_coeffs)
    print(f"Saving coeffs file to {coeff_path}")

    with open(coeff_path, "w+", encoding = "utf-8") as fp:
        for coeff in fir_coeffs:
            value = coeff.val
            if value < 0:
                value += 1 << N_WORD
            fp.write(f"{value:0{n_digits}X}\n")


    print("Goodbye")

if __name__ == "__main__":
    main()
