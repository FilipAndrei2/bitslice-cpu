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
    input I[3:0],
    
    // HIGH => Ignora linia de input
    // LOW =>  Executa instructiunea de pe linia de input
    input input_enable_not,
    
    // Interrupt inputs
    // Un nivel LOW este un request
    input P[7:0],
    
    input group_advance_receive_not,
    
    input group_enable_not,
    
    // Bitii mastii
    inout M[7:0],
    
    // Pentru citirea externa a registrului de status
    inout S[3:0],
    
    output status_overflow_not,
    
    output Y[2:0],
    
    output group_signal_not,
    
    output ripple_disable_not,
    output parallel_disable,
    output interrupt_req_not
);

// posedge triggered
reg interrupt[7:0];

// poate sa fie incarcat pe magistrala M
// sau citit de pe magistrala M
// Intreg registrul, dar si biti individuali pot fi manipulati
reg mask[7:0];

// tine bitii de status
// Poate fi incarcat sau citit pe / de pe magistrala S 

// In timpul unei citiri de vector, se incrementeaza vectorul de intreruperi cu 1, si rezultatul est stocat in registrul de status.

// Astfel, registrul de status indica mereu catre nivelul cel mai mic la care o intrerupere va fi acceptata.
reg status[3:0];

always @(*) begin

end

always @(posedge clk) begin

end

endmodule
