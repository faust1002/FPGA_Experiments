#!/usr/bin/env python3

import os
from pathlib import Path
from typing import Mapping

from cocotb_tools.runner import get_runner

def test_my_design_runner():
    sim = os.getenv("SIM", "icarus")
    build_dir = os.getenv("SIM_DIR")
    print(build_dir)

    proj_path = Path(__file__).resolve().parent

    sources = [proj_path / "rtl/top.v", proj_path / "rtl/multiplier.v"]
    testbenches = [proj_path / "tb"]
    env_variables = {"PYTHONPATH": testbenches}

    runner = get_runner(sim)
    runner.build(sources = sources, hdl_toplevel = "top", verbose = True, build_dir = build_dir)

    runner.test(hdl_toplevel = "top", test_module = "test_tb", extra_env = env_variables, waves = True, verbose = True)

if __name__ == "__main__":
    test_my_design_runner()

