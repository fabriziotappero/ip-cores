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
* Author: Andrzej Paluch
*/

#include <string.h>
#include <stdio.h>

#include <unistd.h>

#include "GpibRegAccess.h"
#include "GpibHwAdapter.h"
#include "GpibHw.h"


int gpibExplorerMain(int argc, char* argv[])
{
	struct GpibRegAccess ra;
	struct GpibHwAdapter ghw;
	struct GpibHw gpib;

	RegType regVal;

	GpibRegAccess_init(&ra);
	GpibHwAdapter_init(&ghw, &ra, 0);
	GpibHw_init(&gpib, &ghw);

	struct GpibHwSettings gs;
	// set T1
	GpibHw_getSettings(&gpib, &gs);
	gs.T1 = 132;
	GpibHw_setSettings(&gpib, &gs);

	// request system control
	GpibHw_requestSystemControl(&gpib, 1);

	// go to standby
	GpibHw_goToStandby(&gpib, 0);
	GpibHw_takeControlAsynchronously(&gpib, 1);

	// system interface clear
	GpibHw_systemInterfaceClear(&gpib, 1);

	// remote enable
	GpibHw_sendRemoteEnable(&gpib, 1);

	do
	{
		GpibHwAdapter_getReg(&ghw, REG_ADDR_GPIB_STATUS, &regVal);
	}
	while(!GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_cwrc));


	GpibHw_systemInterfaceClear(&gpib, 0);

	GpibHw_takeControlAsynchronously(&gpib, 0);

	do
	{
		GpibHwAdapter_getReg(&ghw, REG_ADDR_EVENT, &regVal);
	}
	while(GpibHwAdapter_getBitValue(regVal, MASK_EVENT_IFC));

	char buf[2048];
	SizeType bytesRead;
	SizeType bytesWritten;
	bool endOfStream;



	do
	{
		// set not to listen ///////////////////////////////////////
		/*if(!GpibHwAdapter_getReg(&ghw, REG_ADDR_CONTROL, &regVal))
		{
			return false;
		}

		GpibHwAdapter_setBitValue(regVal, MASK_CONTROL_ltn, 0);

		if(!GpibHwAdapter_setReg(&ghw, REG_ADDR_CONTROL, regVal))
		{
			return false;
		}*/
		////////////////////////////////////////////////////////

		// write command
		int cmdLen = 2;
		buf[0] = 0x22;
		buf[1] = 0x41;

		bytesWritten = 0;

		do
		{
			GpibHw_write(&gpib, buf + bytesWritten, cmdLen - bytesWritten,
					&bytesWritten, false);
		}
		while(bytesWritten < cmdLen);

		do
		{
			GpibHwAdapter_getReg(&ghw, REG_ADDR_WRITER_CONTROL_1, &regVal);
		}
		while(GpibHwAdapter_getFieldValue(regVal, MASK_WRITER_CONTROL_1_bytesInFifo) > 0);


		// go to standby
		GpibHw_goToStandby(&gpib, 1);

		do
		{
			GpibHwAdapter_getReg(&ghw, REG_ADDR_GPIB_STATUS, &regVal);
		}
		while(!GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_cwrd));

		GpibHw_goToStandby(&gpib, 0);

		FILE *file = 0;
		bool readAgain;
		bool doExit;

		do
		{
			readAgain = false;
			doExit = false;

			// gets command
			gets(buf);

			if(strlen(buf) == 1 && buf[0] == 'e')
			{
				if(file)
				{
					fclose(file);
				}

				doExit = true;
				break;
			}
			else if(strstr(buf, "save_to_file") != 0)
			{
				char fileName[512];
				sscanf(buf, "save_to_file %s", fileName);
				file = fopen(fileName, "wb");
				readAgain = true;
			}
		}
		while(readAgain);

		if(doExit)
		{
			break;
		}

		//buf[strlen(buf) + 1] = 0;
		//buf[strlen(buf)] = '\n';

		// write data
		bytesWritten = 0;
		u32 tmpBytesWritten;

		do
		{
			GpibHw_write(&gpib, buf + bytesWritten, strlen(buf) - bytesWritten,
					&tmpBytesWritten, true);
			bytesWritten += tmpBytesWritten;
		}
		while(bytesWritten < strlen(buf));

		do
		{
			GpibHwAdapter_getReg(&ghw, REG_ADDR_WRITER_CONTROL_1, &regVal);
		}
		while(GpibHwAdapter_getFieldValue(regVal, MASK_WRITER_CONTROL_1_bytesInFifo) > 0);

		// take control
		GpibHw_takeControlAsynchronously(&gpib, 1);

		do
		{
			GpibHwAdapter_getReg(&ghw, REG_ADDR_GPIB_STATUS, &regVal);
		}
		while(!GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_cwrc));

		GpibHw_takeControlAsynchronously(&gpib, 0);


		// set to listen ///////////////////////////////////////
		/*if(!GpibHwAdapter_getReg(&ghw, REG_ADDR_CONTROL, &regVal))
		{
			return false;
		}

		GpibHwAdapter_setBitValue(regVal, MASK_CONTROL_ltn, 1);

		if(!GpibHwAdapter_setReg(&ghw, REG_ADDR_CONTROL, regVal))
		{
			return false;
		}*/
		////////////////////////////////////////////////////////


		// write command
		bytesWritten = 0;
		buf[0] = 0x21;
		buf[1] = 0x42;

		do
		{
			GpibHw_write(&gpib, buf + bytesWritten, 2 - bytesWritten,
					&bytesWritten, false);
		}
		while(bytesWritten < 2);

		do
		{
			GpibHwAdapter_getReg(&ghw, REG_ADDR_WRITER_CONTROL_1, &regVal);
		}
		while(GpibHwAdapter_getFieldValue(regVal, MASK_WRITER_CONTROL_1_bytesInFifo) > 0);

		GpibHwAdapter_getReg(&ghw, REG_ADDR_BUS_STATUS, &regVal);

		// go to standby
		GpibHw_goToStandby(&gpib, true);

		do
		{
			GpibHwAdapter_getReg(&ghw, REG_ADDR_GPIB_STATUS, &regVal);
		}
		while(!GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_cwrd));

		GpibHw_goToStandby(&gpib, false);


		int timeout = 0;
		// read data
		do
		{
			GpibHw_read(&gpib, buf, 2047, &bytesRead, &endOfStream);

			if(bytesRead > 0)
			{
				buf[bytesRead] = 0;
				timeout = 0;

				if(!file)
				{
					printf("%s", buf);
				}
				else
				{
					fwrite(buf, 1, bytesRead, file);
				}
			}

			timeout ++;

			if((timeout > 500 && !file) || (timeout > 20000 && file))
			{
				break;
			}
		}
		while(!endOfStream);

		if(file)
		{
			fclose(file);
			file = 0;
		}

		// take control
		GpibHw_takeControlAsynchronously(&gpib, 1);

		do
		{
			GpibHwAdapter_getReg(&ghw, REG_ADDR_GPIB_STATUS, &regVal);
		}
		while(!GpibHwAdapter_getBitValue(regVal, MASK_GPIB_STATUS_cwrc));

		GpibHw_takeControlAsynchronously(&gpib, 0);
	}
	while(true);

	// remote disable
	GpibHw_sendRemoteEnable(&gpib, 0);

	GpibHw_release(&gpib);
	GpibHwAdapter_release(&ghw);
	GpibRegAccess_release(&ra);

	return 0;
}
