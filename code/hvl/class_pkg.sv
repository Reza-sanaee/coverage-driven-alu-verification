//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

package class_pkg;

    import parameters::*;
              
    `include "interface_packages/alu_in_pkg/ALU_in_transaction.sv"
    `include "interface_packages/alu_in_pkg/ALU_in_transaction_range.sv"
    `include "interface_packages/alu_in_pkg/ALU_in_coverage.sv"
    `include "interface_packages/alu_in_pkg/ALU_in_driver.sv"
    `include "interface_packages/alu_in_pkg/ALU_in_monitor.sv"

    `include "interface_packages/alu_out_pkg/ALU_out_transaction.sv"
    `include "interface_packages/alu_out_pkg/ALU_out_coverage.sv"
    `include "interface_packages/alu_out_pkg/ALU_out_monitor.sv"

    `include "environment_packages/Scoreboard.sv"
    `include "environment_packages/Model.sv"
    `include "environment_packages/Generator.sv"
    `include "environment_packages/Environment.sv"
    
endpackage