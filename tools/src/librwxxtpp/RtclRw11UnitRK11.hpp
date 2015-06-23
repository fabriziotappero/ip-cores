// $Id: RtclRw11UnitRK11.hpp 509 2013-04-21 20:46:20Z mueller $
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
// 2013-02-22   490   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11UnitRK11.hpp 509 2013-04-21 20:46:20Z mueller $
  \brief   Declaration of class RtclRw11UnitRK11.
*/

#ifndef included_Retro_RtclRw11UnitRK11
#define included_Retro_RtclRw11UnitRK11 1

#include "librw11/Rw11UnitRK11.hpp"
#include "librw11/Rw11CntlRK11.hpp"

#include "RtclRw11UnitDisk.hpp"
#include "RtclRw11UnitBase.hpp"

namespace Retro {

  class RtclRw11UnitRK11 : public RtclRw11UnitBase<Rw11UnitRK11>,
                           public RtclRw11UnitDisk {
    public:
                    RtclRw11UnitRK11(Tcl_Interp* interp,
                                 const std::string& unitcmd,
                                 const boost::shared_ptr<Rw11UnitRK11>& spunit);
                   ~RtclRw11UnitRK11();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitRK11.ipp"

#endif
