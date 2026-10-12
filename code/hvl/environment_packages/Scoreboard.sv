// Supplied framework attribution: Alireza Abbasian.
// Verification project: Reza Sanaee Nezhad.
class Scoreboard;
    mailbox model2scb,mon_out_2_scb;
    ALU_out_coverage monitor_coverage;
    int failed_num=0,passed_num=0,aborted_num=0;
    function new(mailbox model2scb,mailbox mon_out_2_scb);
        this.model2scb=model2scb;this.mon_out_2_scb=mon_out_2_scb;
        monitor_coverage=new();
    endfunction
    task run();
        ALU_out_transaction expected,actual,reset_expected,reset_actual;
        forever begin
            model2scb.get(expected);mon_out_2_scb.get(actual);
            if(actual.result_rst && !expected.result_rst) begin
                // A reset cancels the pending operation, even before its first output beat.
                if(actual.result!=0) begin failed_num++;$display("Reset produced nonzero output");end
                else aborted_num++;
                actual.aborted=1;monitor_coverage.sample(actual);
                model2scb.get(reset_expected);
                reset_actual=actual.do_copy();reset_actual.aborted=0;
                check_actual(reset_expected,reset_actual);
                monitor_coverage.sample(reset_actual);
            end else begin
                check_actual(expected,actual);monitor_coverage.sample(actual);
            end
        end
    endtask
    function void check_actual(ALU_out_transaction expected,ALU_out_transaction actual);
        if(!actual.aborted && expected.do_compare(actual)) passed_num++;
        else begin failed_num++;$display("Mismatch at %0t",$time);expected.do_print();actual.do_print();end
    endfunction
    function void wrap_up();
        $display("SCOREBOARD: passed=%0d aborted=%0d failed=%0d expected_pending=%0d actual_pending=%0d",
                 passed_num,aborted_num,failed_num,model2scb.num(),mon_out_2_scb.num());
        if(failed_num) $fatal(1,"Scoreboard failure");
        $finish;
    endfunction
endclass
