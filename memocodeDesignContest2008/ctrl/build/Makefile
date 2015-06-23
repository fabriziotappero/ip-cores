
BSC_COMP = bsc

ctrldir = ..
plbdir = ../../xup/PLBMaster
bramdir = ../../../memocodeDesignContest07/hardware/BRAMTarget/
feederdir = ../../../memocodeDesignContest07/hardware/Feeder
commondir = ../../xup/Common
memo_common_dir = ../../common
external_memory_dir = ../../xup/ExternalMemory
sortdir = ../../sort
aesdir  = ../../aesCore/bsv
sort_fifos = ../../sort/BRAMLevelFIFOAdders
sort_muxes = ../../sort/BRAMLevelFIFOMuxes
alfred_bram = ../../sort/BRAM_v

v_dir   = ../../aesCore/verilog/rtl/verilog
pv_dir  = ../../aesCorePipelined
#coregen_dir = ../../aesCore/verilog/rtl/coregen/aesDataFifo
#corelib_dir = ../../common/verilog/src/XilinxCoreLib
#prim_dir =  ../../common/verilog/src/uni9000/
#unisim_dir =  ../../common/verilog/src/unisims/
sim_base = ../../common/verilog/
ref_dir = ../ref_pc

VER_OPTS =  +RTS -K100000000 --RTS -u -v -verilog -aggressive-conditions -dschedule -show-schedule -show-rule-rel \* \* -vdir .
SIM_OPTS =  +RTS -K100000000 --RTS -u -v -sim -aggressive-conditions -show-schedule 
SRCDIRS = :$(plbdir):$(commondir):$(memo_common_dir):$(external_memory_dir):$(bramdir):$(ctrldir):$(sortdir):$(aesdir):$(sort_fifos):$(bram_target_dir):$(sort_muxes):$(alfred_bram)

#--------------------------------------------------------------------
# Build targets 
#--------------------------------------------------------------------
#Need to fix up MAXRECORD
mkTH.v: $(ctrldir)/mkCtrl.bsv
	gcc -o aes.exe -DLOGVAL=10 -I$(ref_dir) ../gen_test_array.c $(ref_dir)/recordio.c $(ref_dir)/aes_core.c 
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -D LogArrayLen=10 -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkTH $(ctrldir)/mkCtrl.bsv > out.log

vsim: mkTH.v
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
		+:$(v_dir):$(pv_dir):$(commondir)$(sim_base):$(alfred_bram) -e mkTH *.v >> out.log

mkEMTB.v: $(ctrldir)/mkTester.bsv
	$(BSC_COMP) $(VER_OPTS) -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkEMTB $(ctrldir)/mkTester.bsv


emtb: mkEMTB.v
	$(BSC_COMP) $(VER_OPTS) -p +$(SRCDIRS) -vsim iverilog -e mkEMTB mkEMTB.v


ftb:
	$(BSC_COMP) $(SIM_OPTS) -bdir . -p +$(SRCDIRS) -g mk421TB $(ctrldir)/mkTester.bsv
	$(BSC_COMP) $(SIM_OPTS) -bdir . -e mk421TB *.ba

