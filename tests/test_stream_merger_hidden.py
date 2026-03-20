from __future__ import annotations
import os
from pathlib import Path
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from cocotb_tools.runner import get_runner


async def reset(dut):
    dut.rst_n.value = 0
    dut.in0_valid.value = 0
    dut.in1_valid.value = 0
    dut.out_ready.value = 0

    for _ in range(5):
        await RisingEdge(dut.clk)

    dut.rst_n.value = 1


@cocotb.test()
async def test_stream_merger_hidden(dut):
    cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

    await reset(dut)

    data0 = list(range(10))
    data1 = list(range(100, 110))

    idx0 = 0
    idx1 = 0

    out0 = []
    out1 = []

    for _ in range(200):
        dut.out_ready.value = random.choice([0, 1])

        if idx0 < len(data0):
            dut.in0_valid.value = 1
            dut.in0_data.value = data0[idx0]
        else:
            dut.in0_valid.value = 0

        if idx1 < len(data1):
            dut.in1_valid.value = 1
            dut.in1_data.value = data1[idx1]
        else:
            dut.in1_valid.value = 0

        await RisingEdge(dut.clk)

        if dut.in0_valid.value and dut.in0_ready.value:
            idx0 += 1

        if dut.in1_valid.value and dut.in1_ready.value:
            idx1 += 1

        if dut.out_valid.value and dut.out_ready.value:
            val = int(dut.out_data.value)
            if val < 100:
                out0.append(val)
            else:
                out1.append(val)

    assert out0 == data0
    assert out1 == data1

def test_stream_merger_hidden_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent.parent

    sources = [
        proj_path / "sources/stream_buffer.sv",
        proj_path / "sources/arbiter.sv",
        proj_path / "sources/top_stream_merger.sv",
    ]

    runner = get_runner(sim)

    runner.build(
        sources=sources,
        hdl_toplevel="top_stream_merger",
        always=True,
    )

    runner.test(
        hdl_toplevel="top_stream_merger",
        test_module="test_stream_merger_hidden",
    )
