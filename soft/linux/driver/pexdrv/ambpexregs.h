//****************** File AmbpexRegs.h *********************************
// AMBPEX card definitions
//
//	Copyright (c) 2007, Instrumental Systems,Corp.
//  Written by Dorokhin Andrey
//
//  History:
//  19-03-07 - builded
//
//*******************************************************************

#ifndef _AMBPEXREGS_H_
#define _AMBPEXREGS_H_

#ifndef __KERNEL__
#include <stdint.h>
typedef uint64_t u64;
typedef uint32_t u32;
typedef uint16_t u16;
typedef uint8_t  u8;
#endif

#define PCI_EXPROM_SIZE 512

#define PE_MAIN_ADDR 0x000
#define PE_FIFO_ADDR 0x100
#define PE_EXT_FIFO_ADDR 0x400

#define PE_MAIN_ID		0x0013
#define PE_FIFO_ID		0x0014
#define PE_EXT_FIFO_ID	0x0018

// PCI-Express Main block Registers Layout
typedef volatile struct _PE_MAIN_REGISTERS {
    u32   BlockId;	// 0 (0x00) Control MAIN block identification register (only read)
    u32   BlockVer;	// 1 (0x04) Control MAIN block version register (only read)
    u32   DeviceId;	// 2 (0x08) Device identification register (only read)
    u32   DeviceRev;	// 3 (0x0C) Device revision register (only read)
    u32   PldVersion;	// 4 (0x10) PLD version register (only read)
    u32   BlockNum;	// 5 (0x14) Number of control blocks (only read)
    u32   DpramOffset;// 6 (0x18) (only read)
    u32   DpramSize;	// 7 (0x1C) (only read)
    u32   BrdMode;	// 8 (0x20) Board control register
    u32   IrqMask;	// 9 (0x24) Interrupt mask register
    u32   IrqInv;		// 10(0x0A) (0x28) Interrupt inversion register
    u32   Leds;		// 11(0x0B) (0x2C) LEDs control register
    u32   Reg12;		// 12(0x0C) (0x30) REG12 - Reserved space
    u32   PSynx;		// 13(0x0D) (0x34) not use
    u32   Reg14;		// 14(0x0E) (0x38) REG14 - Reserved space
    u32   Reg15;		// 15(0x0F) (0x3C) REG15 - Reserved space
    u32   BrdStatus;	// 16(0x10) (0x40) Board status register
    u32   Reg17;		// 17(0x11) (0x44) REG17 - Reserved space
    u32   Reg18;		// 18(0x12) (0x48) REG18 - Reserved space
    u32   Sem0;		// 19(0x13) (0x4C) not use
    u32   PldConf;	// 20(0x14) (0x50) not use
    u32   Reg21;		// 21(0x15) (0x54) REG21 - Reserved space
    u32   SpdCtrl;	// 22(0x16) (0x58) SPD&ADM_ROM Access Control register
    u32   SpdAddr;	// 23(0x17) (0x5C) Memory address register
    u32   SpdDataLo;	// 24(0x18) (0x60) Memory low data register
    u32   SpdDataHi;	// 25(0x19) (0x64) Memory high address register
    u32   LbData;		// 26(0x1A) (0x68) Loopback mode data register
    u32   Reg27;		// 27(0x1B) (0x6C) REG27 - Reserved space
    u32   JtagCnt;	// 28(0x1C) (0x70) number of shift bit register
    u32   JtagTms;	// 29(0x1D) (0x74) signal TMS register
    u32   JtagTdi;	// 30(0x1E) (0x78) signal TDI register
    u32   JtagTdo;	// 31(0x1F) (0x7C) signal TDO register
} PE_MAIN_REGISTERS, *PPE_MAIN_REGISTERS;

