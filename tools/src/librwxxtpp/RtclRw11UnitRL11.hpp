// $Id: RtclRw11UnitRL11.hpp 647 2015-02-17 22:35:36Z mueller $
//
// Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-06-08   561   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11UnitRL11.hpp 647 2015-02-17 22:35:36Z mueller $
  \brief   Declaration of class RtclRw11UnitRL11.
*/

#ifndef included_Retro_RtclRw11UnitRL11
#define included_Retro_RtclRw11UnitRL11 1

#include "librw11/Rw11UnitRL11.hpp"
#include "librw11/Rw11CntlRL11.hpp"

#include "RtclRw11UnitDisk.hpp"
#include "RtclRw11UnitBase.hpp"

namespace Retro {

  class RtclRw11UnitRL11 : public RtclRw11UnitBase<Rw11UnitRL11>,
                           public RtclRw11UnitDisk {
    public:
                    RtclRw11UnitRL11(Tcl_Interp* interp,
                                 const std::string& unitcmd,
                                 const boost::shared_ptr<Rw11UnitRL11>& spunit);
                   ~RtclRw11UnitRL11();

    protected:
  };
  
} // end namespace Retro

//#include "RtclRw11UnitRL11.ipp"

#endif
