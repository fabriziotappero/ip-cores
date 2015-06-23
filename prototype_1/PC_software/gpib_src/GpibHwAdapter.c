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
 * GpibHwAdapter.c
 *
 *  Created on: 2012-01-29
 *      Author: Andrzej Paluch
 */

#include "GpibHwAdapter.h"


bool GpibHwAdapter_init(struct GpibHwAdapter *ghwa,
		struct GpibRegAccess *regAccess, AddrType baseAddr)
{
	ghwa->regAccess = regAccess;
	ghwa->baseAddr = baseAddr;

	return true;
}

void GpibHwAdapter_release(struct GpibHwAdapter *ghwa)
{
	// do nothing
}






