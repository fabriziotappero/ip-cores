// $Id: RtclRw11UnitRHRP.hpp 680 2015-05-14 13:29:46Z mueller $
//
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-05-14   680   1.0    Initial version
// 2015-03-21   659   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11UnitRHRP.hpp 680 2015-05-14 13:29:46Z mueller $
  \brief   Declaration of class RtclRw11UnitRHRP.
*/

#ifndef included_Retro_RtclRw11UnitRHRP
#define included_Retro_RtclRw11UnitRHRP 1

#include "librw11/Rw11UnitRHRP.hpp"
#include "librw11/Rw11CntlRHRP.hpp"

#include "RtclRw11UnitDisk.hpp"
#include "RtclRw11UnitBase.hpp"

namespace Retro {

  class RtclRw11UnitRHRP : public RtclRw11UnitBase<Rw11UnitRHRP>,
                           public RtclRw11UnitDisk {
    public:
                    RtclRw11UnitRHRP(Tcl_Interp* interp,
                                 const std::string& unitcmd,
                                 const boost::shared_ptr<Rw11UnitRHRP>& spunit);
                   ~RtclRw11UnitRHRP();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitRHRP.ipp"

#endif
