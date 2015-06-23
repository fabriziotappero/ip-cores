TECHNOLOGY=virtex4
ifeq ("$(CONFIG_FPGA_LX100)","y")
PART=xc4vlx100
else
ifeq ("$(CONFIG_FPGA_LX160)","y")
PART=xc4vlx160
else
ifeq ("$(CONFIG_FPGA_LX200)","y")
PART=xc4vlx200
else
PART=xc4vlx100
endif
endif
endif
PACKAGE=ff1513
SPEED=-10
SYNFREQ=50
PROMGENPAR=-x xcf32p xcf32p -u 0 $(TOP).bit -p mcs -w -o gr-cpci-xc4vlx100

