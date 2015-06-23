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
 * GpibTypes.h
 *
 *  Created on: 2012-01-29
 *      Author: Andrzej Paluch
 */

#ifndef GPIBTYPES_H_
#define GPIBTYPES_H_

#include <stddef.h>


typedef int bool;
#define false 0
#define true 1
typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef int i32;
typedef size_t SizeType;
typedef unsigned int AddrType;
typedef unsigned short RegType;
typedef unsigned int HandleType;

#endif /* GPIBTYPES_H_ */
