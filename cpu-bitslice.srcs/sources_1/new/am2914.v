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
    inout [3:0] S,
    
    output status_overflow_not,
    
    output reg[2:0]V,
    output reg[2:0]Y,
    
    output group_signal_not,
    
    output ripple_disable_not,
    output parallel_disable,
    output reg interrupt_req_not
);

reg [3:0] s_out; 
assign S = s_out;

reg [7:0] m_out;
assign M = m_out;

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

reg irq_enabled;

wire request_pending;
assign request_pending = (highest_prio_req !== 3'bxxx) &&
                         (highest_prio_req >= status);

always @(*) begin

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

    if (!irq_enabled) begin
        interrupt_req_not = 1'b1;
    end else if (request_pending) begin
        interrupt_req_not = 1'b0;
    end else begin
        interrupt_req_not = 1'b1;
    end
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
                    0. MCLR - MASTER CLEAR 
                    Clear all interrupts, clear mask register, clear status register, enable irq
                */
                4'b0000 : begin
                    interrupt <= 0;
                    mask <= 0;
                    status <= 0;
                    
                    irq_enabled <= 1;
                end
                
                /*
                    1. CLRIN - CLEAR ALL INTERRUPTS
                    
                */
                4'b0001 : begin
                    interrupt <= 0;
                end
                
                /*
                    2. CLRMB - Clear interrupts from M-Bus
                */
                4'b0010 : begin
                    interrupt <= ~M & interrupt;
                end
                
                /*
                    3. CLRMR - Clear interrupts from mask register
                */
                4'b0011 : begin
                    interrupt <= ~mask & interrupt;
                end
                
                /*
                    4. CLRVC - Clear individual interrupt asociated with last vector read
                */
                4'b0100 : begin
                    interrupt[last_vector] = 1'b0;
                end
                
                /*
                    5. READVC - Read Vector
                */
                4'b0101 : begin
                    status <= highest_prio_req + 1;
                    last_vector <= highest_prio_req;
                end
                
                /*
                    6. RDSTA - Read Status Register to S-Bus
                */
                4'b0110 : begin
                    s_out <= status;
                end
                
                /*
                    7. RDM - Read Mask register to M-Bus
                */
                4'b0111 : begin
                    m_out <= mask;
                end
                
                /*
                    8. SETM - Set Mask register (inhibits all interrupts)
                    Seteaza toti bitii in registrul de masca pe 1
                */
                4'b1000 : begin
                    mask <= 8'b11111111;
                end
                
                /*
                    9. LDSTA - Load Status register from S Bus (and LGE flip-flop from GE input)
                */
                4'b1001 : begin
                    status <= S;
                end
                
                /*
                    10. BCLRM - Bit clear mask register from M-Bus
                    Curata bitii din registrul de masca care au biti corespunzatori de 1 pe magistrala M 
                    Bitii din registrul de masca care au biti corespunzatori de 0 pe magistrala M raman neafectati.
                */
                4'b1010 : begin
                    mask <= mask & (~M);
                end
                
                /*
                    11. BSETM - Bit set mask register from M bus
                    Seteaza biti in registrul de masca care au biti corespunzatori de 1 pe magistrala M. Ceilalti biti raman neafectati.
                */
                4'b1011 : begin
                    mask <= mask | M;
                end
                
                /*
                    12. CLRM - Clear mask register
                    Seteaza toti bitii din registrul de masca pe 0
                */
                4'b1100 : begin
                    mask <= 8'b00000000;
                end
                
                /*
                    13. DISIN - Disable interrupt request
                    
                */
                4'b1101 : begin
                    irq_enabled <= 1'b0;
                end
                
                /*
                    14. LDM - Load mask register from M-Bus
                */
                4'b1110 : begin
                    mask <= M;
                end
                
                /*
                    15. ENIN - Enable interrupt request
                */
                4'b1111 : begin
                    irq_enabled <= 1'b1;
                end
        endcase
  end  
end

endmodule
