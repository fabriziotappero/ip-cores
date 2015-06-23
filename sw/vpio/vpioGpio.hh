/* $Id: memtest.hh,v 1.8 2008-06-24 10:03:41 sybreon Exp $
** 
** VIRTUAL PERIPHERAL I/O LIBRARY
** Copyright (C) 2009 Shawn Tan <shawn.tan@aeste.net>
**
** This file is part of AEMB.
**
** AEMB is free software: you can redistribute it and/or modify it
** under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** AEMB is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
** License for more details.
**
** You should have received a copy of the GNU General Public License
** along with AEMB.  If not, see <http://www.gnu.org/licenses/>.
*/

/*!
  GPIO C++ Interface.
  @file vpioGpio.hh

  This file provides a C++ wrapper class to the low-level C interface.
 */

#ifndef VPIO_GPIO_HH
#define VPIO_GPIO_HH

#ifdef __cplusplus
extern "C" {
#endif
#include "vpioGpio.h"
#ifdef __cplusplus
}
#endif

namespace vpio {

/*!
   General-Purpose I/O Class.

   This is a C++ wrapper class around the low-level C code.
*/

class gpioClass : public gpioRegs
{
  
private:    
  
  //gpioClass(const gpioClass&);
  //gpioClass();
  gpioClass& operator=(const gpioClass&);
  
public:

  //void IniPort(int base_addr) { this = (gpioRegs*)base_addr; }
    
  void SetBit(gpioData bit) { gpioSetBit( (gpioRegs*)this, bit); } ///< @see gpioSetBit
  void ClrBit(gpioData bit) { gpioClrBit( (gpioRegs*)this, bit); } ///< @see gpioClrBit
  void TogBit(gpioData bit) { gpioTogBit( (gpioRegs*)this, bit); } ///< @see gpioTogBit
  gpioData  GetBit(gpioData bit) { return gpioGetBit( (gpioRegs*)this, bit); } ///< @see gpioGetBit
  
  // Port Manipulation
  //void PutTris(gpioData mask) { gpioPutTris( (gpioRegs*)this, mask); } ///< @see gpioPutTris
  void SetTris(gpioData mask) { gpioSetTris( (gpioRegs*)this, mask); } ///< @see gpioSetTris
  void PutData(gpioData data) { gpioPutData( (gpioRegs*)this, data); } ///< @see gpioPutData
  //void ClrPort() { gpioClrPort( (gpioRegs*)this ); } ///< @see gpioClrPort
  //gpioData GetTris() { return gpioGetTris( (gpioRegs*)this ); } ///< @see gpioGetTris
  gpioData GetData() { return gpioGetData( (gpioRegs*)this ); } ///< @see gpioGetData
    
  void Init() { gpioInit( (gpioRegs*)this ); } ///< @see gpioInit
};

}

#endif
