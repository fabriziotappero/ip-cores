##############################################################################
#
# Makefile for the T400 Core project.
#
# $Id: Makefile 179 2009-04-01 19:48:38Z arniml $
#
# The dependencies for all VHDL source files are stored here.
#
# Copyright (c) 2006, Arnim Laeuger (arnim.laeuger@gmx.net)
#
# All rights reserved
#
##############################################################################


PROJECT_DIR = ../..
RTL_DIR     = $(PROJECT_DIR)/rtl/vhdl
TECH_DIR    = $(PROJECT_DIR)/rtl/tech/cyclone
GTECH_DIR   = $(PROJECT_DIR)/rtl/tech/generic
SYSTEM_DIR  = $(RTL_DIR)/system
BENCH_DIR   = $(PROJECT_DIR)/bench/vhdl

ANALYZE=ghdl -a --std=87 --workdir=work
ELABORATE=ghdl -e -Wl,-s --std=87 --workdir=work

.PHONY: all
all: work elaborate

work:
	mkdir work


##############################################################################
# Technology dependent parts
#
work/t400_tech_comp_pack-p.o: $(PROJECT_DIR)/rtl/tech/t400_tech_comp_pack-p.vhd
	$(ANALYZE) $<

work/t400_por.o: $(TECH_DIR)/t400_por.vhd
	$(ANALYZE) $<
work/t400_por-c.o: $(TECH_DIR)/t400_por-c.vhd \
                   work/t400_por.o
	$(ANALYZE) $<

work/generic_ram.o: $(GTECH_DIR)/generic_ram.vhd
	$(ANALYZE) $<
work/generic_ram-c.o: $(GTECH_DIR)/generic_ram-c.vhd \
                      work/generic_ram.o
	$(ANALYZE) $<

work/generic_ram_ena.o: $(GTECH_DIR)/generic_ram_ena.vhd
	$(ANALYZE) $<
work/generic_ram_ena-c.o: $(GTECH_DIR)/generic_ram_ena-c.vhd \
                      work/generic_ram_ena.o
	$(ANALYZE) $<
#
##############################################################################


##############################################################################
# T400 Core
#
work/t400_opt_pack-p.o: $(RTL_DIR)/t400_opt_pack-p.vhd
	$(ANALYZE) $<

work/t400_pack-p.o: $(RTL_DIR)/t400_pack-p.vhd
	$(ANALYZE) $<

work/t400_comp_pack-p.o: $(RTL_DIR)/t400_comp_pack-p.vhd \
                         work/t400_opt_pack-p.o          \
                         work/t400_pack-p.o
	$(ANALYZE) $<

work/t400_io_pack-p.o: $(RTL_DIR)/t400_io_pack-p.vhd \
                       work/t400_opt_pack-p.o
	$(ANALYZE) $<

work/t400_clkgen.o: $(RTL_DIR)/t400_clkgen.vhd \
                    work/t400_opt_pack-p.o
	$(ANALYZE) $<
work/t400_clkgen-c.o: $(RTL_DIR)/t400_clkgen-c.vhd \
                      work/t400_clkgen.o
	$(ANALYZE) $<

work/t400_reset.o: $(RTL_DIR)/t400_reset.vhd    \
                   work/t400_opt_pack-p.o
	$(ANALYZE) $<
work/t400_reset-c.o: $(RTL_DIR)/t400_reset-c.vhd \
                     work/t400_reset.o
	$(ANALYZE) $<

work/t400_stack.o: $(RTL_DIR)/t400_stack.vhd \
                   work/t400_opt_pack-p.o    \
                   work/t400_pack-p.o        \
                   work/tb_pack-p.o
	$(ANALYZE) $<
work/t400_stack-c.o: $(RTL_DIR)/t400_stack-c.vhd \
                     work/t400_stack.o
	$(ANALYZE) $<

work/t400_pmem_ctrl.o: $(RTL_DIR)/t400_pmem_ctrl.vhd \
                       work/t400_opt_pack-p.o        \
                       work/t400_pack-p.o            \
                       work/tb_pack-p.o
	$(ANALYZE) $<
work/t400_pmem_ctrl-c.o: $(RTL_DIR)/t400_pmem_ctrl-c.vhd \
                         work/t400_pmem_ctrl.o
	$(ANALYZE) $<

work/t400_alu.o: $(RTL_DIR)/t400_alu.vhd \
                 work/t400_pack-p.o      \
                 work/t400_opt_pack-p.o
	$(ANALYZE) $<
work/t400_alu-c.o: $(RTL_DIR)/t400_alu-c.vhd \
                   work/t400_alu.o
	$(ANALYZE) $<

