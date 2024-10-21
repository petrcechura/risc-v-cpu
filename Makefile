
TOP=simple_tb
DESIGN_DIR=design/cpu/
TESTBENCH=verif/simple_tb.sv
TO_COMPILE=$(DESIGN_DIR)/ram.sv \
		   $(DESIGN_DIR)/alu.sv \
		   $(DESIGN_DIR)/control_unit.sv \
		   $(DESIGN_DIR)/cpu.sv \
		   $(TESTBENCH)

.PHONY: all
all: compile run

.PHONY: all_gui
all_gui: compile run_gui


.PHONY: run
run:
	bsub -Is -q questa vsim $(TOP) -c  -do "run -all; exit"

.PHONY: run_gui
run_gui: 
	bsub -Is -q questa vsim $(TOP) -voptargs="+acc" -do "add wave -position insertpoint sim:/simple_tb/*; add wave -position insertpoint sim:/simple_tb/dut/*; add wave -position insertpoint sim:/simple_tb/dut/cu_i/*; add wave -position insertpoint sim:/simple_tb/dut/mem_i/*; run -all; exit"

.PHONY: compile
compile:
	vlog $(TO_COMPILE)
