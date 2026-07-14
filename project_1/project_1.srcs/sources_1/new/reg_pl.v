`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2026 12:18:44 PM
// Design Name: 
// Module Name: reg_pl
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


module reg_pl #(parameter W = 4)(
    input clk,reset,pl,
    input [W-1:0] d_in,
    output reg [W-1:0] d_out
    );
    always @(posedge clk or posedge reset) begin
        if(reset) d_out <=0;
        else if(pl) d_out <=d_in;
    end
endmodule
