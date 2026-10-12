//--------------------------------------
// Last Update  : 1403/3
// Author       : Alireza Abbasian
//--------------------------------------


module alu_multi_cycle #(
    parameter OPERAND_BUS_WIDTH = 8,
    parameter OPERAND_MAX_DATA_WIDTH = 32,
    parameter RESULT_BUS_WIDTH = 16,
    parameter RESULT_MAX_DATA_WIDTH = 64
) (
    input   wire                            clk,
    input   wire                            rst, // active low
    input   wire                            operand_valid,
    input   wire [2:0]                      op,
    input   wire [OPERAND_BUS_WIDTH-1:0]    a,
    input   wire [OPERAND_BUS_WIDTH-1:0]    b,
    input   wire                            operand_last,
    output  reg                             ready,
    output  reg                             result_valid,
    output  reg [RESULT_BUS_WIDTH-1:0]      result,
    output  reg                             result_last,
    output  reg                             result_rst
);

    // no_op  = 3'b000,
    // add_op = 3'b001, 
    // and_op = 3'b010,
    // xor_op = 3'b011,
    // mul_op = 3'b100,
    // rst_op = 3'b111

    typedef enum logic [1:0] {
        IDLE,
        RECEIVE,
        EXECUTE,
        SEND
    } state_t;

    state_t state, next_state;

    reg [OPERAND_MAX_DATA_WIDTH-1:0] operand_a, operand_b;
    reg [RESULT_MAX_DATA_WIDTH-1:0] result_full;

    reg [$clog2(OPERAND_MAX_DATA_WIDTH/OPERAND_BUS_WIDTH):0] operand_shift_cnt;
    reg [$clog2(RESULT_MAX_DATA_WIDTH/RESULT_BUS_WIDTH):0] result_shift_cnt;

    reg [2:0] op_reg;
    reg [RESULT_MAX_DATA_WIDTH-1:0] calculated_result;
    initial begin
        if (OPERAND_BUS_WIDTH<=0 || RESULT_BUS_WIDTH<=0 ||
            OPERAND_MAX_DATA_WIDTH%OPERAND_BUS_WIDTH || RESULT_MAX_DATA_WIDTH%RESULT_BUS_WIDTH ||
            RESULT_MAX_DATA_WIDTH<2*OPERAND_MAX_DATA_WIDTH)
            $fatal(1,"Unsupported ALU width parameters");
    end
    always @(*) begin
        case(op_reg)
            3'b001: calculated_result = operand_a + operand_b;
            3'b010: calculated_result = operand_a & operand_b;
            3'b011: calculated_result = operand_a ^ operand_b;
            3'b100: calculated_result = operand_a * operand_b;
            default: calculated_result = 0;
        endcase
    end

    always @( * ) begin
        result = result_full[result_shift_cnt*RESULT_BUS_WIDTH +: RESULT_BUS_WIDTH];

        ready = state == IDLE || state == RECEIVE;
    end


    // Main logic
    always @(posedge clk) begin


        if (op == 3'b111 && operand_valid || (!rst)) begin

            state <= IDLE;
            result_rst          <= 1'b1;
            
            result_valid        <= 1'b0;

            result_last         <= 1'b0;
            operand_a           <= '0;
            operand_b           <= '0;
            result_full         <= '0;
            operand_shift_cnt   <= 0;
            result_shift_cnt    <= 0;
            op_reg              <= 3'b000;

        end else begin

            result_rst <= 1'b0;

            case (state)

                IDLE: begin

                    operand_shift_cnt <= 0;
                    operand_a <= '0;
                    operand_b <= '0;
                    result_valid <= 0;
                    result_last <= 0;
                    result_shift_cnt <= 0;
                    result_full         <= '0;
                    
                    if (operand_valid) begin
                        operand_a[OPERAND_BUS_WIDTH-1:0] <= a;
                        operand_b[OPERAND_BUS_WIDTH-1:0] <= b;
                        op_reg <= op;
          
                        operand_shift_cnt <= 1;
                        
                        if (op == 0) begin
                            state <= IDLE;
                        end else if (operand_last) begin
                            state <= EXECUTE;
                        end else begin 
                            state <= RECEIVE;
                        end

                    end


                end
                RECEIVE: begin

                    if (operand_valid) begin
                        if(operand_shift_cnt>=OPERAND_MAX_DATA_WIDTH/OPERAND_BUS_WIDTH)
                            $fatal(1,"Operand frame exceeds declared width");
                        operand_a[operand_shift_cnt*OPERAND_BUS_WIDTH +: OPERAND_BUS_WIDTH] <= a;
                        operand_b[operand_shift_cnt*OPERAND_BUS_WIDTH +: OPERAND_BUS_WIDTH] <= b;
                        operand_shift_cnt <= operand_shift_cnt + 1;

                        if (operand_last) begin
                            
                            state <= EXECUTE;
                        end
                    end

                end
                EXECUTE: begin

                    result_full <= calculated_result;

                    result_shift_cnt <= 0;
                    result_valid <= 1;               

                    if ((calculated_result >> RESULT_BUS_WIDTH) == 0) begin 
                        state <= IDLE;
                        result_last <= 1;
                    end else begin 
                        state <= SEND;
                    end

                end
                SEND: begin

                    result_shift_cnt <= result_shift_cnt + 1;
                    result_valid <= 1;

                    if (result_full >> (result_shift_cnt+2)*RESULT_BUS_WIDTH == 0) begin 
                        state <= IDLE;
                        result_last <= 1;
                    end

                end
            endcase
        end
    end

endmodule
