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
        
        0 - Jump Zero (JZ)
    
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
    output [11:0] Y ,
    
    // Flag care indica daca stiva este plina. Capacitatea stivei este de 5 elemente.
    output full_not
    
  );
  
  reg  [15:0] instruction_register = 16'h0;
  
  always @(*) begin
  
  end
  
  always @(posedge clk) begin
  
  end
  
  
endmodule
