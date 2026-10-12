//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

`timescale 1ns/1ns


import class_pkg::*;
import parameters::*;

module top;

    logic clk;

    logic rst;// active low

    initial begin
        rst = 0; 
        #200ns;
        rst =  1; 
    end

// ========================= System Clock
    initial begin
        $timeformat(-9, 2, " ns", 20);
        clk = 1;
        forever begin
            #5ns clk = ~clk;
        end
    end
// ======================================

    

    ALU_in_if in_bus (
        .clk(clk), 
        .rst(rst)
    );

    ALU_out_if out_bus(
        .clk(clk), 
        .rst(rst)
    );



    alu_multi_cycle #(
        .OPERAND_BUS_WIDTH(OPERAND_BUS_WIDTH), 
        .OPERAND_MAX_DATA_WIDTH(OPERAND_MAX_DATA_WIDTH), 
        .RESULT_BUS_WIDTH(RESULT_BUS_WIDTH), 
        .RESULT_MAX_DATA_WIDTH(RESULT_MAX_DATA_WIDTH)
    ) dut (
        .clk    (in_bus.clk),
        .rst    (rst),
        .ready  (in_bus.ready),
        .operand_last (in_bus.operand_last),
        .operand_valid  (in_bus.operand_valid),
        .op     (in_bus.op),
        .a      (in_bus.a),
        .b      (in_bus.b),
        .result_valid   (out_bus.result_valid),
        .result_last   (out_bus.result_last),
        .result_rst   (out_bus.result_rst),
        .result (out_bus.result)
    );
    
    `ifdef TEST_MID
        test_mid test_inst(.in_bus(in_bus),.out_bus(out_bus));
    `elsif TEST_MIX
        test_mix test_inst(.in_bus(in_bus),.out_bus(out_bus));
    `elsif TEST_RANDOM
        random_test test_inst(.in_bus(in_bus),.out_bus(out_bus));
    `else
        test_high test_inst(.in_bus(in_bus),.out_bus(out_bus));
    `endif
endmodule : top
