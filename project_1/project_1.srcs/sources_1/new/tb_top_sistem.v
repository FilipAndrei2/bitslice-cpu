`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2026 12:38:20 PM
// Design Name: 
// Module Name: tb_top_sistem
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


module tb_top_sistem();
    parameter W=4;
    reg CLK, RESET, SHL, SI, ENCNT, INC, DEC, SEL, PL;
    wire SO;
    wire [W-1:0] OUT_SHR, OUT_CNT, DO;
    
    top_sistem #(W) dut (CLK, RESET,SHL, SI, ENCNT, INC, DEC, SEL, PL, OUT_SHR, OUT_CNT, DO);
    
    always #5 CLK = ~CLK;
    
    initial begin
        CLK = 0; RESET = 1;
        SHL = 0; SI = 0; ENCNT = 0; INC = 0; DEC = 0; SEL = 0; PL = 0;
        #15 RESET = 0;
        #10 SHL = 1; SI = 1;
        #10 SHL = 1; SI = 0;
        #10 SHL = 1; SI = 1;
        #10 SHL = 0;
        #10 SEL = 0; PL = 1;
        #10 PL = 0;
        #10 ENCNT = 1; INC = 1;
        #30 INC = 0; ENCNT = 0;
        #10 SEL = 1; PL = 1;
        #10 PL = 0;
        #10 ENCNT = 1; DEC = 1;
        #20 ENCNT = 0; DEC = 0;
        #10 SEL = 1; PL = 1;
        #10 PL = 0;
        #20 $stop;
    end
endmodule
