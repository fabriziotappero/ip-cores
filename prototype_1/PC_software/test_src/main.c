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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "GpibRegAccess.h"


#define CHECK(x) if(!(x)) goto error;

extern int gpibExplorerMain(int argc, char* argv[]);
extern int rawRegAccessMain(int argc, char* argv[]);
extern int listenOnlyMain(int argc, char* argv[]);


int main(int argc, char *argv[]) {

	if(argc == 2)
	{
		if(strstr(argv[1], "ge"))
		{
			return gpibExplorerMain(argc, argv);
		} else if(strstr(argv[1], "rra"))
		{
			return rawRegAccessMain(argc, argv);
		} else if(strstr(argv[1], "lo"))
		{
			return listenOnlyMain(argc, argv);
		}
	}

	return 1;
}
