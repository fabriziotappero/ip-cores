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
  Character LCD C++ Interface.
  @file vpioLcd.hh

  This file provides a C++ wrapper class to the low-level C interface.
 */

#ifndef VPIO_LCD_HH
#define VPIO_LCD_HH

#ifdef __cplusplus
extern "C" {
#endif
#include "vpioLcd.h"
#ifdef __cplusplus
}
#endif

namespace vpio {

/*!
   General-Purpose I/O Class.

   This is a C++ wrapper class around the low-level C code.
*/

class lcdClass : public lcdRegs
{
  
private:      

  lcdClass& operator=(const lcdClass&);
  
public:

  // Low-level I/O functions
  void Reset() { lcdReset((lcdRegs*)this); } ///< @see lcdReset
  void WaitBusy() { lcdWaitBusy((lcdRegs*)this); } ///< @see lcdWaitBusy
  void PutControl(char ctrl) { lcdPutControl((lcdRegs*)this, ctrl); } ///< @see lcdPutControl
  char GetControl() { return lcdGetControl((lcdRegs*)this); } ///< @see lcdGetControl
  void PutData(char data) { lcdPutData((lcdRegs*)this,data); } ///< @see lcdPutData
  char GetData() { return lcdGetData((lcdRegs*)this); } ///< @see lcdGetData
  void Delay(int ms) { lcdDelay(ms); } ///< @see lcdDelay
  
  // High-level application functions
  void Init() { lcdInit((lcdRegs*)this); } ///< @see lcdInit
  void Home() { lcdHome((lcdRegs*)this); } ///< @see lcdHome
  void Clear() { lcdClear((lcdRegs*)this); } ///< @see lcdClear

};

}

#endif
