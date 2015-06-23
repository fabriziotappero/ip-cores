/*
*This file is part of fpga_gpib_controller.
*
* Fpga_gpib_controller is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Fpga_gpib_controller is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Fpga_gpib_controller.  If not, see <http://www.gnu.org/licenses/>.
*/
/*
 * GpibHwAdapter.h
 *
 *  Created on: 2012-01-29
 *      Author: Andrzej Paluch
 */

#ifndef __GPIB_HW_ADAPTER_H__
#define __GPIB_HW_ADAPTER_H__

#include "GpibTypes.h"
#include "GpibRegAccess.h"

/** Register addresses */
#define REG_ADDR_SETTING_0         0
#define REG_ADDR_SETTING_1         1
#define REG_ADDR_SEC_ADDR_0        2
#define REG_ADDR_SEC_ADDR_1        3
#define REG_ADDR_BUS_STATUS        4
#define REG_ADDR_EVENT             5
#define REG_ADDR_GPIB_STATUS       6
#define REG_ADDR_CONTROL           7
#define REG_ADDR_READER_CONTROL_0  8
#define REG_ADDR_READER_CONTROL_1  9
#define REG_ADDR_WRITER_CONTROL_0 10
#define REG_ADDR_WRITER_CONTROL_1 11
#define REG_ADDR_READER_FIFO      12
#define REG_ADDR_WRITER_FIFO      13

/* Setting 0 register masks. */
#define MASK_SETTING0_ton         0x8000
#define MASK_SETTING0_lon         0x4000
#define MASK_SETTING0_eosMark     6,0xFF
#define MASK_SETTING0_eosUsed     0x0020
#define MASK_SETTING0_fixedPpLine 2,0x7
#define MASK_SETTING0_lpeUsed     0x0002
#define MASK_SETTING0_isLeTe      0x0001

/* Setting 1 register masks. */
#define MASK_SETTING1_T1   5,0xFF
#define MASK_SETTING1_addr 0,0x1F

/* Secondary address register masks. */
// nothing to define

/* Bus status register masks. */
#define MASK_BUS_STATUS_REN  0x8000
#define MASK_BUS_STATUS_IFC  0x4000
#define MASK_BUS_STATUS_SRQ  0x2000
#define MASK_BUS_STATUS_EOI  0x1000
#define MASK_BUS_STATUS_NDAC 0x0800
#define MASK_BUS_STATUS_NRFD 0x0400
#define MASK_BUS_STATUS_DAV  0x0200
#define MASK_BUS_STATUS_ATN  0x0100
#define MASK_BUS_STATUS_DIO  0,0xFF

/* Event register masks. */
#define MASK_EVENT_IFC          0x8000
#define MASK_EVENT_ATN          0x4000
#define MASK_EVENT_REN          0x2000
#define MASK_EVENT_stb_received 0x1000
#define MASK_EVENT_ppr          0x0800
#define MASK_EVENT_srq          0x0400
#define MASK_EVENT_cwrd         0x0200
#define MASK_EVENT_cwrc         0x0100
#define MASK_EVENT_spa          0x0080
#define MASK_EVENT_atl          0x0040
#define MASK_EVENT_att          0x0020
#define MASK_EVENT_trg          0x0010
#define MASK_EVENT_clr          0x0008
#define MASK_EVENT_out_buf_full 0x0004
#define MASK_EVENT_in_buf_full  0x0002
#define MASK_EVENT_isLocal      0x0001

/* GPIB status register masks. */
#define MASK_GPIB_STATUS_isLocal        0x1000
#define MASK_GPIB_STATUS_spa            0x0800
#define MASK_GPIB_STATUS_cwrd           0x0400
#define MASK_GPIB_STATUS_cwrc           0x0200
#define MASK_GPIB_STATUS_lac            0x0100
#define MASK_GPIB_STATUS_atl            0x0080
#define MASK_GPIB_STATUS_tac            0x0040
#define MASK_GPIB_STATUS_att            0x0020
#define MASK_GPIB_STATUS_currentSecAddr 0,0x1F

