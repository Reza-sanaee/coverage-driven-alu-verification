//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------


/////////////////////////////////////////////////////////
class Environment;

    virtual ALU_out_if    out_bus;
    virtual ALU_in_if     in_bus;

    ALU_in_monitor          mon_in;
    ALU_out_monitor         mon_out;
    ALU_in_driver           driver;
    Generator               gen;
    Scoreboard              scb;
    Model                   model;



    mailbox                 mon_out_2_scb;
    mailbox                 mon_in_2_model;
    mailbox                 model2scb;
    mailbox                 gen2drv;
    event                   drv2gen;
    



//----------------------------------new() : Construct an environment instance
    function new (
        input virtual ALU_in_if in_bus,
        input virtual ALU_out_if out_bus
        );
        this.in_bus   = in_bus;
        this.out_bus = out_bus;


        
      
    endfunction : new
//---------------------------------------------------------------------------


//----------------------build() : Build the environment objects for this test
    function void build();

        mon_out_2_scb    = new();        
        mon_in_2_model   = new();        
        model2scb        = new();    
        gen2drv          = new();

        driver = new(  
            .gen2drv(gen2drv),
            .drv2gen(drv2gen),
            .in_bus(in_bus),
            .out_bus(out_bus)
        );

        mon_in = new(
            .bus(in_bus),
            .mon2env(mon_in_2_model)
        );

        mon_out = new(
            .bus(out_bus),
            .mon2env(mon_out_2_scb)
        );

        gen = new(
            .drv2gen(drv2gen), 
            .gen2drv(gen2drv)
        );

        model = new(
            .mon_in_2_model(mon_in_2_model), 
            .model2scb(model2scb)
        );

        scb = new(
            .model2scb(model2scb),
            .mon_out_2_scb(mon_out_2_scb)
        );

        
    endfunction : build
//---------------------------------------------------------------------------


//-------------run() : Starting generator, driver, monitor in the environment
    task run();

        fork
            gen.run();
            driver.run();
            model.run();
            mon_in.run();
            mon_out.run();
            scb.run();
        join_none

        
    endtask : run
//---------------------------------------------------------------------------

   
//-------------------------------wrap_up() : Any post-run cleanup / reporting
    function void wrap_up();
    $display("\n\n=============================");
        $display("\n\n\n@%0t: End of simulation\n", $time);
        scb.wrap_up();
      
    endfunction : wrap_up
//---------------------------------------------------------------------------

endclass : Environment










