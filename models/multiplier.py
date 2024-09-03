#!/usr/bin/env python

def half_adder(a, b):
    sum_out = a ^ b
    carry_out = a & b
    return (sum_out, carry_out)

def full_adder(a, b, carry_in):
    sum_out = a ^ b ^ carry_in
    carry_out = (a & b) | (a & carry_in) | (b & carry_in)
    return (sum_out, carry_out)

def run():
    print("Hello multiplier")

    a = 0b1;
    b = 0b1;
    sum_out, carry_out = half_adder(a, b)
    print(f"a = {a}, b = {b}, sum_out = {sum_out}, carry_out = {carry_out}")

    sum_out, carry_out = full_adder(a, b, carry_out) # use carry_out from the half adder as carry in for the full_adder
    print(f"a = {a}, b = {b}, sum_out = {sum_out}, carry_out = {carry_out}")

    print("Goodbye multiplier")

if __name__ == "__main__":
    run()
