// $Id: RtclRw11CntlRL11.hpp 647 2015-02-17 22:35:36Z mueller $
//
// Copyright 2014-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-01-10   632   1.0    Initial version
// 2014-06-10   561   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11CntlRL11.hpp 647 2015-02-17 22:35:36Z mueller $
  \brief   Declaration of class RtclRw11CntlRL11.
*/

#ifndef included_Retro_RtclRw11CntlRL11
#define included_Retro_RtclRw11CntlRL11 1

#include "RtclRw11CntlBase.hpp"
#include "librw11/Rw11CntlRL11.hpp"

namespace Retro {

  class RtclRw11CntlRL11 : public RtclRw11CntlBase<Rw11CntlRL11> {
    public:
                    RtclRw11CntlRL11();
                   ~RtclRw11CntlRL11();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);

    protected:
      virtual int   M_stats(RtclArgs& args);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlRL11.ipp"

#endif
