# Makefile

#Paths
include ../../../../Paths.config
PATHGLOBALSIMDIR = ../../../../flw/simModelsim/


#targets
main:
	@echo ""
	@echo "Usage:"
	@echo "------"
	@echo "make <target>"
	@echo ""
	@echo "Make Targets for Modelsim:"
	@echo "--------------------------"
	@echo "CompModelsimSh      -> compiles VHDL sources with Modelsim using your shell; hit 'q' to quit!"
	@echo "CompSimModelsimSh   -> compiles and simulates VHDL sources with Modelsim using your shell; hit 'q' to quit!"
	@echo "CompModelsimGui     -> compiles VHDL sources with Modelsim using Modelsims GUI"
	@echo "CompSimModelsimGui  -> compiles and simulates VHDL sources with Modelsim using Modelsims GUI"
	@echo ""
	@echo ""

CompModelsimSh:
	$(LICENSE) $(MODELSIM) -do $(PATHGLOBALSIMDIR)CompShell.do -c

CompSimModelsimSh:
	$(LICENSE) $(MODELSIM) -do $(PATHGLOBALSIMDIR)CompSimShell.do -c

CompModelsimGui:
	$(LICENSE) $(MODELSIM) -do $(PATHGLOBALSIMDIR)Comp.do

CompSimModelsimGui:
	$(LICENSE) $(MODELSIM) -do $(PATHGLOBALSIMDIR)CompSim.do