// Numbers of PCI-Express Main block Registers
typedef enum _PE_MAIN_ADDR_REG {
    PEMAINadr_BLOCK_ID		= 0x00, // 0x00
    PEMAINadr_BLOCK_VER		= 0x08, // 0x01
    PEMAINadr_DEVICE_ID		= 0x10, // 0x02
    PEMAINadr_DEVICE_REV	= 0x18, // 0x03
    PEMAINadr_PLD_VER		= 0x20, // 0x04
    PEMAINadr_BLOCK_CNT		= 0x28, // 0x05
    PEMAINadr_DPRAM_OFFSET	= 0x30, // 0x06
    PEMAINadr_DPRAM_SIZE	= 0x38, // 0x07
    PEMAINadr_BRD_MODE		= 0x40, // 0x08
    PEMAINadr_IRQ_MASK		= 0x48, // 0x09
    PEMAINadr_IRQ_INV		= 0x50, // 0x0A
    PEMAINadr_LEDS			= 0x58, // 0x0B
    PEMAINadr_BRD_STATUS	= 0x80, // 0x10
    PEMAINadr_SPD_CTRL		= 0xB0, // 0x16
    PEMAINadr_SPD_ADDR		= 0xB8, // 0x17
    PEMAINadr_SPD_DATAL		= 0xC0, // 0x18
    PEMAINadr_SPD_DATAH		= 0xC8, // 0x19
    PEMAINadr_LB_DATA		= 0xD0, // 0x1A
    PEMAINadr_JTAG_CNT		= 0xE0, // 0x1C
    PEMAINadr_JTAG_TMS		= 0xE8, // 0x1D
    PEMAINadr_JTAG_TDI		= 0xF0, // 0x1E
    PEMAINadr_JTAG_TDO		= 0xF8, // 0x1F
} PE_MAIN_ADDR_REG;

// PCI-Express FIFO block Registers Layout
typedef volatile struct _PE_FIFO_REGISTERS {
    u32   BlockId;	// 0 (0x00) Control FIFO block identification register (only read)
    u32   BlockVer;	// 1 (0x04) Control FIFO block version register (only read)
    u32   FifoId;		// 2 (0x08) FIFO identification register (only read)
    u32   FifoNumber;	// 3 (0x0C) FIFO number register (only read)
    u32   DmaSize;	// 4 (0x10) DMA size register (only read) - NOT use by EXT
    u32   Reg5;		// 5 (0x14) REG5 - Reserved space
    u32   Reg6;		// 6 (0x18) REG6 - Reserved space
    u32   Reg7;		// 7 (0x1C) REG7 - Reserved space
    u32   FifoCtlr;	// 8 (0x20) FIFO control register - NOT use by EXT
    u32   DmaCtlr;	// 9 (0x24) DMA control register
    u32   Reg10;		// 10(0x0A) (0x28) REG10 - Reserved space
    u32   Reg11;		// 11(0x0B) (0x2C) REG11 - Reserved space
    u32   Reg12;		// 12(0x0C) (0x30) REG12 - Reserved space
    u32   Reg13;		// 13(0x0D) (0x34) REG13 - Reserved space
    u32   Reg14;		// 14(0x0E) (0x38) REG14 - Reserved space
    u32   Reg15;		// 15(0x0F) (0x3C) REG15 - Reserved space
    u32   FifoStatus;	// 16(0x10) (0x40) FIFO status register
    u32   FlagClr;	// 17(0x11) (0x44) Flags clear register
    u32   Reg18;		// 18(0x12) (0x48) REG18 - Reserved space
    u32   Reg19;		// 19(0x13) (0x4C) REG19 - Reserved space
    u32   PciAddrLo;	// 20(0x14) (0x50) PCI address (low part) register
    u32   PciAddrHi;	// 21(0x15) (0x54) PCI address (high part) register
    u32   PciSize;	// 22(0x16) (0x58) block size register - NOT use by EXT
    u32   LocalAddr;	// 23(0x17) (0x5C) Local address register
    u32   Reg24;		// 24(0x18) (0x60) REG24 - Reserved space
    u32   Reg25;		// 25(0x19) (0x64) REG25 - Reserved space
    u32   Reg26;		// 26(0x1A) (0x68) REG26 - Reserved space
    u32   Reg27;		// 27(0x1B) (0x6C) REG27 - Reserved space
    u32   Reg28;		// 28(0x1C) (0x70) REG28 - Reserved space
    u32   Reg29;		// 29(0x1D) (0x74) REG29 - Reserved space
    u32   Reg30;		// 30(0x1E) (0x78) REG30 - Reserved space
    u32   Reg31;		// 31(0x1F) (0x7C) REG31 - Reserved space
} PE_FIFO_REGISTERS, *PPE_FIFO_REGISTERS;

