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

upload : etherlab.bit
	$(IMPACT) -batch upload.cmds
   
build : 
	-@mkdir xst
	-@mkdir xst/projnav.tmp
	$(XST) -ifn etherlab.xst -ofn etherlab.syr -intstyle ise
	$(NGDBUILD) -intstyle ise -dd ngdbuild -nt timestamp -uc etherlab.ucf \
		-p xc3s500e-fg320-4 etherlab.ngc etherlab.ngd 
	$(MAP) -intstyle ise -p xc3s500e-fg320-4 -cm area -ir off -pr off -c 100 \
		-o etherlab_map.ncd etherlab.ngd etherlab.pcf 
	$(PAR) -w -intstyle ise -ol high -t 1 etherlab_map.ncd etherlab.ncd etherlab.pcf 
	$(TRCE) -intstyle ise -v 3 -s 4 -n 3 -fastpaths -xml etherlab.twx etherlab.ncd \
		-o etherlab.twr etherlab.pcf -ucf etherlab.ucf 
	$(BITGEN) -intstyle ise -f etherlab.ut etherlab.ncd 

.PHONY: clean
clean :
	-@$(RM) *.bgn *.bld *.drc *.cmd_log *.lso *.ncd *.ngc *.ngd *.ngr *.pad \
		*.par *.pcf *.ptwx *.stx *.syr *.twr *.twx *.unroutes *.xpi *.xwbt \
		*.map *.mrp *.xrpt *.csv *.txt *.xml *.html *.log *.ngm *.prm *.cfi *.sig