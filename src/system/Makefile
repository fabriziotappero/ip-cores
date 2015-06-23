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
SOURCE= ../VHDL/file/arrayio.vhdl \
	../VHDL/multiplexer/MUX.vhdl \
	../VHDL/blockram/RAM.vhdl \
	components.vhdl \
	controllers.vhdl \
	uctrl.vhdl \
	alu2.vhdl \
	system.vhdl \
	gpio_in.vhdl \
	gpio_out.vhdl \
	incr.vhdl \
	regf.vhdl \
	sync_reset.vhdl \
	zerof.vhdl \
	decoder.vhdl \
	system_sim.vhdl \
	startup_sim.vhdl \
	clock.vhdl \
	ipcore_dir/clock_core_gen.vhd \
	data_reg.vhdl

unisim: unisim-obj93.cf
	ghdl -a --ieee=synopsys --work=unisim $(UNISIM)/unisims/*.vhd
	$(FIND) $(UNISIM)/unisims/primitive/*.vhd -print0 | $(XARGS) -0 -n 1 -t ghdl -a --ieee=synopsys --work=unisim -fexplicit

unisim-obj93.cf:

analyse:
	ghdl -a -P. --ieee=synopsys $(SOURCE)

build: unisim-obj93.cf analyse
	ghdl -e -g -P. --warn-unused --ieee=synopsys startup_sim

run: build
	ghdl -r -P. startup_sim --wave=startup_sim.ghw --stop-time=2us

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

# vim:set noet tw=0 ts=8:
