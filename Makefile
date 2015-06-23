# Set GHDL in environment
GHDL=ghdl 
GHDLFLAGS = --workdir=work -Wl,-lm -Wc,-m32 -Wl,-m32 -Wa,--32  --ieee=synopsys -fexplicit
XST= eis-xst
GHDLA:=$(GHDL) -a $(GHDLFLAGS)
GHDLE:=$(GHDL) -e $(GHDLFLAGS)
#prevent make from deleting the .o files
.PRECIOUS: work/%.o
all: clean work/eis_helpers.o work/fpu_package.o work/fpu_mul.o work/fpu_add.o openfpu64_tb
	
showme_%: %
	./$< --wave=$<.ghw --stop-time=1ms
	gtkwave $<.ghw $<.sav

work/%.o: %.vhd
	$(GHDLA) $<

%_tb: eis_helpers.vhd work/eis_helpers.o %.vhd work/%.o %_tb.vhd work/%_tb.o
	$(GHDLE) $@

%: %.vhd work/%.o
	$(GHDLE) $@

empty_testsuite:
	cat openfpu64_tb.head.vhd openfpu64_tb.tail.vhd > openfpu64_tb.vhd

addsub_testsuite:
	cat openfpu64_tb.head.vhd tests/openfpu64_tb.addsub.inc.vhd openfpu64_tb.tail.vhd > openfpu64_tb.vhd

custom_testsuite:
	cat openfpu64_tb.head.vhd tests/openfpu64_tb.custom.inc.vhd openfpu64_tb.tail.vhd > openfpu64_tb.vhd

add_testsuite:
	cat openfpu64_tb.head.vhd tests/openfpu64_tb.add.inc.txt openfpu64_tb.tail.vhd > openfpu64_tb.vhd

sub_testsuite:
	cat openfpu64_tb.head.vhd tests/openfpu64_tb.sub.inc.txt openfpu64_tb.tail.vhd > openfpu64_tb.vhd

mul_testsuite:
	cat openfpu64_tb.head.vhd tests/openfpu64_tb.mul.inc.txt openfpu64_tb.tail.vhd > openfpu64_tb.vhd

quartus_distribution:
	mkdir -p openfpu64_quartus
	cp -f fpu_package.vhd fpu_add.vhd fpu_mul.vhd openfpu64.vhd openfpu64_hw.tcl gpl.txt openfpu64_quartus
	@echo "Now copy the files in openfpu64_quartus to the root directory of your QuartusII(tm) project"

clean:
	$(GHDL) --clean --workdir=work
	rm -rfv *.ghw *.cf *.log *.ngc *.ngr *.prj *.xrpt *.ifn *.ise xst_work xlnx_auto_0_xdb implement_viscy viscy.bit
