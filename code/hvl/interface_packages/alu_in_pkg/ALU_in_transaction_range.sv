//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------



class ALU_in_transaction_range extends ALU_in_transaction;


//--------------------------------------
     bit [OPERAND_MAX_DATA_WIDTH-1:0] a_min;
     bit [OPERAND_MAX_DATA_WIDTH-1:0] a_max;
     bit [OPERAND_MAX_DATA_WIDTH-1:0] b_min;
     bit [OPERAND_MAX_DATA_WIDTH-1:0] b_max;

//---------------------------constraints

    constraint a_range { 
        a >=    a_min; 
        a <=     a_max;
    }

    constraint b_range { 
        b >=    b_min; 
        b <=     b_max;
    }

//--------------------------------------

//-----------------------------functions
    function new();

        super.new();
        

    endfunction 





    virtual function string convert2string();

        string string_out = super.convert2string();
        
        string_out = {
            string_out, 
            $sformatf(
                "ranged transaction: a in [%0d,%0d], b in [%0d,%0d]\n", 
                a_min, a_max, b_min, b_max
            )
        };
        
        return string_out;

    endfunction






    virtual function void do_print();

        $display(convert2string());

    endfunction




    virtual function bit do_compare (input ALU_in_transaction rhs);
        ALU_in_transaction_range rhs_range;


        // Ensure the cast is valid before proceeding
        if (!$cast(rhs_range, rhs)) begin
            return super.do_compare(rhs);
        end

        return super.do_compare(rhs_range) &&
               (this.a_min == rhs_range.a_min) &&
               (this.a_max == rhs_range.a_max) &&
               (this.b_min == rhs_range.b_min) &&
               (this.b_max == rhs_range.b_max);
    endfunction
    

    

    virtual function ALU_in_transaction do_copy();
        ALU_in_transaction_range dst;

        dst = new();
        
        dst.op     = this.op;
        dst.a      = this.a;
        dst.b      = this.b;
        dst.clk_gap = this.clk_gap;

        dst.a_min  = this.a_min;
        dst.a_max  = this.a_max;
        dst.b_min  = this.b_min;
        dst.b_max  = this.b_max;

        return dst;
    endfunction : do_copy

    
//--------------------------------------

endclass