// Numbers of PCI-Express FIFO block Registers
typedef enum _PE_FIFO_ADDR_REG {
    PEFIFOadr_BLOCK_ID		= 0x00, // 0x00
    PEFIFOadr_BLOCK_VER		= 0x08, // 0x01
    PEFIFOadr_FIFO_ID		= 0x10, // 0x02
    PEFIFOadr_FIFO_NUM		= 0x18, // 0x03
    PEFIFOadr_DMA_SIZE		= 0x20, // 0x04 - RESOURCE by EXT
    PEFIFOadr_FIFO_CTRL		= 0x40, // 0x08 - DMA_MODE by EXT
    PEFIFOadr_DMA_CTRL		= 0x48, // 0x09
    PEFIFOadr_FIFO_STATUS	= 0x80, // 0x10
    PEFIFOadr_FLAG_CLR		= 0x88, // 0x11
    PEFIFOadr_PCI_ADDRL		= 0xA0, // 0x14
    PEFIFOadr_PCI_ADDRH		= 0xA8, // 0x15
    PEFIFOadr_PCI_SIZE		= 0xB0, // 0x16 - NOT use by EXT
    PEFIFOadr_LOCAL_ADR		= 0xB8, // 0x17
} PE_FIFO_ADDR_REG;

// Board Control register 0x40 (PE_MAIN)
typedef union _BRD_MODE {
    u16 AsWhole; // Board Control Register as a Whole Word
    struct { // Board Control Register as Bit Pattern
        u16	RstClkOut	: 1, // Output Clock Reset for ADMPLD
        Sleep		: 1, // Sleep mode for ADMPLD
        RstClkIn	: 1, // Input Clock Reset for ADMPLD
        Reset		: 1, // Reset for ADMPLD
        RegLoop		: 1, // Register operation loopback mode
        Res			: 3, // Reserved
        OutFlags	: 8; // Output Flags
    } ByBits;
} BRD_MODE, *PBRD_MODE;

// Board Status register 0x80 (PE_MAIN)
typedef union _BRD_STATUS {
    u16 AsWhole; // Board Status Register as a Whole Word
    struct { // Board Status Register as Bit Pattern
        u16	SlvDcm		: 1, // Capture Input Clock from ADMPLD
        NotUse		: 7, //
        InFlags		: 8; // Input Flags
    } ByBits;
} BRD_STATUS, *PBRD_STATUS;

// SPD Control register 0xB0 (PE_MAIN)
typedef union _SPD_CTRL {
    u16 AsWhole; // SPD Control Register as a Whole Word
    struct { // SPD Control Register as Bit Pattern
        u16	ReadOp		: 1, // Read Operation
        WriteOp		: 1, // Write Operation
        Res			: 2, // Reserved
        WriteEn		: 1, // Write Enable
        WriteDis	: 1, // Read Disable
        Res1		: 2, // Reserved
        SpdId		: 3, // SPD Identification
        Res2		: 3, // Reserved
        Sema		: 1, // Semaphor
        Ready		: 1; // Data Ready
    } ByBits;
} SPD_CTRL, *PSPD_CTRL;

// FIFO ID register 0x10 (PE_FIFO)
typedef union _FIFO_ID {
    u16 AsWhole; // FIFO ID Register as a Whole Word
    struct { // FIFO ID Register as Bit Pattern
        u16	Size		: 12, // FIFO size (32-bit words)
        Dir			: 4; // DMA direction
    } ByBits;
} FIFO_ID, *PFIFO_ID;

// FIFO Control register 0x40 (PE_FIFO)
typedef union _FIFO_CTRL {
    u16 AsWhole; // FIFO Control Register as a Whole Word
    struct { // FIFO Control Register as Bit Pattern
        u16	Reset		: 1, // FIFO Reset
        DrqEn		: 1, // DMA Request enable
        Loopback	: 1, // Not use
        TstCnt		: 1, // 32-bit Test Counter enable
        Res			: 12; // Reserved
    } ByBits;
} FIFO_CTRL, *PFIFO_CTRL;

