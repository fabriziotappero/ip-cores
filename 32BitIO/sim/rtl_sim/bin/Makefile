PROJECT=present-pure

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

PresentEncTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./PresentEncTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o PresentEncTB_isim_beh.exe -prj ./PresentEncTB_beh.prj work.PresentEncTB

run_PresentEncTB: exports PresentEncTB
	"./PresentEncTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "PresentEncTB_isim_beh.wdb"

keyupdTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./keyupdTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o keyupdTB_isim_beh.exe -prj ./keyupdTB_beh.prj work.keyupdTB

run_keyupdTB: exports keyupdTB	
	"./keyupdTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "keyupdTB_isim_beh.wdb"

sLayerTB: 
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./sLayerTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o sLayerTB_isim_beh.exe -prj ./sLayerTB_beh.prj work.sLayerTB

run_sLayerTB: exports sLayerTB	
	"./sLayerTB_isim_beh.exe" -intstyle ise -gui -tclbatch isim.cmd  -wdb "sLayerTB_isim_beh.wdb"