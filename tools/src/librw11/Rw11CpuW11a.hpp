// $Id: Rw11CpuW11a.hpp 621 2014-12-26 21:20:05Z mueller $
//
// Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-12-25   621   1.1    adopt to 4k word ibus window
// 2013-03-03   494   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11CpuW11a.hpp 621 2014-12-26 21:20:05Z mueller $
  \brief   Declaration of class Rw11CpuW11a.
*/

#ifndef included_Retro_Rw11CpuW11a
#define included_Retro_Rw11CpuW11a 1

#include "Rw11Cpu.hpp"

namespace Retro {

  class Rw11CpuW11a : public Rw11Cpu {
    public:

                    Rw11CpuW11a();
                   ~Rw11CpuW11a();

      void          Setup(size_t ind, uint16_t base, uint16_t ibase);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;
 
    protected:
  };
  
} // end namespace Retro

//#include "Rw11CpuW11a.ipp"

#endif
