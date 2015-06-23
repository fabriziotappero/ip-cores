GRLIB=../..
TOP=leon3hpe

BOARD=ge-hpe-midi-ep2s180

include $(GRLIB)/boards/$(BOARD)/Makefile.inc
DEVICE=$(PART)-$(PACKAGE)$(SPEED)
UCF=$(GRLIB)/boards/$(BOARD)/$(TOP).ucf
QSF=$(GRLIB)/boards/$(BOARD)/$(TOP).qsf
EFFORT=1
XSTOPT=
VHDLSYNFILES=config.vhd ahbrom.vhd leon3hpe.vhd
VHDLSIMFILES=testbench.vhd
VLOGSIMFILES=spi_slave_model.v
SIMTOP=testbench
SDCFILE=$(GRLIB)/boards/$(BOARD)/default.sdc
BITGEN=$(GRLIB)/boards/$(BOARD)/default.ut
CLEAN=soft-clean quartus-cpf-clean mkprom-clean

TECHLIBS = altera altera_mf stratixii
LIBSKIP = core1553bbc core1553brm core1553brt gr1553 corePCIF \
	tmtc openchip hynix cypress ihp grusbhc ec ecp2
DIRSKIP = b1553 pcif leon2 leon2ft crypto satcan pci leon3ft ambatest ddr \
	slink ascs haps coremp7 spacewire

include $(GRLIB)/bin/Makefile

include $(GRLIB)/software/leon3/Makefile

# Select your cable type here.
# Make sure it has been installed via the programmer GUI
# in Quartus.
#
# Examples:
#   USB-Blaster
#   ByteBlasterMV
CABLE=USB-Blaster
QUARTUS_PGM=quartus_pgm


# flags for compilation with gcc
CFLAGS=-O1 -g -msoft-float

##################  project specific targets ##########################

INCLUDEFILES=$(VPATH)/hpi_functions.c

# C files needed for building the hpe_test program
HPE_INCLUDE_FILES=hpe_test MIO memtest spi sdcard hpi_functions flash_functions adcdac adda_func tests
# testpc testpc_prog 

# C files needed for building the hpe_test program
TESTPC_INCLUDE_FILES=MIO memtest flash_functions testpc adcdac adda_func testpc_prog 

# C header files needed for building the hpe_test program
HPE_HEADER_FILES=Leon3MHe.h MIO.h memtest.h flash_functions.h tests.h testpc.h spi.h sdcard.h adc_dac.h adda_func.h hpi_functions.h 

# directory where the hpe_test source files reside in
HPE_INCLUDE_DIR=../../software/gleichmann

# C program files
# ###############

# an object file shall be rebuilt if either the corresponding c file
# or one of the header files has changed
%.o: $(HPE_INCLUDE_DIR)/%.c $(foreach elem, $(HPE_HEADER_FILES), $(HPE_INCLUDE_DIR)/$(elem) )
	$(XAS) -DHPE_MIDI -DEXP_CONN_TEST $(CFLAGS) -I. $< -o $@


# mkprom targets
# ##############

# change the settings below to reflect your hardware
# the frequency is set in the Makefile found in the boards directory
RAMSIZE=1024
ROMSIZE=32768
ROMWS=3
BAUD=38400
FREQ=40

# ROM version of the test program
hpe_test.mkprom: hpe_test.exe #$(addsuffix .o, $(HPE_INCLUDE_FILES))
	sparc-elf-mkprom -dump -baud $(BAUD) -freq $(FREQ) $^ -msoft-float -romws $(ROMWS) -romsize $(ROMSIZE) -rmw -ramsize $(RAMSIZE) -v -o $@

mkprom-clean:
	-rm -f hpe_test.mkprom

### HPI TEST PROGRAM ###################################################

HPI_INCLUDE_FILES= hpi_test hpi_functions
HPI_HEADER_FILES= hpi_functions.h hpi_defs.h
HPI_INCLUDE_DIR=../../software/gleichmann


%.o: $(HPI_INCLUDE_DIR)/%.c $(foreach elem, $(HPI_HEADER_FILES), $(HPI_INCLUDE_DIR)/$(elem) )
	$(XAS) -DHPE_MIDI $(XCFLAGS) -I. $< -o $@

hpi_test.exe: $(addsuffix .o, $(HPI_INCLUDE_FILES))
	$(XCC) $(XCFLAGS) -Ttext=0x40000000 -o hpi_test.exe $(addsuffix .o, $(HPI_INCLUDE_FILES))

# QUARTUS configuration
# #####################

# FPGA programming
quartus-pgm:
	$(QUARTUS_PGM) -c $(CABLE) -m JTAG -o p\;$(TOP).sof\;@2

# JTAG indirect programming of the serial configuration device
# use upper connector on the module for that
quartus-cfg-jic: $(TOP).jic
	$(QUARTUS_PGM) -c $(CABLE) -m JTAG -o pvbi\;$(TOP).jic

# Active serial programming of the serial configuration device
# use lower connector on the module for that
quartus-cfg-pof: $(TOP).pof
	$(QUARTUS_PGM) -c $(CABLE) -m ASC -o pl\;$(TOP).pof

quartus_cpf.opt:
	echo BITSTREAM_COMPRESSION=ON > quartus_cpf.opt

$(TOP).jic: quartus_cpf.opt $(TOP).sof
	quartus_cpf -c --option=quartus_cpf.opt -d $(CONFDEVICE) -s $(PART) $(TOP).sof $(TOP).jic

$(TOP).pof: quartus_cpf.opt $(TOP).sof
	quartus_cpf -c --option=quartus_cpf.opt -d $(CONFDEVICE) $(TOP).sof $(TOP).pof

quartus-cpf: $(TOP).jic $(TOP).pof

quartus-cpf-clean:
	-rm -f quartus_cpf.opt $(TOP).jic $(TOP).pof

