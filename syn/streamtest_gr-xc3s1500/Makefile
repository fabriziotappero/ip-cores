
###############################################################################
##                                                                           ##
##                        project-dependent variables                        ##
##                                                                           ##
###############################################################################

# The project name. The bit-file that is generated in the end will be named
# "$(PROJ).bit"

PROJ = streamtest

# The top-level entity to be instantiated

TOPLEVEL = streamtest_top

# The VHDL sources that need to be compiled during synthesis

RTLDIR = ../../rtl/vhdl
VHDL_SOURCES = streamtest_top.vhd \
               $(RTLDIR)/streamtest.vhd \
               $(RTLDIR)/spwpkg.vhd \
               $(RTLDIR)/spwstream.vhd \
               $(RTLDIR)/spwlink.vhd \
               $(RTLDIR)/spwram.vhd \
               $(RTLDIR)/spwrecv.vhd \
               $(RTLDIR)/spwxmit.vhd \
               $(RTLDIR)/spwxmit_fast.vhd \
               $(RTLDIR)/spwrecvfront_generic.vhd \
               $(RTLDIR)/spwrecvfront_fast.vhd \
               $(RTLDIR)/syncdff.vhd

# For Pender XC3S1500 board
FPGA_TYPE	= xc3s1500-fg456-4

## For Pender XC3S2000 rev2 board
#FPGA_TYPE	= xc3s2000-fg456-4

# The default target; recommended targets: "bitfile" or "upload"

default : bitfile

UCFFILE = streamtest.ucf

###############################################################################
##                                                                           ##
##            miscellaneous project-independent variables & rules            ##
##                                                                           ##
###############################################################################

# use this to make most tools quieter
OPT_INTSTYLE = -intstyle ise

# Phony (non file creating) targets

.PHONY : default clean bitfile

clean :
	$(RM) -rf *~ work dump.xst _ngo 'file graph' xlnx_auto_0_xdb _xmsgs
	$(RM) $(PROJ).xst-script
	$(RM) $(PROJ).lso $(PROJ).prj
	$(RM) $(PROJ).ngc $(PROJ).xst.log $(PROJ).syr $(PROJ).srp $(PROJ).ngr
	$(RM) $(PROJ).ngd $(PROJ).bld
	$(RM) $(PROJ).twx $(PROJ).twr
	$(RM) $(PROJ).pcf $(PROJ)_map.mrp $(PROJ)_map.ncd $(PROJ)_map.ngm
	$(RM) $(PROJ).ncd $(PROJ).pad $(PROJ).par $(PROJ).xpi $(PROJ)_pad.csv $(PROJ)_pad.txt
	$(RM) $(PROJ).bit $(PROJ).bgn $(PROJ).drc
	$(RM) $(PROJ).ptwx $(PROJ).unroutes *.xrpt $(PROJ)_summary.xml $(PROJ)_usage.xml $(PROJ)_map.map
	$(RM) $(PROJ)_bitgen.xwbt usage_statistics_webtalk.html webtalk.log

bitfile : $(PROJ).bit

###############################################################################
#                                                                             #
#                    STAGE 1: "xst" (Xilinx Synthesis Tool)                   #
#  needs:                                                                     #
#                                                                             #
#    $(PROJ).vhdl                                                             #
#    $(PROJ).prj - Project file (created below)                               #
#    $(PROJ).lso - Library Search Order file (created below)                  #
#                                                                             #
#  created files:                                                             #
#                                                                             #
#    $(PROJ).ngc     - netlist                                                #
#    $(PROJ).ngr     - XILINX-XDB 0.1 STUB 0.1 ASCII / XILINX-XDM V1.2e       #
#                      (optional, depending on the '-rtlview' option)         #
#    $(PROJ).xst.log - human-readable synthesis report                        #
#                      (AKA .syr, .srp)                                       #
#                                                                             #
#  created directories:                                                       #
#                                                                             #
#    work                                                                     #
#    dump.xst                                                                 #
#                                                                             #
###############################################################################

# Generate a "Library Search Order" file, containing just "work" for now.

$(PROJ).lso :
	@echo "work" > $@

# Generate a "Project" file, consisting of lines containing each of the
# VHDL_SOURCES, preceded by "vhdl work".

$(PROJ).prj :
	$(shell echo -n $(VHDL_SOURCES) | \
	sed 's/\([^ ]\+\) */vhdl work \1\n/g' > $@)

