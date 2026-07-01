`timescale 1ns / 1ps

module am2901(
        input  [8:0] I,
        input  [3:0] data,
        input  carry_in,
        
        /*
            CLOCK-UL
            Registrul Q si iesirile de pe ram se schimba pe rising edge
        */
        input  clk, 

        // Indica catre ramul intern
        input  [3:0] a_port,
        input  [3:0] b_port,
        
        input  output_enable_not, // functioneaza pe logica negata
        
        input  ram0_in,
        input  ram3_in,
        input  q0_in,
        input  q3_in,
        
        input  in0,
        
        output reg [3:0] do,
        
        output reg p_not,
        output reg g_not,
        output reg ovr,
        output  zero,
        output  msb,
        output reg carry_out
    );
  
wire [2:0] source_op_control;
wire [2:0] function_control;
wire [2:0] destination_control;
  
reg [3:0] Q = 4'b0000;
reg [3:0] R = 4'b0000;
reg [3:0] S = 4'b0000;

reg [3:0] res = 4'b0000;

// RAM -> 16 cuvinte de 4 biti
reg [63:0] ram = 0;

reg [3:0] P;
reg [3:0] G;
wire C3, C4;
reg [3:0] do_internal = 4'b0000;

assign source_op_control = I[   2:0];
assign function_control = I[5:3];
assign destination_control = I[8:6];

assign C4 = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & carry_in);
assign C3 = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & carry_in);

assign zero = ~res[3] & ~res[2] & ~res[1] & ~res[0];
assign msb = res[3];


always@(posedge clk) begin    
    
    // ALU destination control
    case(destination_control)
        // QREG
        3'b000 : begin
            Q <= res;
        end
        
        // NOP
        3'b001 : begin
        end
        
        // RAMA
        3'b010 : begin
            ram[b_port] <= res;
        end
        
        // RAMF
        3'b011 : begin
            ram[b_port] <= res;
        end
        
        // RAMQD
        3'b100 : begin
            ram[b_port] <= { ram3_in, res[3:1] };
            
            Q <= { q3_in, Q[3:1] };
        end
        
        // RAMD
        3'b101 : begin
            ram[b_port] <= { ram3_in, res[3:1] };
        end
        
        // RAMQU
        3'b110 : begin
            ram[b_port] <= { res[2:0], ram0_in };
            Q <= { Q[2:0], q0_in };
        end
        
        // RAMU
        3'b111 : begin
            ram[b_port] <= { res[2:0], ram0_in };
        end
        
        default : begin end
    endcase
end

always @(*) begin

    // ALU source op control -> pagina 2-6 in datasheet
    case (source_op_control)
        3'b000 : begin
            R = ram[a_port];
            S = Q;
        end
        
        3'b001 : begin
            R = ram[a_port];
            R = ram[b_port];
        end
        
        3'b010 : begin
            R = 4'b0000;
            S = Q;
        end
        
        3'b011 : begin
            R = 4'b0000;
            S = ram[b_port];
        end
        
        3'b100 : begin
            R = 4'b0000;
            S = ram[a_port];
        end
        
        3'b101 : begin
            R = data;
            S = ram[a_port];
        end
        
        3'b110 : begin
            R = data;
            S = Q;
        end
        
        3'b111 : begin
            R = data;
            S = 4'b0000;
        end 
    endcase
    
     
    // ALU function control
    case (function_control)
    
        // R + S     
        3'b000 : begin
            res = R + S + carry_in;
            
            // Definitions
            P = R | S;
            G = R & S;
            
            p_not = ~(P[3] & P[2] & P[1] & P[0]);
            g_not = ~(G[3] | (P[3] & G[2]) | P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
            carry_out = C4;
            ovr = C3 ^ C4;
        end
        
        // S - R
        3'b001 : begin
            res = S - R - (~carry_in);
            
            // Definitions
            P = (~R) | S;
            G = (~R) & S;
            
            p_not = ~(P[3] & P[2] & P[1] & P[0]);
            g_not = ~(G[3] | (P[3] & G[2]) | P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
            carry_out = C4;
            ovr = C3 ^ C4;
        end
        
        // R - S
        3'b010 : begin
            res = R - S - (~carry_in);
        
            // Definitions
            P = R | (~S);
            G = R & (~S);
            
            p_not = ~(P[3] & P[2] & P[1] & P[0]);
            g_not = ~(G[3] | (P[3] & G[2]) | P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
            carry_out = C4;
            ovr = C3 ^ C4;
        end
        
        // R or S
        3'b011 : begin
            res = R | S;
            
            // Definitions
            P = R | S;
            G = R & S;
            
            p_not = 1'b0;
            g_not = P[3] & P[2] & P[1] & P[0];
            carry_out = ~(P[3] & P[2] & P[1] & P[0]) | carry_in;
            ovr = ~(P[3] & P[2] & P[1] & P[0]) | carry_in;
        end
        
        // R and S
        3'b100 : begin
            res = R & S;
            
            // Definitions
            P = R | S;
            G = R & S;
            
            p_not = 1'b0;
            g_not = ~(G[3] | G[2] | G[1] | G[0]);
            carry_out = G[3] | G[2] | G[1] | G[0] | carry_in;
            ovr = G[3] | G[2] | G[1] | G[0] | carry_in;
        end
        
        // not(R) and S
        3'b101 : begin
            res = (~R) & S;
        
            // Definitions
            P = (~R) | S;
            G = (~R) & S;
            
            p_not = 1'b0;
            g_not = ~(G[3] | G[2] | G[1] | G[0]);
            carry_out = G[3] | G[2] | G[1] | G[0] | carry_in;
            ovr = G[3] | G[2] | G[1] | G[0] | carry_in;
        end
        
        // R xor S
        3'b110 : begin
            res = R ^ S;
            
             // Definitions
            P = (~R) | S;
            G = (~R) & S;
            
            p_not = G[3] | G[2] | G[1] | G[0];
            g_not = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & P[0]);
            carry_out = ~(G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1])) | ~((P[3] & P[2] & P[1] & P[0]) & (G[0] | (~carry_in)));
            ovr = (~P[2] | ((~G[2]) & (~P[1])) | (~G[2] & ~G[1] & ~P[0]) | (~G[2] & ~G[1] & ~G[0] & carry_in)) ^ (~P[3] | (~G[3] & ~P[2]) | (~G[3] & ~G[2] & ~P[1]) | (~G[3] & ~G[2] & ~G[1] & ~P[0]) | (~G[3] & ~G[2] & ~G[1] & ~G[0] & carry_in));
        end
        
        // not(R xor S)
        3'b111 : begin
            res = ~(R ^ S);
            
            // Definitions
            P = R | S;
            G = R & S;
            
            p_not = G[3] | G[2] | G[1] | G[0];
            g_not = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & P[0]);
            carry_out = ~(G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1])) | ~((P[3] & P[2] & P[1] & P[0]) & (G[0] | (~carry_in)));
            ovr = (~P[2] | ((~G[2]) & (~P[1])) | (~G[2] & ~G[1] & ~P[0]) | (~G[2] & ~G[1] & ~G[0] & carry_in)) ^ (~P[3] | (~G[3] & ~P[2]) | (~G[3] & ~G[2] & ~P[1]) | (~G[3] & ~G[2] & ~G[1] & ~P[0]) | (~G[3] & ~G[2] & ~G[1] & ~G[0] & carry_in));
        end
    endcase 
    
    // ALU destination control
    case(destination_control)
    // QREG
        3'b000 : do_internal = res;
        
        // NOP
        3'b001 : do_internal = res;
        
        // RAMA
        3'b010 : do_internal = ram[a_port];
        
        // RAMF
        3'b011 : do_internal =  res;
        
        // RAMQD
        3'b100 : do_internal = res;
        
        // RAMD
        3'b101 : do_internal <= res;
        
        // RAMQU
        3'b110 : do_internal <= res;
        
        // RAMU
        3'b111 : do_internal <= res;
        
        default : ;
    endcase

    if (output_enable_not) begin
        do = 4'b0000;
    end else begin
        do = do_internal;
    end
end


endmodule
