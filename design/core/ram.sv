`timescale 1us/1ps

module ram#(

  parameter int CELL_SIZE = 8,
  // TODO make clear what this actually means
  parameter int MEM_SIZE = 8,
  parameter bit ACTIVE_RESET = 1'b1
)
(
  input logic rst,
  input logic[MEM_SIZE-1:0] addr,
  input logic write_en,
  // input when `write_en` == 1'b1, otherwise output
  inout wire[CELL_SIZE-1:0] data
);

  logic[MEM_SIZE-1:0][CELL_SIZE-1:0] memory;
  logic[CELL_SIZE-1:0] data_out;
  logic[CELL_SIZE-1:0] data_in;

  assign data = (write_en == 1'b1) ? 'hZ : data_out;
  assign data_out = memory[addr];
  assign data_in = data;

  always@(rst, write_en)
  begin
    if (rst == ACTIVE_RESET) begin
      memory <= 0;
    end
    else if (write_en == 1'b1) begin
      memory[addr] <= data_in;
    end
  end

  final begin
    $display("===MEMORY===");
    foreach(memory[i]) begin
      $display("%2d: %d", i, memory[i]);
    end
  end
endmodule: ram
