//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------

package parameters;

    parameter OPERAND_BUS_WIDTH = 8;
    parameter OPERAND_MAX_DATA_WIDTH = 32;
    parameter RESULT_BUS_WIDTH = 16;
    parameter RESULT_MAX_DATA_WIDTH = 64;

    typedef enum bit[2:0] {no_op = 3'b000, add_op = 3'b001, and_op = 3'b010, xor_op = 3'b011, mul_op = 3'b100, rst_op = 3'b111} alu_in_op_t;
endpackage