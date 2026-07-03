`timescale 1ns / 1ps

// Secventiator
    module am2910(
    // Inputs
    
    // Declanseaza toate schimbarile interne pe rising edge
    input clk,
    
    // Direct input, folosit pentru branching
    input [11:0] direct ,
    
    /* Folosit pentru alegerea instructiunii
        INSTRUCTIUNI IMPLEMENTATE:
        
        2 - JUMP MAP 
            - Instructiune neconditionata care cauzeaza outputul map_not sa fie enabled, astfel incat urmatoarea 
                locatie de microinstructiune sa fie determinata din adresa oferita din mapping PROM. 
    
        3 - CONDITIONAL JUMP PIPELINE
        - Obtine adresa catre care sa sara din valoarea registrului de pipeline (BR0:BR11)
        
        4 - PUSH/CONDITIONAL LOAD COUNTER
        - Folosit pentru a seta bucle in microprogram.
        - 
    */
    input [3:0] instruction,
    
    // Folosit ca si criteriu de test. Trece testul daca CCN este LOW
    input condition_code_not,
    
    // Daca semnalul este HIGH, CCN este ignorat si secventiatorul opereaza de parca CCN este TRUE (LOW)
    input condition_code_enable,

    // Carry input pentru incrementer
    input carry_in, 

    // Daca este LOW, forteaza incarcarea registrelor indiferent de instructiune sau conditie
    input register_load_not,
    
    input output_enable_not,
    
    // Selecteaza input source nr 1 (de obicei registrul de pipeline).
    input pipeline_address_enable_not,
    
    // Selecteaza input source nr 2 (de obicei Mapping PROM sau PLA)
    input map_address_enable_not,
    
    // Selecteaza input source nr 3 (de exemplu, Interrupt starting address)
    input vector_address_enable_not,
    
    // Outputs
    
    // Adresa catre memoria de microprogram
    output reg [11:0] Y ,
    
    // Flag care indica daca stiva este plina. Capacitatea stivei este de 5 elemente.
    output reg full_not
    
  );
  
  wire test;
  assign test = !condition_code_not || condition_code_enable;
  
  reg   [15:0] instruction_register = 16'h0;
  
  // Tine adresa instructiunii curente
  reg   [11:0] uPC = 12'b0;
  
  reg [11:0] stack [4:0];
  
  // Initializare stiva
  initial begin
    stack[0] = 0;
    stack[1] = 0;
    stack[2] = 0;
    stack[3] = 0;
    stack[4] = 0;
  end
  
  reg sp = 0;
  
  always @(*) begin
    case (instruction) 
    
        /*
        0 - Jump Zero (JZ)
        - Sare la inceputul programului
        */
        4'b0000 : begin 
            uPC = 0;
            Y = 0;
        end
        
        /*
        1 - COND JSB PL
        - Daca testul trece, pune in stiva adresa urmatoarei instructiuni pentru return, dupa care sare la o adresa
        - Se bazeaza ca inputul CC_NOT sa fie LOW, pentru ca testul sa treaca
        */
        4'b0001 : begin 
            if (test) begin 
                // pushez in stiva uPC
                if (sp < 5) begin // daca am capacitate sa pushez in stiva
                    stack[sp] = uPC + 1;
                    sp = sp + 1;
                end else begin // stiva e plina
                    
                    // Intrebare: Ce se intampla daca stiva e plina??
                    // R: Se suprascrie varful stivei, dar sp nu se incrementeaza (Pagina 6-157, paragraful stanga jos)
                    stack[4] = uPC + 1;
                end
                uPC = direct;
            end else begin
                uPC = uPC + 1;
            end
            Y = uPC;
        end
        
        /*
            2 - JUMP MAP
            
        */
        4'b0011 : begin end
        4'b0100 : begin end
        4'b0101 : begin end
        4'b0110 : begin end
        4'b0111 : begin end
        4'b1000 : begin end
        4'b1001 : begin end
        4'b1010 : begin end
        4'b1011 : begin end
        4'b1100 : begin end
        4'b1101 : begin end
        4'b1110 : begin end
        4'b1111 : begin end
    endcase
  end
  
  // Calculez flagul full
  always @(sp) begin
    full_not = !(sp == 4);
  end
  
  always @(posedge clk) begin
    case (instruction) 
    
        /*
        0 - Jump Zero (JZ)
        - Sare la inceputul programului
        */
        4'b0000 : begin 
            uPC <= 0;
        end
        
        4'b0001 : begin 
        end
        4'b0010 : begin end
        4'b0011 : begin end
        4'b0100 : begin end
        4'b0101 : begin end
        4'b0110 : begin end
        4'b0111 : begin end
        4'b1000 : begin end
        4'b1001 : begin end
        4'b1010 : begin end
        4'b1011 : begin end
        4'b1100 : begin end
        4'b1101 : begin end
        4'b1110 : begin end
        4'b1111 : begin end
    endcase
  end
  
  
endmodule