$(PROJ).xst-script :
	@echo "set -tmpdir /tmp"                                        > $@
	@echo "set -xsthdpdir ."                                       >> $@
	@echo "run"                                                    >> $@
	@echo "-ifn                                  $(PROJ).prj"      >> $@
	@echo "-ifmt                                 mixed"            >> $@
	@echo "-ofn                                  $(PROJ)"          >> $@
	@echo "-ofmt                                 ngc"              >> $@
	@echo "-p                                    $(FPGA_TYPE)"     >> $@
	@echo "-top                                  $(TOPLEVEL)"      >> $@
	@echo "-opt_mode                             speed"            >> $@
	@echo "-opt_level                            1"                >> $@
	@echo "-iuc                                  no"               >> $@
	@echo "-lso                                  $(PROJ).lso"      >> $@
	@echo "-keep_hierarchy                       no"               >> $@
	@echo "-glob_opt                             AllClockNets"     >> $@
	@echo "-rtlview                              no"               >> $@
	@echo "-read_cores                           yes"              >> $@
# Note: write_timing_constraints is non-standard
	@echo "-write_timing_constraints             yes"              >> $@
	@echo "-cross_clock_analysis                 no"               >> $@
#	@echo "-hierarchy_separator                  _"                >> $@
	@echo "-bus_delimiter                        <>"               >> $@
	@echo "-case                                 maintain"         >> $@
	@echo "-slice_utilization_ratio              100"              >> $@
#	@echo "-verilog2001                          yes"              >> $@
#	@echo "-vlgincdir"                                             >> $@
	@echo "-fsm_extract                          yes"              >> $@
	@echo "-fsm_encoding                         auto"             >> $@
	@echo "-fsm_style                            lut"              >> $@
# Note: safe_implementation is non-standard
	@echo "-safe_implementation                  yes"              >> $@
	@echo "-ram_extract                          yes"              >> $@
	@echo "-ram_style                            auto"             >> $@
	@echo "-rom_extract                          yes"              >> $@
	@echo "-rom_style                            auto"             >> $@
	@echo "-mux_extract                          yes"              >> $@
	@echo "-mux_style                            auto"             >> $@
	@echo "-decoder_extract                      yes"              >> $@
	@echo "-priority_extract                     yes"              >> $@
	@echo "-shreg_extract                        yes"              >> $@
	@echo "-shift_extract                        yes"              >> $@
	@echo "-xor_collapse                         yes"              >> $@
	@echo "-resource_sharing                     yes"              >> $@
	@echo "-mult_style                           auto"             >> $@
	@echo "-iobuf                                yes"              >> $@
	@echo "-max_fanout                           500"              >> $@
	@echo "-bufg                                 8"                >> $@
	@echo "-register_duplication                 yes"              >> $@
	@echo "-equivalent_register_removal          yes"              >> $@
	@echo "-register_balancing                   no"               >> $@
	@echo "-slice_packing                        yes"              >> $@
	@echo "-optimize_primitives                  no"               >> $@
	@echo "-iob                                  auto"             >> $@

$(PROJ).ngc $(PROJ).xst.log : $(VHDL_SOURCES) $(PROJ).prj $(PROJ).lso $(PROJ).xst-script
	rm -rf work dump.xst
	xst $(OPT_INTSTYLE) -ifn $(PROJ).xst-script -ofn $(PROJ).xst.log
	rm -rf work dump.xst

###############################################################################
#                                                                             #
#                               STAGE 2: ngdbuild                             #
#  needs:                                                                     #
#                                                                             #
#    $(PROJ).ngc                                                              #
#                                                                             #
#  created files:                                                             #
#                                                                             #
#    $(PROJ).bld - human-readable build log                                   #
#    $(PROJ).ngd - XILINX-XDB 0.1 STUB 0.1 ASCII / XILINX-XDM V1.2e           #
#                                                                             #
#  created dir:                                                               #
#    _ngo                                                                     #
#                                                                             #
###############################################################################

$(PROJ).ngd $(PROJ).bld: $(PROJ).ngc $(UCFFILE)
	rm -rf _ngo
	ngdbuild $(OPT_INTSTYLE) -dd _ngo -aul -p $(FPGA_TYPE) $(if $(UCFFILE),-uc $(UCFFILE)) $(PROJ).ngc $(PROJ).ngd
	rm -rf _ngo

