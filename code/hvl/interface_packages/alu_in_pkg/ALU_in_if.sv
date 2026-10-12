`timescale 1ns / 1ps

//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------


import parameters::*;

interface ALU_in_if (
    input logic                 clk,
    input logic                 rst // active low
);

    logic                   ready;
    logic                   operand_valid;
    logic                   operand_last;
    logic [2:0]             op;
    logic [OPERAND_BUS_WIDTH-1:0]    a;
    logic [OPERAND_BUS_WIDTH-1:0]    b;


    modport dut_mp (
        input clk,
        input rst,  
        output ready,
        input operand_valid,
        input operand_last,
        input op,
        input a,
        input b
    );

    modport driver_mp (
        input clk,
        input rst,
        input ready,
        output operand_valid,
        output operand_last,
        output op,
        output a,
        output b
    );

    modport monitor_mp (
        input clk,
        input rst,
        input ready,
        input operand_valid,
        input operand_last,
        input op,
        input a,
        input b
    );

    
endinterface

