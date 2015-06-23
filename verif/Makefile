VCS=/proj/cadtools/bin/vcs
TGT=simv
VERICOM=/proj/cadtools/bin/vericom
VERDI=/proj/cadtools/bin/verdi
TAB_FILE=/proj/cadsim/simtools/simtools2.linux/pli64_rh4/dummytbv.tab
PLI_FILE=/proj/cadsim/simtools/simtools2.linux/pli64_rh4/dummytbv_vcs.a
VERDI_TAB=/proj/caeeda/NOVAS/VERDI/201403-3/share/PLI/VCS/LINUX/verdi.tab
VERDI_PLI=/proj/caeeda/NOVAS/VERDI/201403-3/share/PLI/VCS/LINUX/pli.a
SIM_DIR= $(PROJ_TOP)/output/
SRCFILE = src.vlist

FLAGS= +lint=TFIPC-L -P $(VERDI_TAB) $(VERDI_PLI) -unit_timescale=1ps/1ps 
all:simv

setup:
	mkdir -p $(SIM_DIR)
	cd $(SIM_DIR); ln -fs $(PROJ_TOP)/verif/* .

$(TGT):$(SRCFILE)
	rm out -rf
	mkdir out
	$(VCS) -sverilog $(FLAGS) +define+DUMPFSDB  -f $(SRCFILE) -sgq short 

run: $(TGT)
	/proj/caeeda/SYNOPSYS/bin/simv -sgq normal

run_verdi:
	$(VERDI) -f src.vlist -top tb -ssf $(SIM_DIR)/test_wb2axi.fsdb -sgq normal

clean:
	rm simv; rm csrc -rf; rm *.daidir -rf; rm out -rf; rm verdiLog -rf; rm vcs.log; rm novas.*; rm ucli.key

