`timescale 1ns / 1ps

/*

        Acest VPIC primeste 8 interrupt input requests pe liniile P[7:0].
    Un registru masca este folosit pentru a izola intreruperi specifice.
    Requesturile de pe liniile P sunt AND-uite cu bitii din registrul de masca si output-ul este oferit unui priority encoder 8-bit,
    care produce un numar intreg pe 3 biti care reprezinta pozitia inputului cel mai mare care nu este masked.
        
        Un registru intern de status este folosit pentru a indica catre nivelul cel mai mic de prioritate la care o intrerupere va fi acceptata.
    Acest registru poate fi incarcat extern sau citit oricand de pe pinii S.
    
        Output-ul encoderului este comparat cu valoarea continuta in registrul de status, si o iesire cerere de intrerupere va fi produsa
    daca vectorul este mai mare sau egal cu statusul.
        
        De fiecare data cand un vector este citit din AM2914, registrul de status este actualizat automat pentru a indica catre un nivel
    mai mare decat vectorul citit.     

        Controller-ul ofera semnale (Group Advance Send si Group Advance Receive) pentru a muta statusul intre mai multe device-uri
    si pentru a inhiba prioritatile mai mici de la device-uri de ordin mai mare (Ripple Disable, Parallel Disable si Interrupt Disable).
    Un status overflow output indica citirea unei intreruperi la cea mai mare prioritate.
    
        AM2914 este controlat prin 4 campuri de instructiuni, I[3:0]. Comanda de pe magistrala de instructiuni este executata daca
    IE este LOW si este ignorata daca IE este HIGH, permitand celor 4 biti sa fie impartiti de mai multe device-uri.
    
*/

module am2914(

    input clk,

    // LOW este un request  
    input [3:0]I,
    
    // HIGH => Ignora linia de input
    // LOW =>  Executa instructiunea de pe linia de input
    input input_enable_not,
    
    // Interrupt inputs
    // Un nivel LOW este un request
    input [7:0]P,
    
    input group_advance_receive_not,
    
    input group_enable_not,
    
    // Bitii mastii
    inout [7:0]M,
    
    // Pentru citirea externa a registrului de status
    inout [3:0]S,
    
    output status_overflow_not,
    
    output reg[2:0]V,
    output reg[2:0]Y,
    
    output group_signal_not,
    
    output ripple_disable_not,
    output parallel_disable,
    output reg interrupt_req_not
);

// posedge triggered
reg [7:0]interrupt;

// poate sa fie incarcat pe magistrala M
// sau citit de pe magistrala M
// Intreg registrul, dar si biti individuali pot fi manipulati
reg [7:0]mask;

// tine bitii de status
// Poate fi incarcat sau citit pe / de pe magistrala S 

// In timpul unei citiri de vector, se incrementeaza vectorul de intreruperi cu 1, si rezultatul est stocat in registrul de status.

// Astfel, registrul de status indica mereu catre nivelul cel mai mic la care o intrerupere va fi acceptata.
reg [3:0]status;

reg [2:0] last_vector;

reg [2:0] highest_prio_req;

always @(mask or interrupt) begin

    if      (mask[7] && interrupt[7] )  highest_prio_req = 3'b111;
    else if (mask[6] && interrupt[6])   highest_prio_req = 3'b110;
    else if (mask[5] && interrupt[5])   highest_prio_req = 3'b101;
    else if (mask[4] && interrupt[4])   highest_prio_req = 3'b100;
    else if (mask[3] && interrupt[3])   highest_prio_req = 3'b011;
    else if (mask[2] && interrupt[2])   highest_prio_req = 3'b010;
    else if (mask[1] && interrupt[1])   highest_prio_req = 3'b001;
    else if (mask[0] && interrupt[0])   highest_prio_req = 3'b000;
    else                                highest_prio_req = 3'bxxx;
end

always @(*) begin
case (I[3:0]) 
            
            /*
                MCLR - MASTER CLEAR 
                Clear all interrupts, clear mask register, clear status register, enable irq
            */
            4'b0000 : begin
            end
            
            /*
                CLRIN - CLEAR ALL INTERRUPTS
                
            */
            4'b0001 : begin
            end
            
            /*
                CLRMB - Clear interrupts from M-Bus
            */
            4'b0010 : begin
            end
            
            /*
                CLRMR - Clear interrupts from mask register
            */
            4'b0011 : begin
            end
            
            /*
                CLRVC - Clear individual interrupts asociated with last vector read
            */
            4'b0100 : begin
            end
            
            /*
                READVC - Read Vector
            */
            4'b0101 : begin
                V = highest_prio_req;
            end
    endcase
end

always @(posedge clk) begin
    if (!input_enable_not) begin
            case (I[3:0]) 
            
                /*
                    MCLR - MASTER CLEAR 
                    Clear all interrupts, clear mask register, clear status register, enable irq
                */
                4'b0000 : begin
                    interrupt <= 0;
                    mask <= 0;
                    status <= 0;
                    
                    interrupt_req_not <= 1;
                end
                
                /*
                    CLRIN - CLEAR ALL INTERRUPTS
                    
                */
                4'b0001 : begin
                    interrupt <= 0;
                end
                
                /*
                    CLRMB - Clear interrupts from M-Bus
                */
                4'b0010 : begin
                    interrupt <= ~M & interrupt;
                end
                
                /*
                    CLRMR - Clear interrupts from mask register
                */
                4'b0011 : begin
                    interrupt <= ~mask & interrupt;
                end
                
                /*
                    CLRVC - Clear individual interrupts asociated with last vector read
                */
                4'b0100 : begin
                    interrupt[last_vector] = 1'b0;
                end
                
                /*
                    READVC - Read Vector
                */
                4'b0101 : begin
                    status <= highest_prio_req + 1;
                    last_vector <= highest_prio_req;
                end
                
                /*
                    LOADSR - Load Status Register from S-Bus
                */
                4'b0110 : begin
                    status <= S;
                end
        endcase
  end  
end

endmodule
