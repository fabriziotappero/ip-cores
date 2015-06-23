# rsp517 bitgen

TOP = rsp517_top
CG = cg
RTL = rtl
MVP = mvp
NGC = ngc
#MEM = ddr
UCF = ./ucf/fpga1.ucf

all: xst ngdbuild map par trace bitgen
all_build: ngdbuild map par trace bitgen
all_map: map par trace bitgen
all_par: par trace bitgen
all_trace: trace bitgen

help:
	@echo "help"	

xst: ./$(TOP).ngc

./$(TOP).ngc: ./$(RTL)/*.vhd ./$(MVP)/*.vhd ./$(TOP).xst ./$(TOP).prj ./$(TOP).lso
	xst -intstyle silent -ifn ./$(TOP).xst -ofn ./$(TOP).syr

ngdbuild: ./$(TOP).ngd

./$(TOP).ngd: ./$(TOP).ngc $(UCF)
	ngdbuild -intstyle xflow -sd ./ -dd _ngo -nt timestamp -uc $(UCF) -p xc4vlx160-ff1148-10 ./$(TOP).ngc ./$(TOP).ngd > ngdbuild.log

map: ./$(TOP).ngd
	map -intstyle xflow -p xc4vlx160-10-ff1148 -cm balanced -register_duplication -detail -ol high -timing -xe n -t 1 -pr b -k 4 -c 100 -tx off -power off -logic_opt off -global_opt off -ignore_keep_hierarchy -o ./$(TOP)_map.ncd ./$(TOP).ngd ./$(TOP).pcf > map.log

par: ./$(TOP)_map.ncd ./$(TOP).pcf
	par -intstyle xflow -ol high -xe n -w -t 1 -n 1 ./$(TOP)_map.ncd ./$(TOP).ncd ./$(TOP).pcf > par.log

trace: ./$(TOP).ncd ./$(TOP).pcf
	trce -intstyle xflow -u 100 -e 500 -skew -xml ./$(TOP).twx -o ./$(TOP).twr ./$(TOP).ncd ./$(TOP).pcf > trace.log

bitgen: ./$(TOP).ncd ./$(TOP).ut
	bitgen -intstyle xflow -f ./$(TOP).ut ./$(TOP).ncd ./$(TOP).bit ./$(TOP).pcf > bitgen.log
	
clean:
	rm -f $(TOP).syr
	rm -f $(TOP).ngc
	rm -f $(TOP)_map.ncd
	rm -f $(TOP).ncd
	rm -f $(TOP).pcf
	rm -f $(TOP).par
	rm -f $(TOP).pad
	rm -f $(TOP).ngd
	rm -f $(TOP).ngr
	rm -f $(TOP).bgn
	rm -f $(TOP).bld
	rm -f $(TOP).drc
	rm -f $(TOP)_map.*
	rm -f $(TOP)_pad.*
	rm -f $(TOP)*.xml
	rm -f $(TOP)*.twr
	rm -f *.twr
	rm -f $(TOP)*.twx
	rm -f $(TOP)*.xpi
	rm -f $(TOP)*.unroutes
	rm -f $(TOP)*.log
	rm -f *.log
	rm -rf ./xst
	rm -rf ./_ngo	
	mkdir ./xst
	mkdir ./xst/tmp
	rm -f *.*~
	
