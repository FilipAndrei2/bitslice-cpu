`timescale 1ns / 1ps

// Lungimea unei instructiuni este de 12 biti
module am2910(
    
    // Toate schimbarile interne au loc pe posedge.
    input clk,
    
    // Input direct pentru registre
    input [11:0] direct,
    
    // Magistrala de microinstructiuni pentru secventiator
    input [3:0] instr, 
    
    // Folosit pentru salturi bazate pe conditii. O valoare de LOW face ca testul sa treaca.
    input condition_code_not,
    
    // Daca CCEN este HIGH, CCN este ignorat si testul nu trece.
    input condition_code_enable_not,
    
    input carry_in,
    
    // Daca este LOW, forteaza incarcarea registrului R  indiferent de instructiune sau conditie.
    input register_load_not,
    
    // Daca este LOW, magistrala de iesire Y va lua valoarea high impedance.
    input output_enable_not,
    
    // Adresa catre memoria de microprogram.
    output reg [11:0] y,

    // O valoare de LOW indica prezenta a 5 elemente pe stiva.
    output full_not,
    
    /*
        Can select #1 source (usually Pipeline Register) as direct
    input source 
    */
    output reg pipeline_address_enable_not,
    
    /*
        Can select #2 source (usually Mapping PROM or PLA) as
    direct input source 
    */
    output  reg map_address_enable_not,
    
    /*
        Can select #3 source (for example, Interrupt Starting Address)
    as direct input source
    */
    output reg vector_address_enable_not
);

// Stiva de microinstructiuni. Capacitate maxima 5.
reg [11:0] stack [4:0];
 
// Stack pointer. Stiva are capacitate maxima 5.
reg [2:0] sp; 
 
// Registrul de microprogram, care de obicei contine o adresa cu 1 mai mare decat adresa oferita anterior.
reg [11:0] uPC;

// Registrul asta contine date incarcate in microinstructiunea anterioara. 
reg [11:0] R;

// Testul folosit de salturile conditionate.
wire test;
assign test = !condition_code_enable_not && !condition_code_not; 

initial begin

    
    // Initializare registre
    uPC     = 12'b000000000000;
    R       = 12'b000000000000;
end
 
always@(posedge clk) begin
    pipeline_address_enable_not <= 1'b1;
    map_address_enable_not      <= 1'b1;
    vector_address_enable_not   <= 1'b1;
    case (instr)
        
        
        // 0: JZ - JUMP ZERO / RESET
        // Sare la inceputul M
        4'b0000 : begin
            // Initializare stiva
            stack[0] = 12'b000000000000;
            stack[1] = 12'b000000000000;
            stack[2] = 12'b000000000000;
            stack[3] = 12'b000000000000;
            stack[4] = 12'b000000000000;
            sp = 3'b000;    
        
            uPC <= 0;
            y <= 0;
            
            pipeline_address_enable_not <= 1'b0;
        end
        
        // 1: CJS : CONDITIONAL JUMP to SUBROUTINE
        4'b0001 : begin
            pipeline_address_enable_not <= 1'b0;
            if (test) begin // sare si pune in stiva adresa de return
                if (sp < 3'd5) begin
                    stack[sp] = uPC + 12'd1;
                    sp = sp + 3'd1;
                end else begin
                    // Stiva este plina -> Ultimul element este suprascris
                    stack[4] = instr;
                    // nu se incrementeaza sp
                end
                y <= direct; // Sare la adresa specificata
            end else begin // test failed
                // Continua secvential
                y <= uPC;
            end
            

        end
        
        // 2: JMAP - Jump Map
        // Sare neconditionat la map si pune in stiva adresa de return
        4'b0010 : begin
            map_address_enable_not <= 1'b0;
            y <= direct; // Sare la adresa specificata de PROM
        end
        
        // 3: CJP - Conditional Jump PL
        4'b0011 : begin
            pipeline_address_enable_not <= 1'b0;
            if (test) begin
                y <= uPC;
            end else begin
                y <= direct;
            end
        end
        
        // 4: PUSH
        4'b0100 : begin
            pipeline_address_enable_not <= 1'b0;
            
            // Se baga in stiva next addr
            if (sp < 3'd5) begin
                    stack[sp] = uPC + 12'd1;
                    sp = sp + 3'd1;
                end else begin
                    // Stiva este plina -> Ultimul element este suprascris
                    stack[4] = instr;
                    // nu se incrementeaza sp
             end
             
             // Trebuie incarcat conditionat R
             if (test) begin
                R <= direct;
             end
             
             y <= uPC;
        end
        
        // 5: JSRP - COND JSB R/PL
        4'b0101 : begin
            pipeline_address_enable_not <= 1'b0;
            // Se baga in stiva next addr
            if (sp < 3'd5) begin
                    stack[sp] = uPC + 12'd1;
                    sp = sp + 3'd1;
                end else begin
                    // Stiva este plina -> Ultimul element este suprascris
                    stack[4] = instr;
                    // nu se incrementeaza sp
            end
            
            if (test) begin
                y <= direct;
            end else begin
                y <= R;
            end
        end
        
        // 6 : CJV - COND JUMP VECTOR
        4'b0110 : begin
            vector_address_enable_not <= 1'b0;
            
            if (test) begin
                y <= direct;
            end else begin
                y <= uPC;
            end
        end
        
        // 7 : JRP - COND JUMP R/PL
        4'b0111 : begin
            pipeline_address_enable_not <= 1'b0;
            
            if (test) begin
                y <= direct;
            end else begin
                y <= R;
            end
        end
        
        // 8 : RFCT 
        // TODO: BAGA MARE DE AICI
        4'b1000 : begin
            if (R == 12'd0) begin
            
            end else begin
                
            end
        end
        
        4'b1001 : begin
        
        end
        
        4'b1010 : begin
        
        end
        
        4'b1011 : begin
        
        end
        
        4'b1100 : begin
        
        end
        
        4'b1101 : begin
        
        end
        
        4'b1110 : begin
        
        end
        
        4'b1111 : begin
        
        end
        
    endcase
    
    uPC <= y + carry_in;
end
  
endmodule
