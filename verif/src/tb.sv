`timescale 1ns/1ps

`include "../ip/Asm2Bin.svh"

module tb;

  logic clk;
  logic rst;
  logic clk_en;

  logic[31:0] ins;
  logic[7:0]  pc;
  logic cpu_set;

  Asm2Bin asm2bin;
  logic[31:0] instructions[$];

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
    while (pc <= instructions.size()) begin
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
    asm2bin = new;
    void'(asm2bin.readFile("src/asm/test.asm"));
    instructions = asm2bin.getInsBuffer();

    foreach (instructions[i]) begin
      $display("%0b", instructions[i]);
    end

    #1ns;

    clk_en = 1;
    rst = 0;
    cpu_set = 0;
    #10ns;
    rst = 1;
    #20ns;
    rst = 0;
    #20ns;



    $display("TEST STARTED!");

    //run();

    #100ns;

    $display("TEST ENDED!");
    $finish;
  end


endmodule: tb