work/t400_dmem_ctrl.o: $(RTL_DIR)/t400_dmem_ctrl.vhd \
                       work/t400_opt_pack-p.o        \
                       work/t400_pack-p.o
	$(ANALYZE) $<
work/t400_dmem_ctrl-c.o: $(RTL_DIR)/t400_dmem_ctrl-c.vhd \
                         work/t400_dmem_ctrl.o
	$(ANALYZE) $<

work/t400_skip.o: $(RTL_DIR)/t400_skip.vhd \
                  work/t400_pack-p.o
	$(ANALYZE) $<
work/t400_skip-c.o: $(RTL_DIR)/t400_skip-c.vhd \
                    work/t400_skip.o
	$(ANALYZE) $<

work/t400_mnemonic_pack-p.o: $(RTL_DIR)/t400_mnemonic_pack-p.vhd \
                             work/t400_pack-p.o                  \
                             work/t400_opt_pack-p.o
	$(ANALYZE) $<

work/t400_decoder.o: $(RTL_DIR)/t400_decoder.vhd \
                     work/t400_opt_pack-p.o      \
                     work/t400_pack-p.o          \
                     work/t400_mnemonic_pack-p.o
	$(ANALYZE) $<
work/t400_decoder-c.o: $(RTL_DIR)/t400_decoder-c.vhd \
                       work/t400_decoder.o
	$(ANALYZE) $<

work/t400_io_l.o: $(RTL_DIR)/t400_io_l.vhd \
                  work/t400_opt_pack-p.o   \
                  work/t400_pack-p.o       \
                  work/t400_io_pack-p.o
	$(ANALYZE) $<
work/t400_io_l-c.o: $(RTL_DIR)/t400_io_l-c.vhd \
                    work/t400_io_l.o
	$(ANALYZE) $<

work/t400_io_d.o: $(RTL_DIR)/t400_io_d.vhd \
                  work/t400_opt_pack-p.o   \
                  work/t400_pack-p.o       \
                  work/t400_io_pack-p.o
	$(ANALYZE) $<
work/t400_io_d-c.o: $(RTL_DIR)/t400_io_d-c.vhd \
                    work/t400_io_d.o
	$(ANALYZE) $<

work/t400_io_g.o: $(RTL_DIR)/t400_io_g.vhd \
                  work/t400_opt_pack-p.o   \
                  work/t400_pack-p.o       \
                  work/t400_io_pack-p.o
	$(ANALYZE) $<
work/t400_io_g-c.o: $(RTL_DIR)/t400_io_g-c.vhd \
                    work/t400_io_g.o
	$(ANALYZE) $<

work/t400_io_in.o: $(RTL_DIR)/t400_io_in.vhd \
                   work/t400_pack-p.o
	$(ANALYZE) $<
work/t400_io_in-c.o: $(RTL_DIR)/t400_io_in-c.vhd \
                     work/t400_io_in.o
	$(ANALYZE) $<

work/t400_sio.o: $(RTL_DIR)/t400_sio.vhd \
                 work/t400_pack-p.o      \
                 work/t400_opt_pack-p.o
	$(ANALYZE) $<
work/t400_sio-c.o: $(RTL_DIR)/t400_sio-c.vhd \
                   work/t400_sio.o
	$(ANALYZE) $<

work/t400_timer.o: $(RTL_DIR)/t400_timer.vhd \
                   work/t400_pack-p.o
	$(ANALYZE) $<
work/t400_timer-c.o: $(RTL_DIR)/t400_timer-c.vhd \
                     work/t400_timer.o
	$(ANALYZE) $<

work/t400_core.o: $(RTL_DIR)/t400_core.vhd \
                  work/t400_opt_pack-p.o   \
                  work/t400_pack-p.o       \
                  work/t400_comp_pack-p.o
	$(ANALYZE) $<
work/t400_core-c.o: $(RTL_DIR)/t400_core-c.vhd \
                    work/t400_clkgen-c.o       \
                    work/t400_reset-c.o        \
                    work/t400_pmem_ctrl-c.o    \
                    work/t400_dmem_ctrl-c.o    \
                    work/t400_decoder-c.o      \
                    work/t400_skip-c.o         \
                    work/t400_alu-c.o          \
                    work/t400_stack-c.o        \
                    work/t400_io_l-c.o         \
                    work/t400_io_d-c.o         \
                    work/t400_io_g-c.o         \
                    work/t400_io_in-c.o        \
                    work/t400_sio-c.o          \
                    work/t400_timer-c.o        \
                    work/t400_core.o
	$(ANALYZE) $<

