// $Id: RtclRw11UnitDisk.hpp 509 2013-04-21 20:46:20Z mueller $
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
// 2013-04-19   507   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11UnitDisk.hpp 509 2013-04-21 20:46:20Z mueller $
  \brief   Declaration of class RtclRw11UnitDisk.
*/

#ifndef included_Retro_RtclRw11UnitDisk
#define included_Retro_RtclRw11UnitDisk 1

#include "librw11/Rw11UnitDisk.hpp"

#include "RtclRw11Unit.hpp"

namespace Retro {

  class RtclRw11UnitDisk {
    public:
                    RtclRw11UnitDisk(RtclRw11Unit* ptcl, Rw11UnitDisk* pobj);
                   ~RtclRw11UnitDisk();

    protected:

    protected:
      RtclRw11Unit* fpTcl;
      Rw11UnitDisk* fpObj;
  };
  
} // end namespace Retro

//#include "RtclRw11UnitDisk.ipp"

#endif
