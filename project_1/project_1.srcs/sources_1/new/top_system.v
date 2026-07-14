`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2026 12:30:41 PM
// Design Name: 
// Module Name: top_sistem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_system #(parameter W = 4)(
    input CLK, RESET, SHL, SI, ENCNT, INC, DEC, SEL, PL,
    input SO,
    output [W-1:0] OUT_SHR, OUT_CNT, DO
    );
    wire [W-1:0] w_mux;
    
    lshr #(W) u_lshr(CLK, RESET, SHL, SI, OUT_SHR, SO);
    cnt #(W) u_cnt(CLK, RESET, ENCNT, INC, DEC, OUT_CNT);
    mux21 #(W) u_mux(OUT_SHR, OUT_CNT, SEL, w_mux);
    reg_pl #(W) u_reg(CLK, RESET, PL, w_mux, DO);
endmodule
