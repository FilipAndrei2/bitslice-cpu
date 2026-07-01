`timescale 1ns / 1ps

module am2901_tb;

reg [8:0] I;
reg [3:0] data;
reg carry_in;

/*


    CLOCK-UL
    Registrul Q si iesirile de pe ram se schimba pe rising edge
*/
/*reg clk;

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
    output_enable_not <= 0;
end

always #5 begin
    clk <= ~clk;
end

initial begin
   // facem niste 6 + 7 ca sa testam 


   // 0 + LINIA DE DATE -> B
   #6
   b_port <= 4'b0001;
   data <= 4'b0110;
   I <= 9'b100000101;
   
   #200000
   $finish;   

end

endmodule */
`timescale 1ns / 1ps

module am2901_tb_nou();

    // 1. Declararea variabilelor
    reg [8:0] I;
    reg [3:0] data;
    reg carry_in;
    reg clk;
    
    reg [3:0] a_port;
    reg [3:0] b_port;
    
    reg output_enable_not;
    reg ram0_in, ram3_in, q0_in, q3_in;
    reg in0; // Neofolosit în logica ta, dar îl punem ca s? nu dea eroare de pin l?sat în aer

    wire [3:0] do_out; // Ie?irea Y
    wire p_not, g_not, ovr, zero, msb, carry_out;

    // 2. Instan?ierea modulului t?u
    am2901 uut (
        .I(I), .data(data), .carry_in(carry_in), .clk(clk),
        .a_port(a_port), .b_port(b_port),
        .output_enable_not(output_enable_not),
        .ram0_in(ram0_in), .ram3_in(ram3_in), .q0_in(q0_in), .q3_in(q3_in),
        .in0(in0),
        .do(do_out), .p_not(p_not), .g_not(g_not), .ovr(ovr),
        .zero(zero), .msb(msb), .carry_out(carry_out)
    );

    // 3. Generarea ceasului
    always #5 clk = ~clk;

    // 4. Scenariul de testare
    initial begin
        // Ini?ializare semnale
        clk = 0;
        output_enable_not = 0; // 0 logic ca s? lase datele s? ias? pe 'do'
        I = 0; data = 0; carry_in = 0;
        a_port = 0; b_port = 0;
        ram0_in = 0; ram3_in = 0; q0_in = 0; q3_in = 0; in0 = 0;

        #15; // A?tept?m s? se stabilizeze semnalele

        // --- TESTUL 1: Scriem 5 în RAM[0] ---
        I = 9'b011_011_111; // RAMF, OR, DZ
        data = 4'b0101;
        b_port = 4'h0;
        #40; // A?tept?m 4 cicluri de ceas ca s? apuce codul t?u s? propage semnalul

        // --- TESTUL 2: Scriem 3 în RAM[1] ---
        I = 9'b011_011_111; 
        data = 4'b0011;
        b_port = 4'h1;
        #40;

        // --- TESTUL 3: Adun?m RAM[0] cu RAM[1] ---
        I = 9'b001_000_001; // NOP, ADD, AB
        a_port = 4'h0;
        b_port = 4'h1;
        carry_in = 0;
        #40;

        $finish;
    end
endmodule
          
          
          
          
          
          