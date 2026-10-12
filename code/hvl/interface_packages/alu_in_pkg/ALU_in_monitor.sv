// Supplied RTL / framework attribution: Alireza Abbasian.
// Verification project: Reza Sanaee Nezhad.

class ALU_in_monitor;
    virtual ALU_in_if bus;
    mailbox mon2env;
    ALU_in_coverage monitor_coverage;
    function new(virtual ALU_in_if.monitor_mp bus,mailbox mon2env);
        this.bus=bus;this.mon2env=mon2env;monitor_coverage=new();
    endfunction
    task run();
        ALU_in_transaction tr;
        forever begin do_monitor(tr);monitor_coverage.sample(tr);mon2env.put(tr.do_copy());end
    endtask
    task do_monitor(output ALU_in_transaction tr);
        int idle_cycles=0,beat=0;
        forever begin
            @(posedge bus.clk);
            if(!bus.rst) idle_cycles=0;
            else if(bus.operand_valid && (bus.ready || bus.op==rst_op)) break;
            else if(bus.ready) idle_cycles++;
            else idle_cycles=0;
        end
        tr=new();tr.op=alu_in_op_t'(bus.op);
        if(tr.op==rst_op) return;
        if(idle_cycles>14) $fatal(1,"Observed idle gap exceeds the stimulus contract: %0d",idle_cycles);
        tr.clk_gap=idle_cycles;
        forever begin
            if(bus.operand_valid && bus.ready) begin
                if(beat>=OPERAND_MAX_DATA_WIDTH/OPERAND_BUS_WIDTH) $fatal(1,"Too many operand beats");
                tr.a[beat*OPERAND_BUS_WIDTH+:OPERAND_BUS_WIDTH]=bus.a;
                tr.b[beat*OPERAND_BUS_WIDTH+:OPERAND_BUS_WIDTH]=bus.b;
                beat++;
                if(bus.operand_last) break;
            end
            @(posedge bus.clk);
            if(!bus.rst || (bus.operand_valid && bus.op==rst_op)) $fatal(1,"Input frame interrupted before completion");
        end
    endtask
endclass
