# Copyright 2015, Jürgen Defurne
#
# This file is part of the Experimental Unstable CPU System.
#
# The Experimental Unstable CPU System Is free software: you can redistribute
# it and/or modify it under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# The Experimental Unstable CPU System is distributed in the hope that it will
# be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with Experimental Unstable CPU System. If not, see
# http://www.gnu.org/licenses/lgpl.txt.

FIND=gfind
XARGS=gxargs
UNISIM=/usr/local/share
SOURCE= ../src/util/file/arrayio.vhdl \
	../src/components/components.vhdl \
	../src/components/multiplexer/MUX.vhdl \
	../src/components/BRAM/RAM.vhdl \
	../src/components/ALU/alu2.vhdl \
	../src/components/ALU/logic.vhdl \
	../src/components/ALU/shift.vhdl \
	../src/components/ALU/summation.vhdl \
	../src/components/data_reg.vhdl \
	../src/components/incr.vhdl \
	../src/components/regf.vhdl \
	../src/components/zerof.vhdl \
	../src/system/controllers.vhdl \
	../src/system/uctrl.vhdl \
	../src/system/system.vhdl \
	../src/system/decoder.vhdl \
	../src/io/gpio_in.vhdl \
	../src/io/gpio_out.vhdl \
	../tb/startup_sim.vhdl

unisim: unisim-obj93.cf
	ghdl -a --ieee=synopsys --work=unisim --workdir=tmp $(UNISIM)/unisims/*.vhd
	$(FIND) $(UNISIM)/unisims/primitive/*.vhd -print0 | $(XARGS) -0 -n 1 -t ghdl -a --ieee=synopsys --work=unisim --workdir=tmp -fexplicit

unisim-obj93.cf:

analyse:
	ghdl -a -P./. -P./tmp --ieee=synopsys --workdir=tmp $(SOURCE)

build: unisim-obj93.cf analyse
	ghdl -e -g -P./. -P./tmp --warn-unused --ieee=synopsys --workdir=tmp startup_sim

run: build
	ghdl -r -P. -P./tmp --ieee=synopsys --workdir=tmp startup_sim --wave=startup_sim.ghw --stop-time=300ns

clean:
	-rm *.o
	-rm unisim*

init: cp_init

cp_init:
	cp uctrl-init.vhdl uctrl.vhdl

main: cp_main

cp_main:
	cp uctrl-main.vhdl uctrl.vhdl

test: cp_test

cp_test:
	cp test/$(INST).txt input_data.txt

# vim:set noet tw=0 ts=8 nowrap:
