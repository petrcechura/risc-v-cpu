
TOP=tb
DESIGN_DIR=design/cpu
TESTBENCH=verif/src/tb.sv
TO_COMPILE=$(DESIGN_DIR)/ram.sv \
		   $(DESIGN_DIR)/alu.sv \
		   $(DESIGN_DIR)/control_unit.sv \
		   $(DESIGN_DIR)/cpu.sv \
		   $(TESTBENCH)
SNAPSHOT=cpusim

.PHONY: all
all: compile run

.PHONY: compile
compile:
	cd verif/ && \
	xvlog -sv -nolog -work work $(foreach unit, $(TO_COMPILE), ../$(unit)) && \
	xelab -nolog -debug wave $(foreach unit, ../$(TO_COMPILE), $(notdir $(basename $(unit)))) -s $(SNAPSHOT)

.PHONY: run
run: 
	cd verif/ && \
	xsim -runall cpusim

.PHONY: wave
wave:
	cd verif/ && \
		xsim -gui -wdb $(SNAPSHOT).wdb $(SNAPSHOT)

.PHONY: clean
clean:
	rm -rf verif/xsim*
	rm verif/xvlog*
	rm verif/xelab*
	rm verif/$(SNAPSHOT).wdb

