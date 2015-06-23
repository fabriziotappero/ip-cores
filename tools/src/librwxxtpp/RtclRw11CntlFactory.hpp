// $Id: RtclRw11CntlFactory.hpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-03-06   495   1.0    Initial version
// 2013-02-09   485   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11CntlFactory.hpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Declaration of global function RtclRw11CntlFactory.
*/

#ifndef included_Retro_RtclRw11CntlFactory
#define included_Retro_RtclRw11CntlFactory 1

#include "librtcltools/RtclArgs.hpp"
#include "RtclRw11Cpu.hpp"

namespace Retro {

  int RtclRw11CntlFactory(RtclArgs& args, RtclRw11Cpu& cpu);
  
} // end namespace Retro

#endif
