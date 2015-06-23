# Some useful constants
SRC_LIST = ./rtl/sources.list
TB = tb/test_map_table.v

# Simulator used for testing is Icarus Verilog
# To dump waves, add -DWAVE_DUMP to ICARUS_OPTS
INCLUDE_CMD = -I ./rtl 
ICARUS_OPTS = -DWAVE_DUMP
ICARUS_CMD = iverilog

MAP_TABLE_SRC = rtl/map_table.v \
								rtl/free_list.v \
								rtl/dp_sram.v \
								rtl/ooops_defs.v \
								rtl/ooops_lib.v
MAP_TABLE_TB  = tb/test_map_table.v
								
all: sim

# Main command to compile simulation model
sim:
	$(ICARUS_CMD) $(ICARUS_OPTS) $(INCLUDE_CMD) -f $(SRC_LIST) $(TB) -o sim.exe

map_table: $(MAP_TABLE_SRC) $(MAP_TABLE_TB)
	$(ICARUS_CMD) $(ICARUS_OPTS) $(INCLUDE_CMD) $(MAP_TABLE_SRC) $(MAP_TABLE_TB) -o sim.exe

clean:
	rm ./*.exe
