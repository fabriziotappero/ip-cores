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
 * GpibHw.h
 *
 *  Created on: Feb 9, 2012
 *      Author: Andrzej Paluch
 */

#include "GpibHwAdapter.h"

#ifndef __GPIB_HW_H__
#define __GPIB_HW_H__

/** Encapsulates GPIB hardware issues. */
struct GpibHw
{
	struct GpibHwAdapter *ghwa;
	bool writerLastEndOfStream;
};

/** Encapsulates GPIB device settings. */
struct GpibHwSettings
{
	bool talkOnly;
	bool listenOnly;
	char eosMark;
	bool eosUsed;
	char fixedPpLine;
	bool lpeUsed;
	bool isLeTe;
	char T1;
	char address;
	u32 secondaryAddressMask;
};

/** Encapsulates GPIB device events. */
struct GpibHwEvents
{
	u16 IFC : 1;
	u16 ATN : 1;
	u16 REN : 1;
	u16 stb_received : 1;
	u16 ppr : 1;
	u16 srq : 1;
	u16 cwrd : 1;
	u16 cwrc : 1;
	u16 spa : 1;
	u16 atl : 1;
	u16 att : 1;
	u16 trg : 1;
	u16 clr : 1;
	u16 out_ready : 1;
	u16 in_ready : 1;
	u16 isLocal : 1;
};

/** Encapsulates GPIB device status. */
struct GpibHwStatus
{
	u16 isLocal : 1;
	u16 spa : 1;
	u16 cwrd : 1;
	u16 cwrc : 1;
	u16 lac : 1;
	u16 atl : 1;
	u16 tac : 1;
	u16 att : 1;
	u16 currentSecondaryAddress : 5;
};

/** Initializes GpibHw. */
bool GpibHw_init(struct GpibHw *gpibHw, struct GpibHwAdapter *ghw);

/** Releases gpib. */
void GpibHw_release(struct GpibHw *gpibHw);


/** Gets GPIB hw settings. */
bool GpibHw_getSettings(struct GpibHw *gpibHw, struct GpibHwSettings *settings);

/** Sets GPIB hw settings. */
bool GpibHw_setSettings(struct GpibHw *gpibHw, struct GpibHwSettings *settings);


/** Gets GPIB hw event status. */
bool GpibHw_getEventStatus(struct GpibHw *gpibHw, struct GpibHwEvents *events);


/** Gets GPIB hw status. */
bool GpibHw_getGpibStatus(struct GpibHw *gpibHw, struct GpibHwStatus *status);


/** Controls rsc signal. */
bool GpibHw_requestSystemControl(struct GpibHw *gpibHw, bool value);

/** Controls sic signal. */
bool GpibHw_systemInterfaceClear(struct GpibHw *gpibHw, bool value);

/** Controls sre signal. */
bool GpibHw_sendRemoteEnable(struct GpibHw *gpibHw, bool value);

/** Controls gts line. */
bool GpibHw_goToStandby(struct GpibHw *gpibHw, bool value);

/** Controls tca signal. */
bool GpibHw_takeControlAsynchronously(struct GpibHw *gpibHw, bool value);

/** Controls tcs signal. */
bool GpibHw_takeControlSynchronously(struct GpibHw *gpibHw, bool value);

/** Controls rpp signal. */
bool GpibHw_requestParallelPoll(struct GpibHw *gpibHw, bool value);

/** Controls rec_stb signal. */
bool GpibHw_receiveStatusByte(struct GpibHw *gpibHw, bool value);

/** Controls lpe signal. */
bool GpibHw_localPollEnable(struct GpibHw *gpibHw, bool value);

/** Controls ist signal. */
bool GpibHw_setIndividualStatus(struct GpibHw *gpibHw, bool value);

/** Controls rsv signal. */
bool GpibHw_requestService(struct GpibHw *gpibHw, bool value);

/** Controls rtl signal. */
bool GpibHw_returnToLocal(struct GpibHw *gpibHw, bool value);

/** Sets local listen unlisten state by control of lines ltn and lun. */
bool GpibHw_setLocalListenUnlisten(struct GpibHw *gpibHw, bool ltn, bool lun);

/** Gets bytes available in reader fifo. */
bool GpibHw_availableBytesToRead(struct GpibHw *gpibHw, SizeType *len);

/** Reads bytes from reader fifo. */
bool GpibHw_read(struct GpibHw *gpibHw, char *buf, SizeType bufLen,
		SizeType *bytesRead, bool *endOfStream);

/** Gets bytes count in writer fifo. */
bool GpibHw_bytesInWriterFifo(struct GpibHw *gpibHw, SizeType *count);

/** Writes bytes to writer fifo. */
bool GpibHw_write(struct GpibHw *gpibHw, char *buf, SizeType bufLen,
		SizeType *bytesWritten, bool endOfStream);


#endif /* __GPIB_HW_H__ */