work/t400_core_comp_pack-p.o: $(RTL_DIR)/t400_core_comp_pack-p.vhd \
                              work/t400_opt_pack-p.o
	$(ANALYZE) $<
#
##############################################################################


##############################################################################
# T400 Systems
#
work/t410_rom-e.o: $(SYSTEM_DIR)/t410_rom-e.vhd
	$(ANALYZE) $<
work/t420_rom-e.o: $(SYSTEM_DIR)/t420_rom-e.vhd
	$(ANALYZE) $<

work/t410_notri.o: $(SYSTEM_DIR)/t410_notri.vhd \
                   work/t400_opt_pack-p.o       \
                   work/t400_core_comp_pack-p.o \
                   work/t400_tech_comp_pack-p.o
	$(ANALYZE) $<
work/t410_notri-c.o: $(SYSTEM_DIR)/t410_notri-c.vhd \
                     work/t400_core-c.o             \
                     work/generic_ram_ena-c.o       \
                     work/t410_rom-lpm-c.o          \
                     work/t400_por-c.o              \
                     work/t410_notri.o
	$(ANALYZE) $<

work/t420_notri.o: $(SYSTEM_DIR)/t420_notri.vhd \
                   work/t400_opt_pack-p.o       \
                   work/t400_core_comp_pack-p.o \
                   work/t400_tech_comp_pack-p.o
	$(ANALYZE) $<
work/t420_notri-c.o: $(SYSTEM_DIR)/t420_notri-c.vhd \
                     work/t400_core-c.o             \
                     work/generic_ram_ena-c.o       \
                     work/t420_rom-lpm-c.o          \
                     work/t400_por-c.o              \
                     work/t420_notri.o
	$(ANALYZE) $<

work/t400_system_comp_pack-p.o: $(SYSTEM_DIR)/t400_system_comp_pack-p.vhd
	$(ANALYZE) $<

work/t410.o: $(SYSTEM_DIR)/t410.vhd         \
             work/t400_opt_pack-p.o         \
             work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/t410-c.o: $(SYSTEM_DIR)/t410-c.vhd \
               work/t410_notri-c.o      \
               work/t410.o
	$(ANALYZE) $<

work/t411.o: $(SYSTEM_DIR)/t411.vhd         \
             work/t400_opt_pack-p.o         \
             work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/t411-c.o: $(SYSTEM_DIR)/t411-c.vhd \
               work/t410_notri-c.o      \
               work/t411.o
	$(ANALYZE) $<

work/t420.o: $(SYSTEM_DIR)/t420.vhd         \
             work/t400_opt_pack-p.o         \
             work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/t420-c.o: $(SYSTEM_DIR)/t420-c.vhd \
               work/t420_notri-c.o      \
               work/t420.o
	$(ANALYZE) $<

work/t421.o: $(SYSTEM_DIR)/t421.vhd         \
             work/t400_opt_pack-p.o         \
             work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/t421-c.o: $(SYSTEM_DIR)/t421-c.vhd \
               work/t420_notri-c.o      \
               work/t421.o
	$(ANALYZE) $<
#
##############################################################################


##############################################################################
# Testbenches
#
work/tb_pack-p.o: $(BENCH_DIR)/tb_pack-p.vhd \
                  work/t400_pack-p.o
	$(ANALYZE) $<

work/lpm_rom.o: $(BENCH_DIR)/lpm_rom.vhd
	$(ANALYZE) $<

work/lpm_ram_dq.o: $(BENCH_DIR)/lpm_ram_dq.vhd
	$(ANALYZE) $<

work/t410_rom-lpm-a.o: $(BENCH_DIR)/t410_rom-lpm-a.vhd \
                       work/t410_rom-e.o
	$(ANALYZE) $<
work/t410_rom-lpm-c.o: $(BENCH_DIR)/t410_rom-lpm-c.vhd \
                       work/lpm_rom.o                  \
                       work/t410_rom-lpm-a.o
	$(ANALYZE) $<

work/t420_rom-lpm-a.o: $(BENCH_DIR)/t420_rom-lpm-a.vhd \
                       work/t420_rom-e.o
	$(ANALYZE) $<
work/t420_rom-lpm-c.o: $(BENCH_DIR)/t420_rom-lpm-c.vhd \
                       work/lpm_rom.o                  \
                       work/t420_rom-lpm-a.o
	$(ANALYZE) $<

work/tb_elems.o: $(BENCH_DIR)/tb_elems.vhd
	$(ANALYZE) $<
