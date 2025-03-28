
module reg_file(
  input wire[4:0] addr,
  input wire[15:0] data_i,
  input wire write,
  input wire clk,
  input wire rst,
  output wire[15:0] data_o
);

  wire[15:0] mux_o;
  wire[31:0] demux_i;

  reg[31:0][15:0] regs;

  assign data_o = mux_o;
  
  always(addr) begin
    // multiplexer
    mux_o = regs[addr];
  end
  
  // CLK event
  always@(rst,clk) begin
    if (rst==1'b1) begin
      regs = '0;
    end
    else if (posedge clk) begin
      if (write) begin
        regs[addr] <= data_i;
      end
    end
  end

endmodule: reg_file
