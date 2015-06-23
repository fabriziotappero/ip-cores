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
#include <time.h>

#include <unistd.h>

#include "GpibRegAccess.h"
#include "GpibHwAdapter.h"
#include "GpibHw.h"


int listenOnlyMain(int argc, char* argv[])
{
	struct GpibRegAccess ra;
	struct GpibHwAdapter ghw;
	struct GpibHw gpib;

	time_t rawtime;
	struct tm * timeinfo;

	GpibRegAccess_init(&ra);
	GpibHwAdapter_init(&ghw, &ra, 0);
	GpibHw_init(&gpib, &ghw);

	struct GpibHwSettings gs;
	// set listen only
	// set T1
	GpibHw_getSettings(&gpib, &gs);
	gs.T1 = 132;
	gs.listenOnly = true;
	GpibHw_setSettings(&gpib, &gs);

	char buf[2048];
	SizeType bytesRead;
	bool endOfStream;
	int i;
	char fileName[1024];
	bool fileAllocated;
	FILE *file;


	while(true){
		sprintf(fileName, "/home/andrzej/Downloads/TDS420/img%u.tiff", i);
		fileAllocated = false;

		do
		{
			GpibHw_read(&gpib, buf, 2048, &bytesRead, &endOfStream);

			if(bytesRead > 0)
			{
				if(!fileAllocated)
				{
					file = fopen(fileName, "wb");
					fileAllocated = true;
					rawtime = time (0);
					timeinfo = localtime ( &rawtime );
					printf ( "Start time: %s\n", asctime (timeinfo) );
				}

				fwrite(buf, 1, bytesRead, file);
			}
		}
		while(!endOfStream);

		rawtime = time (0);
		timeinfo = localtime ( &rawtime );
		printf ( "Stop time: %s\n", asctime (timeinfo) );

		fclose(file);
		i++;
	}

	GpibHw_release(&gpib);
	GpibHwAdapter_release(&ghw);
	GpibRegAccess_release(&ra);

	return 0;
}
