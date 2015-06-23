TECHNOLOGY=virtex5
#ifeq ("$(CONFIG_FPGA_LX50)","y")
#PART=xc5vlx50
#else
#ifeq ("$(CONFIG_FPGA_LX85)","y")
#PART=xc5vlx85
#else
#PART=xc5vlx110
#endif
#endif
PART=xc5vlx50
PACKAGE=ff1153
SPEED=-1
SYNFREQ=50
PROMGENPAR=-x xcf32p xcf32p -u 0 $(TOP).bit -p mcs -w -o gr-pci-xc5v

