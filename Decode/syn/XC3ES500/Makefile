PROJECT=present-decode

RM=rm -rf

PLATFORM=xc3s500e-fg320-5

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
	$(XST_DIR) -intstyle ise -ifn "./PresentFullDecoder.xst" -ofn "./PresentFullDecoder.syr"

translate: synthesize
	$(NGDBUILD_DIR) -intstyle ise -dd _ngo -nt timestamp -i -p $(PLATFORM) "PresentFullDecoder.ngc" PresentFullDecoder.ngd

map: translate
	$(MAP) -intstyle ise -p $(PLATFORM) -cm area -ir off -pr off -c 100 -o PresentFullDecoder_map.ncd PresentFullDecoder.ngd PresentFullDecoder.pcf

par: map
	$(PAR) -w -intstyle ise -pl std -rl std -t 1 PresentFullDecoder_map.ncd PresentFullDecoder.ncd PresentFullDecoder.pcf

trce: par
	$(TRCE) -intstyle ise -v 3 -s 5 -n 3 -fastpaths -xml PresentFullDecoder.twx PresentFullDecoder.ncd -o PresentFullDecoder.twr PresentFullDecoder.pcf

bitgen: par
	$(BITGEN) -intstyle ise -f PresentFullDecoder.ut PresentFullDecoder.ncd

postgen:
	mv *.bit ./out
	mv *.xrpt ./log
	mv *.txt ./log
	mv *.xml ./log
	mv *.html ./log