/* Control register masks. */
#define MASK_CONTROL_rec_stb 0x2000
#define MASK_CONTROL_rpp     0x1000
#define MASK_CONTROL_tca     0x0800
#define MASK_CONTROL_tcs     0x0400
#define MASK_CONTROL_gts     0x0200
#define MASK_CONTROL_sre     0x0100
#define MASK_CONTROL_sic     0x0080
#define MASK_CONTROL_rsc     0x0040
#define MASK_CONTROL_lpe     0x0020
#define MASK_CONTROL_ist     0x0010
#define MASK_CONTROL_rsv     0x0008
#define MASK_CONTROL_rtl     0x0004
#define MASK_CONTROL_lun     0x0002
#define MASK_CONTROL_ltn     0x0001

/* Reader control 0 register masks. */
#define MASK_READER_CONTROL_0_dataSecAddr   4,0x1F
#define MASK_READER_CONTROL_0_resetBuffer   0x0008
#define MASK_READER_CONTROL_0_endOfStream   0x0004
#define MASK_READER_CONTROL_0_dataAvailable 0x0002
#define MASK_READER_CONTROL_0_bufInterrupt  0x0001

/* Reader control 1 register masks. */
#define MASK_READER_CONTROL_1_bytesInFifo 0,0xFFF

/* Writer control 0 register masks. */
#define MASK_WRITER_CONTROL_0_statusByte    9,0x7F
#define MASK_WRITER_CONTROL_0_dataSecAddr   4,0x1F
#define MASK_WRITER_CONTROL_0_resetBuffer   0x0008
#define MASK_WRITER_CONTROL_0_endOfStream   0x0004
#define MASK_WRITER_CONTROL_0_dataAvailable 0x0002
#define MASK_WRITER_CONTROL_0_bufInterrupt  0x0001

/* Writer control 1 register masks. */
#define MASK_WRITER_CONTROL_1_bytesInFifo 0,0xFFF


/** Encapsulates GPIB hardware adapter issues. */
struct GpibHwAdapter
{
	struct GpibRegAccess *regAccess;
	AddrType baseAddr;
};

///////////// do not use //////////////////////////
#define __GpibHwAdapter_getValue(reg, bitNum, valueMask)\
	((reg >> bitNum) & valueMask)

#define __GpibHwAdapter_setValue(pReg, bitNum, valueMask, value)\
	*pReg &= ( ~(valueMask << bitNum) ) & 0xFFFF;\
	*pReg |= ((value) << bitNum) & (valueMask << bitNum);
///////////// end of - do not use //////////////////

/** Initializes GpibHwAdapter */
bool GpibHwAdapter_init(struct GpibHwAdapter *ghwa, struct GpibRegAccess *regAccess,
		AddrType baseAddr);

/** Releases GpibHwAdapter. */
void GpibHwAdapter_release(struct GpibHwAdapter *ghwa);

/** Gets register value. */
#define GpibHwAdapter_getReg(ghwa, regAddr, pvalue)\
	GpibRegAccess_readReg((ghwa)->regAccess,\
		(ghwa)->baseAddr + regAddr, pvalue)

/** Sets register value. */
#define GpibHwAdapter_setReg(ghwa, regAddr, value)\
	GpibRegAccess_writeReg((ghwa)->regAccess,\
		(ghwa)->baseAddr + regAddr, value)

/** Reads data fifo. */
#define GpibHwAdapter_readFifo(ghwa, buf, bufLen)\
	GpibRegAccess_repeatedlyRead((ghwa)->regAccess,\
		(ghwa)->baseAddr + REG_ADDR_READER_FIFO, buf, bufLen)

/** Writes to data fifo. */
#define GpibHwAdapter_writeFifo(ghwa, buf, bufLen)\
	GpibRegAccess_repeatedlyWrite((ghwa)->regAccess,\
		(ghwa)->baseAddr + REG_ADDR_WRITER_FIFO, buf, bufLen)

/** Gets register value's bit. */
#define GpibHwAdapter_getBitValue(reg, mask) ((reg & mask) != 0)

/** Sets register value's bit. */
#define GpibHwAdapter_setBitValue(pReg, mask, newValue)\
	if(newValue == 0) {\
		*pReg &= ( ~(mask) ) & 0xFFFF;\
	} else {\
		*pReg |= mask;\
	}

/** Gets register value's field. */
#define GpibHwAdapter_getFieldValue(reg, bitNumAndMask)\
	__GpibHwAdapter_getValue(reg, bitNumAndMask)

/** Sets register value's field. */
#define GpibHwAdapter_setFieldValue(pReg, bitNumAndMask, newValue)\
	__GpibHwAdapter_setValue(pReg, bitNumAndMask, newValue)


#endif /* __GPIB_HW_ADAPTER_H__ */
