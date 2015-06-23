
SHELL = /bin/sh
#.QUIET

# test_bench/test_bench_top.v

MC_TARGETS=	../../../rtl/verilog/mc_top.v			\
		../../../rtl/verilog/mc_wb_if.v			\
		../../../rtl/verilog/mc_cs_rf.v			\
		../../../rtl/verilog/mc_rf.v			\
		../../../rtl/verilog/mc_adr_sel.v		\
		../../../rtl/verilog/mc_dp.v			\
		../../../rtl/verilog/mc_rd_fifo.v		\
		../../../rtl/verilog/mc_refresh.v		\
		../../../rtl/verilog/mc_obct.v			\
		../../../rtl/verilog/mc_obct_top.v		\
		../../../rtl/verilog/mc_timing.v		\
		../../../rtl/verilog/mc_mem_if.v		\
		../../../rtl/verilog/mc_incn_r.v
		

MC_TB=		../../../bench/verilog/test_bench_top.v		\
		../../../bench/verilog/sync_cs_dev.v		\
		../../../bench/verilog/wb_mast_model.v		\
		../../../bench/verilog/160b3ver/adv_bb.v		\
		../../../bench/verilog/sram_models/MicronSRAM/mt58l1my18d.v \
		../../../bench/verilog/sram_models/IDT71T67802/idt71t67802s133.v \
		../../../bench/verilog/sdram_models/2Mx32/mt48lc2m32b2.v	\
		

RT=		../../../bench/vhdl/tst_bench.vhd		\
		../../../bench/vhdl/8Kx8_vhdl.vhd		\
		../../../../vga_lcd/hdl/vga.vhd			\
		../../../../vga_lcd/hdl/dpm.vhd			\
		../../../../vga_lcd/hdl/pgen.vhd		\
		../../../../vga_lcd/hdl/wb_master.vhd		\
		../../../../vga_lcd/hdl/colproc.vhd 		\
		../../../../vga_lcd/hdl/fifo.vhd		\
		../../../../vga_lcd/hdl/tgen.vhd		\
		../../../../vga_lcd/hdl/wb_slave.vhd		\
		../../../../vga_lcd/hdl/counter.vhd		\
		../../../../vga_lcd/hdl/fifo_dc.vhd		\
		../../../../vga_lcd/hdl/vtim.vhd		\



TOP=test
INCDIR=-INCDIR ../../../rtl/verilog/ -INCDIR ../../../bench/verilog/



clean:
	rm -f ./waves/*.dsn ./waves/*.trn ./ncwork/inca* .ncwork/.inc* ./count/inca.* ./count/.inca*

er:
	grep ERROR .nclog

hal:
	@hal	+incdir+./verilog/					\
		-NOP -NOS -nocheck STYVAL:USEPRT:NOBLKN:DLNBLK		\
		$(MC_TARGETS)

#################################################################################
#
# NCVLOG
#
#################################################################################


rtt:
	ncvhdl -CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var	\
		-WORK count -NOCOPYRIGHT -V93			\
		-LOGFILE .nclog ../../../../vga_lcd/hdl/counter.vhd

	ncvhdl -CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var	\
		-WORK ncwork -NOCOPYRIGHT  -V93			\
		-LOGFILE .nclog $(RT)

	ncvlog -CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var	\
		-WORK ncwork -NOCOPYRIGHT -UPDATE		\
		-LOGFILE .nclog $(INCDIR) $(MC_TARGETS)		\
		../../../bench/vhdl/mt48lc2m32b2.v

	ncelab -CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var	 \
		-WORK ncwork -NOCOPYRIGHT -ACCESS +r 		 \
		-LOGFILE .nclog -APPEND_LOG -NOTIMINGCHECKS	 \
		ncwork.testbench:test

	ncsim -CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var 	\
		-NOCOPYRIGHT -STATUS -LOGFILE .nclog 		\
		-APPEND_LOG -ERRORMAX 10 -NOKEY -UPDATE		\
		ncwork.testbench



vlog:
	ncvlog -CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var	\
		-WORK ncwork -NOCOPYRIGHT -UPDATE	\
		-LOGFILE .nclog $(WAVES) $(TARGETS) $(INCDIR)

# -IEEE1364

#################################################################################
#
# NCELAB
#
#################################################################################

elab:
	@ncelab -CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var	 \
		-WORK ncwork -NOCOPYRIGHT $(ACCESS) \
		-LOGFILE .nclog -APPEND_LOG -NOTIMINGCHECKS	 \
		ncwork.$(TOP)

# -IEEE1364
#################################################################################
#
# NCSIM
#
#################################################################################

sim:
	@ncsim -CDSLIB ncwork/cds.lib -HDLVAR ncwork/hdl.var 	\
		-NOCOPYRIGHT -STATUS -LOGFILE .nclog -EXIT	\
		-APPEND_LOG -ERRORMAX 10 -NOKEY -UPDATE	\
		ncwork.$(TOP)


