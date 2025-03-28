
/** A standalone parser for RISC-V architecture instruction set
  *   - parses ASM file, returns binary queue with corr. instructions */
class Asm2Bin;

  // whole instruction size in binary format for RISC-V architecture
  localparam int OPCODESIZE = 32;

  function new;
  endfunction

  // A type representing 32b length coded instruction
  typedef logic[OPCODESIZE-1:0] ins_t;
  // A type for an instruction line parsed to separated substrings (free of
  // whitespaces and comments)
  typedef string str_queue_t[$];
  // A queue of `ins_t` type
  typedef ins_t ins_queue_t[$];

  /** A buffer containing all parsed instructions in binary, executable format */
  protected ins_queue_t insBuffer;

  protected bit[4:0] regLut[string] = '{
      "x0"  : 5'd0,
      "x1"  : 5'd1,
      "x2"  : 5'd2,
      "x3"  : 5'd3,
      "x4"  : 5'd4,
      "x5"  : 5'd5,
      "x6"  : 5'd6,
      "x7"  : 5'd7,
      "x8"  : 5'd8,
      "x9"  : 5'd9,
      "x10" : 5'd10,
      "x11" : 5'd11,
      "x12" : 5'd12,
      "x13" : 5'd13,
      "x14" : 5'd14,
      "x15" : 5'd15,
      "x16" : 5'd16,
      "x17" : 5'd17,
      "x18" : 5'd18,
      "x19" : 5'd19,
      "x20" : 5'd20,
      "x21" : 5'd21,
      "x22" : 5'd22,
      "x23" : 5'd23,
      "x24" : 5'd24,
      "x25" : 5'd25,
      "x26" : 5'd26,
      "x27" : 5'd27,
      "x28" : 5'd28,
      "x29" : 5'd29,
      "x30" : 5'd30,
      "x31" : 5'd31
  };

  // A list of all instructions that are R type by RISC-V spec (RV32I)
  protected ins_t instRType[string] = '{
      "SLLI" : 32'b0000000xxxxxxxxxx001xxxxx0010011,
      "SRLI" : 32'b0000000xxxxxxxxxx101xxxxx0010011,
      "SRAI" : 32'b0100000xxxxxxxxxx101xxxxx0010011,
      "ADD"  : 32'b0000000xxxxxxxxxx001xxxxx0110011,
      "SUB"  : 32'b0100000xxxxxxxxxx000xxxxx0110011,
      "SLL"  : 32'b0000000xxxxxxxxxx001xxxxx0110011,
      "SLT"  : 32'b0000000xxxxxxxxxx010xxxxx0110011,
      "SLTU" : 32'b0000000xxxxxxxxxx011xxxxx0110011,
      "XOR"  : 32'b0000000xxxxxxxxxx100xxxxx0110011,
      "SRL"  : 32'b0000000xxxxxxxxxx101xxxxx0110011,
      "SRA"  : 32'b0100000xxxxxxxxxx101xxxxx0110011,
      "OR"   : 32'b0000000xxxxxxxxxx110xxxxx0110011,
      "AND"  : 32'b0000000xxxxxxxxxx111xxxxx0110011
  };

  protected ins_t instIType[string] = '{
      "JALR" : 32'bxxxxxxxxxxxxxxxxx000xxxxx1100111,
      "LB"   : 32'bxxxxxxxxxxxxxxxxx000xxxxx0000011,
      "LH"   : 32'bxxxxxxxxxxxxxxxxx001xxxxx0000011,
      "LW"   : 32'bxxxxxxxxxxxxxxxxx010xxxxx0000011,
      "LBU"  : 32'bxxxxxxxxxxxxxxxxx100xxxxx0000011,
      "LHU"  : 32'bxxxxxxxxxxxxxxxxx101xxxxx0000011,
      "ADDI" : 32'bxxxxxxxxxxxxxxxxx000xxxxx0010011,
      "SLTI" : 32'bxxxxxxxxxxxxxxxxx010xxxxx0010011,
      "SLTIU": 32'bxxxxxxxxxxxxxxxxx011xxxxx0010011,
      "XORI" : 32'bxxxxxxxxxxxxxxxxx100xxxxx0010011,
      "ORI"  : 32'bxxxxxxxxxxxxxxxxx110xxxxx0010011,
      "ANDI" : 32'bxxxxxxxxxxxxxxxxx111xxxxx0010011
  };

  protected ins_t instSType[string] = '{
      "SB"   : 32'bxxxxxxxxxxxxxxxxx000xxxxx0100011,
      "SH"   : 32'bxxxxxxxxxxxxxxxxx001xxxxx0100011,
      "SW"   : 32'bxxxxxxxxxxxxxxxxx010xxxxx0100011
  };

  protected ins_t instBType[string] = '{
      "BEQ"  : 32'bxxxxxxxxxxxxxxxxx000xxxxx1100011,
      "BNE"  : 32'bxxxxxxxxxxxxxxxxx001xxxxx1100011,
      "BLT"  : 32'bxxxxxxxxxxxxxxxxx100xxxxx1100011,
      "BGE"  : 32'bxxxxxxxxxxxxxxxxx101xxxxx1100011,
      "BLTU" : 32'bxxxxxxxxxxxxxxxxx110xxxxx1100011,
      "BGEU" : 32'bxxxxxxxxxxxxxxxxx111xxxxx1100011
  };

  protected ins_t instUType[string] = '{
      "LUI"  : 32'bxxxxxxxxxxxxxxxxxxxxxxxxx0110111,
      "AUIPC": 32'bxxxxxxxxxxxxxxxxxxxxxxxxx0010111
  };

  protected ins_t instJType[string] = '{
      "JAL"  : 32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111
  };

  /** Takes raw instruction line and returns a corresponding **opcode**
    * binary.
    *
    * This function expects instruction line that follows R-type pattern
    * and **returns empty opcode otherwise** */
  protected function ins_t asmRType(str_queue_t str_queue);
    automatic ins_t ins = '0;

    // sanity check for str_queue
    if (!instRType.exists(str_queue[0])) begin
      $warning("Instruction %0s is not an R-type! Returning 32'd0 ...", str_queue[0]);
      return ins;
    end
    else if (str_queue.size() != 4) begin
      $warning("Instruction %0s has invalid number of subarguments! Expected: %0d, Provided: %0d",
        str_queue[0], 3, str_queue.size()-1);
      return ins;
    end

    // parse subarguments (regs) into their position in binary line
    foreach(str_queue[i]) begin
      if(i==0) continue;

      if (regLut.exists(str_queue[i])) begin
        case(i)
          1: ins[24:20] = regLut[str_queue[i]];
          2: ins[19:15] = regLut[str_queue[i]];
          3: ins[11:7]  = regLut[str_queue[i]];
          default: begin
            $error("Unexpected subargument %0s for instruction %0s",
              str_queue[i], str_queue[0]);
            return '0;
          end
        endcase
      end else begin
        $warning("A register %s given as operand for %0s instruction doesn't exist!",
          str_queue[1], str_queue[0]);
        ins = '0;
        return ins;
      end
    end

    return ins;
  endfunction: asmRType

  // TODO
  protected function ins_t asmIType(str_queue_t str_queue);
    $error("TODO I type instructions not implemented yet!");
    return '0;
  endfunction: asmIType

  // TODO
  protected function ins_t asmSType(str_queue_t str_queue);
    $error("todo S type instructions not implemented yet!");
    return '0;
  endfunction: asmSType

  // TODO
  protected function ins_t asmBType(str_queue_t str_queue);
    $error("todo B type instructions not implemented yet!");
    return '0;
  endfunction: asmBType

  // TODO
  protected function ins_t asmUType(str_queue_t str_queue);
    $error("todo U type instructions not implemented yet!");
    return '0;
  endfunction: asmUType

  // TODO
  protected function ins_t asmJType(str_queue_t str_queue);
    $error("TODO J type instructions not implemented yet!");
    return '0;
  endfunction: asmJType

  /** A built-in function that parses an instruction line into a string queue,
    * disrearding any whitespace, comment or newline
    */
  virtual function str_queue_t parseLine(string line);
    automatic string subs;
    automatic str_queue_t str_q;

    // for each character in a line
    foreach(line[i]) begin
      case(line[i])
        " ": begin
          if (subs == "") begin
            str_q.push_back(subs);
            subs = "";
          end

        continue;
        end

        "\\n" || ";" : begin
          break;
        end

        default: begin
          subs = {subs, line[i]};
        end
      endcase
    end

  endfunction: parseLine

  function ins_t asmLine(string line);
    automatic str_queue_t str_queue = parseLine(line);
    automatic ins_t ins = '0;

    if (instRType.exists(str_queue[0])) begin
      ins = asmRType(str_queue);
    end
    else if (instIType.exists(str_queue[0])) begin
      ins = asmIType(str_queue);
    end
    else if (instSType.exists(str_queue[0])) begin
      ins = asmSType(str_queue);
    end
    else if (instBType.exists(str_queue[0])) begin
      ins = asmBType(str_queue);
    end
    else if (instUType.exists(str_queue[0])) begin
      ins = asmUType(str_queue);
    end
    else if (instJType.exists(str_queue[0])) begin
      ins = asmJType(str_queue);
    end
    else begin
      $error("Could not assemble line '%0s'!", line);
    end

    return ins;

  endfunction: asmLine


  /** Reads the entire file containg an assembly code. Stores instructions
    * into separated buffer.*/
  function bit readFile(string fname);
    string line;
    int f = $fopen(fname, "r");

    if (!f) begin
      $error("failed to open a file %s", fname);
      return 1'b1;
    end

    while(!$feof(f)) begin
      automatic ins_t ins;
      $fgets(line, f);
      ins = asmLine(line);

      insBuffer.push_back(ins);
    end

    $fclose(f);
    return 1'b0;
  endfunction: readFile

  function ins_queue_t getInsBuffer();
    return this.insBuffer;
  endfunction: getInsBuffer


endclass: Asm2Bin
