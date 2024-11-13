virtual class Parser#(parameter int OPCODE_SIZE = 7);

  function new;
    make_map();
  endfunction

  typedef logic[OPCODE_SIZE-1:0] instructions_t[];
  protected instructions_t instructions;

  protected int end_of_program;

  /**
  * This is an auxiliary associative array that stores instructions and their
  * opcodes for RV32I Base Instruction Set.
  *
  * The format is [987|6543210]
  *                 |     |
  *               funct3 opcode
  * */
  protected logic[OPCODE_SIZE-1:0] instructions[string] =
    '{"LUI" :     10'bxxx0110111,
      "AUIPC" :   10'bxxx0010111,
      "JAL" :     10'bxxx1101111,
      "JALR" :    10'b0001100111,
      "BEQ" :     10'b0001100011,
      "BNE" :     10'b0011100011,
      "BLT" :     10'b1001100011,
      "BGE" :     10'b1011100011,
      "BLTU" :    10'b1101100011,
      "BGEU" :    10'b1111100011,
      "LB" :      10'b0000000011,
      "LH" :      10'b0010000011,
      "LW" :      10'b0100000011,
      "LBU" :     10'b1000000011,
      "LHU" :     10'b1010000011,
      "SB" :      10'b0000100011,
      "SH" :      10'b0010100011,
      "SW" :      10'b0100100011,
      "ADDI" :    10'b0000010011,
      "SLTI" :    10'b0100010011,
      "SLTIU" :   10'b0110010011,
      "XORI" :    10'b1000010011,
      "ORI" :     10'b1100010011,
      "ANDI" :    10'b1110010011,
      "SLLI" :    10'b0010010011,
      "SRLI" :    10'b1010010011,
      "SRAI" :    10'b1010010011,
      "ADD" :     10'b0000110011,
      "SUB" :     10'b0000110011,
      "SLL" :     10'b0010110011,
      "SLT" :     10'b0100110011,
      "SLTU" :    10'b0110110011,
      "XOR" :     10'b1000110011,
      "SRL" :     10'b1010110011,
      "SRA" :     10'b1010110011,
      "OR" :      10'b1100110011,
      "AND" :     10'b1110110011,
      "FENCE" :   10'b0000001111,
      "FENCE.I" : 10'b0010001111,
      "ECALL" :   10'b0001110011,
      "EBREAK" :  10'b0001110011,
      "CSRRW" :   10'b0011110011,
      "CSRRS" :   10'b0101110011,
      "CSRRC" :   10'b0111110011,
      "CSRRWI" :  10'b1011110011,
      "CSRRSI" :  10'b1101110011,
      "CSRRCI" :  10'b1101110011
      };

  /**
  * Takes an assembly line as an argument, parses it and returns corresponding
  * **opcode** in logic array.
  * */

  /** A built-in function that parses input line into an array containing
  * instruction string in lower-case and its arguments.
  *
  * A function also checks whether the line has a proper format and if the
  * first element is a valid instruction. Comments are discarded. */
  protected virtual function string[] get_elements(string line);
    // TODO
  endfunction: get_elements

  // TODO
  virtual function logic[OPCODE_SIZE-1:0] parse_line(string line);

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

  /**
  * Reads an assembly file and parses its contents into internal array of
  * bitstream that can be used to program cpu via verification tools.
  *
  * Returns 1'b0 if reading was succesfull, 1'b1 otherwise. */
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
    return 1'b0;
  endfunction: read_file

  function instructions_t get_instructions();
    return instructions;
  endfunction: get_instructions

  function int get_end();
    return end_of_program;
  endfunction: get_end

endclass: Parser
