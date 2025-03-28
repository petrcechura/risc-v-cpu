module cpu#(
  int REG_SIZE = 8
)(
  // CLK & RESET
  input logic RST,
  input logic CLK,

  // SYSTEM BUS INTERFACE
  // These interface signals the CPU uses to communicate with RAM and other
  // peripherals on chip, using highly paralel protocol.
  system_bus_if sys_if,

  // SYSTEM BUS BACKDOOR INTERFACE
  // Some of the inputs are designed to backdoor system bus interface to
  // provide a way to program CPU. Hence using following signals, CPU can be
  // driven from "outside world" to either stop it's execution, prepare for
  // programming or other actions
  system_bus_backdoor_if sys_backdoor_if

);

  // alu <-> control unit
  logic[1:0] alu_operation;
  logic[REG_SIZE-1:0] alu_op1;
  logic[REG_SIZE-1:0] alu_op2;
  logic  alu_req;
  logic  alu_done;
  logic  alu_res;

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

endmodule: cpu
