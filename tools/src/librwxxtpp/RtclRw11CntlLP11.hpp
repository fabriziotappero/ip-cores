// $Id: RtclRw11CntlLP11.hpp 515 2013-05-04 17:28:59Z mueller $
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
  \version $Id: RtclRw11CntlLP11.hpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Declaration of class RtclRw11CntlLP11.
*/

#ifndef included_Retro_RtclRw11CntlLP11
#define included_Retro_RtclRw11CntlLP11 1

#include "RtclRw11CntlBase.hpp"
#include "librw11/Rw11CntlLP11.hpp"

namespace Retro {

  class RtclRw11CntlLP11 : public RtclRw11CntlBase<Rw11CntlLP11> {
    public:
                    RtclRw11CntlLP11();
                   ~RtclRw11CntlLP11();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlLP11.ipp"

#endif
