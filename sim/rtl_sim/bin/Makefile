PROJECT=present-pure

RM=/bin/rm -rf

PLATFORM=xc3s500e-fg320-5

XILINX_DIR="D:/Programy/Xilinx/14.2/ISE_DS/ISE/bin/nt64/"
FUSE=$(XILINX_DIR)"unwrapped/fuse.exe"
VHPCOMP=$(XILINX_DIR)"vhpcomp.exe"
PATH=${XILINX}/bin/${SYSOP}:/cygdrive/D/Programy/Xilinx/14.2/ISE_DS/ISE/sysgen/bin/nt64/:/cygdrive/D/Programy/Xilinx/14.2/ISE_DS/ISE/lib/nt64/

clean: 
	$(RM) ./isim
	$(RM) ./isim.wdb
	$(RM) *.log 
	$(RM) *.xmsgs
	$(RM) ./fuseRelaunch.cmd 
	$(RM) *.exe
	$(RM) *.wdb
	
exports:
	export DISPLAY=:0
	export XILINX=D:/Programy/Xilinx/14.2/ISE_DS/ISE
	export SYSOP=nt64
	export PATH=${XILINX}/bin/${SYSOP}
	export LD_LIBRARY_PATH=${XILINX}/lib/${SYSOP}

ModMult32: exports
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./ModularMultiplierIterative32bitTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o ModularMultiplierIterative32bitTB_isim_beh.exe -prj ./ModularMultiplierIterative32bitTB_beh.prj work.ModularMultiplierIterative32bitTB 

run_ModMult32: exports ModMult32	
	"./ModularMultiplierIterative32bitTB_isim_beh.exe" -intstyle ise -tclbatch isim.cmd  -wdb "./ModularMultiplierIterative32bitTB_isim_beh.wdb"
	
ModMult64: exports
	$(FUSE) -intstyle ise -incremental -o ModularMultiplierIterative64bitTB_isim_beh.exe -prj ./ModularMultiplierIterative64bitTB_beh.prj work.ModularMultiplierIterative64bitTB 

run_ModMult64: exports ModMult64
	"./ModularMultiplierIterative64bitTB_isim_beh.exe" -intstyle ise -tclbatch isim.cmd  -wdb "ModularMultiplierIterative64bitTB_isim_beh.wdb"
	
ModMult512: exports
	$(FUSE) -intstyle ise -incremental -o ModularMultiplierIterative512bitTB_isim_beh.exe -prj ./ModularMultiplierIterative512bitTB_beh.prj work.ModularMultiplierIterative512bitTB 

run_ModMult512: exports ModMult512
	"./ModularMultiplierIterative512bitTB_isim_beh.exe" -intstyle ise -tclbatch isim.cmd  -wdb "ModularMultiplierIterative512bitTB_isim_beh.wdb"

ModExp32: exports
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./ModExp32bitTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o ModExp32bitTB_isim_beh.exe -prj ./ModExp32bitTB_beh.prj work.ModExp32bitTB 

run_ModExp32: exports ModExp32	
	"./ModExp32bitTB_isim_beh.exe" -intstyle ise -tclbatch isim.cmd  -wdb "./ModExp32bitTB_isim_beh.wdb"

ModExp64: exports
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./ModExp64bitTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o ModExp64bitTB_isim_beh.exe -prj ./ModExp64bitTB_beh.prj work.ModExp64bitTB 

run_ModExp64: exports ModExp64	
	"./ModExp64bitTB_isim_beh.exe" -intstyle ise -tclbatch isim.cmd  -wdb "./ModExp64bitTB_isim_beh.wdb"

ModExp512: exports
	$(VHPCOMP) -work isim_temp -intstyle ise -prj ./ModExp512bitTB_stx_beh.prj
	$(FUSE) -intstyle ise -incremental -o ModExp512bitTB_isim_beh.exe -prj ./ModExp512bitTB_beh.prj work.ModExp512bitTB 

run_ModExp512: exports ModExp512	
	"./ModExp512bitTB_isim_beh.exe" -intstyle ise -tclbatch isim.cmd  -wdb "./ModExp512bitTB_isim_beh.wdb"
