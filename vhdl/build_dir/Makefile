# Makefile for Plasma on the s3Esk
# For Linux development environment using free GHDL simulator and
# Xilinx synthesis tools.
# Derives from the DDRSDRAM-on-s3Esk makefile
#
# This makefile was created by me, Dan Clemmensen. I hereby place it in
# the public domain, releasing any rights. I retain the right to re-use
# this work as the basis for a derived work.
#
# Use GHDL for simulation, and then use the Xilinx tools in batch mode for
# synthesis and download. 
# Before you use this makefile for the first time, you will need to build 
# the plasma tools.  After that, you can do the rest of the development 
# using this makefile, unless you change a tool.
# Place this makefile and the associated ISE_scripts directory in a 
# subdirectory of the VHDL directory.  We use this approach because the Xilinx
# tools create a large number of temporary files in the working directory.
#
# Usage:
# make clean    # removes derived files and directories 
# make load     # builds everthing from scratch and 
#               #   loads the flash mem on the target
# make simtest  # builds and runs as a GHDL simulation
# make view     # displays the results of the simulation

# To help isolate problems, you may run a series of steps instead of the whole
# "make load." Look below to see them.

# VHDL_DIR is the top-level VHDL directory for Plasma. 
VHDL_DIR = ..
# PROJ_VHDL comprises files used in both the actual target and the sim
PROJ_VHDL = \
      $(VHDL_DIR)/mlite_pack.vhd \
      $(VHDL_DIR)/plasma_3e.vhd \
      $(VHDL_DIR)/ddr_ctrl.vhd \
      $(VHDL_DIR)/plasma.vhd \
      generated/ram_image.vhd \
      $(VHDL_DIR)/uart.vhd \
      $(VHDL_DIR)/eth_dma.vhd \
      $(VHDL_DIR)/mlite_cpu.vhd \
      $(VHDL_DIR)/alu.vhd \
      $(VHDL_DIR)/bus_mux.vhd \
      $(VHDL_DIR)/control.vhd \
      $(VHDL_DIR)/mem_ctrl.vhd \
      $(VHDL_DIR)/mult.vhd \
      $(VHDL_DIR)/pipeline.vhd \
      $(VHDL_DIR)/pc_next.vhd \
      $(VHDL_DIR)/reg_bank.vhd \
      $(VHDL_DIR)/shifter.vhd \
      $(VHDL_DIR)/cache.vhd

# TARGET_VHDL comprises files used on the target but not in sim
TARGET_VHDL =

# SIM_VHDL comprises files used in sim but not on the target
# for this  sim, these simulate the rest of the S3Esk board
SIM_DIR = $(VHDL_DIR)/simulation
SIM_VHDL = \
      $(VHDL_DIR)/mt46v16m16.vhd \
      $(VHDL_DIR)/tbench.vhd

SIM_TOP = tbench
GCC_PARAMS=

OBJS = $(VHDL:.vhd=.o)

# GHDL config
OBJDIR = obj
ISE_DIR=/opt/Xilinx/11.1/ISE
GHDL_LIBS = $(ISE_DIR)/ghdl/unisim
GHDL_FLAGS = --ieee=synopsys -fexplicit -P$(GHDL_LIBS)
GHDL_FLAGS += --workdir=$(OBJDIR) --warn-no-vital-generic

%.o: %.vhd
	ghdl -a $(GHDL_FLAGS) $<

all: simtest

old:  workdir $(OBJS)

# invocation strings for helper tools to build Xilinx BRAM memory images.
TOOLS = ../../tools
# generate the ram_image.vhd
generated: 
	rm -rf generated
	mkdir generated
	$(TOOLS)/ram_image.exe $(VHDL_DIR)/ram_xilinx.vhd $(TOOLS)/code.txt generated/ram_image.vhd

NAME=main
workdir:
	mkdir -p $(OBJDIR)

clean:
	rm -rf *.o *.cf $(OBJDIR) tb *.vcd main $(SIM_TOP) *.ghw
	rm -f *.bit *.bgn *_pad.txt *_pad.csv *.xpi *.srp *.ngc *.par
	rm -f *.lst *.ngd *.ngm *.pcf *.mrp *.unroutes *.pad
	rm -f *.bld *.ncd *.twr *.drc
	rm -rf xst $(NAME).prj
	rm -rf generated

simtest: workdir generated
	ghdl -i $(GHDL_FLAGS) $(PROJ_VHDL) $(SIM_VHDL)
	ghdl -m $(GHDL_FLAGS) $(SIM_TOP)
sim:
	ghdl -r $(SIM_TOP) --stop-time=10ms --wave=generated/out.ghw 2> /dev/null

view:
	gtkwave generated/out.ghw view.sav

#Xilinx ISE actions. Uses a wrapper script named "xilinx" to run the ISE batch commands

# create an ISE project file from the list of VHDL files
$(NAME).prj: $(PROJ_VHDL) $(TARGET_VHDL)
	echo $(PROJ_VHDL) $(TARGET_VHDL)|tr " " "\n">$(NAME).prj

bitfile:  generated step0 step1 step2 step3 step4 step5

step0: $(NAME).prj 
	xilinx xst -ifn ISE_scripts/$(NAME).scrs -ofn $(NAME).srp
step1:
	xilinx ngdbuild -nt on -uc ../spartan3e.ucf $(NAME).ngc $(NAME).ngd
step2:
	xilinx map -pr b $(NAME).ngd -o $(NAME).ncd $(NAME).pcf
step3:
	xilinx par -w -ol high $(NAME).ncd $(NAME).ncd $(NAME).pcf
step4:
	xilinx trce -v 10 -o $(NAME).twr $(NAME).ncd $(NAME).pcf
step5:
	xilinx bitgen $(NAME).ncd generated/$(NAME).bit -w #-f $(NAME).ut

generated/main.bit: bitfile

mcs:  generated/main.bit
	xilinx impact -batch ISE_scripts/makeprom.cmds

generated/main.mcs: mcs

load: generated/main.mcs
	xilinx impact -batch ISE_scripts/loadprom.cmds

impact:
	xilinx impact
ise: $(NAME).prj
	xilinx ise