work/tb_elems-c.o: $(BENCH_DIR)/tb_elems-c.vhd \
                   work/tb_elems.o
	$(ANALYZE) $<

work/tb_t410.o: $(BENCH_DIR)/tb_t410.vhd       \
                work/t400_opt_pack-p.o         \
                work/tb_pack-p.o               \
                work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/tb_t410-c.o: $(BENCH_DIR)/tb_t410-c.vhd \
                  work/t410-c.o              \
                  work/tb_elems-c.o          \
                  work/tb_t410.o
	$(ANALYZE) $<

work/tb_t411.o: $(BENCH_DIR)/tb_t411.vhd       \
                work/t400_opt_pack-p.o         \
                work/tb_pack-p.o               \
                work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/tb_t411-c.o: $(BENCH_DIR)/tb_t411-c.vhd \
                  work/t411-c.o              \
                  work/tb_elems-c.o          \
                  work/tb_t411.o
	$(ANALYZE) $<

work/tb_t420.o: $(BENCH_DIR)/tb_t420.vhd       \
                work/t400_opt_pack-p.o         \
                work/tb_pack-p.o               \
                work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/tb_t420-c.o: $(BENCH_DIR)/tb_t420-c.vhd \
                  work/t420-c.o              \
                  work/tb_elems-c.o          \
                  work/tb_t420.o
	$(ANALYZE) $<

work/tb_t421.o: $(BENCH_DIR)/tb_t421.vhd       \
                work/t400_opt_pack-p.o         \
                work/tb_pack-p.o               \
                work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/tb_t421-c.o: $(BENCH_DIR)/tb_t421-c.vhd \
                  work/t421-c.o              \
                  work/tb_elems-c.o          \
                  work/tb_t421.o
	$(ANALYZE) $<

work/tb_int.o: $(BENCH_DIR)/tb_int.vhd        \
               work/t400_opt_pack-p.o         \
               work/tb_pack-p.o               \
               work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/tb_int-c.o: $(BENCH_DIR)/tb_int-c.vhd \
                 work/t420-c.o             \
                 work/tb_elems-c.o         \
                 work/tb_int.o
	$(ANALYZE) $<

work/tb_microbus.o: $(BENCH_DIR)/tb_microbus.vhd   \
                    work/t400_opt_pack-p.o         \
                    work/tb_pack-p.o               \
                    work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/tb_microbus-c.o: $(BENCH_DIR)/tb_microbus-c.vhd \
                      work/t420-c.o                  \
                      work/tb_elems-c.o              \
                      work/tb_microbus.o
	$(ANALYZE) $<

work/tb_prod.o: $(BENCH_DIR)/tb_prod.vhd       \
                work/t400_opt_pack-p.o         \
                work/tb_pack-p.o               \
                work/t400_system_comp_pack-p.o
	$(ANALYZE) $<
work/tb_prod-c.o: $(BENCH_DIR)/tb_prod-c.vhd \
                  work/t420-c.o              \
                  work/tb_elems-c.o          \
                  work/tb_prod.o
	$(ANALYZE) $<
#
##############################################################################


.PHONY: elaborate
elaborate: tb_t410_behav_c0 tb_t411_behav_c0 \
           tb_t420_behav_c0 tb_t421_behav_c0 \
           tb_int_behav_c0 tb_microbus_behav_c0 tb_prod_behav_c0

tb_t410_behav_c0: work/tb_t410-c.o
	$(ELABORATE) $@

tb_t411_behav_c0: work/tb_t411-c.o
	$(ELABORATE) $@

tb_t420_behav_c0: work/tb_t420-c.o
	$(ELABORATE) $@

tb_t421_behav_c0: work/tb_t421-c.o
	$(ELABORATE) $@

tb_int_behav_c0: work/tb_int-c.o
	$(ELABORATE) $@

tb_microbus_behav_c0: work/tb_microbus-c.o
	$(ELABORATE) $@

tb_prod_behav_c0: work/tb_prod-c.o
	$(ELABORATE) $@


.PHONY: analyze
analyze: work \
         work/tb_t410-c.o work/tb_t411-c.o \
         work/tb_t420-c.o work/tb_t421-c.o \
         work/tb_int-c.o work/tb_microbus-c.o work/tb_prod-c.o


.PHONY: clean
clean:
	rm -rf *~ UNUSED *hex \
        tb_t410_behav_c0      \
        tb_t411_behav_c0      \
        tb_t420_behav_c0      \
        tb_t421_behav_c0      \
        tb_int_behav_c0       \
        tb_microbus_behav_c0  \
        tb_prod_behav_c0      \
        work
