all: ifft_tb
############################################################################
##
## Filename: 	Makefile
##
## Project:	A Doubletime Pipelined FFT
##
## Purpose:	This programs the build process for part of the ifft_tb test
##		bench associated with the double clocked FFT project.
##
##		This is only part of the test bench program.  This one is
##		different from the others, in that the ifft_tb includes
##		both verilator code in the test bench as well as the
##		C++ code.  The C++ code will depend upon the verilog
##		code found in this directory and built here.
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

OBJDR:= ../../sw/fft-core/obj_dir
VSRCD:= ../../sw/fft-core
LCLDR:= obj_dir
VINC := -I/usr/share/verilator/include -I$(OBJDR)/ -I$(LCLDR)/
IFTLB:= $(LCLDR)/Vifft_tb__ALL.a
VERILATOR_ROOT := /usr/share/verilator

.PHONY: ifft_tb
ifft_tb: $(IFTLB)

$(IFTLB): $(LCLDR)/Vifft_tb.cpp
	cd $(LCLDR); make -f Vifft_tb.mk
$(LCLDR)/Vifft_tb.cpp: ifft_tb.v $(VSRCD)/fftmain.v $(VSRCD)/ifftmain.v
	verilator -y $(VSRCD) -cc ifft_tb.v

.PHONY: clean
clean:
	rm -rf $(LCLDR)

-include $(VERILATOR_ROOT)/include/verilated.mk
