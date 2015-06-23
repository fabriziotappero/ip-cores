#
#	Makefile for ModelSim simulation
#


LEROSDIR=../vhdl
#OPTIONS=-93 -quiet -check_synthesis -lint -pedanticerrors
OPTIONS=-93 -quiet

ifeq ($(WINDIR),)
	WINE=wine
	S=:
else
	WINE=
	S=\;
endif

all: clean base
	$(WINE) vcom $(OPTIONS) $(LEROSDIR)/simulation/tb_leros.vhd
	$(WINE) vsim -do sim.do tb_leros

base:
	$(WINE) vlib work
	$(WINE) vcom $(OPTIONS) $(LEROSDIR)/core/leros_types.vhd
	$(WINE) vcom $(OPTIONS) $(LEROSDIR)/generated/leros_rom.vhd
	$(WINE) vcom $(OPTIONS) $(LEROSDIR)/core/leros_im.vhd
	$(WINE) vcom $(OPTIONS) $(LEROSDIR)/core/leros_decode.vhd
	$(WINE) vcom $(OPTIONS) $(LEROSDIR)/core/leros_fedec.vhd
	$(WINE) vcom $(OPTIONS) $(LEROSDIR)/core/leros_ex.vhd
	$(WINE) vcom $(OPTIONS) $(LEROSDIR)/core/leros.vhd
clean:
	-rm *.wlf

