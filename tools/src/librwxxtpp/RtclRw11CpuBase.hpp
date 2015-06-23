// $Id: RtclRw11CpuBase.hpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-02-23   491   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11CpuBase.hpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Declaration of class RtclRw11CpuBase.
*/

#ifndef included_Retro_RtclRw11CpuBase
#define included_Retro_RtclRw11CpuBase 1

#include "boost/shared_ptr.hpp"

#include "RtclRw11Cpu.hpp"

namespace Retro {

  template <class TO>
  class RtclRw11CpuBase : public RtclRw11Cpu {
    public:
                    RtclRw11CpuBase(Tcl_Interp* interp, const char* name,
                                    const std::string& type);
                   ~RtclRw11CpuBase();

      TO&           Obj();
      const boost::shared_ptr<TO>&  ObjSPtr();

    protected:
      boost::shared_ptr<TO>  fspObj; //!< sptr to managed object
  };
  
} // end namespace Retro

// implementation is all inline
#include "RtclRw11CpuBase.ipp"

#endif
