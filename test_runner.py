#!/usr/bin/env python3

import os
from dataclasses import dataclass
from pathlib import Path

from cocotb_tools.runner import get_runner


@dataclass
class SimulatorDescriptor:
    toplevel: str
    sources: list
    test_module: str
    env_variables: dict
    build_dir: Path
    waves: bool
    verbose: bool

def run_simulation(sim, simulation_descriptor : SimulatorDescriptor) -> None:
    runner = get_runner(sim)
    runner.build(sources      = simulation_descriptor.sources,
                 hdl_toplevel = simulation_descriptor.toplevel,
                 verbose      = simulation_descriptor.verbose,
                 build_dir    = simulation_descriptor.build_dir,
                 waves        = simulation_descriptor.waves)

    runner.test(hdl_toplevel  = simulation_descriptor.toplevel,
                test_module   = simulation_descriptor.test_module,
                extra_env     = simulation_descriptor.env_variables,
                waves         = simulation_descriptor.waves,
                verbose       = simulation_descriptor.verbose)


def test_my_design_runner() -> None:
    sim = os.getenv("SIM", "verilator")
    build_dir = Path(os.getenv("SIM_DIR", "./output/sim"))
    waves = os.getenv("WAVES", "0") == "1"

    proj_path = Path(__file__).resolve().parent

    top_tb = SimulatorDescriptor(
        toplevel      = "top",
        sources       = [proj_path / "rtl/top.v", proj_path / "rtl/multiplier.v"],
        test_module   = "top_tb",
        env_variables = {"PYTHONPATH": [proj_path / "tb"]},
        build_dir     = build_dir / "top_tb",
        waves         = waves,
        verbose       = True
    )

    fir_tb = SimulatorDescriptor(
        toplevel      = "fir",
        sources       = [proj_path / "rtl/fir.sv"],
        test_module   = "fir_tb",
        env_variables = {"PYTHONPATH": [proj_path / "tb"]},
        build_dir     = build_dir / "fir_tb",
        waves         = waves,
        verbose       = True
    )

    simulations = [
        top_tb,
        fir_tb
    ]

    for simulation in simulations:
        run_simulation(sim, simulation)

if __name__ == "__main__":
    test_my_design_runner()
