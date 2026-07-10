`timescale 1ns / 1ps
module am2914(

    input clk,

    // LOW este un request
    input I[3:0],
    
    // HIGH => Ignora linia de input
    // LOW =>  Executa instructiunea de pe linia de input
    input input_enable_not,
    
    // Interrupt inputs
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


endmodule
