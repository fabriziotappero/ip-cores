#ifndef __EB_SYSCTRL_H__
#define __EB_SYSCTRL_H__
/* TODO: Better to stick this file in a ARM specific folder as most realview boards
 * tend to have this component
 */
#define SYS_ID			0x0000
#define SYS_SW			0x0004
#define SYS_LED			0x0008

#define SYS_OSC0		0x000C
#define SYS_OSC1		0x0010
#define SYS_OSC2		0x0014
#define SYS_OSC3		0x0018
#define SYS_OSC4		0x001C

#define SYS_LOCK		0x0020
#define SYS_100HZ		0x0024

#define SYS_CFGDATA0		0x0028
#define SYS_CFGDATA1		0x002C

#define SYS_FLAGS		0x0030
#define SYS_FLAGS_SET		0x0030
#define SYS_FLAGS_CLR		0x0034
#define SYS_NVFLAGS		0x0038
#define SYS_NVFLAGS_SET		0x0038
#define SYS_NVFLAGS_CLR		0x003C

#define SYS_PCICTL		0x0044
#define SYS_MCI			0x0048
#define SYS_FLASH		0x004C
#define SYS_CLCD		0x0050
#define SYS_CLCDSER		0x0054
#define SYS_BOOTCS		0x0058

#define SYS_24MHZ		0x005C
#define SYS_MISC		0x0060
#define SYS_DMAPSR0		0x0064
#define SYS_DMAPSR1		0x0068
#define SYS_DMAPSR2		0x006C
#define SYS_IOSEL		0x0070
#define SYS_PLDCTL1		0x0074
#define SYS_PLDCTL2		0x0078

#define SYS_BUSID		0x0080
#define SYS_PROCID1		0x0084
#define SYS_PROCID0		0x0088

#define SYS_OSCRESET0		0x008C
#define SYS_OSCRESET1		0x0090
#define SYS_OSCRESET2		0x0094
#define SYS_OSCRESET3		0x0098
#define SYS_OSCRESET4		0x009C


/* System Controller Lock/Unlock */
#define SYSCTRL_LOCK		0xFF
#define SYSCTRL_UNLOCK		0xA05F


#define ID_MASK_REV		0xF0000000
#define ID_MASK_HBI		0x0FFF0000
#define ID_MASK_BUILD		0x0000F000
#define ID_MASK_ARCH		0x00000F00
#define ID_MASK_FPGA		0x000000FF


#define SW_MASK_BOOTSEL		0x0000FF00
#define SW_MASK_GP		0x000000FF

#define LED_MASK_LED		0x000000FF

#define FLASH_WRITE_EN		0x1
#define FLASH_WRITE_DIS		0x0

#define CLCD_QVGA		(0 << 8) /* 320x240 */
#define CLDE_VGA		(1 << 8) /* 640x480 */
#define CLCD_SMALL		(2 << 8) /* 220x176 */
#define CLCD_SSP_CS		(1 << 7) /* SSP Chip Select */
#define CLCD_TS_EN		(1 << 6) /* Touch Screen Enable */
/* Different Voltages */
#define CLCD_NEG_EN		(1 << 5)
#define CLCD_3V5V_EN		(1 << 4)
#define CLCD_POS_EN		(1 << 3)
#define CLCD_IO_ON		(1 << 2)


/* Normal without DCC, no FIQ, recommended for SMP */
#define PLD_CTRL1_INTMOD_WITHOUT_DCC	(1 << 22)
/* Not Recommended */
#define PLD_CTRL1_INTMOD_WITH_DCC	(2 << 22)
/* For single cpu such as 1136 */
#define PLD_CTRL1_INTMOD_LEGACY		(4 << 22)

#endif	/* __EB_SYSCTRL_H__ */
