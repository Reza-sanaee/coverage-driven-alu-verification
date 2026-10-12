//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

`timescale 1ns/1ns

import class_pkg::*;
import parameters::*;


module test_high (
    ALU_in_if   in_bus,
    ALU_out_if  out_bus
    );

    Environment env;
    ALU_in_transaction tr_random;
    ALU_in_transaction_range tr_range;

    localparam int  N       = OPERAND_MAX_DATA_WIDTH; 

    localparam bit [N-1:0] MAX_VAL    = {N{1'b1}};           
    localparam bit [N-1:0] MID_RANGE  = MAX_VAL >> 1;     
    localparam bit [N-1:0] HIGH_RANGE = MAX_VAL;

    initial begin
        $display("Simulation running ...");
        #10;
        env = new(.in_bus(in_bus), .out_bus(out_bus));
        tr_range = new();
        tr_range.a_min = HIGH_RANGE-1;
        tr_range.a_max = HIGH_RANGE;
        tr_range.b_min = HIGH_RANGE-1;
        tr_range.b_max = HIGH_RANGE;
        #10;
        env.build();
        env.gen.blueprint = tr_range;
        #10;
        env.run();
        #10;
        
    end
    

    initial begin
        
        
        

        #20000;


        env.wrap_up();
        
        

    end


    

    

endmodule

