// $Id: RtclRw11CntlTM11.hpp 686 2015-06-04 21:08:08Z mueller $
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
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11CntlTM11.hpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Declaration of class RtclRw11CntlTM11.
*/

#ifndef included_Retro_RtclRw11CntlTM11
#define included_Retro_RtclRw11CntlTM11 1

#include "RtclRw11CntlBase.hpp"
#include "librw11/Rw11CntlTM11.hpp"

namespace Retro {

  class RtclRw11CntlTM11 : public RtclRw11CntlBase<Rw11CntlTM11> {
    public:
                    RtclRw11CntlTM11();
                   ~RtclRw11CntlTM11();

      virtual int   FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu);

    protected:
      virtual int   M_stats(RtclArgs& args);
  };
  
} // end namespace Retro

//#include "RtclRw11CntlTM11.ipp"

#endif
