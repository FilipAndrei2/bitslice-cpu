`timescale 1ns / 1ps

module am2901_tb;

reg [8:0] I;
reg [3:0] data;
reg carry_in;

reg clk;

// Indica catre ramul intern
reg [3:0] a_port;
reg [3:0] b_port;

reg output_enable_not; // functioneaza pe logica negata

reg ram0_in;
reg ram3_in;
reg q0_in;
reg q3_in;

reg in0;

wire [3:0] do;

wire p_not;
wire g_not;
wire ovr;
wire zero;
wire msb;
wire carry_out;



am2901 uut(
    .I(I),
    .data(data),
    .carry_in(carry_in),
    .clk(clk),
    .a_port(a_port),
    .b_port(b_port),
    .output_enable_not(output_enable_not),
    .ram0_in(ram0_in),
    .ram3_in(ram3_in),
    .q0_in(q0_in),
    .q3_in(q3_in),
    .in0(in0),
    .do(do),
    .p_not(p_not),
    .g_not(g_not),
    .ovr(ovr),
    .zero(zero),
    .msb(msb),
    .carry_out(carry_out)
);

initial begin
    clk <= 0;
end

always #5 begin
    clk <= ~clk;
end

initial begin
   // facem niste 6 + 7 ca sa testam 


   // 0 + LINIA DE DATE -> B
   #6
   a_port = 4'b0000;
   b_port = 4'b0001;
   data = 4'b0110;
   I = 9'b100000101;
   output_enable_not = 1'b0;
   carry_in = 0;
   

   
   #200000
   $finish;   

end

endmodule
          
          
          