PROJECT=present-pure-testing

RM=rm -rf

PLATFORM=xc3s500e-fg320-5
UCF="../../rtl/vhdl/PresentCommImpl.ucf"

XILINX_DIR="D:/Programy/Xilinx/14.2/ISE_DS/ISE/bin/nt64/"
XST_DIR=$(XILINX_DIR)"xst.exe"
NGDBUILD_DIR=$(XILINX_DIR)"ngdbuild.exe"
MAP=$(XILINX_DIR)"map.exe"
PAR=$(XILINX_DIR)"par.exe"
TRCE=$(XILINX_DIR)"trce.exe"
BITGEN=$(XILINX_DIR)"bitgen.exe"

clean: clean_postgen
	$(RM) "./out/"*.*
	$(RM) "./log/"*.* 

clean_postgen:
	$(RM) "./_xmsgs"
	$(RM) "./_ngo"
	$(RM) "./xlnx_auto_0_xdb"
	$(RM) "./xst"
	$(RM) *_vhdl.prj *.bgn *.bld *.csv *.drc *.lso *.map *.mrp *.ncd *.ngc *.ngd *.ngm *.ngr *.pad *.par *.pcf *.ptwx *.syr *.twr *.twx *.unroutes *.xpi *.xwbt

synthesize: clean
	mkdir "./xst"
	mkdir "./xst/projnav.tmp"
	$(XST_DIR) -intstyle ise -ifn "./PresentComm.xst" -ofn "./PresentComm.syr"

translate: synthesize
	$(NGDBUILD_DIR) -intstyle ise -dd _ngo -nt timestamp -uc $(UCF) -p $(PLATFORM) "PresentComm.ngc" PresentComm.ngd

map: translate
	$(MAP) -intstyle ise -p $(PLATFORM) -cm area -ir off -pr off -c 100 -o PresentComm_map.ncd PresentComm.ngd PresentComm.pcf

par: map
	$(PAR) -w -intstyle ise -pl std -rl std -t 1 PresentComm_map.ncd PresentComm.ncd PresentComm.pcf

trce: par
	$(TRCE) -intstyle ise -v 3 -s 5 -n 3 -fastpaths -xml PresentComm.twx PresentComm.ncd -o PresentComm.twr PresentComm.pcf -ucf $(UCF)

bitgen: par
	$(BITGEN) -intstyle ise -f PresentComm.ut PresentComm.ncd

postgen:
	mv *.bit ./out
	mv *.xrpt ./log
	mv *.txt ./log
	mv *.xml ./log
	mv *.html ./log