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

work/snespad_pack-p.o: $(RTL_DIR)/snespad_pack-p.vhd
	$(ANALYZE) $(RTL_DIR)/snespad_pack-p.vhd

work/snespad_ctrl.o: $(RTL_DIR)/snespad_ctrl.vhd \
                     work/snespad_pack-p.o
	$(ANALYZE) $(RTL_DIR)/snespad_ctrl.vhd
work/snespad_ctrl-c.o: $(RTL_DIR)/snespad_ctrl-c.vhd \
                       work/snespad_ctrl.o
	$(ANALYZE) $(RTL_DIR)/snespad_ctrl-c.vhd

work/snespad_pad.o: $(RTL_DIR)/snespad_pad.vhd \
                    work/snespad_pack-p.o
	$(ANALYZE) $(RTL_DIR)/snespad_pad.vhd
work/snespad_pad-c.o: $(RTL_DIR)/snespad_pad-c.vhd  \
                      work/snespad_pad.o
	$(ANALYZE) $(RTL_DIR)/snespad_pad-c.vhd

work/snespad.o: $(RTL_DIR)/snespad.vhd \
                work/snespad_pack-p.o  \
                work/snespad_ctrl.o    \
                work/snespad_pad.o
	$(ANALYZE) $(RTL_DIR)/snespad.vhd
work/snespad-c.o: $(RTL_DIR)/snespad-c.vhd \
                  work/snespad.o           \
                  work/snespad_ctrl-c.o    \
                  work/snespad_pad-c.o
	$(ANALYZE) $(RTL_DIR)/snespad-c.vhd

work/snespad_comp-pack.o: $(RTL_DIR)/snespad_comp-pack.vhd
	$(ANALYZE) $(RTL_DIR)/snespad_comp-pack.vhd

work/tb.o: $(BENCH_DIR)/tb.vhd      \
           work/snespad_comp-pack.o \
           work/snespad.o
	$(ANALYZE) $(BENCH_DIR)/tb.vhd
work/tb-c.o: $(BENCH_DIR)/tb-c.vhd \
             work/tb.o             \
             work/snespad-c.o
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
