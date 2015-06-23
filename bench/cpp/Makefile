############################################################################
##
## Filename: 	Makefile
##
## Project:	A Doubletime Pipelined FFT
##
## Purpose:	This programs the build process for the test benches
##		associated with the double clocked FFT project.  These
##		test benches are designed for the size and arguments of the
##		FFT as given by the Makefile in the trunk/sw directory, 
##		although they shouldn't be too difficult to modify for
##		other FFT parameters.
##
##		Please note that running these test benches requires access
##		to the *cmem_*.hex files found in trunk/sw/fft-core.  I
##		usually soft link them into this directory, but such linking
##		is not currently part of this makefile or the build scripts.
##
## Creator:	Dan Gisselquist, Ph.D.
##		Gisselquist Tecnology, LLC
##
##########################################################################/
##
## Copyright (C) 2015, Gisselquist Technology, LLC
##
## This program is free software (firmware): you can redistribute it and/or
## modify it under the terms of  the GNU General Public License as published
## by the Free Software Foundation, either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
## FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
## for more details.
##
## You should have received a copy of the GNU General Public License along
## with this program.  (It's in the $(ROOT)/doc directory, run make with no
## target there if the PDF file isn't present.)  If not, see
## <http:##www.gnu.org/licenses/> for a copy.
##
## License:	GPL, v3, as defined and found on www.gnu.org,
##		http:##www.gnu.org/licenses/gpl.html
##
##
##########################################################################/
all: mpy_tb dblrev_tb dblstage_tb qtrstage_tb fft_tb test

OBJDR:= ../../sw/fft-core/obj_dir
VSRCD = ../../sw/fft-core
TBODR:= ../rtl/obj_dir
VINC := -I/usr/share/verilator/include -I$(OBJDR)/ -I$(TBODR)/
MPYLB:= $(OBJDR)/Vshiftaddmpy__ALL.a
DBLRV:= $(OBJDR)/Vdblreverse__ALL.a
DBLSG:= $(OBJDR)/Vdblstage__ALL.a
QTRSG:= $(OBJDR)/Vqtrstage__ALL.a
BFLYL:= $(OBJDR)/Vbutterfly__ALL.a
HWBFY:= $(OBJDR)/Vhwbfly__ALL.a
FFTLB:= $(OBJDR)/Vfftmain__ALL.a
IFTLB:= $(TBODR)/Vifft_tb__ALL.a
STGLB:= $(OBJDR)/Vfftstage_o2048__ALL.a
VERILATOR_ROOT := /usr/share/verilator

mpy_tb: mpy_tb.cpp $(MPYLB)
	g++ -g $(VINC) $< $(MPYLB) $(VERILATOR_ROOT)/include/verilated.cpp -o $@

dblrev_tb: dblrev_tb.cpp twoc.cpp twoc.h $(DBLRV)
	g++ -g $(VINC) $< twoc.cpp $(DBLRV) $(VERILATOR_ROOT)/include/verilated.cpp -o $@

dblstage_tb: dblstage_tb.cpp twoc.cpp twoc.h $(DBLSG)
	g++ -g $(VINC) $< twoc.cpp $(DBLSG) $(VERILATOR_ROOT)/include/verilated.cpp -o $@

qtrstage_tb: qtrstage_tb.cpp twoc.cpp twoc.h $(QTRSG)
	g++ -g $(VINC) $< twoc.cpp $(QTRSG) $(VERILATOR_ROOT)/include/verilated.cpp -o $@

butterfly_tb: butterfly_tb.cpp twoc.cpp twoc.h $(BFLYL)
	g++ -g $(VINC) $< twoc.cpp $(BFLYL) $(VERILATOR_ROOT)/include/verilated.cpp -o $@

hwbfly_tb: hwbfly_tb.cpp twoc.cpp twoc.h $(HWBFY)
	g++ -g $(VINC) $< twoc.cpp $(HWBFY) $(VERILATOR_ROOT)/include/verilated.cpp -o $@

fftstage_o2048_tb: fftstage_o2048_tb.cpp twoc.cpp twoc.h $(STGLB)
	g++ -g $(VINC) $< twoc.cpp $(STGLB) $(VERILATOR_ROOT)/include/verilated.cpp -o $@

fft_tb: fft_tb.cpp twoc.cpp twoc.h $(FFTLB)
	g++ -g $(VINC) $< twoc.cpp $(FFTLB) $(VERILATOR_ROOT)/include/verilated.cpp -lfftw3 -o $@

ifft_tb: ifft_tb.cpp twoc.cpp twoc.h $(IFTLB)
	g++ -g $(VINC) $< twoc.cpp $(IFTLB) $(VERILATOR_ROOT)/include/verilated.cpp -lfftw3 -o $@

.PHONY: HEX
# HEX:	 cmem_e2048.hex  cmem_e1024.hex  cmem_e512.hex  cmem_e256.hex 
# HEX:	 cmem_o2048.hex  cmem_o1024.hex  cmem_o512.hex  cmem_o256.hex 
# HEX:	icmem_e2048.hex icmem_e1024.hex icmem_e512.hex icmem_e256.hex 
# HEX:	icmem_o2048.hex icmem_o1024.hex icmem_o512.hex icmem_o256.hex 
# HEX:	 cmem_e128.hex  cmem_e64.hex  cmem_e32.hex  cmem_e16.hex  cmem_e8.hex
# HEX:	 cmem_o128.hex  cmem_o64.hex  cmem_o32.hex  cmem_o16.hex  cmem_o8.hex
# HEX:	icmem_e128.hex icmem_e64.hex icmem_e32.hex icmem_e16.hex icmem_e8.hex
# HEX:	icmem_o128.hex icmem_o64.hex icmem_o32.hex icmem_o16.hex icmem_o8.hex
# cmem_%.hex: $(VSRCD)/cmem_%.hex
	# echo ln -s $* $<
HEX:
	ln -s $(VSRCD)/*.hex .

.PHONY: test
test: mpy_tb dblrev_tb dblstage_tb qtrstage_tb butterfly_tb fftstage_o2048_tb
test: fft_tb ifft_tb hwbfly_tb
	./mpy_tb
	./dblrev_tb
	./dblstage_tb
	./qtrstage_tb
	./butterfly_tb
	./hwbfly_tb
	./fftstage_o2048_tb
	./fft_tb
	./ifft_tb

.PHONY: clean
clean:
	rm -f mpy_tb dblrev_tb dblstage_tb qtrstage_tb butterfly_tb
	rm -f fftstage_o2048_tb fft_tb ifft_tb hwbfly_tb
	rm -rf fft_tb.dbl ifft_tb.dbl
	rm -rf *cmem_*.hex

include $(VERILATOR_ROOT)/include/verilated.mk
