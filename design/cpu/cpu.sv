

module cpu#(
	int REG_SIZE = 8	
)(
	// CPU INTERFACE
	// |ins|op1|op2|op3|
	input logic[31:0] ins_in,
	input logic cpu_set,
	input logic clk,
	input logic rst,
	output logic[7:0] pc
);
	
	// alu <-> control unit
	logic[1:0] alu_operation;
	logic[REG_SIZE-1:0] alu_op1;
	logic[REG_SIZE-1:0] alu_op2;
	logic	alu_req;
	logic	alu_done;
	logic	alu_res;

	// ram <-> control unit
	logic[REG_SIZE-1:0] addr;
	logic write_en;
	wire[REG_SIZE-1:0] data;

	ram mem_i(
		.rst(rst),
		.addr(addr),
		.write_en(write_en),
		.data(data)
	);

	control_unit cu_i(
		.alu_operation(alu_operation),
		.alu_op1(alu_op1),
		.alu_op2(alu_op2),
		.alu_req(alu_req),
		.alu_done(alu_done),
		.alu_res(alu_res),

		.addr(addr),
		.write_en(write_en),
		.data(data),

		.rst(rst),
		.clk(clk),
		.ins_in(ins_in),
		.cpu_set(cpu_set),
		.pc(pc)
	);
	
	alu alu_i(
		.alu_operation(alu_operation),
		.alu_op1(alu_op1),
		.alu_op2(alu_op2),
		.alu_req(alu_req),
		.alu_done(alu_done),
		.alu_res(alu_res),

		.rst(rst),
		.clk(clk)
	);

	initial begin
		$display("CPU");
	end

endmodule: cpu