###############################################################################
#                                                                             #
#                                STAGE 3: Mapper                              #
#  needs:                                                                     #
#                                                                             #
#    $(PROJ).ngd                                                              #
#                                                                             #
#  created files:                                                             #
#                                                                             #
#    $(PROJ).pcf     - ASCII file                                             #
#    $(PROJ)_map.mrp - human-readable mapping report                          #
#    $(PROJ)_map.ncd - binary format                                          #
#    $(PROJ)_map.ngm - XILINX-XDB 0.1 STUB 0.1 ASCII / XILINX-XDM V1.2e       #
#                                                                             #
#  NOTE:                                                                      #
#                                                                             #
#    In order to prevent the make process from terminating on these spurious  #
#    problems, we precede the "map" invocation with a hyphen, instructing     #
#    make to ignore the return code from "map".                               #
#                                                                             #
###############################################################################

$(PROJ).pcf $(PROJ)_map.mrp $(PROJ)_map.ncd $(PROJ)_map.ngm: $(PROJ).ngd
	map $(OPT_INTSTYLE) -p $(FPGA_TYPE) -cm area -pr b -c 100 -o $(PROJ)_map.ncd $(PROJ).ngd $(PROJ).pcf

###############################################################################
#                                                                             #
#                          STAGE 4: Place-and-Route                           #
#  needs:                                                                     #
#                                                                             #
#    $(PROJ).pcf                                                              #
#    $(PROJ)_map.ncd                                                          #
#                                                                             #
#  created files:                                                             #
#                                                                             #
#    $(PROJ).ncd     - binary file                                            #
#    $(PROJ).pad     - ASCII file for import in spreadsheet                   #
#    $(PROJ).par     - human-readable place-and-route report                  #
#    $(PROJ).xpi     - ASCII file                                             #
#    $(PROJ)_pad.csv - human-readable CVS file                                #
#    $(PROJ)_pad.txt - human-readable file                                    #
#                                                                             #
###############################################################################

$(PROJ).ncd $(PROJ).pad $(PROJ).par $(PROJ).xpi $(PROJ)_pad.csv $(PROJ)_pad.txt: $(PROJ).pcf $(PROJ)_map.ncd
	par -w $(OPT_INTSTYLE) -t 1 $(PROJ)_map.ncd $(PROJ).ncd $(PROJ).pcf

###############################################################################
#                                                                             #
#                         STAGE 4.5 (optional): trace                         #
#  needs:                                                                     #
#                                                                             #
#  created files:                                                             #
#                                                                             #
###############################################################################

$(PROJ).twr $(PROJ).twx : $(PROJ).ncd $(PROJ).pcf
	trce $(OPT_INTSTYLE) -e 5 -l 5 -u 5 -xml $(PROJ) $(PROJ).ncd -o $(PROJ).twr $(PROJ).pcf

###############################################################################
#                                                                             #
#                          STAGE 5: Generate BIT-file                         #
#  needs:                                                                     #
#                                                                             #
#    $(PROJ).ncd                                                              #
#                                                                             #
#  created files: $(PROJ).bgn $(PROJ).bit $(PROJ).drc                         #
#                                                                             #
#    $(PROJ).bgn - human-readable BitGen report                               #
#    $(PROJ).drc - human readable DRC report                                  #
#    $(PROJ).bit - binary image file                                          #
#                                                                             #
###############################################################################

# We omit "-g StartUpClk:JtagClk" ; this doesn't work if the image is loaded
# from a PROM.

# Note: LCK_cycle:3 is non-standard
OPT_BITGEN = -w                     \
             -g DebugBitstream:No   \
             -g Binary:no           \
             -g CRC:Enable          \
             -g ConfigRate:6        \
             -g CclkPin:PullUp      \
             -g M0Pin:PullUp        \
             -g M1Pin:PullUp        \
             -g M2Pin:PullUp        \
             -g ProgPin:PullUp      \
             -g DonePin:PullUp      \
             -g TckPin:PullUp       \
             -g TdiPin:PullUp       \
             -g TdoPin:PullUp       \
             -g TmsPin:PullUp       \
             -g UnusedPin:PullDown  \
             -g UserID:0xFFFFFFFF   \
             -g DCMShutDown:Disable \
             -g DONE_cycle:4        \
             -g GTS_cycle:5         \
             -g GWE_cycle:6         \
             -g LCK_cycle:3         \
             -g Match_cycle:Auto    \
             -g Security:None       \
             -g DonePipe:No         \
             -g DriveDone:No

$(PROJ).bit $(PROJ).bgn $(PROJ).drc: $(PROJ).ncd
	bitgen $(OPT_INTSTYLE) $(OPT_BITGEN) $(PROJ).ncd

###############################################################################

