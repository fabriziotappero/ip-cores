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
 * RegAccess.c
 *
 *  Created on: 2012-01-28
 *      Author: Andrzej Paluch
 */

#include <windows.h>

#include "GpibRegAccess.h"


bool GpibRegAccess_init(struct GpibRegAccess *ra)
{
	const char *portName = "COM3";

	ra->isBurstMode = false;

	ra->portHandle = (HandleType)CreateFile(
		portName,
		GENERIC_READ | GENERIC_WRITE,
		0,
		NULL,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		NULL
	);

	if(INVALID_HANDLE_VALUE != (HANDLE)ra->portHandle)
	{
		COMMTIMEOUTS timeouts;

		timeouts.ReadIntervalTimeout = 5000;
		timeouts.ReadTotalTimeoutMultiplier = 2;
		timeouts.ReadTotalTimeoutConstant = 5000;
		timeouts.WriteTotalTimeoutMultiplier = 1;
		timeouts.WriteTotalTimeoutConstant= 5000;

		SetCommTimeouts(
			(HANDLE)ra->portHandle,
			&timeouts
		);

		DCB commSetting;

		memset(&commSetting, 0, sizeof(DCB));

		commSetting.DCBlength = sizeof(DCB);
		commSetting.BaudRate = 921600;
		commSetting.fBinary = TRUE;
		commSetting.fParity = FALSE;
		commSetting.fOutxCtsFlow = FALSE;
		commSetting.fOutxDsrFlow = FALSE;
		commSetting.fDtrControl = DTR_CONTROL_DISABLE;
		commSetting.fDsrSensitivity = FALSE;
		commSetting.fTXContinueOnXoff = FALSE;
		commSetting.fOutX = FALSE;
		commSetting.fInX = FALSE;
		commSetting.fErrorChar = FALSE;
		commSetting.fNull = FALSE;
		commSetting.fRtsControl = RTS_CONTROL_DISABLE;
		commSetting.fAbortOnError = TRUE;
		commSetting.ByteSize = 8;
		commSetting.Parity = NOPARITY;
		commSetting.StopBits = ONESTOPBIT;

		SetCommState(
			(HANDLE)ra->portHandle,
			&commSetting
		);
	}

	return INVALID_HANDLE_VALUE != (HANDLE)ra->portHandle;
}

void GpibRegAccess_release(struct GpibRegAccess *ra)
{
	if(INVALID_HANDLE_VALUE != (HANDLE)ra->portHandle)
	{
		CloseHandle((HANDLE)ra->portHandle);
	}
}

bool GpibRegAccess_readReg(struct GpibRegAccess *ra, SizeType addr, RegType *value)
{
	if(INVALID_HANDLE_VALUE != (HANDLE)ra->portHandle)
	{
		unsigned char realAddr = (unsigned char)addr | 0x80;
		DWORD bytesWrittenRead;
		bool result;

		result = WriteFile(
				(HANDLE)ra->portHandle,
			&realAddr,
			1,
			&bytesWrittenRead,
			NULL
		);

		if(!result || bytesWrittenRead != 1)
		{
			return false;
		}

		result = ReadFile(
				(HANDLE)ra->portHandle,
			value,
			2,
			&bytesWrittenRead,
			NULL
		);

		if(!result || bytesWrittenRead != 2)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	else
	{
		return false;
	}
}

bool GpibRegAccess_repeatedlyRead(struct GpibRegAccess *ra, SizeType addr,
		char *buf, SizeType bufLen)
{
	if(INVALID_HANDLE_VALUE != (HANDLE)ra->portHandle)
	{
		if(!ra->isBurstMode)
		{
			ra->isBurstMode = true;
		}

		unsigned char realAddr = (unsigned char)addr | 0xc0;
		DWORD bytesWrittenRead;
		char addrBuf[3];
		bool result;

		addrBuf[0] = realAddr;
		addrBuf[1] = bufLen & 0xFF;
		addrBuf[2] = (bufLen >> 8) & 0xFF;

		result = WriteFile(
			(HANDLE)ra->portHandle,
			addrBuf,
			3,
			&bytesWrittenRead,
			NULL
		);

		if(!result || bytesWrittenRead != 3)
		{
			return false;
		}

		bytesWrittenRead = 0;

		result = ReadFile(
			(HANDLE)ra->portHandle,
			buf,
			bufLen,
			&bytesWrittenRead,
			NULL
		);

		if(!result || bytesWrittenRead != bufLen)
		{
			return false;
		}

		return true;
	}
	else
	{
		return false;
	}
}

bool GpibRegAccess_writeReg(struct GpibRegAccess *ra, SizeType addr, RegType value)
{
	if(INVALID_HANDLE_VALUE != (HANDLE)ra->portHandle)
	{
		unsigned char realAddr = (unsigned char)addr & 0x7F;
		DWORD writeBuf;
		DWORD bytesWrittenRead;
		bool result;

		writeBuf = realAddr;
		writeBuf |= value << 8;

		result = WriteFile(
				(HANDLE)ra->portHandle,
			&writeBuf,
			3,
			&bytesWrittenRead,
			NULL
		);

		if(!result || bytesWrittenRead != 3)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	else
	{
		return false;
	}
}

bool GpibRegAccess_repeatedlyWrite(struct GpibRegAccess *ra, SizeType addr,
		char *buf, SizeType bufLen)
{
	if(INVALID_HANDLE_VALUE != (HANDLE)ra->portHandle)
	{
		unsigned char realAddr = (unsigned char)addr | 0x40;
		DWORD bytesWrittenRead;
		char addrBuf[3];
		bool result;

		addrBuf[0] = realAddr;
		addrBuf[1] = bufLen & 0xFF;
		addrBuf[2] = (bufLen >> 8) & 0xFF;

		result = WriteFile(
			(HANDLE)ra->portHandle,
			addrBuf,
			3,
			&bytesWrittenRead,
			NULL
		);

		if(!result || bytesWrittenRead != 3)
		{
			return false;
		}

		result = WriteFile(
			(HANDLE)ra->portHandle,
			buf,
			bufLen,
			&bytesWrittenRead,
			NULL
		);

		if(!result || bytesWrittenRead != bufLen)
		{
			return false;
		}

		return true;
	}
	else
	{
		return false;
	}
}
