###############################################################################
#
# ICARUS VERILOG & GTKWAVE MAKEFILE
# MADE BY WILLIAM GIBB FOR HACDC
# williamgibb@gmail.com
#
# Modified by Tom Pritchard, 2018
# 
# USE THE FOLLOWING COMMANDS WITH THIS MAKEFILE
#	"make check" - compiles your verilog design - good for checking code
#	"make sim" - compiles your design+TB & simulates your design
#	"make display" - compiles, simulates and displays waveforms
# 
###############################################################################

#TOOL INPUT
SRC_DIR := ./src
SRC_FILES := $(wildcard $(SRC_DIR)/*.v)

TEST_DIR := ./test
TEST_FILES := $(wildcard $(TEST_DIR)/*.v)

# TESTBENCH = i2s_interface.v
TBOUTPUT = i2s_interface_tb.vcd

#TOOLS
COMPILER = iverilog
SIMULATOR = vvp
VIEWER = gtkwave
#TOOL OPTIONS
COFLAGS = -v -o
SFLAGS = -v -n
SOUTPUT = -vcd		#SIMULATOR OUTPUT TYPE
#TOOL OUTPUT
COUTPUT = compiler.out			#COMPILER OUTPUT

#MAKE DIRECTIVES
check : $(TEST_FILES) $(SRC_FILES)
	$(COMPILER) -v $(SRC_FILES)

simulate: $(COUTPUT)
	$(SIMULATOR) $(SFLAGS) $(COUTPUT) $(SOUTPUT)

sim: $(COUTPUT)
	$(SIMULATOR) $(SFLAGS) $(COUTPUT) $(SOUTPUT)

display: $(TBOUTPUT)
	$(VIEWER) $(TBOUTPUT) &

#MAKE DEPENDANCIES
$(TBOUTPUT): $(COUTPUT)
	$(SIMULATOR) $(SOPTIONS) $(COUTPUT) $(SOUTPUT)

$(COUTPUT): $(TEST_FILES) $(SRC_FILES)
	$(COMPILER) $(COFLAGS) $(COUTPUT) $(TEST_FILES) $(SRC_FILES)