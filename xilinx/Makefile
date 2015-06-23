#------------------------------------------------------------------------------#
# Xilinx Makefile                                                              #
#------------------------------------------------------------------------------#
# Copyright (C) 2012 Mathias Hoertnagl, mathias.hoertnagl@gmail.com            #
#                                                                              #
# This program is free software; you can redistribute it and/or modify it      #
# under the terms of the GNU General Public License as published by the Free   #
# Software Foundation; either version 3 of the License, or (at your option)    #
# any later version.                                                           #
# This program is distributed in the hope that it will be useful, but WITHOUT  #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for     #
# more details.                                                                #
# You should have received a copy of the GNU General Public License along with #
# this program; if not, see <http://www.gnu.org/licenses/>.                    #
#------------------------------------------------------------------------------#
TOOL_DIR = /cygdrive/c/Xilinx/13.1/ISE_DS/ISE/bin/nt/

XST = $(TOOL_DIR)xst.exe
NGDBUILD = $(TOOL_DIR)ngdbuild.exe
MAP = $(TOOL_DIR)map.exe
PAR = $(TOOL_DIR)par.exe
TRCE = $(TOOL_DIR)trce.exe
BITGEN = $(TOOL_DIR)bitgen.exe
IMPACT = $(TOOL_DIR)impact.exe

upload : layer2.bit
	$(IMPACT) -batch upload.cmds

prom : layer2.bit  
	$(IMPACT) -batch prom.cmds
   
build : 
	-@mkdir xst
	-@mkdir xst/projnav.tmp
	$(XST) -ifn layer2.xst -ofn layer2.syr -intstyle ise
	$(NGDBUILD) -intstyle ise -dd ngdbuild -nt timestamp -uc layer2.ucf \
		-p xc3s500e-fg320-4 layer2.ngc layer2.ngd 
	$(MAP) -intstyle ise -p xc3s500e-fg320-4 -cm area -ir off -pr off -c 100 \
		-o layer2_map.ncd layer2.ngd layer2.pcf 
	$(PAR) -w -intstyle ise -ol high -t 1 layer2_map.ncd layer2.ncd layer2.pcf 
	$(TRCE) -intstyle ise -v 3 -s 4 -n 3 -fastpaths -xml layer2.twx layer2.ncd \
		-o layer2.twr layer2.pcf -ucf layer2.ucf 
	$(BITGEN) -intstyle ise -f layer2.ut layer2.ncd 

.PHONY: clean
clean :
	-@$(RM) *.bgn *.bld *.drc *.cmd_log *.lso *.ncd *.ngc *.ngd *.ngr *.pad \
		*.par *.pcf *.ptwx *.stx *.syr *.twr *.twx *.unroutes *.xpi *.xwbt \
		*.map *.mrp *.xrpt *.csv *.txt *.xml *.html *.log *.ngm *.prm *.cfi *.sig