// $Id: Rbits.hpp 530 2013-08-09 21:25:04Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
// Revision History: 
// Date         Rev Version  Comment
// 2013-03-01   493   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rbits.hpp 530 2013-08-09 21:25:04Z mueller $
  \brief   Declaration of class Rbits .
*/

#ifndef included_Retro_Rbits
#define included_Retro_Rbits 1

#include <cstdint>

namespace Retro {
  class Rbits {
    public:

    static const uint8_t  kBBit00 = 1u<< 0;
    static const uint8_t  kBBit01 = 1u<< 1;
    static const uint8_t  kBBit02 = 1u<< 2;
    static const uint8_t  kBBit03 = 1u<< 3;
    static const uint8_t  kBBit04 = 1u<< 4;
    static const uint8_t  kBBit05 = 1u<< 5;
    static const uint8_t  kBBit06 = 1u<< 6;
    static const uint8_t  kBBit07 = 1u<< 7;
    
    static const uint16_t kWBit00 = 1u<< 0;
    static const uint16_t kWBit01 = 1u<< 1;
    static const uint16_t kWBit02 = 1u<< 2;
    static const uint16_t kWBit03 = 1u<< 3;
    static const uint16_t kWBit04 = 1u<< 4;
    static const uint16_t kWBit05 = 1u<< 5;
    static const uint16_t kWBit06 = 1u<< 6;
    static const uint16_t kWBit07 = 1u<< 7;
    static const uint16_t kWBit08 = 1u<< 8;
    static const uint16_t kWBit09 = 1u<< 9;
    static const uint16_t kWBit10 = 1u<<10;
    static const uint16_t kWBit11 = 1u<<11;
    static const uint16_t kWBit12 = 1u<<12;
    static const uint16_t kWBit13 = 1u<<13;
    static const uint16_t kWBit14 = 1u<<14;
    static const uint16_t kWBit15 = 1u<<15;

    static const uint32_t kLBit00 = 1u<< 0;
    static const uint32_t kLBit01 = 1u<< 1;
    static const uint32_t kLBit02 = 1u<< 2;
    static const uint32_t kLBit03 = 1u<< 3;
    static const uint32_t kLBit04 = 1u<< 4;
    static const uint32_t kLBit05 = 1u<< 5;
    static const uint32_t kLBit06 = 1u<< 6;
    static const uint32_t kLBit07 = 1u<< 7;
    static const uint32_t kLBit08 = 1u<< 8;
    static const uint32_t kLBit09 = 1u<< 9;
    static const uint32_t kLBit10 = 1u<<10;
    static const uint32_t kLBit11 = 1u<<11;
    static const uint32_t kLBit12 = 1u<<12;
    static const uint32_t kLBit13 = 1u<<13;
    static const uint32_t kLBit14 = 1u<<14;
    static const uint32_t kLBit15 = 1u<<15;
    static const uint32_t kLBit16 = 1u<<16;
    static const uint32_t kLBit17 = 1u<<17;
    static const uint32_t kLBit18 = 1u<<18;
    static const uint32_t kLBit19 = 1u<<19;
    static const uint32_t kLBit20 = 1u<<20;
    static const uint32_t kLBit21 = 1u<<21;
    static const uint32_t kLBit22 = 1u<<22;
    static const uint32_t kLBit23 = 1u<<23;
    static const uint32_t kLBit24 = 1u<<24;
    static const uint32_t kLBit25 = 1u<<25;
    static const uint32_t kLBit26 = 1u<<26;
    static const uint32_t kLBit27 = 1u<<27;
    static const uint32_t kLBit28 = 1u<<28;
    static const uint32_t kLBit29 = 1u<<29;
    static const uint32_t kLBit30 = 1u<<30;
    static const uint32_t kLBit31 = 1u<<31;

  };
  
} // end namespace Retro

//#include "Rbits.ipp"

#endif
