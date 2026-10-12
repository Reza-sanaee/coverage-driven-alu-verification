//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

`timescale 1ns/1ns

import class_pkg::*;
import parameters::*;


module random_test (
    ALU_in_if   in_bus,
    ALU_out_if  out_bus
    );

    Environment env;
    ALU_in_transaction tr_blueprint;

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
        
        
        tr_blueprint = new();

        env.gen.blueprint = tr_blueprint;
        #100000;


        env.wrap_up();
        
        

    end


    

    

endmodule

