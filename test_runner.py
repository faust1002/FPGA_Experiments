#!/usr/bin/env python

import os
from pathlib import Path
from typing import Mapping

from cocotb.runner import get_runner

def test_my_design_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent

    sources = [proj_path / "src/test.v"]
    testbenches = [proj_path / "tb"]
    env_variables = {"PYTHONPATH": testbenches}

    runner = get_runner(sim)
    runner.build(sources = sources, hdl_toplevel = "test", verbose = True)

    runner.test(hdl_toplevel = "test", test_module = "test_tb", extra_env = env_variables, waves = True, verbose = True)

if __name__ == "__main__":
    test_my_design_runner()

