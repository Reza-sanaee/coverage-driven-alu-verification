`timescale 1ns / 1ps

//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

import parameters::*;


interface ALU_out_if (
    input logic                 clk,
    input logic                 rst
);
    
    logic                       result_valid;
    logic                       result_last;
    logic                       result_rst;
    logic [RESULT_BUS_WIDTH-1:0]    result;


    modport dut_mp (
        input clk,
        input rst,  
        output result_valid,
        output result_last,
        output result_rst,
        output result
    );

    modport monitor_mp (
        input clk,
        input rst,
        input result_valid,
        input result_last,
        input result_rst,
        input result
    );

    
endinterface

