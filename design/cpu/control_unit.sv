module control_unit#(
  int REG_SIZE = 8,
  logic ACTIVE_RESET = 1'b1
)
(

  // === I/O ===
  // ===========
  input logic clk,
  input logic rst,
  // [INSTRUCTION|addr_mode|data|data|data]
  input logic[4+4+REG_SIZE*3-1:0] ins_in,
  input logic cpu_set,
  // program counter
  output logic[REG_SIZE-1:0] pc,
  // stack pointer
  output logic[REG_SIZE-1:0] sp,

  // ===============================
  // between `control_unit` and `alu`
  output logic[1:0] alu_operation,
  output logic[REG_SIZE-1:0] alu_op1,
  output logic[REG_SIZE-1:0] alu_op2,
  output logic alu_req,
  input logic alu_done,
  input logic alu_res,

  // ==================================
  // between `control_unit` and `ram`
  output logic[REG_SIZE-1:0] addr,
  output logic write_en,
  inout wire[REG_SIZE-1:0] data

);

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
    // [CLC|addr|0|0]
    // clear data on `addr`
    CLC = 4'b1100
  } ins_t;

  typedef enum logic[3:0] {
    // cu waits for next instruction
    // when obtained -> ins stored into `INSTR` reg & go to DECODE
    FETCH,
    // cu obtains all required data from memory for instr execution
    // when obtained -> go to INS_*
    DECODE,

    INS_ADD,
    //
    INS_SUB,

    INS_MUL,

    INS_DIV,

    INS_MOV,

    INS_SET,

    INS_BRE,

    INS_NOP,

    INS_JMP,

    INS_ORR,

    INS_XOR,

    INS_CLC,

    INS_XXX
  } state_t;


  // === INTERNAL SIGNALS ===
  // ========================
  logic[REG_SIZE-1:0] data_out;
  logic[REG_SIZE-1:0] data_in;

  // ====== REGISTERS =======
  // ========================
  // seq part
  state_t state_q;
  logic[REG_SIZE/2-1:0] ins_q;
  logic[REG_SIZE-1:0] op1_q;
  logic[REG_SIZE-1:0] op2_q;
  logic[REG_SIZE-1:0] op3_q;
  logic[REG_SIZE-1:0] pc_q;
  logic[REG_SIZE-1:0] ads_q;
  // comb part
  state_t state_d;
  logic[REG_SIZE/2-1:0] ins_d;
  logic[REG_SIZE-1:0] op1_d;
  logic[REG_SIZE-1:0] op2_d;
  logic[REG_SIZE-1:0] op3_d;
  logic[REG_SIZE-1:0] pc_d;
  logic[REG_SIZE-1:0] ads_d;

  // RISC-V registers
  logic[REG_SIZE-1:0] x0;
  logic[REG_SIZE-1:0] x1;
  logic[REG_SIZE-1:0] x2;
  logic[REG_SIZE-1:0] x3;
  logic[REG_SIZE-1:0] x4;
  logic[REG_SIZE-1:0] x5;
  logic[REG_SIZE-1:0] x6;
  logic[REG_SIZE-1:0] x7;
  logic[REG_SIZE-1:0] x8;
  logic[REG_SIZE-1:0] x9;
  logic[REG_SIZE-1:0] x10;
  logic[REG_SIZE-1:0] x11;
  logic[REG_SIZE-1:0] x12;
  logic[REG_SIZE-1:0] x13;
  logic[REG_SIZE-1:0] x14;
  logic[REG_SIZE-1:0] x15;
  logic[REG_SIZE-1:0] x16;
  logic[REG_SIZE-1:0] x17;
  logic[REG_SIZE-1:0] x18;
  logic[REG_SIZE-1:0] x19;
  logic[REG_SIZE-1:0] x20;
  logic[REG_SIZE-1:0] x21;
  logic[REG_SIZE-1:0] x22;
  logic[REG_SIZE-1:0] x23;
  logic[REG_SIZE-1:0] x24;
  logic[REG_SIZE-1:0] x25;
  logic[REG_SIZE-1:0] x26;
  logic[REG_SIZE-1:0] x27;
  logic[REG_SIZE-1:0] x28;
  logic[REG_SIZE-1:0] x29;
  logic[REG_SIZE-1:0] x30;
  logic[REG_SIZE-1:0] x31;

  // === memory driver ===
  //======================
  assign data = (write_en == 1'b1) ? data_out : 'hZ;
  assign data_in = data;


  assign pc = pc_q;



  // === STATE MACHINE ===
  // =====================
  // seq part
  always_ff@(posedge clk, rst)
  begin
    if (rst == ACTIVE_RESET) begin
      state_q <= FETCH;
      ins_q <= 0;
      op1_q <= 0;
      op2_q <= 0;
      op3_q <= 0;
      pc_q <= 0;
      ads_q <= 0;
    end
    else if (cpu_set == 1'b1) begin
      state_q <= state_d;
      ins_q <= ins_d;
      op1_q <= op1_d;
      op2_q <= op2_d;
      op3_q <= op3_d;
      pc_q <= pc_d;
      ads_q <= ads_d;
    end
  end

  // comb part
  always_comb
  begin
    // default values
    addr = 0;
    write_en = 1'b0;
    data_out = 0;
    ads_d = ads_q;
    pc_d = pc_q;
    alu_req = 0;
    alu_op1 = 0;
    alu_op2 = 0;
    alu_operation = 0;

    case(state_q)
      FETCH: begin
        ins_d = ins_in[27:24];
        op1_d = ins_in[23:16];
        op2_d = ins_in[15:8];
        op3_d = ins_in[7:0];

        state_d = DECODE;
      end
      DECODE: begin

        pc_d = pc_q + 1;

        case(ins_q)
          NOP: begin
            state_d = INS_NOP;
          end

          ADD: begin
            alu_operation = 2'b00;
            alu_req = 1'b1;

            state_d = INS_ADD;
          end

          SUB: begin
            alu_operation = 2'b01;
            alu_req = 1'b1;

            state_d = INS_SUB;
          end

          MUL: begin
            alu_operation = 2'b10;
            alu_req = 1'b1;

            state_d = INS_MUL;
          end

          DIV: begin
            alu_operation = 2'b11;
            alu_req = 1'b1;

            state_d = INS_DIV;
          end

          JMP: begin
            pc_d = op1_q;

            state_d = INS_JMP;
          end

          MOV: begin
            // read from addr (`op1`)
            addr = op1_q;
            ads_d = data_in;

            state_d = INS_MOV;
          end

          SET: begin

            state_d = INS_SET;
          end

          CLC: begin

            state_d = INS_CLC;
          end

          BRE: begin
            pc_d = (!op1_q) ? op2_q : pc_q;

            state_d = INS_BRE;
          end


          default: begin
            state_d = INS_XXX;
          end

        endcase
      end

      INS_MOV: begin
        // write to addr (`op2`)
        addr = op2_q;
        write_en = 1'b1;
        data_out = ads_q;

        state_d = FETCH;
      end

      INS_ADD,
      INS_MUL,
      INS_SUB,
      INS_DIV: begin

        if (alu_done == 1'b1) begin
          // write to memory
          write_en = 1'b1;
          data_out = alu_res;
          addr = op3_q;

          state_d = FETCH;
        end

      end

      INS_SET: begin


        addr = op1_q;
        data_out = op2_q;
        write_en = 1'b1;

        state_d = FETCH;
      end

      INS_CLC: begin
        addr = op1_q;
        data_out = 0;
        write_en = 1'b1;

        state_d = FETCH;
      end

      INS_BRE: begin
        state_d = FETCH;
      end

      INS_JMP: begin
        state_d = FETCH;
      end

      INS_NOP: begin
        state_d = FETCH;
      end

      INS_XXX: begin
        state_d = FETCH;
      end

      default: begin
        $error(1, "Unknown state! (%s)", state_q.name());
      end

    endcase
  end
endmodule: control_unit
