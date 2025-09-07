`default_nettype none
`timescale 1ns/1ps
`default_nettype none

module tb;

    // Clock and reset
    reg clk = 0;
    reg rst_n = 0;

    // TinyTapeout signals
    reg [7:0] ui_in = 8'b0;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg ena = 0;

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    // Instantiate DUT
    tt_um_stone_paper_scissors dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(8'b0),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        // Open VCD file for waveform
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        // Reset sequence
        rst_n = 0;
        ena   = 0;
        #20;
        rst_n = 1;
        #10;

        // Enable the DUT
        ena = 1;

        // Test case 1: P1=Stone(00), P2=Scissors(10) => P1 wins
        ui_in = 8'b00001000;  // p1=00, p2=10, start=1
        #10;
        ui_in[4] = 0; // stop start
        #10;

        // Check output
        if (uo_out[5:4] !== 2'b01) $display("Test case 1 failed!");

        // Test case 2: P1=Paper(01), P2=Stone(00) => P1 wins
        ui_in = 8'b00010100;  // p1=01, p2=00, start=1
        #10;
        ui_in[4] = 0; // stop start
        #10;
        if (uo_out[5:4] !== 2'b01) $display("Test case 2 failed!");

        // Test case 3: P1=Scissors(10), P2=Scissors(10) => Tie
        ui_in = 8'b00101000;  // p1=10, p2=10, start=1
        #10;
        ui_in[4] = 0;
        #10;
        if (uo_out[5:4] !== 2'b00) $display("Test case 3 failed!");

        // Test case 4: Invalid move P1=11
        ui_in = 8'b00001100;  // p1=11, p2=00, start=1
        #10;
        ui_in[4] = 0;
        #10;
        if (uo_out[5:4] !== 2'b11) $display("Test case 4 failed!");

        $display("All test cases completed.");
        $finish;
    end

endmodule
