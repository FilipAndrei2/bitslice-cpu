`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2026 12:17:09 PM
// Design Name: 
// Module Name: cnt
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


module cnt #(parameter W=4)(
    input clk,reset,encnt,inc,dec,
    output reg [W-1:0] out_cnt
    );
    always @(posedge clk or posedge reset) begin
        if(reset) out_cnt <=0;
        else if(encnt) begin
            if(inc && !dec) out_cnt <=out_cnt +1;
            else if (dec && !inc) out_cnt <= out_cnt -1;
        end
    end
endmodule
