PROJECT=present-pure-testing

RM=rm -rf

PLATFORM=xc3s500e-fg320-5

XILINX_DIR="D:/Programy/Xilinx/14.2/ISE_DS/ISE/bin/nt64/"
FUSE=$(XILINX_DIR)"fuse.exe"
VHPCOMP=$(XILINX_DIR)"vhpcomp.exe"

clean: 
	$(RM) ./isim
	$(RM) ./isim.wdb
	$(RM) *.log 
	$(RM) *.xmsgs
	$(RM) ./fuseRelaunch.cmd 
	$(RM) *.exe
	
exports:
	export DISPLAY=:0
	export XILINX=D:/Programy/Xilinx/14.2/ISE_DS/ISE
	export SYSOP=nt64
	export PATH=${XILINX}/bin/${SYSOP}
	export LD_LIBRARY_PATH=${XILINX}/lib/${SYSOP}
	
PresentCommTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./PresentCommTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o PresentCommTB_isim_beh.exe -prj ./PresentCommTB_beh.prj work.PresentCommTB

run_PresentCommTB: exports PresentCommTB
	"./PresentCommTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "PresentCommTB_isim_beh.wdb"

PresentTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./PresentTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o PresentTB_isim_beh.exe -prj ./PresentTB_beh.prj work.PresentTB

run_PresentTB: exports PresentTB	
	"./PresentTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "PresentTB_isim_beh.wdb"

keyupdTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./keyupdTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o keyupdTB_isim_beh.exe -prj ./keyupdTB_beh.prj work.keyupdTB

run_keyupdTB: exports keyupdTB	
	"./keyupdTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "keyupdTB_isim_beh.wdb"

ShiftRegTB:
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./ShiftRegTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o ShiftRegTB_isim_beh.exe -prj ./ShiftRegTB_beh.prj work.ShiftRegTB

run_ShiftRegTB: exports ShiftRegTB
	"./ShiftRegTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "ShiftRegTB_isim_beh.wdb"

sLayerTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./sLayerTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o sLayerTB_isim_beh.exe -prj ./sLayerTB_beh.prj work.sLayerTB

run_sLayerTB: exports sLayerTB	
	"./sLayerTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "sLayerTB_isim_beh.wdb"