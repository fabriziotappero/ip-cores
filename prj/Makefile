VERILOG_PROJECTS = minsoc_bench.prj minsoc_top.prj or1200_top.prj adbg_top.prj jtag_top.prj uart_top.prj ethmac.prj
VHDL_PROJECTS = altera_virtual_jtag.prj

PROJECTS = $(VERILOG_PROJECTS) $(VHDL_PROJECTS)
SRC_DIR = src
SCRIPTS_DIR = scripts

SIMULATION_DIR = sim
XILINX_DIR = xilinx
ALTERA_DIR = altera

SIM_VERILOG_FILES = $(addprefix $(SIMULATION_DIR)/, $(addsuffix .verilog, $(basename $(VERILOG_PROJECTS))))
SIM_VHDL_FILES = $(addprefix $(SIMULATION_DIR)/, $(addsuffix .vhdl, $(basename $(VHDL_PROJECTS))))

XILINX_PRJ_FILES = $(addprefix $(XILINX_DIR)/, $(addsuffix .prj, $(basename $(PROJECTS))))
XILINX_XST_FILES = $(addprefix $(XILINX_DIR)/, $(addsuffix .xst, $(basename $(PROJECTS))))

ALTERA_VERILOG_PRJ_FILES = $(addprefix $(ALTERA_DIR)/, $(addsuffix .vprj, $(basename $(VERILOG_PROJECTS))))
ALTERA_VHDL_PRJ_FILES = $(addprefix $(ALTERA_DIR)/, $(addsuffix .vhdprj, $(basename $(VHDL_PROJECTS))))

all: $(SIMULATION_DIR)/minsoc_verilog.src $(SIMULATION_DIR)/minsoc_vhdl.src $(XILINX_PRJ_FILES) $(XILINX_XST_FILES) $(ALTERA_VERILOG_PRJ_FILES) $(ALTERA_VHDL_PRJ_FILES)

clean:
	rm -rf $(SIMULATION_DIR)/*.verilog $(SIMULATION_DIR)/*.vhdl $(SIMULATION_DIR)/*.src $(XILINX_DIR)/*.prj $(XILINX_DIR)/*.xst $(ALTERA_DIR)/*.vprj $(ALTERA_DIR)/*.vhdprj


$(XILINX_DIR)/minsoc_top.xst: $(SRC_DIR)/minsoc_top.prj
	bash $(SCRIPTS_DIR)/xilinxxst.sh $^ $@ minsoc_top.prj minsoc_top topmodule

$(XILINX_DIR)/minsoc_top.prj: $(SRC_DIR)/minsoc_top.prj
	bash $(SCRIPTS_DIR)/xilinxprj.sh $^ $@ topmodule

$(XILINX_DIR)/%.xst: $(SRC_DIR)/%.prj
	bash $(SCRIPTS_DIR)/xilinxxst.sh $^ $@ $*.prj $*

$(XILINX_DIR)/%.prj: $(SRC_DIR)/%.prj
	bash $(SCRIPTS_DIR)/xilinxprj.sh $^ $@


$(ALTERA_DIR)/%.vprj: $(SRC_DIR)/%.prj
	bash $(SCRIPTS_DIR)/altvprj.sh $^ $@

$(ALTERA_DIR)/%.vhdprj: $(SRC_DIR)/%.prj
	bash $(SCRIPTS_DIR)/altvhdprj.sh $^ $@


$(SIMULATION_DIR)/minsoc_verilog.src: $(SIM_VERILOG_FILES)
	cat $(SIM_VERILOG_FILES) > $(SIMULATION_DIR)/minsoc_verilog.src

$(SIMULATION_DIR)/minsoc_vhdl.src: $(SIM_VHDL_FILES)
	cat $(SIM_VHDL_FILES) > $(SIMULATION_DIR)/minsoc_vhdl.src

$(SIMULATION_DIR)/%.verilog: $(SRC_DIR)/%.prj
	bash $(SCRIPTS_DIR)/simverilog.sh $^ $@

$(SIMULATION_DIR)/%.vhdl: $(SRC_DIR)/%.prj
	bash $(SCRIPTS_DIR)/simvhdl.sh $^ $@

