TECHNOLOGY=VIRTEX-E
PART=XCV300E
PACKAGE=BG352
SPEED=-6
SYNFREQ=50
PROMGENPAR=-p bin -w -u 0 $(TOP).bit -o wildcard-xcv300e
MANUFACTURER=Xilinx

vsim-wildcard:
	vmap system       ./modelsim/work
	vmap pe_lib       ./modelsim/work
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/system_pkg.vhd
	$(VCOM) pe_lib -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/pe/pe_pkg.vhd
	$(VCOM) pe_lib -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/pe/pe_ent.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/clk_gen/clkgen_pkg.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/clk_gen/clkgen_entarch.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/cb_ctrl/cb_ctrl_pkg.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/cb_ctrl/cb_ctrl_entarch.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/mem/mem_pkg.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/mem/mem_ent.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/mem/mem_empty_arch.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/mem/mem_static_arch.vhd
	@if test -r "$(WILDCARD_BASE)/vhdl/src/wildcard/io_conn/io_if_ent.vhd"; \
      then $(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/io_conn/io_if_ent.vhd; \
	fi
	@if test -r "$(WILDCARD_BASE)/vhdl/src/wildcard/io_conn/io_if_inactive_arch.vhd"; \
      then $(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/io_conn/io_if_inactive_arch.vhd; \
	fi
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/wildcard_pkg.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/wildcard/wildcard_entarch.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/host/host_pkg.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/host/host_ent.vhd
	$(VCOM) system -explicit $(WILDCARD_BASE)/vhdl/src/system_entarch.vhd
	$(VCOM) pe_lib -explicit pe_arch.vhd
	$(VCOM) system -explicit host_arch.vhd
	$(VCOM) system -explicit system_cfg.vhd
	@echo "" > make.work
	@for i in `cat libs.txt`; do vmake $$i >> make.work ; done