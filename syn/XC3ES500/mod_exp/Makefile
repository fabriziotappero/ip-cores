PROJECT=mont-exp

RM=/bin/rm -rf
CP=/bin/cp

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
	$(RM) "./out/"
	$(RM) "./log/"

clean_postgen:
	$(RM) "./_xmsgs"
	$(RM) "./_ngo"
	$(RM) "./xlnx_auto_0_xdb"
	$(RM) "./xst"
	$(RM) *_vhdl.prj *.bgn *.bld *.csv *.drc *.lso *.map *.mrp *.ncd *.ngc *.ngd *.ngm *.ngr *.pad *.par *.pcf *.ptwx *.syr *.twr *.twx *.unroutes *.xpi *.xwbt

synthesize: clean
	mkdir "./xst"
	mkdir "./xst/projnav.tmp"
	mkdir "./out/"
	mkdir "./log/"

	$(XST_DIR) -intstyle ise -ifn "./ModExp$(word).xst" -ofn "./ModExp.syr"

translate: synthesize
	$(NGDBUILD_DIR) -intstyle ise -dd _ngo -sd "../../../rtl/vhdl/mod_exp/blockMemory$(word)" -nt timestamp -i -p $(PLATFORM) "ModExp.ngc" ModExp.ngd

map: translate
	$(MAP) -intstyle ise -p $(PLATFORM) -cm area -ir off -pr off -c 100 -o ModExp_map.ncd ModExp.ngd ModExp.pcf

par: map
	$(PAR) -w -intstyle ise -ol high -t 1 ModExp_map.ncd ModExp.ncd ModExp.pcf

trce: par
	$(TRCE) -intstyle ise -v 3 -s 4 -n 3 -fastpaths -xml ModExp.twx ModExp.ncd -o ModExp.twr ModExp.pcf

bitgen: trce
	$(BITGEN) -intstyle ise -f ModExp.ut ModExp.ncd

postgen:
	mv *.log ./log
	mv *.xrpt ./log
	mv *.txt ./log
	mv *.xml ./log
	mv *.html ./log
	mv *.bit ./out