# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

@cocotb.test()
async def stone_paper_scissors_test(dut):
    """Test the TinyTapeout Stone-Paper-Scissors module"""

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    dut.ena.value = 0
    dut.ui_in.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    dut.ena.value = 1

    # Helper function
    async def play(p1, p2):
        dut.ui_in.value = (p2 << 2) | p1 | (1 << 4)  # start=1
        await RisingEdge(dut.clk)
        dut.ui_in.value = dut.ui_in.value & ~(1 << 4)  # stop start
        await RisingEdge(dut.clk)
        winner = (dut.uo_out.value.integer >> 3) & 0b11
        return winner

    # Test cases
    assert await play(0, 2) == 1, "P1 Stone vs P2 Scissors failed"
    assert await play(1, 0) == 1, "P1 Paper vs P2 Stone failed"
    assert await play(2, 2) == 0, "P1 Scissors vs P2 Scissors failed"
    assert await play(3, 0) == 3, "Invalid move failed"

    dut._log.info("All test cases passed!")

