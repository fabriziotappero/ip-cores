/*****************************************************************************
* Filename:          C:\Users\mjlyons\workspace\vSPI\projnav\xps/drivers/spiifc_v1_00_a/src/spiifc.h
* Version:           1.00.a
* Description:       spiifc Driver Header File
* Date:              Tue Feb 28 11:11:28 2012 (by Create and Import Peripheral Wizard)
*****************************************************************************/

#ifndef SPIIFC_H
#define SPIIFC_H

/***************************** Include Files *******************************/

#include "xbasic_types.h"
#include "xstatus.h"
#include "xil_io.h"

/************************** Constant Definitions ***************************/


/**
 * User Logic Slave Space Offsets
 * -- SLV_REG0 : user logic slave module register 0
 * -- SLV_REG1 : user logic slave module register 1
 * -- SLV_REG2 : user logic slave module register 2
 * -- SLV_REG3 : user logic slave module register 3
 * -- SLV_REG4 : user logic slave module register 4
 * -- SLV_REG5 : user logic slave module register 5
 * -- SLV_REG6 : user logic slave module register 6
 * -- SLV_REG7 : user logic slave module register 7
 * -- SLV_REG8 : user logic slave module register 8
 * -- SLV_REG9 : user logic slave module register 9
 * -- SLV_REG10 : user logic slave module register 10
 * -- SLV_REG11 : user logic slave module register 11
 * -- SLV_REG12 : user logic slave module register 12
 * -- SLV_REG13 : user logic slave module register 13
 * -- SLV_REG14 : user logic slave module register 14
 * -- SLV_REG15 : user logic slave module register 15
 */
#define SPIIFC_USER_SLV_SPACE_OFFSET (0x00000000)
#define SPIIFC_SLV_REG0_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000000)
#define SPIIFC_SLV_REG1_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000004)
#define SPIIFC_SLV_REG2_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000008)
#define SPIIFC_SLV_REG3_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x0000000C)
#define SPIIFC_SLV_REG4_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000010)
#define SPIIFC_SLV_REG5_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000014)
#define SPIIFC_SLV_REG6_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000018)
#define SPIIFC_SLV_REG7_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x0000001C)
#define SPIIFC_SLV_REG8_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000020)
#define SPIIFC_SLV_REG9_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000024)
#define SPIIFC_SLV_REG10_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000028)
#define SPIIFC_SLV_REG11_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x0000002C)
#define SPIIFC_SLV_REG12_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000030)
#define SPIIFC_SLV_REG13_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000034)
#define SPIIFC_SLV_REG14_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x00000038)
#define SPIIFC_SLV_REG15_OFFSET (SPIIFC_USER_SLV_SPACE_OFFSET + 0x0000003C)

/**
 * Interrupt Controller Space Offsets
 * -- INTR_DGIER : device (peripheral) global interrupt enable register
 * -- INTR_ISR   : ip (user logic) interrupt status register
 * -- INTR_IER   : ip (user logic) interrupt enable register
 */
#define SPIIFC_INTR_CNTRL_SPACE_OFFSET (0x00000100)
#define SPIIFC_INTR_DGIER_OFFSET (SPIIFC_INTR_CNTRL_SPACE_OFFSET + 0x0000001C)
#define SPIIFC_INTR_IPISR_OFFSET (SPIIFC_INTR_CNTRL_SPACE_OFFSET + 0x00000020)
#define SPIIFC_INTR_IPIER_OFFSET (SPIIFC_INTR_CNTRL_SPACE_OFFSET + 0x00000028)

/**
 * Interrupt Controller Masks
 * -- INTR_TERR_MASK : transaction error
 * -- INTR_DPTO_MASK : data phase time-out
 * -- INTR_IPIR_MASK : ip interrupt requeset
 * -- INTR_RFDL_MASK : read packet fifo deadlock interrupt request
 * -- INTR_WFDL_MASK : write packet fifo deadlock interrupt request
 * -- INTR_IID_MASK  : interrupt id
 * -- INTR_GIE_MASK  : global interrupt enable
 * -- INTR_NOPEND    : the DIPR has no pending interrupts
 */
#define INTR_TERR_MASK (0x00000001UL)
#define INTR_DPTO_MASK (0x00000002UL)
#define INTR_IPIR_MASK (0x00000004UL)
#define INTR_RFDL_MASK (0x00000020UL)
#define INTR_WFDL_MASK (0x00000040UL)
#define INTR_IID_MASK (0x000000FFUL)
#define INTR_GIE_MASK (0x80000000UL)
#define INTR_NOPEND (0x80)

/**************************** Type Definitions *****************************/


/***************** Macros (Inline Functions) Definitions *******************/

