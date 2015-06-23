VERILOG_CMD = iverilog
VVP_CMD = vvp
DUMPTYPE = vcd
WAVEFORM_VIEWER = gtkwave

TEST_IMAGE ?= ./test_image.bin

# Cache
ICACHE = ENABLED
DCACHE = DISABLED
 
all: compile run                                                                                      
 
# Testbench
SRC+= ./top.v ./top_tb.v

# CPU
SRC+= ../cpu/altor32.v ../cpu/altor32_alu.v ../cpu/altor32_regfile_sim.v
SRC+= ../cpu/altor32_fetch.v ../cpu/altor32_exec.v ../cpu/altor32_lsu.v
SRC+= ../cpu/altor32_dfu.v ../cpu/altor32_lfu.v ../cpu/altor32_writeback.v
SRC+= ../cpu/altor32_icache.v ../cpu/altor32_noicache.v ../cpu/altor32_wb_fetch.v
SRC+= ../cpu/altor32_dcache.v ../cpu/altor32_dcache_mem_if.v
SRC+= ../cpu/altor32_ram_dp.v ../cpu/altor32_ram_sp.v

# SOC
SRC+= ../soc/soc.v ../soc/soc_pif8.v ../soc/dmem_mux3.v ../soc/cpu_if.v

# Memory
SRC+= ./ram.v ./ram_dp8.v

# Peripherals
SRC+= ../peripheral/timer_periph.v
SRC+= ../peripheral/intr_periph.v
SRC+= ../peripheral/uart_periph.v 
SRC+= ../peripheral/uart.v

SRC_FLAGS = -DSIMULATION
SRC_FLAGS+= -DALTOR32_CLEAR_RAM
INC_DIRS  = -I. -I../soc -I../peripheral -I../cpu

# Cache
ifeq ($(ICACHE),ENABLED)
	SRC_FLAGS += -DICACHE_ENABLED=\"ENABLED\"
else
	SRC_FLAGS += -DICACHE_ENABLED=\"DISABLED\"
endif
ifeq ($(DCACHE),ENABLED)
	SRC_FLAGS += -DDCACHE_ENABLED=\"ENABLED\"
else
	SRC_FLAGS += -DDCACHE_ENABLED=\"DISABLED\"
endif


memory_img:
	gcc -o readmem readmem.c
	./readmem -o 0 -f $(TEST_IMAGE) > mem_0.hex
	./readmem -o 1 -f $(TEST_IMAGE) > mem_1.hex
	./readmem -o 2 -f $(TEST_IMAGE) > mem_2.hex
	./readmem -o 3 -f $(TEST_IMAGE) > mem_3.hex

check: 
	$(VERILOG_CMD) -t null $(SRC) $(INC_DIRS) $(SRC_FLAGS) 
 
compile :
	$(VERILOG_CMD) -o output.out $(SRC) $(INC_DIRS) $(SRC_FLAGS)            
 
run : compile memory_img
	$(VVP_CMD) output.out -$(DUMPTYPE) $(VVP_FLAGS) 
 
view : compile                                                                                              
	$(WAVEFORM_VIEWER) waveform.vcd gtksettings.sav                                           
 
clean :                                                                                                  
	-rm output.out waveform.vcd *.hex readmem

