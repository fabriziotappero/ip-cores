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
 * GpibHw.c
 *
 *  Created on: Feb 9, 2012
 *      Author: Andrzej Paluch
 */

#include "GpibHw.h"

#define MAX_FIFO_LEN 2047

bool GpibHw_init(struct GpibHw *gpibHw, struct GpibHwAdapter *ghwa)
{
	gpibHw->ghwa = ghwa;
	gpibHw->writerLastEndOfStream = false;

	return ghwa != 0;
}

void GpibHw_release(struct GpibHw *gpibHw)
{
	// do nothing
}

bool GpibHw_getSettings(struct GpibHw *gpibHw, struct GpibHwSettings *settings)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_SETTING_0, &regVal))
	{
		return false;
	}

	settings->talkOnly = GpibHwAdapter_getBitValue(regVal, MASK_SETTING0_ton);
	settings->listenOnly = GpibHwAdapter_getBitValue(regVal, MASK_SETTING0_lon);
	settings->eosMark = GpibHwAdapter_getFieldValue(regVal, MASK_SETTING0_eosMark);
	settings->eosUsed = GpibHwAdapter_getBitValue(regVal, MASK_SETTING0_eosUsed);
	settings->fixedPpLine = GpibHwAdapter_getFieldValue(regVal, MASK_SETTING0_fixedPpLine);
	settings->lpeUsed = GpibHwAdapter_getBitValue(regVal, MASK_SETTING0_lpeUsed);
	settings->isLeTe = GpibHwAdapter_getBitValue(regVal, MASK_SETTING0_isLeTe);

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_SETTING_1, &regVal))
	{
		return false;
	}

	settings->T1 = GpibHwAdapter_getFieldValue(regVal, MASK_SETTING1_T1);
	settings->address = GpibHwAdapter_getFieldValue(regVal, MASK_SETTING1_addr);

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_SEC_ADDR_0, &regVal))
	{
		return false;
	}

	settings->secondaryAddressMask = regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_SEC_ADDR_1, &regVal))
	{
		return false;
	}

	settings->secondaryAddressMask |= regVal << 16;

	return true;
}

bool GpibHw_setSettings(struct GpibHw *gpibHw, struct GpibHwSettings *settings)
{
	RegType regVal = 0;

	GpibHwAdapter_setBitValue(&regVal, MASK_SETTING0_ton, settings->talkOnly);
	GpibHwAdapter_setBitValue(&regVal, MASK_SETTING0_lon, settings->listenOnly);
	GpibHwAdapter_setFieldValue(&regVal, MASK_SETTING0_eosMark, settings->eosMark);
	GpibHwAdapter_setBitValue(&regVal, MASK_SETTING0_eosUsed, settings->eosUsed);
	GpibHwAdapter_setFieldValue(&regVal, MASK_SETTING0_fixedPpLine, settings->fixedPpLine);
	GpibHwAdapter_setBitValue(&regVal, MASK_SETTING0_lpeUsed, settings->lpeUsed);
	GpibHwAdapter_setBitValue(&regVal, MASK_SETTING0_isLeTe, settings->isLeTe);

	if(!GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_SETTING_0, regVal))
	{
		return false;
	}

	GpibHwAdapter_setFieldValue(&regVal, MASK_SETTING1_T1, settings->T1);
	GpibHwAdapter_setFieldValue(&regVal, MASK_SETTING1_addr, settings->address);

	if(!GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_SETTING_1, regVal))
	{
		return false;
	}

	regVal = settings->secondaryAddressMask & 0xffff;

	if(!GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_SEC_ADDR_0, regVal))
	{
		return false;
	}

	regVal = settings->secondaryAddressMask >> 16;

	if(!GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_SEC_ADDR_1, regVal))
	{
		return false;
	}

	return true;
}

bool GpibHw_getEventStatus(struct GpibHw *gpibHw, struct GpibHwEvents *events)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_EVENT, &regVal))
	{
		return false;
	}

	events->IFC = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_IFC);
	events->ATN = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_ATN);
	events->REN = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_REN);
	events->stb_received = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_stb_received);
	events->ppr = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_ppr);
	events->srq = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_srq);
	events->cwrd = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_cwrd);
	events->cwrc = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_cwrc);
	events->spa = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_spa);
	events->atl = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_atl);
	events->att = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_att);
	events->trg = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_trg);
	events->clr = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_clr);
	events->out_ready = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_out_buf_full);
	events->in_ready = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_in_buf_full);
	events->isLocal = GpibHwAdapter_getBitValue(regVal, MASK_EVENT_isLocal);

	return true;
}

bool GpibHw_getGpibStatus(struct GpibHw *gpibHw, struct GpibHwStatus *status)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_GPIB_STATUS, &regVal))
	{
		return false;
	}

	status->isLocal = GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_isLocal);
	status->spa = GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_spa);
	status->cwrd = GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_cwrd);
	status->cwrc = GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_cwrc);
	status->lac = GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_lac);
	status->atl = GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_atl);
	status->tac = GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_tac);
	status->att = GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_att);
	status->currentSecondaryAddress =
			GpibHwAdapter_getFieldValue(regVal, MASK_GPIB_STATUS_currentSecAddr);

	return true;
}

