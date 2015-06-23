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
 ============================================================================
 Name        : GPIB_access.c
 Author      : Andrzej Paluch
 Version     :
 Copyright   : Your copyright notice
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>

#include "GpibRegAccess.h"

#define CHECK(x) if(!(x)) goto error;

int rawRegAccessMain(int argc, char* argv[]) {

	printf("start\n");

	struct GpibRegAccess ra;

	CHECK(GpibRegAccess_init(&ra));

	RegType value, value1;
	unsigned int tempInt;
	SizeType regAddr = 1;

	char chr;

	do
	{
		chr = getchar();

		value = 0;
		value1 = 0;

		if(chr != 'e')
		{
			if(chr == 'r')
			{
				scanf("%u", &regAddr);
				CHECK(GpibRegAccess_readReg(&ra, regAddr, &value));
				printf("\n%x\n", value);
			}
			else if(chr == 'w')
			{
				scanf("%u", &regAddr);
				scanf("%x", &tempInt);

				value = tempInt;

				//printf("\n%u %u\n", regAddr, value);

				CHECK(GpibRegAccess_writeReg(&ra, regAddr, value));
			}
			else if(chr == 'a')
			{
				scanf("%u", &regAddr);
				scanf("%x", &tempInt);

				value = tempInt;

				//printf("\n%u %u\n", regAddr, value);

				CHECK(GpibRegAccess_readReg(&ra, regAddr, &value1));
				CHECK(GpibRegAccess_writeReg(&ra, regAddr, value & value1));
			}
			else if(chr == 'o')
			{
				scanf("%u", &regAddr);
				scanf("%x", &tempInt);

				value = tempInt;

				//printf("\n%u %u\n", regAddr, value);

				CHECK(GpibRegAccess_readReg(&ra, regAddr, &value1));
				CHECK(GpibRegAccess_writeReg(&ra, regAddr, value | value1));
			}
		}
		else
		{
			break;
		}
	}
	while(true);

	GpibRegAccess_release(&ra);

	printf("end\n");

	return 0;

	error:
		printf("error");
		GpibRegAccess_release(&ra);
		return -1;
}
