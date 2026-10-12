//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------



class ALU_in_transaction;

//-------------------The random variables
    rand alu_in_op_t                     op;
    rand bit            [OPERAND_MAX_DATA_WIDTH-1:0]   a;
    rand bit            [OPERAND_MAX_DATA_WIDTH-1:0]   b;
    rand bit            [3:0]   clk_gap;
//--------------------------------------
    time issue_time;

//---------------------------constraints

    constraint valid_op_c { 
        op inside {no_op, add_op, and_op, xor_op, mul_op, rst_op}; 
    }

    constraint valid_clk_gap { 
        clk_gap<4'd15;
        clk_gap>=4'd0;
    }

//--------------------------------------

//-----------------------------functions
    function new();

        this.issue_time = $time;

    endfunction 





    virtual function string convert2string();

        string string_out = "ALU_in_transaction:\n";

        string_out = {string_out, $sformatf(" operation = %s\n", op.name())};
        string_out = {string_out, $sformatf(" a = %x\n", a)};
        string_out = {string_out, $sformatf(" b = %x\n", b)};
        string_out = {string_out, $sformatf(" clk_gap = %d\n", clk_gap)};
        

        return string_out;

    endfunction






    virtual function void do_print();

        $display(convert2string());

    endfunction




    virtual function bit do_compare (input ALU_in_transaction rhs);
   

        return (
                (this.op ==   rhs.op)
                &&(this.a ==    rhs.a)
                &&(this.b ==    rhs.b)
                );

    endfunction
    

    

    virtual function ALU_in_transaction do_copy();
        ALU_in_transaction dst;

        dst = new();
        
        dst.op  = this.op;
        dst.a   = this.a;
        dst.b   = this.b;
        dst.clk_gap=this.clk_gap;

        return dst;

    endfunction : do_copy

    
//--------------------------------------

endclass