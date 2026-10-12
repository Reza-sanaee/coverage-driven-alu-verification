// Supplied RTL / framework attribution: Alireza Abbasian.
// Verification project: Reza Sanaee Nezhad.

class ALU_out_monitor;
    virtual ALU_out_if bus;
    mailbox mon2env;
    ALU_out_coverage monitor_coverage;
    function new(virtual ALU_out_if.monitor_mp bus,mailbox mon2env);
        this.bus=bus;this.mon2env=mon2env;monitor_coverage=new();
    endfunction
    task run();
        ALU_out_transaction tr;
        forever begin do_monitor(tr);mon2env.put(tr.do_copy());end
    endtask
    task do_monitor(output ALU_out_transaction tr);
        int beat=0;
        @(negedge bus.clk);
        while(!bus.rst || (!bus.result_valid && !bus.result_rst)) @(negedge bus.clk);
        tr=new();tr.result=0;
        if(bus.result_rst) begin
            tr.result=bus.result;tr.result_rst=1;
        end else begin
            forever begin
                if(bus.result_rst) begin
                    tr.result=0;tr.result_rst=1;tr.aborted=1;break;
                end
                if(!bus.result_valid) $fatal(1,"Result frame ended without result_last or reset");
                if(beat>=RESULT_MAX_DATA_WIDTH/RESULT_BUS_WIDTH) $fatal(1,"Too many result beats");
                tr.result[beat*RESULT_BUS_WIDTH+:RESULT_BUS_WIDTH]=bus.result;beat++;
                if(bus.result_last) break;
                @(negedge bus.clk);
            end
        end
        // Each active software-reset cycle corresponds to one accepted reset command.
        // The next call starts at the next falling edge, including back-to-back resets.
    endtask
endclass
