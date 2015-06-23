/*****************************************************************************
* Filename:          C:\Users\mjlyons\workspace\vSPI\projnav\xps/drivers/spiifc_v1_00_a/src/spiifc_selftest.c
* Version:           1.00.a
* Description:       Contains a diagnostic self-test function for the spiifc driver
* Date:              Tue Feb 28 11:11:28 2012 (by Create and Import Peripheral Wizard)
*****************************************************************************/


/***************************** Include Files *******************************/

#include "spiifc.h"

/************************** Constant Definitions ***************************/


/************************** Variable Definitions ****************************/

extern Xuint32 LocalBRAM; /* User logic local memory (BRAM) base address */

/************************** Function Definitions ***************************/

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
XStatus SPIIFC_SelfTest(void * baseaddr_p)
{
  int     Index;
  Xuint32 baseaddr;
  Xuint8  Reg8Value;
  Xuint16 Reg16Value;
  Xuint32 Reg32Value;
  Xuint32 Mem32Value;

  /*
   * Check and get the device address
   */
  /*
   * Base Address maybe 0. Up to developer to uncomment line below.
  XASSERT_NONVOID(baseaddr_p != XNULL);
   */
  baseaddr = (Xuint32) baseaddr_p;

  xil_printf("******************************\n\r");
  xil_printf("* User Peripheral Self Test\n\r");
  xil_printf("******************************\n\n\r");

  /*
   * Write to user logic slave module register(s) and read back
   */
  xil_printf("User logic slave module test...\n\r");
  xil_printf("   - write 1 to slave register 0 word 0\n\r");
  SPIIFC_mWriteSlaveReg0(baseaddr, 0, 1);
  Reg32Value = SPIIFC_mReadSlaveReg0(baseaddr, 0);
  xil_printf("   - read %d from register 0 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 1 )
  {
    xil_printf("   - slave register 0 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 2 to slave register 1 word 0\n\r");
  SPIIFC_mWriteSlaveReg1(baseaddr, 0, 2);
  Reg32Value = SPIIFC_mReadSlaveReg1(baseaddr, 0);
  xil_printf("   - read %d from register 1 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 2 )
  {
    xil_printf("   - slave register 1 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 3 to slave register 2 word 0\n\r");
  SPIIFC_mWriteSlaveReg2(baseaddr, 0, 3);
  Reg32Value = SPIIFC_mReadSlaveReg2(baseaddr, 0);
  xil_printf("   - read %d from register 2 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 3 )
  {
    xil_printf("   - slave register 2 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 4 to slave register 3 word 0\n\r");
  SPIIFC_mWriteSlaveReg3(baseaddr, 0, 4);
  Reg32Value = SPIIFC_mReadSlaveReg3(baseaddr, 0);
  xil_printf("   - read %d from register 3 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 4 )
  {
    xil_printf("   - slave register 3 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 5 to slave register 4 word 0\n\r");
  SPIIFC_mWriteSlaveReg4(baseaddr, 0, 5);
  Reg32Value = SPIIFC_mReadSlaveReg4(baseaddr, 0);
  xil_printf("   - read %d from register 4 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 5 )
  {
    xil_printf("   - slave register 4 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 6 to slave register 5 word 0\n\r");
  SPIIFC_mWriteSlaveReg5(baseaddr, 0, 6);
  Reg32Value = SPIIFC_mReadSlaveReg5(baseaddr, 0);
  xil_printf("   - read %d from register 5 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 6 )
  {
    xil_printf("   - slave register 5 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 7 to slave register 6 word 0\n\r");
  SPIIFC_mWriteSlaveReg6(baseaddr, 0, 7);
  Reg32Value = SPIIFC_mReadSlaveReg6(baseaddr, 0);
  xil_printf("   - read %d from register 6 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 7 )
  {
    xil_printf("   - slave register 6 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 8 to slave register 7 word 0\n\r");
  SPIIFC_mWriteSlaveReg7(baseaddr, 0, 8);
  Reg32Value = SPIIFC_mReadSlaveReg7(baseaddr, 0);
  xil_printf("   - read %d from register 7 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 8 )
  {
    xil_printf("   - slave register 7 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 9 to slave register 8 word 0\n\r");
  SPIIFC_mWriteSlaveReg8(baseaddr, 0, 9);
  Reg32Value = SPIIFC_mReadSlaveReg8(baseaddr, 0);
  xil_printf("   - read %d from register 8 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 9 )
  {
    xil_printf("   - slave register 8 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 10 to slave register 9 word 0\n\r");
  SPIIFC_mWriteSlaveReg9(baseaddr, 0, 10);
  Reg32Value = SPIIFC_mReadSlaveReg9(baseaddr, 0);
  xil_printf("   - read %d from register 9 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 10 )
  {
    xil_printf("   - slave register 9 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 11 to slave register 10 word 0\n\r");
  SPIIFC_mWriteSlaveReg10(baseaddr, 0, 11);
  Reg32Value = SPIIFC_mReadSlaveReg10(baseaddr, 0);
  xil_printf("   - read %d from register 10 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 11 )
  {
    xil_printf("   - slave register 10 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 12 to slave register 11 word 0\n\r");
  SPIIFC_mWriteSlaveReg11(baseaddr, 0, 12);
  Reg32Value = SPIIFC_mReadSlaveReg11(baseaddr, 0);
  xil_printf("   - read %d from register 11 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 12 )
  {
    xil_printf("   - slave register 11 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 13 to slave register 12 word 0\n\r");
  SPIIFC_mWriteSlaveReg12(baseaddr, 0, 13);
  Reg32Value = SPIIFC_mReadSlaveReg12(baseaddr, 0);
  xil_printf("   - read %d from register 12 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 13 )
  {
    xil_printf("   - slave register 12 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 14 to slave register 13 word 0\n\r");
  SPIIFC_mWriteSlaveReg13(baseaddr, 0, 14);
  Reg32Value = SPIIFC_mReadSlaveReg13(baseaddr, 0);
  xil_printf("   - read %d from register 13 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 14 )
  {
    xil_printf("   - slave register 13 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 15 to slave register 14 word 0\n\r");
  SPIIFC_mWriteSlaveReg14(baseaddr, 0, 15);
  Reg32Value = SPIIFC_mReadSlaveReg14(baseaddr, 0);
  xil_printf("   - read %d from register 14 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 15 )
  {
    xil_printf("   - slave register 14 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - write 16 to slave register 15 word 0\n\r");
  SPIIFC_mWriteSlaveReg15(baseaddr, 0, 16);
  Reg32Value = SPIIFC_mReadSlaveReg15(baseaddr, 0);
  xil_printf("   - read %d from register 15 word 0\n\r", Reg32Value);
  if ( Reg32Value != (Xuint32) 16 )
  {
    xil_printf("   - slave register 15 word 0 write/read failed\n\r");
    return XST_FAILURE;
  }
  xil_printf("   - slave register write/read passed\n\n\r");

  /*
   * Write data to user logic BRAMs and read back
   */
  xil_printf("User logic BRAM test...\n\r");
  xil_printf("   - local BRAM address is 0x%08x\n\r", LocalBRAM);
  xil_printf("   - write pattern to local BRAM and read back\n\r");
  for ( Index = 0; Index < 256; Index++ )
  {
    SPIIFC_mWriteMemory(LocalBRAM+4*Index, 0xDEADBEEF);
    Mem32Value = SPIIFC_mReadMemory(LocalBRAM+4*Index);
    if ( Mem32Value != 0xDEADBEEF )
    {
      xil_printf("   - write/read BRAM failed on address 0x%08x\n\r", LocalBRAM+4*Index);
      return XST_FAILURE;
    }
  }
  xil_printf("   - write/read BRAM passed\n\n\r");

  /*
   * Enable all possible interrupts and clear interrupt status register(s)
   */
  xil_printf("Interrupt controller test...\n\r");
  Reg32Value = SPIIFC_mReadReg(baseaddr, SPIIFC_INTR_IPISR_OFFSET);
  xil_printf("   - IP (user logic) interrupt status : 0x%08x\n\r", Reg32Value);
  xil_printf("   - clear IP (user logic) interrupt status register\n\r");
  SPIIFC_mWriteReg(baseaddr, SPIIFC_INTR_IPISR_OFFSET, Reg32Value);
  xil_printf("   - enable all possible interrupt(s)\n\r");
  SPIIFC_EnableInterrupt(baseaddr_p);
  xil_printf("   - write/read interrupt register passed\n\n\r");

  return XST_SUCCESS;
}
