//-----------------------------------------------------------------
//                           AltOR32 
//                Alternative Lightweight OpenRisc 
//                            V2.0
//                     Ultra-Embedded.com
//                   Copyright 2011 - 2013
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2011 - 2013 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------
#ifndef __PERIPHERAL_H__
#define __PERIPHERAL_H__

//--------------------------------------------------------------------
// Class
//--------------------------------------------------------------------
class Peripheral
{
public:  
    // Peripheral access
    virtual void        Reset(void) = 0;
    virtual void        Clock(void) = 0;
    virtual TRegister   Access(TAddress addr, TRegister data_in, TRegister wr, TRegister rd) = 0;
    virtual bool        Interrupt(void) = 0;
    virtual TAddress    GetStartAddress() = 0;
    virtual TAddress    GetStopAddress() = 0;
};

//--------------------------------------------------------------------
// Class
//--------------------------------------------------------------------
class PeripheralInstance
{
public:
    PeripheralInstance() { instance = NULL; start_address = end_address = 0; }

public:
    Peripheral *    instance;
    TRegister       start_address;
    TRegister       end_address;
};

#endif
