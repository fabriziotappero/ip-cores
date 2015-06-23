/* Vendor codes */
#define VENDOR_GAISLER   0x01
#define VENDOR_PENDER    0x02
#define VENDOR_ESA       0x04
#define VENDOR_OPENCORES 0x08
#define VENDOR_RADIONOR  0x0F
#define VENDOR_GLEICHMANN 0x10


/* Gaisler cores */
#define GAISLER_LEON2DSU 0x002
#define GAISLER_LEON3    0x003
#define GAISLER_LEON3DSU 0x004
#define GAISLER_ETHAHB   0x005
#define GAISLER_APBMST   0x006
#define GAISLER_AHBUART  0x007
#define GAISLER_SRCTRL   0x008
#define GAISLER_SDCTRL   0x009
#define GAISLER_SSRCTRL  0x00A
#define GAISLER_APBUART  0x00C
#define GAISLER_IRQMP    0x00D
#define GAISLER_AHBRAM   0x00E
#define GAISLER_GPTIMER  0x011
#define GAISLER_PCITRG   0x012
#define GAISLER_PCISBRG  0x013
#define GAISLER_PCIFBRG  0x014
#define GAISLER_PCITRACE 0x015
#define GAISLER_PCIDMA   0x016
#define GAISLER_AHBTRACE 0x017
#define GAISLER_ETHDSU   0x018
#define GAISLER_CANAHB   0x019
#define GAISLER_GRGPIO   0x01A
#define GAISLER_AHBROM   0x01B
#define GAISLER_AHBJTAG  0x01C
#define GAISLER_ETHMAC   0x01D
#define GAISLER_SPW      0x01F
#define GAISLER_SPACEWIRE 0x01F
#define GAISLER_AHB2AHB  0x020
#define GAISLER_USBCTRL  0x021
#define GAISLER_USBDCL   0x022
#define GAISLER_DDRMP    0x023
#define GAISLER_ATACTRL  0x024
#define GAISLER_DDRSP    0x025
#define GAISLER_EHCI     0x026
#define GAISLER_UHCI     0x027
#define GAISLER_I2CMST   0x028

#define GAISLER_NUHOSP3  0x02b

#define GAISLER_SPICTRL  0x02D

#define GAISLER_GRTM     0x030
#define GAISLER_GRTC     0x031
#define GAISLER_GRPW     0x032
#define GAISLER_GRCTM    0x033
#define GAISLER_GRHCAN   0x034
#define GAISLER_GRFIFO   0x035
#define GAISLER_GRADCDAC 0x036
#define GAISLER_GRPULSE  0x037
#define GAISLER_GRTIMER  0x038
#define GAISLER_AHB2PP   0x039
#define GAISLER_GRVERSION 0x03A

#define GAISLER_FTAHBRAM 0x050
#define GAISLER_FTSRCTRL 0x051
#define GAISLER_AHBSTAT  0x052
#define GAISLER_LEON3FT  0x053
#define GAISLER_FTMCTRL  0x054
#define GAISLER_FTSDCTRL 0x055
#define GAISLER_FTSRCTRL8 0x056

#define GAISLER_KBD      0x060
#define GAISLER_VGA      0x061
#define GAISLER_LOGAN    0x062
#define GAISLER_SVGA     0x063

#define GAISLER_B1553BC  0x070
#define GAISLER_B1553RT  0x071
#define GAISLER_B1553BRM 0x072

#define GAISLER_PCIF	 0x75

#define GAISLER_SATCAN   0x080
#define GAISLER_CANMUX   0x081

#define GAISLER_PIPEWRAPPER 0xffa
#define GAISLER_LEON2    0xffb
#define GAISLER_L2IRQ    0xffc /* internal device: leon2 interrupt controller */
#define GAISLER_L2TIME   0xffd /* internal device: leon2 timer */
#define GAISLER_L2C      0xffe /* internal device: leon2compat */
#define GAISLER_PLUGPLAY 0xfff /* internal device: plug & play configarea */

/* ESA cores */
#define  ESA_LEON2       0x002
#define  ESA_LEON2APB    0x003
#define  ESA_L2IRQ       0x005
#define  ESA_L2TIMER     0x006
#define  ESA_L2UART      0x007
#define  ESA_L2CFG       0x008
#define  ESA_L2IO        0x009
#define  ESA_MCTRL       0x00F
#define  ESA_PCIARB      0x010
#define  ESA_HURRICANE   0x011
#define  ESA_SPW_RMAP    0x012
#define  ESA_AHBUART     0x013
#define  ESA_SPWA        0x014
#define  ESA_BOSCHCAN    0x015
#define  ESA_L2IRQ2      0x016
#define  ESA_L2STAT      0x017
#define  ESA_L2WPROT     0x018
#define  ESA_L2WPROT2    0x019

/* GLEICHMANN cores */
#define GLEICHMANN_CUSTOM 0x001
#define GLEICHMANN_GEOLCD01 0x002
#define GLEICHMANN_DAC 0x003

