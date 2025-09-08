/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_stone_paper_scissors (
    input  wire [7:0] ui_in,   // 8 input pins
    output wire [7:0] uo_out,  // 8 output pins
    input  wire [7:0] uio_in,  // unused
    output wire [7:0] uio_out, // unused
    output wire [7:0] uio_oe,  // unused
    input  wire       ena,     // enable
    input  wire       clk,     // system clock
    input  wire       rst_n    // active-low reset
);

    // Tie off unused bidirectional pins
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Input mapping
    wire [1:0] p1_move = ui_in[1:0];  // Player 1 move
    wire [1:0] p2_move = ui_in[3:2];  // Player 2 move
    wire       start   = ui_in[4];    // Start button
    wire       mode    = ui_in[5];    // Reserved
    wire       reset   = ~rst_n;      // Active-high reset

    // Registers
    reg [1:0] winner, next_winner;
    reg [2:0] state, next_state;
    reg [2:0] debug, next_debug;

    // FSM states
    localparam S_IDLE     = 3'b000;
    localparam S_EVALUATE = 3'b001;
    localparam S_RESULT   = 3'b010;

    // Sequential logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= S_IDLE;
            winner  <= 2'b00;
            debug   <= 3'b000;
        end else begin
            state   <= next_state;
            winner  <= next_winner;
            debug   <= next_debug;
        end
    end

    // FSM combinational logic
    always @(*) begin
        // defaults
        next_state  = state;
        next_winner = winner;
        next_debug  = debug;

        case (state)
            S_IDLE: begin
                if (start) next_state = S_EVALUATE;
            end

            S_EVALUATE: begin
                // Check validity
                if (p1_move == 2'b11 || p2_move == 2'b11)
                    next_winner = 2'b11;  // Invalid input
                else if (p1_move == p2_move)
                    next_winner = 2'b00;  // Tie
                else begin
                    case (p1_move)
                        2'b00: next_winner = (p2_move == 2'b10) ? 2'b01 : 2'b10; // Stone
                        2'b01: next_winner = (p2_move == 2'b00) ? 2'b01 : 2'b10; // Paper
                        2'b10: next_winner = (p2_move == 2'b01) ? 2'b01 : 2'b10; // Scissors
                        default: next_winner = 2'b11; // Invalid
                    endcase
                end
                next_debug = {p1_move[0], p2_move[1:0]};
                next_state = S_RESULT;
            end

            S_RESULT: begin
                // Stay in result until reset or new start
                if (!start) next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    // Output mapping (8 bits)
    // Format: {state[2:0], winner[1:0], debug[2:0]}
    assign uo_out = ena ? {state, winner, debug} : 8'b0;
 
endmodule
