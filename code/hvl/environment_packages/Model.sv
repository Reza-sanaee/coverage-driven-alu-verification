//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

  
class Model;

    

    mailbox mon_in_2_model;
    mailbox model2scb;


    function new(
        input mailbox mon_in_2_model,
    	input mailbox model2scb
        );

        this.mon_in_2_model = mon_in_2_model;
        this.model2scb = model2scb;

      
    endfunction : new

    



    function ALU_out_transaction calc(ALU_in_transaction tr_in);

        ALU_out_transaction tr_out;
        tr_out = new();
        
        case (tr_in.op)
            add_op: begin
                tr_out.result = tr_in.a + tr_in.b;
                tr_out.result_rst=0;
                return tr_out;
            end
            and_op: begin
                tr_out.result = tr_in.a & tr_in.b;
                tr_out.result_rst=0;
                return tr_out;
            end
            xor_op: begin
                tr_out.result = tr_in.a ^ tr_in.b;
                tr_out.result_rst=0;
                return tr_out;
            end
            mul_op: begin
                tr_out.result = tr_in.a * tr_in.b;
                tr_out.result_rst=0;
                return tr_out;
            end
            rst_op: begin
                tr_out.result ='0;
                tr_out.result_rst=1;
                return tr_out;
            end
        endcase 

        return null;
        
        

    endfunction






    task run();

        ALU_in_transaction tr_in;
        ALU_out_transaction tr_out;

        forever begin
            mon_in_2_model.get(tr_in);

            tr_out = calc(tr_in);
            
            if (tr_out != null) begin
                model2scb.put(tr_out);
            end
        end

    endtask

endclass