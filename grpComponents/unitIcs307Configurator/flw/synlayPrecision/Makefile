# Makefile

#Paths
include ../../../../Paths.config
PATHGLOBALSYNDIR = ../../../../flw/synlayPrecision/

#targets
main:
	@echo ""
	@echo "usage:"
	@echo "------"
	@echo "make <target>"
	@echo ""
	@echo "Make Targets for Precision:"
	@echo "---------------------------"
	@echo "SynPrecisionSh      -> does synthesis with Precision on you shell"
	@echo "SynLayPrecisionSh   -> does synthesis and place&route with Precsion on your shell"
	@echo "SynPrecisionGui     -> does synthesis with Precision using Precisions GUI"
	@echo "SynLayPrecisionGui  -> does synthesis and place&route with Precision using Precisions GUI"
	@echo "ConfigureImpact     -> configures your Xilinx FPGA; WARNING: CHECK YOUR SYNLAY RESULTS FIRST!"
	@echo ""
	@echo ""
		

SynPrecisionSh:
	$(LICENSE) XILINX=$(XILINXDIR) $(PRECISION) -shell -file $(PATHGLOBALSYNDIR)Syn.tcl;

SynPrecisionGui:
	$(LICENSE) XILINX=$(XILINXDIR) $(PRECISION) -file $(PATHGLOBALSYNDIR)Syn.tcl

SynLayPrecisionSh:
	XILINX=$(XILINXDIR) source ./xilinxlibs.sh; $(LICENSE) XILINX=$(XILINXDIR) QUARTUS_ROOTDIR=$(QUARTUSDIR) $(PRECISION) -shell -file $(PATHGLOBALSYNDIR)SynLay.tcl

SynLayPrecisionGui:
	XILINX=$(XILINXDIR) source ./xilinxlibs.sh;	$(LICENSE) XILINX=$(XILINXDIR) QUARTUS_ROOTDIR=$(QUARTUSDIR) $(PRECISION) -file $(PATHGLOBALSYNDIR)SynLay.tcl

ConfigureImpact:
	XILINX=$(XILINXDIR) source ./xilinxlibs.sh; $(LICENSE) XILINX=$(XILINXDIR) QUARTUS_ROOTDIR=$(QUARTUSDIR) $(PRECISION) -shell -file $(PATHGLOBALSYNDIR)ConfigureFpga.tcl
