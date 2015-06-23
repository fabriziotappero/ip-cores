#########################
# configuration section #
#########################

# Defines the location of the EZ-USB SDK
ZTEXPREFIX=../../ztex

# The name of the jar archive
JARTARGET=ZtexBTCMiner.jar
# Java Classes that have to be build 
CLASSTARGETS=BTCMiner.class
# Extra dependencies for Java Classes
CLASSEXTRADEPS=

# ihx files (firmware ROM files) that have to be build 
IHXTARGETS=ztex_ufm1_15b1.ihx ztex_ufm1_15d4.ihx ztex_ufm1_15y1.ihx ztex_ufm1_15d.ihx ztex_ufm1_15y.ihx ztex_ufm1_15d4-nomac.ihx ztex_ufm1_15y1-nomac.ihx
# Extra Dependencies for ihx files
IHXEXTRADEPS=btcminer.h

# Extra files that should be included into th jar archive
EXTRAJARFLAGS=
EXTRAJARFILES=$(IHXTARGETS) fpga/ztex_ufm1_15b1.bit fpga/ztex_ufm1_15d1.bit fpga/ztex_ufm1_15d3.bit fpga/ztex_ufm1_15d4.bit fpga/ztex_ufm1_15y1.bit
# fpga/ztex_ufm1_15d.bit

################################
# DO NOT CHANAGE THE FOLLOWING #
################################
# includes the main Makefile
include $(ZTEXPREFIX)/Makefile.mk
