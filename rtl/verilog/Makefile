VLIB_BASE = vmemctrl_vl_
VLIB_DEFINES = +define+BASE+$(VLIB_BASE)
VLIB_DEFINES += +define+WB3WB3_BRIDGE
VLIB_DEFINES += +define+WB3_ARBITER_TYPE1
VLIB_DEFINES += +define+CNT_LFSR_ZQ
VLIB_DEFINES += +define+DELAY_EMPTYFLAG
VLIB_DEFINES += +define+DFF_CE_CLEAR
VLIB_DEFINES += +define+WB_B3_RAM_BE
#VLIB_DEFINES += +define+SYSTEMVERILOG
VLIB_ALTERA = vmemctrl_vl_altera.v
VLIB_ACTEL = vmemctrl_vl_actel.v
VLIB = versatile_library.v
VLIB += $(VLIB_ALTERA)
VLIB += $(VLIB_ACTEL)
RTL_FILES = versatile_mem_ctrl_defines.v
RTL_FILES += sdr_sdram_ctrl.v
RTL_FILES += versatile_mem_ctrl_top.v
#RTL_FILES += ddr3_2agx125n_cache_dpram.v
#RTL_FILES += ddr3_2agx125n_if.v
#RTL_FILES += ddr3_2agx125n/ddr3_2agx125n_ip.v
OUT_FILE = vmemctrl.v
#ALTERA_INCLUDE = /opt/altera/11.0/ip/altera/alt_mem_if/alt_mem_if_controllers/alt_mem_if_nextgen_ddr_controller_110/rtl/alt_mem_ddrx_define

VCOUNT_FILES = VersatileCounter.class.php
VCOUNT_FILES += VersatileCounter.php
$(VCOUNT_FILES):
	for file in $(VCOUNT_FILES) ; do \
	    svn export http://opencores.org/ocsvn/versatile_library/versatile_library/trunk/misc/$$file ; \
	done
refresh: $(VCOUNT_FILES)
	./VersatileCounter.php 10 1000
	./VersatileCounter.php 9 500
	./VersatileCounter.php 11 1172
	./VersatileCounter.php 10 586
	./VersatileCounter.php 11 1954
	./VersatileCounter.php 10 977
	./VersatileCounter.php 12 2079
	./VersatileCounter.php 11 1040
	./VersatileCounter.php 12 2407
	./VersatileCounter.php 11 1204

export:
	svn export http://opencores.org/ocsvn/versatile_library/versatile_library/trunk/rtl/verilog/versatile_library.v
	svn export http://opencores.org/ocsvn/versatile_library/versatile_library/trunk/backend/altera/lpm_ff.v
	vppreproc --noline --noblank +define+ALTERA $(VLIB_DEFINES) versatile_library.v | sed -r -e 's/\/\/E2_([a-z]+)/`\1/' > $(VLIB_ALTERA)
	vppreproc --noline --noblank +define+ACTEL  $(VLIB_DEFINES) versatile_library.v | sed -r -e 's/\/\/E2_([a-z]+)/`\1/' > $(VLIB_ACTEL)

config:
	configurator versatile_mem_ctrl_defines.v

versatile_mem_ctrl: config
	vppreproc --simple +define+VLBASE+$(VLIB_BASE) $(RTL_FILES) | cat copyright.v - > $(OUT_FILE)

test: versatile_mem_ctrl
	iverilog -y$(ALTERA_INCLUDE) -tnull lpm_ff.v $(VLIB_ALTERA) $(OUT_FILE)
	iverilog -y$(ALTERA_INCLUDE) -tnull $(VLIB_ACTEL) $(OUT_FILE)

# the single all rule
all: export versatile_mem_ctrl

clean:
	rm -rf $(VLIB) $(OUT_FILE) $(VCOUNT_FILES) lpm_ff.v
