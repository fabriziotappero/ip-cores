/*
--
--    opb_usblite - opb_uartlite replacement
--
--    opb_usblite is using components from Rudolf Usselmann see
--    http://www.opencores.org/cores/usb_phy/
--    and Joris van Rantwijk see http://www.xs4all.nl/~rjoris/fpga/usb.html
--
--    Copyright (C) 2010 Ake Rehnman
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU Lesser General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU Lesser General Public License for more details.
--
--    You should have received a copy of the GNU Lesser General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
*/

#ifndef USBLITE_L_H /* prevent circular inclusions */
#define USBLITE_L_H /* by using protection macros */

#ifdef __cplusplus
extern "C" {
#endif

/* register offsets */

#define XUL_RX_FIFO_OFFSET              0   /* receive FIFO, read only */
#define XUL_TX_FIFO_OFFSET              4   /* transmit FIFO, write only */
#define XUL_STATUS_REG_OFFSET           8   /* status register, read only */
#define XUL_CONTROL_REG_OFFSET          12  /* control register, write only */

/* control register bit positions */

#define XUL_CR_ENABLE_INTR              0x10    /* enable interrupt */
#define XUL_CR_FIFO_RX_RESET            0x02    /* reset receive FIFO */
#define XUL_CR_FIFO_TX_RESET            0x01    /* reset transmit FIFO */

/* status register bit positions */

#define XUL_SR_INTR_ENABLED             0x10    /* interrupt enabled */
#define XUL_SR_TX_FIFO_FULL             0x08    /* transmit FIFO full */
#define XUL_SR_TX_FIFO_EMPTY            0x04    /* transmit FIFO empty */
#define XUL_SR_RX_FIFO_FULL             0x02    /* receive FIFO full */
#define XUL_SR_RX_FIFO_VALID_DATA       0x01    /* data in receive FIFO */

/*****************************************************************************/
#define usblite_out32(addr, data) *(unsigned int*)(addr)=(unsigned int)(data)

#define usblite_in32(addr) *(unsigned int*)(addr)

#define usblite_mSetControlReg(BaseAddress, Mask) \
                    usblite_out32((BaseAddress) + XUL_CONTROL_REG_OFFSET, (Mask))

#define usblite_mGetStatusReg(BaseAddress) \
                    usblite_in32((BaseAddress) + XUL_STATUS_REG_OFFSET)

#define usblite_mIsReceiveEmpty(BaseAddress) \
  ((usblite_mGetStatusReg((BaseAddress)) & XUL_SR_RX_FIFO_VALID_DATA) != \
    XUL_SR_RX_FIFO_VALID_DATA)

#define usblite_mIsTransmitFull(BaseAddress) \
    ((usblite_mGetStatusReg((BaseAddress)) & XUL_SR_TX_FIFO_FULL) == \
      XUL_SR_TX_FIFO_FULL)

#define usblite_mIsIntrEnabled(BaseAddress) \
    ((usblite_mGetStatusReg((BaseAddress)) & XUL_SR_INTR_ENABLED) == \
      XUL_SR_INTR_ENABLED)

#define usblite_mEnableIntr(BaseAddress) \
               usblite_mSetControlReg((BaseAddress), XUL_CR_ENABLE_INTR)

#define usblite_mDisableIntr(BaseAddress) \
              usblite_mSetControlReg((BaseAddress), 0)


/************************** Function Prototypes *****************************/

void usblite_SendByte(unsigned int base, unsigned char Data);

unsigned char usblite_RecvByte(unsigned int base);

#ifdef __cplusplus
}
#endif

#endif            /* end of protection macro */

