class parser#(parameter int OPCODE_SIZE = 32);

	function new;
		make_map();
	endfunction

	typedef logic[OPCODE_SIZE-1:0] instructions_t[];
	protected instructions_t instructions;

	protected int end_of_program;

	// instructions
	typedef enum logic[4-1:0] {
		// do nothing
		NOP = 4'b0000,
		// [JMP|line|0|0]
		// jump to `line` (set pc to `line`)
		JMP = 4'b0001,
		// [ADD|op1|op2|addr]
		// add `op1` and `op2`, store it to `addr`
		ADD = 4'b0010,
		// [SUB|op1|op2|addr]
		// sub `op1` and `op2`, store it to `addr`
		SUB = 4'b0011,
		// [MUL|op1|op2|addr]
		// mul `op1` and `op2`, store it to `addr`
		MUL = 4'b0100,
		// [DIV|op1|op2|addr]
		// div `op1` and `op2`, store it to `addr`
		DIV = 4'b0101,
		// [BRE|expr|line|0]
		// if `expr` is non-0, jmp to `line`
		BRE = 4'b0110,
		// [MOV|addr1|addr1|0]
		// move data from `addr1` to `addr2` (actually, copy them)
		MOV = 4'b0111,
		// [SET|addr|value|0]
		// set data on `addr` to `value`
		AND = 4'b1000,
		ORR = 4'b1001,
		XOR = 4'b1010,
		SET = 4'b1011,
		CLC = 4'b1100
	} ins_e;


	ins_e place_map[string];

	function void make_map;
		ins_e ins;
      	ins = ins.first();
      	do begin
        	place_map[ins.name()]=ins;
         	ins = ins.next();
      	end while (ins != ins.first());
	endfunction: make_map

	function logic[OPCODE_SIZE-1:0] parse_line(string line);
		
		logic[OPCODE_SIZE-1:0] opcode = 0;
		// aux. string var
		string subs;
		// 0 = instr, 1 = op1, 2 = op2 ...
		int j = 0;
		foreach(line[i]) begin
			if (line[i] == " " || line[i] == "\n") begin
				case(j)
					0: begin
						if (place_map.exists(subs)) begin
							automatic ins_e str = place_map[subs];
							automatic string s = {"0000", $sformatf("%b", str)};

							opcode[31:24] = s.atobin();
						end
						else begin
							$error("instruction %s not found!", subs);
						end
						
						subs = "";
						j++;
					end
					1: begin
						automatic string s = $sformatf("%8b", subs.atoi());
						opcode[23:16] = s.atobin();
						subs = "";
						j++;
					end
					2: begin
						automatic string s = $sformatf("%8b", subs.atoi());
						opcode[15:8] = s.atobin();
						subs = "";
						j++;
					end
					3: begin
						automatic string s = $sformatf("%8b", subs.atoi());
						opcode[7:0] = s.atobin();
						subs = "";
						j++;
					end
					default: begin
						$error("unexpected argument in line '%s' (%s)", line, subs);
					end

				endcase
			end
			else begin
				subs = {subs, line[i]};
			end
		end
		
		return opcode;
	endfunction: parse_line

	function bit read_file(string fname);
		string line;
		int f = $fopen(fname, "r");

		if (!f) begin
			$error("failed to open a file %s", fname);
			return 1'b1;
		end

		
		while(!$feof(f)) begin
			automatic logic[31:0] ins;
			$fgets(line, f);
			ins = parse_line(line);
			
			instructions = {instructions, ins};
		end

		end_of_program = instructions.size()-1;

		$fclose(f);
	endfunction: read_file

	function instructions_t get_instructions();
		return instructions;
	endfunction: get_instructions

	function int get_end();
		return end_of_program;
	endfunction: get_end

endclass: parser
