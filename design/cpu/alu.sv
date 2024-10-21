module alu#(
	parameter int REG_SIZE = 8
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

	// TODO


endmodule: alu
