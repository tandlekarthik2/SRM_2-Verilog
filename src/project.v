/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_stone_paper_scissors (
    input  wire [7:0] ui_in,   // 8-bit input
    output wire [7:0] uo_out,  // 8-bit output
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,            // must exist
    input  wire clk,
    input  wire rst_n
);

    // Tie off unused bidir pins
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Input mapping
    wire [1:0] p1_move = ui_in[1:0];
    wire [1:0] p2_move = ui_in[3:2];
    wire       start   = ui_in[4];
    wire       mode    = ui_in[5];
    wire       reset   = ~rst_n;

    // Registers
    reg [1:0] winner, next_winner;
    reg [2:0] state;
    reg [2:0] debug; next_debug;
    reg [2:0] next_state;

    // FSM states
    localparam S_IDLE     = 3'b000;
    localparam S_EVALUATE = 3'b001;
    localparam S_RESULT   = 3'b010;

    // Sequential logic
    always @(posedge clk or posedge reset) begin
    if (reset) begin
        winner <= 2'b00;
        debug  <= 3'b000;
    end else begin
        winner <= next_winner;
        debug  <= next_debug;
    end
end


    // FSM combinational logic
    always @(*) begin
    next_winner = 2'b00;    // default
    next_debug  = 3'b000;   // default

    case (state)
        S_EVALUATE: begin
            if (p1_move == 2'b11 || p2_move == 2'b11)
                next_winner = 2'b11;  // Invalid
            else if (p1_move == p2_move)
                next_winner = 2'b00;  // Tie
            else begin
                case (p1_move)
                    2'b00: next_winner = (p2_move == 2'b10) ? 2'b01 : 2'b10; // Stone
                    2'b01: next_winner = (p2_move == 2'b00) ? 2'b01 : 2'b10; // Paper
                    2'b10: next_winner = (p2_move == 2'b01) ? 2'b01 : 2'b10; // Scissors
                    default: next_winner = 2'b11;
                endcase
            end
            next_debug = {p1_move[0], p2_move[1:0]};
        end
    endcase
end


    // Output mapping: must be exactly 8 bits
    // state[2:0] + winner[1:0] + debug[2:0] = 8 bits
    assign uo_out = ena ? {state, winner, debug} : 8'b0;

endmodule
