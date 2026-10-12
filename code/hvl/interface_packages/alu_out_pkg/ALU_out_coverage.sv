//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

class ALU_out_coverage;

    localparam int  N       = RESULT_MAX_DATA_WIDTH; 

    localparam bit [N-1:0] MAX_VAL    = {N{1'b1}};           
    localparam bit [N-1:0] MID_RANGE  = MAX_VAL >> 1;       
    localparam bit [N-1:0] HIGH_RANGE = MAX_VAL;

    covergroup ALU_out_transaction_cg with function sample(ALU_out_transaction tr_out);
    
        option.auto_bin_max=64;
        


        result: coverpoint tr_out.result iff (!tr_out.result_rst && !tr_out.aborted) { 
            option.at_least = 10;
            bins low    = {   [0:MID_RANGE] };
            bins high    = { [MID_RANGE+1:HIGH_RANGE] };
        }

        result_rst: coverpoint tr_out.result_rst { 
            option.at_least = 10;
            bins low    = { 0 };
            bins high    = { 1 };
        }

        reset_during_calculation: coverpoint tr_out.aborted { 
            option.at_least = 10;
            bins NO_mid_cal_reset    = { 0 };
            bins mid_cal_reset    = { 1 };
        }
        

    endgroup




    function new();
    	ALU_out_transaction_cg = new();
    endfunction





    function void sample(ALU_out_transaction tr_out);

        
        ALU_out_transaction_cg.sample(tr_out);
    endfunction

endclass