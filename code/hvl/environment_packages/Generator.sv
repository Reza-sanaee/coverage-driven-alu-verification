//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

class Generator;


    ALU_in_transaction blueprint;	// Blueprint for generator
    ALU_in_transaction generated_tr;	
    mailbox  gen2drv;	        // Mailbox to driver for cells
    event    drv2gen;	        // Event from driver when done with cell 

//----------------------------------------new(): Construct a generator object
    function new(
	    input event drv2gen,
	    input mailbox gen2drv
        );

        this.gen2drv = gen2drv;
        this.drv2gen = drv2gen;
        blueprint = new();


    endfunction : new
//---------------------------------------------------------------------------

//--------------------------------------------------run(): Run the generator. 
    task run();

        

        
        forever begin

            generated_tr = blueprint.do_copy();

            assert(generated_tr.randomize());
            
            gen2drv.put(generated_tr);

            // for debug =========================
            // $display("generated input @%0t: ",generated_tr.issue_time);
            // generated_tr.do_print();
            // $display("\n\n*********************\n\n");
            // =================================

            @drv2gen;		// Wait for driver to drive transaction
            
            
        end
    endtask : run

//---------------------------------------------------------------------------

endclass : Generator

