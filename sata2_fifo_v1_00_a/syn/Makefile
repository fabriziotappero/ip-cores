PROJECT=sata_core
COMPONENT=sata_core
DEVICE=xc6vlx240tff1156-1
XST_PRJ=$(PROJECT).scr
XST_SRP=$(PROJECT).srp

SYNTHESIS=$(COMPONENT).ngc
NGDBUILD=$(COMPONENT).ngd
MAP=$(COMPONENT)_map.ncd
PAR=$(COMPONENT).ncd
BITS=$(COMPONENT).bit

#netlist: $(NETLIST)
synthesis: $(SYNTHESIS)
ngdbuild: $(NGDBUILD)
map: $(MAP)
par: $(PAR)
bits: $(BITS)

#$(NETLIST):
#	make ../netlist/ 

$(SYNTHESIS):
	xst -ifn $(XST_PRJ) -ofn $(XST_SRP)

$(NGDBUILD): 
	ngdbuild -p $(DEVICE) -sd ../netlist -uc ../ucf/$(COMPONENT).ucf $(COMPONENT).ngc

$(MAP):
	map -o sata_core_map.ncd -pr b -ol high -timing -xe n -global_opt on $(COMPONENT).ngd $(COMPONENT).pcf

$(PAR):
	par -w -ol high sata_core_map.ncd $(COMPONENT).ncd $(COMPONENT).pcf

$(BITS):
	bitgen -w -f ../etc/bitgen.ut $(COMPONENT) 

clean:
	rm -rf $(COMPONENT).lso $(COMPONENT).ngc $(COMPONENT).ngc_xst.xrpt $(PROJECT).ngr $(XST_SRP) _xmsgs *.xrpt *.lst *.ngo *.bld *.log *.xpi xlnx_auto_0.ise xlnx_auto_0_xdb xst *~
	rm -rf $(COMPONENT).ngd
	rm -rf $(COMPONENT)_map.ncd $(COMPONENT)_map.map $(COMPONENT)_map.mrp $(COMPONENT)_map.ngm $(COMPONENT)_map.psr
	rm -rf $(COMPONENT)_pad.csv $(COMPONENT)_pad.txt 
	rm -rf $(COMPONENT).ncd $(COMPONENT).pad $(COMPONENT).par $(COMPONENT).pcf $(COMPONENT).ptwx $(COMPONENT).unroutes $(COMPONENT).drc $(COMPONENT).bgn
	rm -rf $(COMPONENT).bit
	rm -rf *.xml *.html *.xwbt
