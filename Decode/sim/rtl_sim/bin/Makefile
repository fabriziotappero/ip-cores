PROJECT=present-decode

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

PresentDecTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./PresentDecTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o PresentDecTB_isim_beh.exe -prj ./PresentDecTB_beh.prj work.PresentDecTB

run_PresentDecTB: exports PresentDecTB	
	"./PresentDecTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "PresentDecTB_isim_beh.wdb"

keyupd_invTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./keyupd_invTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o keyupd_invTB_isim_beh.exe -prj ./keyupd_invTB_beh.prj work.keyupd_invTB

run_keyupd_invTB: exports keyupd_invTB	
	"./keyupd_invTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "keyupd_invTB_isim_beh.wdb"

sLayer_invTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./sLayer_invTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o sLayer_invTB_isim_beh.exe -prj ./sLayer_invTB_beh.prj work.sLayer_invTB

run_sLayer_invTB: exports sLayer_invTB	
	"./sLayer_invTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "sLayer_invTB_isim_beh.wdb"
	
PresentFullDecoderTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./PresentFullDecoderTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o PresentFullDecoderTB_isim_beh.exe -prj ./PresentFullDecoderTB_beh.prj work.PresentFullDecoderTB

run_PresentFullDecoderTB: exports PresentFullDecoderTB	
	"./PresentFullDecoderTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "PresentFullDecoderTB_isim_beh.wdb"
	
PresentKeyGenTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./PresentKeyGenTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o PresentKeyGenTB_isim_beh.exe -prj ./PresentKeyGenTB_beh.prj work.PresentKeyGenTB

run_PresentKeyGenTB: exports PresentKeyGenTB	
	"./PresentKeyGenTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "PresentKeyGenTB_isim_beh.wdb"