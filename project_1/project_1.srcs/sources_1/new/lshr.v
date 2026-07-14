`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2026 12:16:51 PM
// Design Name: 
// Module Name: lshr
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


module lshr #(parameter W=4)(
    input clk, reset, shl, si,
    output reg [W-1:0] out_shr,
    output so
    );
    assign so = out_shr[W-1];
    always @(posedge clk or posedge reset) begin
        if(reset) out_shr <=0;
        else if (shl) out_shr <={out_shr[W-2:0], si};
    end
endmodule
