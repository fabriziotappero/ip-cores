prove: psl_analyze psl_compile psl_prove

confirm: psl_analyze psl_compile psl_confirm

psl_analyze:
	0in -od SFV_PSL_VH -cmd analyze \
	-vhdl ../../../grpGlobal/pkgGlobal/src/Global-p.vhdl \
	../src/SdClockMaster-e.vhdl \
	../src/SdClockMaster-Rtl-a.vhdl \
	-work zwork -libmap zwork=zwork

psl_compile:
	0in -od SFV_PSL_VH -cmd csl -d SdClockMaster \
	-work zwork -libmap zwork=zwork \
	-pslfile_vh ../src/SdClockMaster.psl \
	-vhctrl csl_ctrl.vhd \
	-eode

psl_prove:
	0in_prove +0in_od+SFV_PSL_RESULTS_VH \
	+0in_dir+SFV_PSL_VH/0in_cache \
	+0in_effort+high

psl_confirm:
	0in_confirm +0in_od+SFV_PSL_RESULTS_VH \
	+0in_dir+SFV_PSL_VH/0in_cache \
	+0in_effort+high

clean:
	\rm -rf work zwork *.wlf *.log replay* transcript *.db *.fcdb \
	SFV_PSL_VH SFV_PSL_RESULTS_VH
