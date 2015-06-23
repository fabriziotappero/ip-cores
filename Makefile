help:
	@echo -e "Select operation to perform. Type 'make' followed by the name of the operation."
	@echo
	@echo -e "Available operations:"
	@echo -e "doxygen             - run the doxygen tool on the aoOCS project."
	@echo -e "                      Doxverilog version required."
	@echo -e "control_osd         - generate ./rtl/control_osd.mif"
	@echo -e "sd_disk             - generate SD disk image containing ROMs and ADFs."
	@echo -e "                      The disk image should be written to a SD card starting at offset 0."
	@echo -e "spec_extract        - generate the specification.odt file from the Doxygen HTML docs."
	@echo -e "vga_to_png          - extract VGA dump file to a set of PNG frame images."
	@echo -e "terasic_de2_70      - synthesise the aoOCS project for the Terasic DE2-70 board."
	@echo -e "clean               - clean all."
	@echo
	@exit 0

doxygen: ./doc/doxygen/doxygen.cfg
ifndef DOXVERILOG
	@echo "DOXVERILOG environment variable not set. Set it to a Doxverilog executable."
	@exit 1
endif
	$(DOXVERILOG) ./doc/doxygen/doxygen.cfg

aoOCS_tool:
	javac -d ./tmp ./sw/aoOCS_tool/*.java

control_osd: aoOCS_tool
	java -cp ./tmp aoOCS_tool.Main control_osd ./rtl/control_osd.mif

sd_disk: aoOCS_tool
ifndef AO_INTRO_IMAGE
	@echo "AO_INTRO_IMAGE environment variable not set. Set it to a PNG graphic file to display at startup."
	@exit 1
endif
ifndef AO_ROMS
	@echo "AO_ROMS environment variable not set. Set it to a directory with ROM files to insert into the sd disk image."
	@exit 1
endif
ifndef AO_FLOPPIES
	@echo "AO_FLOPPIES environment variable not set. Set it to a directory with ADF files to insert into the sd disk image."
	@exit 1
endif
	@echo "Generating SD disk image to file ./tmp/sd_disk.img"
	java -cp ./tmp aoOCS_tool.Main sd_disk $(AO_INTRO_IMAGE) $(AO_ROMS) $(AO_FLOPPIES) ./tmp/sd_disk.img

vga_to_png: aoOCS_tool
ifndef AO_VGA_DUMP_FILE
	@echo "AO_VGA_DUMP_FILE environment variable not set. Set it to a VGA dump file."
	@exit 1
endif
ifndef AO_FRAME_OUTPUT_DIR
	@echo "AO_FRAME_OUTPUT_DIR environment variable not set. Set it to a output directory for extracted frames."
	@exit 1
endif
	java -cp ./tmp aoOCS_tool.Main vga_to_png $(AO_VGA_DUMP_FILE) $(AO_FRAME_OUTPUT_DIR)

spec_extract: aoOCS_tool
	mkdir -p ./tmp/spec_extract
	java -cp ./tmp aoOCS_tool.Main spec_extract ./doc/doxygen/html/page_spec_references.html ./tmp/spec_extract/references.html
	java -cp ./tmp aoOCS_tool.Main spec_extract ./doc/doxygen/html/page_spec_ports.html ./tmp/spec_extract/ports.html
	java -cp ./tmp aoOCS_tool.Main spec_extract ./doc/doxygen/html/page_spec_clocks.html ./tmp/spec_extract/clocks.html
	java -cp ./tmp aoOCS_tool.Main spec_extract ./doc/doxygen/html/page_spec_registers.html ./tmp/spec_extract/registers.html
	java -cp ./tmp aoOCS_tool.Main spec_extract ./doc/doxygen/html/page_spec_operation.html ./tmp/spec_extract/operation.html
	java -cp ./tmp aoOCS_tool.Main spec_extract ./doc/doxygen/html/page_spec_architecture.html ./tmp/spec_extract/architecture.html
	java -cp ./tmp aoOCS_tool.Main spec_extract ./doc/doxygen/html/page_spec_introduction.html ./tmp/spec_extract/introduction.html
	java -cp ./tmp aoOCS_tool.Main spec_extract ./doc/doxygen/html/page_spec_revisions.html ./tmp/spec_extract/revisions.html
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/doc/src/specification_template.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<REFERENCES>,file://$(CURDIR)/tmp/spec_extract/references.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<PORTS>,file://$(CURDIR)/tmp/spec_extract/ports.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<CLOCKS>,file://$(CURDIR)/tmp/spec_extract/clocks.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<REGISTERS>,file://$(CURDIR)/tmp/spec_extract/registers.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<OPERATION>,file://$(CURDIR)/tmp/spec_extract/operation.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<ARCHITECTURE>,file://$(CURDIR)/tmp/spec_extract/architecture.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<INTRODUCTION>,file://$(CURDIR)/tmp/spec_extract/introduction.html,True)"
	soffice "macro:///Standard.Module1.Main(file://$(CURDIR)/tmp/spec_extract/specification.odt,file://$(CURDIR)/tmp/spec_extract/specification.odt,<REVISIONS>,file://$(CURDIR)/tmp/spec_extract/revisions.html,False)"

terasic_de2_70:
	mkdir -p ./tmp/terasic_de2_70
	cp ./rtl/*.v ./tmp/terasic_de2_70
	cp ./rtl/*.mif ./tmp/terasic_de2_70
	cp ./rtl/terasic_de2_70/* ./tmp/terasic_de2_70
	cp ./syn/terasic_de2_70/* ./tmp/terasic_de2_70
	cd ./tmp/terasic_de2_70 && quartus_sh --flow compile aoOCS

clean:
	rm -R -f ./tmp/*
