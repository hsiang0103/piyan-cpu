# Simple Makefile for Verilog/SystemVerilog projects
# Edit SRC and TB as needed for your testbench and source files

# Variables
SRC_DIR = src
TB = top_tb.sv
SRC = $(wildcard $(SRC_DIR)/*.sv)
OUT = simv

# Compiler (change to your simulator, e.g., vcs, iverilog, etc.)
VLOG = vcs
VLOG_FLAGS = -full64 -sverilog +access+r +vcs+fsdbon +fsdb+mda +v2k -debug_access+all

all: $(OUT)

$(OUT): $(SRC) $(TB)
	$(VLOG) $(VLOG_FLAGS) $(SRC) $(TB) -o $(OUT)



run: $(OUT)
	./$(OUT)

clean:
	rm -rf $(OUT) *.daidir *.log *.key *.fsdb novas* nWaveLog/ csrc/

.PHONY: all run clean
