//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

`timescale 1ns/1ns

import class_pkg::*;
import parameters::*;


module test_mix (
    ALU_in_if   in_bus,
    ALU_out_if  out_bus
    );

    Environment env;
    ALU_in_transaction tr_random;
    ALU_in_transaction_range tr_range;

    localparam bit [OPERAND_MAX_DATA_WIDTH-1:0] MID_RANGE = {1'b1,{(OPERAND_MAX_DATA_WIDTH-1){1'b0}}};
    localparam bit [OPERAND_MAX_DATA_WIDTH-1:0] HIGH_RANGE = {OPERAND_MAX_DATA_WIDTH{1'b1}};
    localparam LOW_RANGE = 0;
    initial begin
        $display("Simulation running ...");
        #10;
        env = new(.in_bus(in_bus), .out_bus(out_bus));
        #10;
        env.build();
        #10;
        env.run();
        #10;
        
    end
    

    initial begin
        #50;
        
        tr_random = new();

        env.gen.blueprint = tr_random;
        #10000;

        // ==================

        tr_range = new();
        tr_range.a_min = MID_RANGE;
        tr_range.a_max = HIGH_RANGE;
        tr_range.b_min = MID_RANGE;
        tr_range.b_max = HIGH_RANGE;

        env.gen.blueprint = tr_range;

        #12000;

        // ====================
        
        tr_range = new();
        tr_range.a_min = HIGH_RANGE-1;
        tr_range.a_max = HIGH_RANGE;
        tr_range.b_min = HIGH_RANGE-1;
        tr_range.b_max = HIGH_RANGE;

        env.gen.blueprint = tr_range;
        #1000;

        // ====================
        tr_range = new();
        tr_range.a_min = LOW_RANGE;
        tr_range.a_max = MID_RANGE;
        tr_range.b_min = LOW_RANGE;
        tr_range.b_max = MID_RANGE;

        env.gen.blueprint = tr_range;
        #12000;


        env.wrap_up();
        
        

    end


    

    

endmodule

