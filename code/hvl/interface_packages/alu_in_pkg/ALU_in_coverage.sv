//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

class ALU_in_coverage;




    localparam int  N       = OPERAND_MAX_DATA_WIDTH; 

    localparam bit [N-1:0] MAX_VAL    = {N{1'b1}};           
    localparam bit [N-1:0] MID_RANGE  = MAX_VAL >> 1;     
    localparam bit [N-1:0] HIGH_RANGE = MAX_VAL;

    covergroup ALU_in_transaction_cg with function sample(ALU_in_transaction tr_in);
    
        option.auto_bin_max=64;
        

        op: coverpoint tr_in.op { 
            option.at_least = 10;
            bins noop   = { 3'b000 };
            bins addop  = { 3'b001 };
            bins andop  = { 3'b010 };
            bins xorop  = { 3'b011 };
            bins mulop  = { 3'b100 };
            bins rstop  = { 3'b111 };
            illegal_bins invalid_op = default;
        }

        a: coverpoint tr_in.a iff (tr_in.op inside {add_op,and_op,xor_op,mul_op}) { 
            option.at_least = 10;
            bins low    = {   [0:MID_RANGE] };
            bins mid    = { [MID_RANGE+1:HIGH_RANGE-2] };
            bins high   = { [HIGH_RANGE-1:HIGH_RANGE] };
        }

        b: coverpoint tr_in.b iff (tr_in.op inside {add_op,and_op,xor_op,mul_op}) { 
            option.at_least = 10;
            bins low    = {   [0:MID_RANGE] };
            bins mid    = { [MID_RANGE+1:HIGH_RANGE-2] };
            bins high   = { [HIGH_RANGE-1:HIGH_RANGE] };
        }

        clk_gap: coverpoint tr_in.clk_gap iff (tr_in.op != rst_op) { 
            option.at_least = 10;
            bins zero    = { 0 };
            bins Low    = { [1:8] };
            bins high   = { [9:14]};
        }

    endgroup




    function new();
    	ALU_in_transaction_cg = new();
    endfunction





    function void sample(ALU_in_transaction tr_in);

        
        ALU_in_transaction_cg.sample(tr_in);
    endfunction

endclass