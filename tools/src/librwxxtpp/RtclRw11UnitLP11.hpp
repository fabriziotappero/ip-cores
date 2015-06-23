// $Id: RtclRw11UnitLP11.hpp 515 2013-05-04 17:28:59Z mueller $
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
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11UnitLP11.hpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Declaration of class RtclRw11UnitLP11.
*/

#ifndef included_Retro_RtclRw11UnitLP11
#define included_Retro_RtclRw11UnitLP11 1

#include "librw11/Rw11UnitLP11.hpp"
#include "librw11/Rw11CntlLP11.hpp"

#include "RtclRw11UnitStream.hpp"
#include "RtclRw11UnitBase.hpp"

namespace Retro {

class RtclRw11UnitLP11 : public RtclRw11UnitBase<Rw11UnitLP11>,
                         public RtclRw11UnitStream {
    public:
                    RtclRw11UnitLP11(Tcl_Interp* interp,
                                const std::string& unitcmd,
                                const boost::shared_ptr<Rw11UnitLP11>& spunit);
                   ~RtclRw11UnitLP11();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitLP11.ipp"

#endif
