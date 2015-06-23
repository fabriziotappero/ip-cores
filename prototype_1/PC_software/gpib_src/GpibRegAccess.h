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
 * GpibRegAccess.h
 *
 *  Created on: 2012-01-28
 *      Author: Andrzej Paluch
 */

#ifndef GPIB_REGACCESS_H_
#define GPIB_REGACCESS_H_

#include "GpibTypes.h"

/** Register access structure. */
struct GpibRegAccess
{
	HandleType portHandle;
	bool isBurstMode;
};

/** Initializes register access. */
bool GpibRegAccess_init(struct GpibRegAccess *ra);

/** Releases register access. */
void GpibRegAccess_release(struct GpibRegAccess *ra);

/** Reads register. */
bool GpibRegAccess_readReg(struct GpibRegAccess *ra, SizeType addr, RegType *pValue);

/** Reads register repeatedly. */
bool GpibRegAccess_repeatedlyRead(struct GpibRegAccess *ra, SizeType addr,
		char *buf, SizeType bufLen);

/** Writes register. */
bool GpibRegAccess_writeReg(struct GpibRegAccess *ra, SizeType addr, RegType value);

/** Writes register repeatedly. */
bool GpibRegAccess_repeatedlyWrite(struct GpibRegAccess *ra, SizeType addr,
		char *buf, SizeType bufLen);

#endif /* GPIB_REGACCESS_H_ */
