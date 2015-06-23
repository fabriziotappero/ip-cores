##############################################################################
#
# Tool-specific Makefile for the GHDL compiler.
#
# $Id: Makefile 41 2009-04-01 19:58:04Z arniml $
#
# Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org)
#
# All rights reserved
#
##############################################################################


PROJECT_DIR = ../..
RTL_DIR     = $(PROJECT_DIR)/rtl/vhdl
BENCH_DIR   = $(PROJECT_DIR)/bench/vhdl



ANALYZE=ghdl -a --std=87 --workdir=work
ELABORATE=ghdl -e --std=87 --workdir=work

.PHONY: all
all: work elaborate

work:
	mkdir work

work/gcpad_pack-p.o: $(RTL_DIR)/gcpad_pack-p.vhd
	$(ANALYZE) $(RTL_DIR)/gcpad_pack-p.vhd

work/gcpad_sampler.o: $(RTL_DIR)/gcpad_sampler.vhd \
                      work/gcpad_pack-p.o
	$(ANALYZE) $(RTL_DIR)/gcpad_sampler.vhd
work/gcpad_sampler-c.o: $(RTL_DIR)/gcpad_sampler-c.vhd \
                        work/gcpad_sampler.o
	$(ANALYZE) $(RTL_DIR)/gcpad_sampler-c.vhd

work/gcpad_rx.o: $(RTL_DIR)/gcpad_rx.vhd \
                 work/gcpad_sampler.o    \
                 work/gcpad_pack-p.o
	$(ANALYZE) $(RTL_DIR)/gcpad_rx.vhd
work/gcpad_rx-c.o: $(RTL_DIR)/gcpad_rx-c.vhd \
                   work/gcpad_sampler-c.o    \
                   work/gcpad_rx.o
	$(ANALYZE) $(RTL_DIR)/gcpad_rx-c.vhd

work/gcpad_tx.o: $(RTL_DIR)/gcpad_tx.vhd \
                 work/gcpad_pack-p.o
	$(ANALYZE) $(RTL_DIR)/gcpad_tx.vhd
work/gcpad_tx-c.o: $(RTL_DIR)/gcpad_tx-c.vhd \
                 work/gcpad_tx.o
	$(ANALYZE) $(RTL_DIR)/gcpad_tx-c.vhd

work/gcpad_ctrl.o: $(RTL_DIR)/gcpad_ctrl.vhd \
                 work/gcpad_pack-p.o
	$(ANALYZE) $(RTL_DIR)/gcpad_ctrl.vhd
work/gcpad_ctrl-c.o: $(RTL_DIR)/gcpad_ctrl-c.vhd \
                 work/gcpad_ctrl.o
	$(ANALYZE) $(RTL_DIR)/gcpad_ctrl-c.vhd

work/gcpad_basic.o: $(RTL_DIR)/gcpad_basic.vhd \
              work/gcpad_pack-p.o              \
              work/gcpad_ctrl.o                \
              work/gcpad_tx.o                  \
              work/gcpad_rx.o
	$(ANALYZE) $(RTL_DIR)/gcpad_basic.vhd
work/gcpad_basic-c.o: $(RTL_DIR)/gcpad_basic-c.vhd \
              work/gcpad_basic.o                   \
              work/gcpad_ctrl-c.o                  \
              work/gcpad_tx-c.o                    \
              work/gcpad_rx-c.o
	$(ANALYZE) $(RTL_DIR)/gcpad_basic-c.vhd

work/gcpad_full.o: $(RTL_DIR)/gcpad_full.vhd \
              work/gcpad_pack-p.o            \
              work/gcpad_ctrl.o              \
              work/gcpad_tx.o                \
              work/gcpad_rx.o
	$(ANALYZE) $(RTL_DIR)/gcpad_full.vhd
work/gcpad_full-c.o: $(RTL_DIR)/gcpad_full-c.vhd \
              work/gcpad_full.o                  \
              work/gcpad_ctrl-c.o                \
              work/gcpad_tx-c.o                  \
              work/gcpad_rx-c.o
	$(ANALYZE) $(RTL_DIR)/gcpad_full-c.vhd

work/gcpad_comp-p.o: $(RTL_DIR)/gcpad_comp-p.vhd
	$(ANALYZE) $(RTL_DIR)/gcpad_comp-p.vhd

work/gcpad_mod.o: $(BENCH_DIR)/gcpad_mod.vhd
	$(ANALYZE) $(BENCH_DIR)/gcpad_mod.vhd
work/gcpad_mod-c.o: $(BENCH_DIR)/gcpad_mod-c.vhd \
                    work/gcpad_mod.o
	$(ANALYZE) $(BENCH_DIR)/gcpad_mod-c.vhd

work/tb.o: $(BENCH_DIR)/tb.vhd \
           work/gcpad_pack-p.o \
           work/gcpad_comp-p.o \
           work/gcpad_basic.o  \
           work/gcpad_full.o   \
           work/gcpad_mod.o
	$(ANALYZE) $(BENCH_DIR)/tb.vhd
work/tb-c.o: $(BENCH_DIR)/tb-c.vhd \
             work/tb.o             \
             work/gcpad_basic-c.o  \
             work/gcpad_full-c.o   \
             work/gcpad_mod-c.o
	$(ANALYZE) $(BENCH_DIR)/tb-c.vhd


.PHONY: elaborate
elaborate: tb_behav_c0

tb_behav_c0: analyze
	$(ELABORATE) tb_behav_c0; \
	strip tb_behav_c0

.PHONY: analyze
analyze: work/tb-c.o

.PHONY: clean
clean:
	rm -rf work tb_behav_c0 *~
