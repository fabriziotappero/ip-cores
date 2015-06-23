TECHNOLOGY=virtex2p
PART=xc2vp30
PACKAGE=ff896
SPEED=-7
SYNFREQ=100
#PROMGENPAR=-x xcf32p -u 0 $(TOP).bit -p mcs -w -o digilent-xup-xc2vp
PROMGENPAR=-x xcf32p -i 0 -ver 0 $(TOP).bit -ver 1 $(TOP).bit -p mcs -w -o digilent-xup-xc2vp

MANUFACTURER=Xilinx
MGCPART=2vp30$(PACKAGE)
MGCTECHNOLOGY={VIRTEX-II PRO}
MGCPACKAGE=$(PACKAGE)