/**
 *
 * Write a value to a SPIIFC register. A 32 bit write is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is written.
 *
 * @param   BaseAddress is the base address of the SPIIFC device.
 * @param   RegOffset is the register offset from the base to write to.
 * @param   Data is the data written to the register.
 *
 * @return  None.
 *
 * @note
 * C-style signature:
 * 	void SPIIFC_mWriteReg(Xuint32 BaseAddress, unsigned RegOffset, Xuint32 Data)
 *
 */
#define SPIIFC_mWriteReg(BaseAddress, RegOffset, Data) \
 	Xil_Out32((BaseAddress) + (RegOffset), (Xuint32)(Data))

/**
 *
 * Read a value from a SPIIFC register. A 32 bit read is performed.
 * If the component is implemented in a smaller width, only the least
 * significant data is read from the register. The most significant data
 * will be read as 0.
 *
 * @param   BaseAddress is the base address of the SPIIFC device.
 * @param   RegOffset is the register offset from the base to write to.
 *
 * @return  Data is the data from the register.
 *
 * @note
 * C-style signature:
 * 	Xuint32 SPIIFC_mReadReg(Xuint32 BaseAddress, unsigned RegOffset)
 *
 */
#define SPIIFC_mReadReg(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (RegOffset))


/**
 *
 * Write/Read 32 bit value to/from SPIIFC user logic slave registers.
 *
 * @param   BaseAddress is the base address of the SPIIFC device.
 * @param   RegOffset is the offset from the slave register to write to or read from.
 * @param   Value is the data written to the register.
 *
 * @return  Data is the data from the user logic slave register.
 *
 * @note
 * C-style signature:
 * 	void SPIIFC_mWriteSlaveRegn(Xuint32 BaseAddress, unsigned RegOffset, Xuint32 Value)
 * 	Xuint32 SPIIFC_mReadSlaveRegn(Xuint32 BaseAddress, unsigned RegOffset)
 *
 */
#define SPIIFC_mWriteSlaveReg0(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG0_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg1(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG1_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg2(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG2_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg3(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG3_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg4(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG4_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg5(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG5_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg6(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG6_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg7(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG7_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg8(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG8_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg9(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG9_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg10(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG10_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg11(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG11_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg12(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG12_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg13(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG13_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg14(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG14_OFFSET) + (RegOffset), (Xuint32)(Value))
#define SPIIFC_mWriteSlaveReg15(BaseAddress, RegOffset, Value) \
 	Xil_Out32((BaseAddress) + (SPIIFC_SLV_REG15_OFFSET) + (RegOffset), (Xuint32)(Value))

#define SPIIFC_mReadSlaveReg0(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG0_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg1(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG1_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg2(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG2_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg3(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG3_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg4(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG4_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg5(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG5_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg6(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG6_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg7(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG7_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg8(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG8_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg9(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG9_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg10(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG10_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg11(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG11_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg12(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG12_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg13(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG13_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg14(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG14_OFFSET) + (RegOffset))
#define SPIIFC_mReadSlaveReg15(BaseAddress, RegOffset) \
 	Xil_In32((BaseAddress) + (SPIIFC_SLV_REG15_OFFSET) + (RegOffset))

/**
 *
 * Write/Read 32 bit value to/from SPIIFC user logic memory (BRAM).
 *
 * @param   Address is the memory address of the SPIIFC device.
 * @param   Data is the value written to user logic memory.
 *
 * @return  The data from the user logic memory.
 *
 * @note
 * C-style signature:
 * 	void SPIIFC_mWriteMemory(Xuint32 Address, Xuint32 Data)
 * 	Xuint32 SPIIFC_mReadMemory(Xuint32 Address)
 *
 */
#define SPIIFC_mWriteMemory(Address, Data) \
 	Xil_Out32(Address, (Xuint32)(Data))
#define SPIIFC_mReadMemory(Address) \
 	Xil_In32(Address)

/************************** Function Prototypes ****************************/


/**
 *
 * Enable all possible interrupts from SPIIFC device.
 *
 * @param   baseaddr_p is the base address of the SPIIFC device.
 *
 * @return  None.
 *
 * @note    None.
 *
 */
void SPIIFC_EnableInterrupt(void * baseaddr_p);

/**
 *
 * Example interrupt controller handler.
 *
 * @param   baseaddr_p is the base address of the SPIIFC device.
 *
 * @return  None.
 *
 * @note    None.
 *
 */
void SPIIFC_Intr_DefaultHandler(void * baseaddr_p);

/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the SPIIFC instance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus SPIIFC_SelfTest(void * baseaddr_p);

#endif /** SPIIFC_H */
