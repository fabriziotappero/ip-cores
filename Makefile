PWD := $(shell pwd)

XST := $(shell which xst)

TMP = tmp/
$(shell mkdir tmp)

PROJECT := pci_7seg

all: gen_vhdl xst ngdbuild map par trace prom final

gen_vhdl:
	cd source/generate_pci32tlite/ && make
	cd source/generate_pciregs/ && make

log:
	time make all &>build.log

xst: $(PROJECT).ngc

ngdbuild: $(PROJECT).ngc $(PROJECT).ngd

$(PROJECT).ngc:
	@# echo synclib > $(PROJECT).lso # hmm. things are different in ise 9.1
	echo work >> $(PROJECT).lso
	xst -intstyle ise -ifn $(PROJECT).xst -ofn $(PROJECT).syr &> tmp/build.xst.log
	#cat $(PROJECT).syr
	mv $(PROJECT).syr $(TMP)
	mv $(PROJECT).ngr $(PROJECT).lso $(TMP)
	mv xst $(TMP)

$(PROJECT).ngd:
	ngdbuild -intstyle ise -dd "$(PWD)/_ngo" -nt timestamp -uc $(PROJECT).ucf  -p xc3s400-fg456-4 $(PROJECT).ngc $(PROJECT).ngd &> tmp/build.ngdbuild.log
	mv $(PROJECT).bld $(TMP)
	mv _ngo  $(TMP)

map:
	map -intstyle ise -p xc3s400-fg456-4 -cm area -pr b -k 4 -c 100 -o $(PROJECT)_map.ncd $(PROJECT).ngd $(PROJECT).pcf &> tmp/build.map.log
	mv $(PROJECT)_map.mrp $(PROJECT)_map.ngm $(PROJECT).ngc $(TMP)

par:
	@#par -w -intstyle ise -ol std -n 4 -t 1 $(PROJECT)_map.ncd $(PROJECT).dir $(PROJECT).pcf &> tmp/build.par.log
	par -w -intstyle ise -ol std -t 1 $(PROJECT)_map.ncd $(PROJECT).ncd $(PROJECT).pcf &> tmp/build.par.log
	mv $(PROJECT).xpi $(PROJECT).par $(PROJECT).pad $(TMP)
	mv $(PROJECT)_pad.csv $(PROJECT)_pad.txt $(TMP)

trace:
	trce -intstyle ise -e 3 -l 3 -s 4 -xml $(PROJECT) $(PROJECT).ncd -o $(PROJECT).twr $(PROJECT).pcf &> tmp/build.trce.log
	#cat $(PROJECT).twr
	mv $(PROJECT).twr $(TMP)
	mv $(PROJECT).twx $(TMP)
	mv $(PROJECT)_map.ncd $(PROJECT).ngd $(PROJECT).pcf $(TMP)

prom:
	bitgen -intstyle ise -f $(PROJECT).ut $(PROJECT).ncd &> tmp/build.bitgen.log
	# cp $(PROJECT).bit ../jcarr_last.bit
	#cat $(PROJECT).drc
	mv $(PROJECT).drc  $(TMP)
	#cat $(PROJECT).bgn
	mv $(PROJECT).bgn  $(TMP)

final:
	-mv $(PROJECT).unroutes *.xml $(TMP)
	-mv $(PROJECT)*.map $(TMP)
	-mv $(PROJECT).ncd $(TMP)
	-grep -A 8 -B 1 ^Selected\ Device tmp/build.xst.log
	-grep -A 8 -B 1 ^Timing\ Summary tmp/build.xst.log
	-grep -A 21 -B 1 ^Design\ Summary tmp/build.map.log

burn:
	xc3sprog $(PROJECT).bit

clean:
	rm -rf $(TMP)
	rm -rf *.bit *.bgn *.mcs *.prm *.bld *.drc *.mcs *.ncd *.ngc *.ngd
	rm -rf *.ngr *.pad *.par *.pcf *.prm *.syr *.twr *.twx *.xpi *.lso
	rm -rf $(PROJECT)_map.* $(PROJECT)_pad.*
	rm -rf _ngo xst 
	rm -rf build.log
	rm -rf source/new_*
	rm -rf $(PROJECT).unroutes *.xml
