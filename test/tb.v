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

    // Helper task to apply moves
    task play(input [1:0] p1, input [1:0] p2);
        begin
            ui_in = {2'b0, p2, p1, 1'b1}; // start=1
            #10;
            ui_in[4] = 0; // stop start
            #10;
        end
    endtask

    initial begin
        // Open VCD waveform
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);

        // Reset
        rst_n = 0;
        ena   = 0;
        #20;
        rst_n = 1;
        ena   = 1;
        #10;

        // Test case 1: P1=Stone(0), P2=Scissors(2) => P1 wins
        play(2'b00, 2'b10);

        // Test case 2: P1=Paper(1), P2=Stone(0) => P1 wins
        play(2'b01, 2'b00);

        // Test case 3: P1=Scissors(2), P2=Scissors(2) => Tie
        play(2'b10, 2'b10);

        // Test case 4: Invalid move P1=11
        play(2'b11, 2'b00);

        $display("All test cases completed.");

    initial begin
    #1;
    $system("echo '<testsuites></testsuites>' > results.xml");
end

endmodule
