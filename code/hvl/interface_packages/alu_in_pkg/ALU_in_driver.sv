// Supplied RTL / framework attribution: Alireza Abbasian.
// Verification project: Reza Sanaee Nezhad.

class ALU_in_driver;
    mailbox gen2drv;
    event drv2gen;
    virtual ALU_in_if in_bus;
    virtual ALU_out_if out_bus;
    function new(mailbox gen2drv,event drv2gen,virtual ALU_in_if.driver_mp in_bus,
                 virtual ALU_out_if.monitor_mp out_bus);
        this.gen2drv=gen2drv;this.drv2gen=drv2gen;this.in_bus=in_bus;this.out_bus=out_bus;
    endfunction
    task run();
        ALU_in_transaction tr;
        in_bus.operand_valid=0;in_bus.operand_last=0;in_bus.op=no_op;in_bus.a=0;in_bus.b=0;
        forever begin gen2drv.get(tr);send(tr);->drv2gen;end
    endtask
    task send(ALU_in_transaction tr);
        localparam int NUM_BEATS=OPERAND_MAX_DATA_WIDTH/OPERAND_BUS_WIDTH;
        // Drive on falling edges; the DUT accepts stable data on rising edges.
        if(in_bus.clk !== 1'b0) @(negedge in_bus.clk);
        while(!in_bus.rst || (!in_bus.ready && tr.op!=rst_op)) @(negedge in_bus.clk);
        if(tr.op==rst_op) begin
            in_bus.op=rst_op;in_bus.operand_valid=1;in_bus.operand_last=1;in_bus.a=0;in_bus.b=0;
            @(posedge in_bus.clk);@(negedge in_bus.clk);
        end else begin
            repeat(tr.clk_gap) @(negedge in_bus.clk);
            for(int i=0;i<NUM_BEATS;i++) begin
                in_bus.operand_valid=1;in_bus.operand_last=(i==NUM_BEATS-1);in_bus.op=tr.op;
                in_bus.a=tr.a[i*OPERAND_BUS_WIDTH+:OPERAND_BUS_WIDTH];
                in_bus.b=tr.b[i*OPERAND_BUS_WIDTH+:OPERAND_BUS_WIDTH];
                @(posedge in_bus.clk);@(negedge in_bus.clk);
            end
        end
        in_bus.operand_valid=0;in_bus.operand_last=0;in_bus.op=no_op;
    endtask
endclass
