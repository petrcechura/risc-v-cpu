`timescale 1ns/1ps

`include "../design/cpu/parser.svh"

module simple_tb;

	logic clk;
	logic rst;
	logic clk_en;
	
	logic[31:0] ins;
	logic[7:0]  pc;
	logic cpu_set;

	parser p;
	logic[31:0] instructions[];

	cpu dut (
		.ins_in(ins),
		.cpu_set(cpu_set),
		.clk(clk),
		.rst(rst),
		.pc(pc)
	);

	task run;
		ins = 0;
		#5ns;
		cpu_set = 1;
		while (pc <= p.get_end()) begin
			ins = instructions[int'(pc)];
			#2ns;
		end
	endtask: run


	always
	begin
		#1ns clk = 0;
		#1ns clk = 1;
	end


	initial begin
		// read `asm.txt` file
		p = new;
		void'(p.read_file("verif/asm.txt"));
		instructions = p.get_instructions();

		clk_en = 1;
		rst = 0;
		cpu_set = 0;
		#10ns;
		rst = 1;
		#20ns;
		rst = 0;
		#20ns;



		$display("TEST STARTED!");

		run();
		
		#100ns;

		$display("TEST ENDED!");
		$finish;
	end


endmodule: simple_tb
