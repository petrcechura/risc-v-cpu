module alu#(
  parameter int REG_SIZE = 8,
  parameter bit RESET_ACTIVE = 1'b1
)
(
  input logic[1:0] alu_operation,
  input logic[REG_SIZE-1:0] alu_op1,
  input logic[REG_SIZE-1:0] alu_op2,
  input logic alu_req,
  output logic alu_done,
  output logic alu_res,

  input logic rst,
  input logic clk
);
  // big TODO

  //===INTERNAL SIGNALS===

  //===REGISTERS==
  logic on_d;
  logic[REG_SIZE-1:0] op1_d;
  logic[REG_SIZE-1:0] op2_d;
  logic[REG_SIZE-1:0] res_d;

  logic on_q;
  logic[REG_SIZE-1:0] op1_q;
  logic[REG_SIZE-1:0] op2_q;
  logic[REG_SIZE-1:0] res_q;


  always_ff@(posedge clk, rst)
  begin
    if (rst == RESET_ACTIVE) begin
      on_q <= 0;
      op1_q <= 0;
      op2_q <= 0;
      res_q <= 0;
    end
    else if (clk & alu_req) begin
      on_q <= on_d;
      op1_q <= op1_d;
      op2_q <= op2_d;
      res_q <= res_d;
    end
  end

endmodule: alu
