//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------



class ALU_out_transaction;

//-------------------The random variables
    
//--------------------------------------
    time issue_time;
    bit [RESULT_MAX_DATA_WIDTH-1:0] result ;
    bit result_rst;
    bit aborted;

//---------------------------constraints

    

//--------------------------------------

//-----------------------------functions
    function new();

        this.issue_time = $time;
        this.aborted=0;
    endfunction 





    virtual function string convert2string();

    string string_out = "ALU_out_transaction:\n";

        string_out = {string_out, $sformatf("result:0x%x \n",result)};
        string_out = {string_out, $sformatf("result_rst= %b\n", result_rst)};
        

        return string_out;

    endfunction






    virtual function void do_print();

        $display(convert2string());

    endfunction




    virtual function bit do_compare (input ALU_out_transaction rhs);
   

        return (
                 (this.result == rhs.result) && (this.result_rst == rhs.result_rst)
                );

    endfunction
    

    

    virtual function ALU_out_transaction do_copy();
        ALU_out_transaction dst;

        dst = new();
        
        dst.result  = this.result;
        dst.result_rst  = this.result_rst;
        dst.aborted  = this.aborted;
        return dst;

    endfunction : do_copy

    
//--------------------------------------

endclass