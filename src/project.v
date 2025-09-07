/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_stone_paper_scissors (
    input  wire [7:0] ui_in,   // 8 external inputs
    output wire [7:0] uo_out,  // 8 external outputs
    input  wire [7:0] uio_in,  // bidirectional (unused)
    output wire [7:0] uio_out, // bidirectional (unused)
    output wire [7:0] uio_oe,  // bidirectional (unused)
    input  wire ena,           // enable required by TinyTapeout
    input  wire clk,           // global clock
    input  wire rst_n          // active-low reset
);

    // Tie unused bidirectional pins
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // Map inputs
    wire [1:0] p1_move = ui_in[1:0];
    wire [1:0] p2_move = ui_in[3:2];
    wire       start   = ui_in[4];
    wire       mode    = ui_in[5];
    wire       reset   = ~rst_n;

    // Internal registers
    reg [1:0] winner;   // 00=Tie, 01=P1 wins, 10=P2 wins, 11=Invalid
    reg [2:0] state;    // FSM state
    reg [2:0] debug;    // Debug info
    reg [2:0] next_state;

    // FSM states
    localparam S_IDLE     = 3'b000;
    localparam S_EVALUATE = 3'b001;
    localparam S_RESULT   = 3'b010;
    localparam S_RESET    = 3'b011;

    // Sequential logic: state update and reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state  <= S_IDLE;
            winner <= 2'b00;
            debug  <= 3'b000;
        end else begin
            state  <= next_state;
        end
    end

    // FSM combinational logic
    always @(*) begin
        next_state = state;
        winner     = winner; // hold previous value by default
        debug      = debug;  // hold previous value by default

        case(state)
            S_IDLE: begin
                if (start)
                    next_state = S_EVALUATE;
            end

            S_EVALUATE: begin
                // Determine winner
                if (p1_move == 2'b11 || p2_move == 2'b11)
                    winner = 2'b11; // Invalid
                else if (p1_move == p2_move)
                    winner = 2'b00; // Tie
                else begin
                    case(p1_move)
                        2'b00: winner = (p2_move == 2'b10) ? 2'b01 : 2'b10; // Stone
                        2'b01: winner = (p2_move == 2'b00) ? 2'b01 : 2'b10; // Paper
                        2'b10: winner = (p2_move == 2'b01) ? 2'b01 : 2'b10; // Scissors
                        default: winner = 2'b11; // Invalid
                    endcase
                end
                debug = {p1_move[0], p2_move[1:0]};
                next_state = S_RESULT;
            end

            S_RESULT: begin
                if (!start)
                    next_state = S_IDLE;
            end

            S_RESET: begin
                next_state = S_IDLE;
            end

            default: next_state = S_IDLE;
        endcase
    end

    // Map outputs (fully driven) and gated by ena
    assign uo_out = ena ? {state, winner, debug[1:0]} : 8'b0;

endmodule


