
TOPLEVEL_LANG ?= verilog
PWD=$(shell pwd)
TOPDIR=$(PWD)/..
COCOTB=/home/cospan/Projects/cocotb
PYTHONPATH := ./model:$(PYTHONPATH)
export PYTHONPATH


EXTRA_ARGS+=-I$(TOPDIR)/rtl/

VERILOG_SOURCES =  $(TOPDIR)/sim/test_in.v
VERILOG_SOURCES += $(TOPDIR)/sim/test_out.v

VERILOG_SOURCES += $(TOPDIR)/sim/hd_data_writer.v
VERILOG_SOURCES += $(TOPDIR)/sim/hd_data_reader.v


VERILOG_SOURCES += $(TOPDIR)/rtl/generic/blk_mem.v
VERILOG_SOURCES += $(TOPDIR)/rtl/generic/cross_clock_enable.v
VERILOG_SOURCES += $(TOPDIR)/rtl/generic/debounce.v
VERILOG_SOURCES += $(TOPDIR)/rtl/generic/ppfifo.v
VERILOG_SOURCES += $(TOPDIR)/rtl/link/cont_controller.v
VERILOG_SOURCES += $(TOPDIR)/rtl/link/crc.v
VERILOG_SOURCES += $(TOPDIR)/rtl/link/sata_link_layer.v
VERILOG_SOURCES += $(TOPDIR)/rtl/link/sata_link_layer_read.v
VERILOG_SOURCES += $(TOPDIR)/rtl/link/sata_link_layer_write.v
VERILOG_SOURCES += $(TOPDIR)/rtl/link/scrambler.v
VERILOG_SOURCES += $(TOPDIR)/rtl/phy/oob_controller.v
VERILOG_SOURCES += $(TOPDIR)/rtl/phy/sata_phy_layer.v
VERILOG_SOURCES += $(TOPDIR)/rtl/transport/sata_transport_layer.v
VERILOG_SOURCES += $(TOPDIR)/rtl/command/sata_command_layer.v
VERILOG_SOURCES += $(TOPDIR)/rtl/sata_stack.v

VERILOG_SOURCES += $(TOPDIR)/sim/faux_sata_hd_phy.v
VERILOG_SOURCES += $(TOPDIR)/sim/faux_sata_hd_transport.v
VERILOG_SOURCES += $(TOPDIR)/sim/faux_sata_hd_command_layer.v
VERILOG_SOURCES += $(TOPDIR)/sim/faux_sata_hd.v

VERILOG_SOURCES += $(TOPDIR)/sim/tb_cocotb.v


TOPLEVEL = tb_cocotb

GPI_IMPL := vpi

export TOPLEVEL_LANG
MODULE=test_sata

include $(COCOTB)/makefiles/Makefile.inc
include $(COCOTB)/makefiles/Makefile.sim

wave:
	gtkwave waveforms.gtkw &