smoke:
	touch $(ctrldir)/mkCtrl.bsv
	gcc -o aes.exe -DLOGVAL=10 -I$(ref_dir) ../gen_test_array.c $(ref_dir)/recordio.c $(ref_dir)/aes_core.c 
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -D LogArrayLen=10 -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkTH $(ctrldir)/mkCtrl.bsv
	cp $(v_dir)/*.v .
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
		+:$(v_dir):$(pv_dir):$(commondir):$(sim_base):$(alfred_bram) -e mkTH *.v
	./a.out


	touch $(ctrldir)/mkCtrl.bsv
	gcc -o aes.exe -DLOGVAL=11 -I$(ref_dir) ../gen_test_array.c $(ref_dir)/recordio.c $(ref_dir)/aes_core.c 
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -D LogArrayLen=11 -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkTH $(ctrldir)/mkCtrl.bsv
	cp $(v_dir)/*.v .
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
		+:$(v_dir):$(pv_dir):$(commondir):$(sim_base):$(alfred_bram) -e mkTH *.v
	./a.out


	touch $(ctrldir)/mkCtrl.bsv
	gcc -o aes.exe -DLOGVAL=12 -I$(ref_dir) ../gen_test_array.c $(ref_dir)/recordio.c $(ref_dir)/aes_core.c 
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -D LogArrayLen=12 -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkTH $(ctrldir)/mkCtrl.bsv
	cp $(v_dir)/*.v .
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
		+:$(v_dir):$(pv_dir):$(commondir):$(sim_base):$(alfred_bram) -e mkTH *.v
	./a.out


	touch $(ctrldir)/mkCtrl.bsv
	gcc -o aes.exe -DLOGVAL=13 -I$(ref_dir) ../gen_test_array.c $(ref_dir)/recordio.c $(ref_dir)/aes_core.c 
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -D LogArrayLen=13 -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkTH $(ctrldir)/mkCtrl.bsv
	cp $(v_dir)/*.v .
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
		+:$(v_dir):$(pv_dir):$(commondir):$(sim_base):$(alfred_bram) -e mkTH *.v
	./a.out


	touch $(ctrldir)/mkCtrl.bsv
	gcc -o aes.exe -DLOGVAL=14 -I$(ref_dir) ../gen_test_array.c $(ref_dir)/recordio.c $(ref_dir)/aes_core.c 
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -D LogArrayLen=14 -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkTH $(ctrldir)/mkCtrl.bsv
	cp $(v_dir)/*.v .
	cp $(coregen_dir)/*.mif .
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
		+:$(v_dir):$(pv_dir):$(commondir):$(coregen_dir):$(corelib_dir):$(prim_dir):$(unisim_dir):$(sim_base):$(alfred_bram) -e mkTH *.v
	./a.out


	touch $(ctrldir)/mkCtrl.bsv
	gcc -o aes.exe -DLOGVAL=15 -I$(ref_dir) ../gen_test_array.c $(ref_dir)/recordio.c $(ref_dir)/aes_core.c 
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -D LogArrayLen=15 -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkTH $(ctrldir)/mkCtrl.bsv
	cp $(v_dir)/*.v .
	cp $(coregen_dir)/*.mif .
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
		+:$(v_dir):$(pv_dir):$(commondir):$(coregen_dir):$(corelib_dir):$(prim_dir):$(unisim_dir):$(sim_base):$(alfred_bram) -e mkTH *.v
	./a.out


	touch $(ctrldir)/mkCtrl.bsv
	gcc -o aes.exe -DLOGVAL=16 -I$(ref_dir) ../gen_test_array.c $(ref_dir)/recordio.c $(ref_dir)/aes_core.c 
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -D LogArrayLen=16 -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkTH $(ctrldir)/mkCtrl.bsv
	cp $(v_dir)/*.v .
	cp $(coregen_dir)/*.mif .
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
		+:$(v_dir):$(pv_dir):$(commondir):$(coregen_dir):$(corelib_dir):$(prim_dir):$(unisim_dir):$(sim_base):$(alfred_bram) -e mkTH *.v
	./a.out


	touch $(ctrldir)/mkCtrl.bsv
	gcc -o aes.exe -DLOGVAL=17 -I$(ref_dir) ../gen_test_array.c $(ref_dir)/recordio.c $(ref_dir)/aes_core.c 
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -D LogArrayLen=17 -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkTH $(ctrldir)/mkCtrl.bsv
	cp $(v_dir)/*.v .
	cp $(coregen_dir)/*.mif .
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
		+:$(v_dir):$(pv_dir):$(commondir):$(coregen_dir):$(corelib_dir):$(prim_dir):$(unisim_dir):$(sim_base):$(alfred_bram) -e mkTH *.v
	./a.out

	touch $(ctrldir)/mkCtrl.bsv
	gcc -o aes.exe -DLOGVAL=18 -I$(ref_dir) ../gen_test_array.c $(ref_dir)/recordio.c $(ref_dir)/aes_core.c 
	./aes.exe
	$(BSC_COMP) $(VER_OPTS) -D LogArrayLen=18 -v -scheduler-effort 1 -bdir . -p +$(SRCDIRS) -g mkTH $(ctrldir)/mkCtrl.bsv
	cp $(v_dir)/*.v .
	cp $(coregen_dir)/*.mif .
	$(BSC_COMP) $(VER_OPTS) -vsim iverilog -p \
		+:$(v_dir):$(pv_dir):$(commondir):$(coregen_dir):$(corelib_dir):$(prim_dir):$(unisim_dir):$(sim_base):$(alfred_bram) -e mkTH *.v
	./a.out




#--------------------------------------------------------------------
# Clean up
#--------------------------------------------------------------------

clean :
	rm -rf $(junk) *~ \#* *.cxx *.ba *.o *.h *.bi *.bo *.bsv *.v *.log *.so a.out