// DMA Mode register 0x40 (PE_EXT_FIFO)
typedef union _DMA_MODE_EXT {
    u16 AsWhole; // DMA Mode Register as a Whole Word
    struct { // FIFO Control Register as Bit Pattern
        u16	SGModeEnbl	: 1, // 1 - Scatter/Gather mode enable
        DemandMode	: 1, // 1 - always
        Dir			: 1, // DMA direction
        Res0		: 2, // Reserved
        IntEnbl		: 1, // Interrrupt enable (End of DMA)
        Res			: 10; // Reserved
    } ByBits;
} DMA_MODE_EXT, *PDMA_MODE_EXT;

// DMA Control register 0x48 (PE_FIFO)
typedef union _DMA_CTRL {
    u16 AsWhole; // DMA Control Register as a Whole Word
    struct { // DMA Control Register as Bit Pattern
        u16	Start		: 1, // DMA start
        Stop		: 1, // DMA stop
        SGEnbl		: 1, // Scatter/Gather mode enable
        Res0		: 1, // Reserved
        DemandMode	: 1, // 1 - always
        IntEnbl		: 1, // Interrrupt enable (End of DMA)
        Res			: 10; // Reserved
    } ByBits;
} DMA_CTRL, *PDMA_CTRL;

// DMA Control register 0x48 (PE_EXT_FIFO)
typedef union _DMA_CTRL_EXT {
    u16 AsWhole; // DMA Control Register as a Whole Word
    struct { // DMA Control Register as Bit Pattern
        u16	Start		: 1, // DMA start/stop
        Res0		: 2, // Reserved
        Pause		: 1, // DMA pause
        ResetFIFO	: 1, // FIFO Reset
        Res			: 11; // Reserved
    } ByBits;
} DMA_CTRL_EXT, *PDMA_CTRL_EXT;

// FIFO Status register 0x80 (PE_FIFO)
typedef union _FIFO_STATUS {
    u16 AsWhole; // FIFO Status Register as a Whole Word
    struct { // FIFO Status Register as Bit Pattern
        u16	DmaStat	: 4, // DMA Status
        DmaEot		: 1, // DMA block Complete (End of Transfer)
        SGEot		: 1, // Scatter/Gather End of Transfer (all blocks complete)
        IntErr		: 1, // not serviced of interrrupt - ERROR!!! block leave out!!!
        IntRql		: 1, // Interrrupt request
        //				DmaErr		: 1, // DMA channel error
        DscrErr		: 1, // Descriptor error
        NotUse		: 3, // Not Use
        Sign		: 4; // Signature (0x0A)
    } ByBits;
} FIFO_STATUS, *PFIFO_STATUS;

// Numbers of Tetrad Registers
typedef enum _TETRAD_REG {
    TRDadr_STATUS,
    TRDadr_DATA,
    TRDadr_CMD_ADR,
    TRDadr_CMD_DATA
} TETRAD_REG, *PTETRAD_REG;

typedef enum _AmbStatusRegBits {
    AMB_statCMDRDY = 1
                 } AmbStatusRegBits;

// Main Select of Interrupts & DMA channels Register (MODE0 +16)
typedef union _MAIN_SELX {
    u32 AsWhole; // Board Mode Register as a Whole Word
    struct { // Mode Register as Bit Pattern
        u32	IrqNum	: 4, // Interrupt number
        Res1	: 4, // Reserved
        DmaTetr	: 4, // Tetrad number for DMA channel X
        DrqEnbl	: 1, // DMA request enable
        DmaMode	: 3; // DMA mode
    } ByBits;
} MAIN_SELX, *PMAIN_SELX;

#define REG_SIZE	0x00001000		// register size
#define TETRAD_SIZE	0x00004000		// tetrad size
#define ADM_SIZE	0x00020000		// ADM interface size

// Numbers of Registers
typedef enum _AMB_AUX_NUM_REG {
    AUXnr_ADM_PLD_DATA			= 0,
    AUXnr_ADM_PLD_MODE_STATUS	= 1,
    AUXnr_SUBMOD_ID_ROM			= 2,
    AUXnr_DSP_PLD_DATA			= 3,
    AUXnr_DSP_PLD_MODE_STATUS	= 4,
} AMB_AUX_NUM_REG;

#endif //_AMBPEXREGS_H_