bool GpibHw_requestSystemControl(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_rsc, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_systemInterfaceClear(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_sic, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_sendRemoteEnable(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_sre, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_goToStandby(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_gts, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_takeControlAsynchronously(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_tca, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_takeControlSynchronously(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_tcs, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_requestParallelPoll(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_rpp, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_receiveStatusByte(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_rec_stb, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_localPollEnable(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_lpe, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_setIndividualStatus(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_ist, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_requestService(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_rsv, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_returnToLocal(struct GpibHw *gpibHw, bool value)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_rtl, value);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_setLocalListenUnlisten(struct GpibHw *gpibHw, bool ltn, bool lun)
{
	RegType regVal;

	if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_CONTROL, &regVal))
	{
		return false;
	}

	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_ltn, ltn);
	GpibHwAdapter_setBitValue(&regVal, MASK_CONTROL_lun, lun);

	return GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_CONTROL, regVal);
}

bool GpibHw_availableBytesToRead(struct GpibHw *gpibHw, SizeType *count)
{
	RegType regVal;

	if(GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_READER_CONTROL_1, &regVal))
	{
		*count = GpibHwAdapter_getFieldValue(regVal, MASK_READER_CONTROL_1_bytesInFifo);

		return true;
	}
	else
	{
		return false;
	}
}

bool GpibHw_read(struct GpibHw *gpibHw, char *buf, SizeType bufLen,
		SizeType *bytesRead, bool *endOfStream)
{
	RegType regVal;
	SizeType availableCount;
	SizeType bytesToCopy;
	//SizeType i;

	*bytesRead = 0;
	*endOfStream = false;

	if(!GpibHw_availableBytesToRead(gpibHw, &availableCount))
	{
		return false;
	}


	while(availableCount > 0 && *bytesRead < bufLen)
	{
		if((bufLen - *bytesRead) < availableCount)
		{
			bytesToCopy = bufLen - *bytesRead;
		}
		else
		{
			bytesToCopy = availableCount;
		}

//		for(i=0; i<bytesToCopy; ++i)
//		{
//			if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_READER_FIFO, &regVal))
//			{
//				return false;
//			}
//
//			buf[*bytesRead] = regVal & 0xFF;
//
//			++ (*bytesRead);
//		}

		if(!GpibHwAdapter_readFifo(gpibHw->ghwa, &(buf[*bytesRead]), bytesToCopy)) {
			return false;
		}

		(*bytesRead) += bytesToCopy;

		if(!GpibHw_availableBytesToRead(gpibHw, &availableCount))
		{
			return false;
		}
	}

	if(availableCount == 0)
	{
		if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_READER_CONTROL_0, &regVal))
		{
			return false;
		}

		*endOfStream = GpibHwAdapter_getBitValue(regVal,
				MASK_READER_CONTROL_0_endOfStream);

		if(GpibHwAdapter_getBitValue(regVal, MASK_READER_CONTROL_0_bufInterrupt))
		{
			GpibHwAdapter_setBitValue(&regVal, MASK_READER_CONTROL_0_resetBuffer, 1);

			if(!GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_READER_CONTROL_0, regVal))
			{
				return false;
			}
		}
	}

	return true;
}

bool GpibHw_bytesInWriterFifo(struct GpibHw *gpibHw, SizeType *count)
{
	RegType regVal;

	if(GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_WRITER_CONTROL_1, &regVal))
	{
		*count = GpibHwAdapter_getFieldValue(regVal, MASK_WRITER_CONTROL_1_bytesInFifo);

		return true;
	}
	else
	{
		return false;
	}
}

bool GpibHw_write(struct GpibHw *gpibHw, char *buf, SizeType bufLen,
		SizeType *bytesWritten, bool endOfStream)
{
	RegType regVal;
	SizeType outFifoCount;
	SizeType bytesToCopy;
	//SizeType i;

	*bytesWritten = 0;

	GpibHw_bytesInWriterFifo(gpibHw, &outFifoCount);

	if(gpibHw->writerLastEndOfStream)
	{
		if(outFifoCount > 0)
		{
			return true;
		}
		else
		{
			if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_WRITER_CONTROL_0, &regVal))
			{
				return false;
			}

			GpibHwAdapter_setBitValue(&regVal, MASK_WRITER_CONTROL_0_resetBuffer, 1);
			GpibHwAdapter_setBitValue(&regVal, MASK_WRITER_CONTROL_0_endOfStream, 0);

			if(!GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_WRITER_CONTROL_0, regVal))
			{
				return false;
			}

			gpibHw->writerLastEndOfStream = false;
		}
	}

	while(outFifoCount < MAX_FIFO_LEN && *bytesWritten < bufLen)
	{
		if((bufLen - *bytesWritten) <= (MAX_FIFO_LEN - outFifoCount))
		{
			bytesToCopy = bufLen - *bytesWritten;

			if(endOfStream)
			{
				if(bytesToCopy == 1)
				{
					if(!GpibHwAdapter_getReg(gpibHw->ghwa, REG_ADDR_WRITER_CONTROL_0, &regVal))
					{
						return false;
					}

					GpibHwAdapter_setBitValue(&regVal, MASK_WRITER_CONTROL_0_endOfStream, 1);

					if(!GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_WRITER_CONTROL_0, regVal))
					{
						return false;
					}

					gpibHw->writerLastEndOfStream = true;
				}
				else
				{
					bytesToCopy --;
				}
			}
		}
		else
		{
			bytesToCopy = MAX_FIFO_LEN - outFifoCount;
		}

//		for(i=0; i<bytesToCopy; ++i)
//		{
//			if(!GpibHwAdapter_setReg(gpibHw->ghwa, REG_ADDR_WRITER_FIFO, buf[*bytesWritten]))
//			{
//				return false;
//			}
//
//			++ (*bytesWritten);
//		}

		if(!GpibHwAdapter_writeFifo(gpibHw->ghwa, &(buf[*bytesWritten]), bytesToCopy))
		{
			return false;
		}

		*bytesWritten += bytesToCopy;

		if(!GpibHw_bytesInWriterFifo(gpibHw, &outFifoCount))
		{
			return false;
		}
	}

	return true;
}
