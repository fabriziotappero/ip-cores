/*****************************************************************************
* Filename:          C:\Users\mjlyons\workspace\vSPI\projnav\xps/drivers/spiifc_v1_00_a/src/spiifc.c
* Version:           1.00.a
* Description:       spiifc Driver Source File
* Date:              Tue Feb 28 11:11:28 2012 (by Create and Import Peripheral Wizard)
*****************************************************************************/


/***************************** Include Files *******************************/

#include "spiifc.h"

/************************** Function Definitions ***************************/

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
void SPIIFC_EnableInterrupt(void * baseaddr_p)
{
  Xuint32 baseaddr;
  baseaddr = (Xuint32) baseaddr_p;

  /*
   * Enable all interrupt source from user logic.
   */
  SPIIFC_mWriteReg(baseaddr, SPIIFC_INTR_IPIER_OFFSET, 0x00000001);

  /*
   * Set global interrupt enable.
   */
  SPIIFC_mWriteReg(baseaddr, SPIIFC_INTR_DGIER_OFFSET, INTR_GIE_MASK);
}

/**
 *
 * Example interrupt controller handler for SPIIFC device.
 * This is to show example of how to toggle write back ISR to clear interrupts.
 *
 * @param   baseaddr_p is the base address of the SPIIFC device.
 *
 * @return  None.
 *
 * @note    None.
 *
 */
void SPIIFC_Intr_DefaultHandler(void * baseaddr_p)
{
  Xuint32 baseaddr;
  Xuint32 IntrStatus;
Xuint32 IpStatus;
  baseaddr = (Xuint32) baseaddr_p;

  {
    xil_printf("User logic interrupt! \n\r");
    IpStatus = SPIIFC_mReadReg(baseaddr, SPIIFC_INTR_IPISR_OFFSET);
    SPIIFC_mWriteReg(baseaddr, SPIIFC_INTR_IPISR_OFFSET, IpStatus);
  }

}

