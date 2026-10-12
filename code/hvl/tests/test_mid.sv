//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

`timescale 1ns/1ns

import class_pkg::*;
import parameters::*;


module test_mid (
    ALU_in_if   in_bus,
    ALU_out_if  out_bus
    );

    Environment env;
    ALU_in_transaction tr_random;
    ALU_in_transaction_range tr_range;

    localparam bit [OPERAND_MAX_DATA_WIDTH-1:0] MID_RANGE = {1'b1,{(OPERAND_MAX_DATA_WIDTH-1){1'b0}}};
    localparam bit [OPERAND_MAX_DATA_WIDTH-1:0] HIGH_RANGE = {OPERAND_MAX_DATA_WIDTH{1'b1}};

    initial begin
        env=new(.in_bus(in_bus),.out_bus(out_bus));env.build();
        tr_range=new();tr_range.a_min=MID_RANGE;tr_range.a_max=HIGH_RANGE;
        tr_range.b_min=MID_RANGE;tr_range.b_max=HIGH_RANGE;env.gen.blueprint=tr_range;
        env.run();#20000;env.wrap_up();
    end
endmodule
