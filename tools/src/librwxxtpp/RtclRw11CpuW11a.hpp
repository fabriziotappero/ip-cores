// $Id: RtclRw11CpuW11a.hpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-02-16   488   1.0    Initial version
// 2013-02-02   480   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11CpuW11a.hpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Declaration of class RtclRw11CpuW11a.
*/

#ifndef included_Retro_RtclRw11CpuW11a
#define included_Retro_RtclRw11CpuW11a 1

#include "RtclRw11CpuBase.hpp"
#include "librw11/Rw11CpuW11a.hpp"

namespace Retro {

  class RtclRw11CpuW11a : public RtclRw11CpuBase<Rw11CpuW11a> {
    public:
                    RtclRw11CpuW11a(Tcl_Interp* interp, const char* name);
                   ~RtclRw11CpuW11a();

    protected:
      void          SetupGetSet();

  };
  
} // end namespace Retro

//#include "RtclRw11CpuW11a.ipp"

#endif
