help:
	@echo -e "Select operation to perform. Type 'make' followed by the name of the operation."
	@echo
	@echo -e "Available operations:"
	@echo -e "doxygen             - run the doxygen tool on the ao68000 project."
	@echo -e "                      Doxverilog version required."
	@echo -e "microcode           - generate ao68000 microcode from Java sources."
	@echo -e "spec_extract        - generate the specification.odt file from the Doxygen HTML docs."
	@echo -e "soc_for_linux       - synthesise soc_for_linux SoC with ao68000 processor for"
	@echo -e "                      the Terasic DE2-70 board."
	@echo -e "test_bcd            - test BCD opcode algorithms."
	@echo -e "compare_with_winuae - compare ao68000 processor with WinUAE MC68000 emulator (www.winuae.net)."
	@echo -e "clean               - clean all."
	@echo
	@exit 0

doxygen: ./doc/doxygen/doxygen.cfg
ifndef DOXVERILOG
	@echo "DOXVERILOG environment variable not set. Set it to a Doxverilog executable."
	@exit 1
endif
	$(DOXVERILOG) ./doc/doxygen/doxygen.cfg

ao68000_tool:
	javac -d ./tmp ./sw/ao68000_tool/*.java

microcode: ao68000_tool
	java -cp ./tmp ao68000_tool.Main parser ./rtl/ao68000.v ./sw/ao68000_tool/Parser.java
	javac -d ./tmp ./sw/ao68000_tool/*.java
	java -cp ./tmp ao68000_tool.Main microcode ./rtl/ao68000.v ./rtl/ao68000_microcode.mif

test_bcd:
	gcc -o ./tmp/test_bcd ./tests/nbcd_abcd_sbcd/nbcd_abcd_sbcd.c
	./tmp/test_bcd

soc_for_linux:
	mkdir -p ./tmp/soc_for_linux_on_terasic_de2_70
	cp ./rtl/* ./tmp/soc_for_linux_on_terasic_de2_70
	cp ./tests/soc_for_linux_on_terasic_de2_70/verilog/* ./tmp/soc_for_linux_on_terasic_de2_70
	cp ./tests/soc_for_linux_on_terasic_de2_70/quartus_project/* ./tmp/soc_for_linux_on_terasic_de2_70
	cd ./tmp/soc_for_linux_on_terasic_de2_70 && quartus_sh --flow compile soc_for_linux

spec_extract: ao68000_tool
	mkdir -p ./tmp/spec_extract
	java -cp ./tmp ao68000_tool.Main spec_extract ./doc/doxygen/html/page_spec_references.html ./tmp/spec_extract/references.html
	java -cp ./tmp ao68000_tool.Main spec_extract ./doc/doxygen/html/page_spec_ports.html ./tmp/spec_extract/ports.html
	java -cp ./tmp ao68000_tool.Main spec_extract ./doc/doxygen/html/page_spec_clocks.html ./tmp/spec_extract/clocks.html
	java -cp ./tmp ao68000_tool.Main spec_extract ./doc/doxygen/html/page_spec_registers.html ./tmp/spec_extract/registers.html
	java -cp ./tmp ao68000_tool.Main spec_extract ./doc/doxygen/html/page_spec_operation.html ./tmp/spec_extract/operation.html
	java -cp ./tmp ao68000_tool.Main spec_extract ./doc/doxygen/html/page_spec_architecture.html ./tmp/spec_extract/architecture.html
	java -cp ./tmp ao68000_tool.Main spec_extract ./doc/doxygen/html/page_spec_introduction.html ./tmp/spec_extract/introduction.html
	java -cp ./tmp ao68000_tool.Main spec_extract ./doc/doxygen/html/page_spec_revisions.html ./tmp/spec_extract/revisions.html
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/doc/src/specification_template.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<REFERENCES>,file://$(CURDIR)/tmp/spec_extract/references.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<PORTS>,file://$(CURDIR)/tmp/spec_extract/ports.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<CLOCKS>,file://$(CURDIR)/tmp/spec_extract/clocks.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<REGISTERS>,file://$(CURDIR)/tmp/spec_extract/registers.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<OPERATION>,file://$(CURDIR)/tmp/spec_extract/operation.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<ARCHITECTURE>,file://$(CURDIR)/tmp/spec_extract/architecture.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<INTRODUCTION>,file://$(CURDIR)/tmp/spec_extract/introduction.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<REVISIONS>,file://$(CURDIR)/tmp/spec_extract/revisions.html,False)"

winuae:
	mkdir -p ./tmp/compare_with_winuae/winuae
	cd ./tmp/compare_with_winuae/winuae && gcc -DCPUEMU_68000_ONLY -DCPUEMU_11 -I./../../../tests/compare_with_winuae/winuae -o build68k ./../../../tests/compare_with_winuae/winuae/build68k.c
	cd ./tmp/compare_with_winuae/winuae && ./build68k < ./../../../tests/compare_with_winuae/winuae/table68k > table68k.c
	cd ./tmp/compare_with_winuae/winuae && gcc -DCPUEMU_68000_ONLY -DCPUEMU_11 -I./../../../tests/compare_with_winuae/winuae -c ./../../../tests/compare_with_winuae/winuae/gencpu.c
	cd ./tmp/compare_with_winuae/winuae && gcc -DCPUEMU_68000_ONLY -DCPUEMU_11 -I./../../../tests/compare_with_winuae/winuae -c ./../../../tests/compare_with_winuae/winuae/readcpu.c
	cd ./tmp/compare_with_winuae/winuae && gcc -DCPUEMU_68000_ONLY -DCPUEMU_11 -I./../../../tests/compare_with_winuae/winuae -c table68k.c
	cd ./tmp/compare_with_winuae/winuae && gcc -DCPUEMU_68000_ONLY -DCPUEMU_11 -I./../../../tests/compare_with_winuae/winuae -o gencpu gencpu.o readcpu.o table68k.o
	cd ./tmp/compare_with_winuae/winuae && ./gencpu
	cd ./tmp/compare_with_winuae/winuae && gcc -DCPUEMU_68000_ONLY -DCPUEMU_11 -I./../../../tests/compare_with_winuae/winuae -c ./../../../tests/compare_with_winuae/winuae/ao.c
	cd ./tmp/compare_with_winuae/winuae && gcc -DCPUEMU_68000_ONLY -DCPUEMU_11 -I./../../../tests/compare_with_winuae/winuae -c cpustbl.c
	cd ./tmp/compare_with_winuae/winuae && gcc -DCPUEMU_68000_ONLY -DCPUEMU_11 -I./../../../tests/compare_with_winuae/winuae -c cpuemu_11.c
	cd ./tmp/compare_with_winuae/winuae && gcc -o ao ao.o cpustbl.o cpuemu_11.o table68k.o readcpu.o

tb_ao68000:
ifndef QUARTUS_ROOTDIR
	@echo "Environment variable QUARTUS_ROOTDIR not set. Please set it to point to Altera Quartus II rootdir."
	@exit 1
endif
	mkdir -p ./tmp/compare_with_winuae/verilog
	cd ./tmp/compare_with_winuae/verilog && ln -s -f $(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.v altsyncram.v
	cd ./tmp/compare_with_winuae/verilog && ln -s -f $(QUARTUS_ROOTDIR)/eda/sim_lib/220model.v lpm_mult.v
	cd ./tmp/compare_with_winuae/verilog && ln -s -f $(QUARTUS_ROOTDIR)/eda/sim_lib/220model.v lpm_divide.v
	cd ./tmp/compare_with_winuae/verilog && iverilog -y. -y./../../../rtl -y./../../../tests/compare_with_winuae/verilog -o tb_ao68000 ./../../../tests/compare_with_winuae/verilog/tb_ao68000.v
	cp ./rtl/ao68000_microcode.mif ./tmp/compare_with_winuae/verilog

START_IR_DEC 	:= 24828
END_IR_DEC 	:= 24836
TERM_PROGRAM 	:= xterm
COUNT 		:= 4
COUNT_LIST 	:= $(wordlist 1,$(COUNT),0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19)
STEP 		:= `expr \( $(END_IR_DEC) - $(START_IR_DEC) \) / $(COUNT)`

compare_with_winuae: ao68000_tool winuae tb_ao68000
	$(foreach i,$(COUNT_LIST), mkdir -p ./tmp/compare_with_winuae/run_$(i); )
	$(foreach i,$(COUNT_LIST), cp ./rtl/ao68000_microcode.mif ./tmp/compare_with_winuae/run_$(i); )
	$(foreach i,$(COUNT_LIST), echo -e "#!/bin/bash\n./../verilog/tb_ao68000 \$$@" \
		> ./tmp/compare_with_winuae/run_$(i)/run.sh; \
	)
	$(foreach i,$(COUNT_LIST), chmod +x ./tmp/compare_with_winuae/run_$(i)/run.sh; )
	$(foreach i,$(COUNT_LIST), $(TERM_PROGRAM) -e java -cp ./tmp ao68000_tool.Main test \
		./tmp/compare_with_winuae/winuae/ao \
		./tmp/compare_with_winuae/run_$(i)/run.sh \
		`expr $(START_IR_DEC) + $(i) \* \( \( $(END_IR_DEC) - $(START_IR_DEC) \) / $(COUNT) \)` \
		`expr $(START_IR_DEC) + \( $(i) + 1 \) \* \( \( $(END_IR_DEC) - $(START_IR_DEC) \) / $(COUNT) \)` \
		& \
	)

clean:
	rm -R -f ./tmp/*
