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
 * RegAccess_linux.c
 *
 *  Created on: 2012-01-28
 *      Author: Andrzej Paluch
 */
#include <string.h>

#include <unistd.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "GpibRegAccess.h"


#define HND(handle) ((int)handle)

void GpibRegAccess_setFlags(int fd, SizeType dataLength)
{
	struct termios settings;

	memset(&settings, 0, sizeof(settings));

	settings.c_cflag = B921600 | CS8 | CLOCAL;

	//settings.c_lflag = IGNPAR;

	settings.c_cc[VINTR]    = 0;     /* Ctrl-c */
	settings.c_cc[VQUIT]    = 0;     /* Ctrl-\ */
	settings.c_cc[VERASE]   = 0;     /* del */
	settings.c_cc[VKILL]    = 0;     /* @ */
	settings.c_cc[VEOF]     = 0;     /* Ctrl-d */
	settings.c_cc[VTIME]    = 0;     /* inter-character timer unused */
	/* blocking read until "dataLength" characters arrives */
	settings.c_cc[VMIN]     = dataLength;
	settings.c_cc[VSWTC]    = 0;     /* '\0' */
	settings.c_cc[VSTART]   = 0;     /* Ctrl-q */
	settings.c_cc[VSTOP]    = 0;     /* Ctrl-s */
	settings.c_cc[VSUSP]    = 0;     /* Ctrl-z */
	settings.c_cc[VEOL]     = 0;     /* '\0' */
	settings.c_cc[VREPRINT] = 0;     /* Ctrl-r */
	settings.c_cc[VDISCARD] = 0;     /* Ctrl-u */
	settings.c_cc[VWERASE]  = 0;     /* Ctrl-w */
	settings.c_cc[VLNEXT]   = 0;     /* Ctrl-v */
	settings.c_cc[VEOL2]    = 0;     /* '\0' */

	//tcflush(fd, TCIFLUSH);
	tcsetattr(fd, TCSANOW, &settings);
}

bool GpibRegAccess_init(struct GpibRegAccess *ra)
{
	const char *portName = "/dev/ttyUSB0";

	ra->isBurstMode = false;

	ra->portHandle = (HandleType) open(portName, O_RDWR | O_NOCTTY);

	int fd = HND(ra->portHandle);

	if(fd > 0)
	{
		tcflush(fd, TCIFLUSH);
		GpibRegAccess_setFlags(fd, 2);

	}

	return fd >= 0;
}

void GpibRegAccess_release(struct GpibRegAccess *ra)
{
	int fd = HND(ra->portHandle);

	if(fd >= 0)
	{
		close(fd);
	}
}

bool GpibRegAccess_readReg(struct GpibRegAccess *ra, SizeType addr, RegType *pValue)
{
	int fd = HND(ra->portHandle);

	if(fd >= 0)
	{
		if(ra->isBurstMode)
		{
			ra->isBurstMode = false;
			GpibRegAccess_setFlags(fd, 2);
		}

		unsigned char realAddr = (unsigned char)addr | 0x80;
		ssize_t bytesWrittenRead;
		
		bytesWrittenRead = write(fd, &realAddr, 1);

		if(bytesWrittenRead != 1)
		{
			return false;
		}

		bytesWrittenRead = read(fd, pValue, 2);

		if(bytesWrittenRead != 2)
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
	int fd = HND(ra->portHandle);
	int i;

	if(fd > 0)
	{
		if(!ra->isBurstMode)
		{
			ra->isBurstMode = true;
			GpibRegAccess_setFlags(fd, 1);
		}

		unsigned char realAddr = (unsigned char)addr | 0xc0;
		ssize_t bytesWrittenRead;
		char addrBuf[3];

		addrBuf[0] = realAddr;
		addrBuf[1] = bufLen & 0xFF;
		addrBuf[2] = (bufLen >> 8) & 0xFF;

		bytesWrittenRead = write(fd, addrBuf, 3);

		if(bytesWrittenRead != 3)
		{
			return false;
		}

		bytesWrittenRead = 0;

		for(i=0; i<bufLen; i++)
		{
			bytesWrittenRead += read(fd, buf+i, 1);
		}

		//bytesWrittenRead = read(fd, buf, bufLen);

		if(bytesWrittenRead != bufLen)
		{
			return false;
		}
		else
		{
			return true;
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
	int fd = HND(ra->portHandle);

	if(fd >= 0)
	{
		if(ra->isBurstMode)
		{
			ra->isBurstMode = false;
			GpibRegAccess_setFlags(fd, 2);
		}

		unsigned char realAddr = (unsigned char)addr & 0x7F;
		unsigned int writeBuf;
		ssize_t bytesWrittenRead;
		
		writeBuf = realAddr;
		writeBuf |= value << 8;

		bytesWrittenRead = write(fd, &writeBuf, 3);

		if(bytesWrittenRead != 3)
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
	int fd = HND(ra->portHandle);

	if(fd > 0)
	{
		unsigned char realAddr = (unsigned char)addr | 0x40;
		ssize_t bytesWrittenRead;
		char addrBuf[3];

		addrBuf[0] = realAddr;
		addrBuf[1] = bufLen & 0xFF;
		addrBuf[2] = (bufLen >> 8) & 0xFF;

		bytesWrittenRead = write(fd, addrBuf, 3);

		if(bytesWrittenRead != 3)
		{
			return false;
		}

		bytesWrittenRead = write(fd, buf, bufLen);

		if(bytesWrittenRead != bufLen)
		{
			return false;
		}
		else
		{
			return true;
		}

		return true;
	}
	else
	{
		return false;
	}
}
