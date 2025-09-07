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
    reg [1:0] winner;
    reg [2:0] state;
    reg [2:0] debug;
    reg [2:0] next_state;

    // FSM states
    localparam S_IDLE     = 3'b000;
    localparam S_EVALUATE = 3'b001;
    localparam S_RESULT   = 3'b010;

    // Sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state  <= S_IDLE;
            winner <= 2'b00;
            debug  <= 3'b000;
        end else begin
            state <= next_state;
        end
    end

    // FSM combinational logic
    always @(*) begin
        next_state = state;
        winner     = winner;
        debug      = debug;

        case(state)
            S_IDLE: begin
                if (start)
                    next_state = S_EVALUATE;
            end

            S_EVALUATE: begin
                // Determine winner
                if (p1_move == 2'b11 || p2_move == 2'b11)
                    winner = 2'b11;
                else if (p1_move == p2_move)
                    winner = 2'b00;
                else begin
                    case(p1_move)
                        2'b00: winner = (p2_move == 2'b10) ? 2'b01 : 2'b10;
                        2'b01: winner = (p2_move == 2'b00) ? 2'b01 : 2'b10;
                        2'b10: winner = (p2_move == 2'b01) ? 2'b01 : 2'b10;
                        default: winner = 2'b11;
                    endcase
                end
                debug = {p1_move[0], p2_move[1:0]}; // 3 bits
                next_state = S_RESULT;
            end

            S_RESULT: begin
                if (!start)
                    next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    // Output mapping: must be exactly 8 bits
    // state[2:0] + winner[1:0] + debug[2:0] = 8 bits
    assign uo_out = ena ? {state, winner, debug} : 8'b0;

endmodule
