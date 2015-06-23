// $Id: RlinkPortFactory.hpp 486 2013-02-10 22:34:43Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkPortFactory.hpp 486 2013-02-10 22:34:43Z mueller $
  \brief   Declaration of class RlinkPortFactory.
*/

#ifndef included_Retro_RlinkPortFactory
#define included_Retro_RlinkPortFactory 1

#include "librtools/RerrMsg.hpp"
#include "RlinkPort.hpp"

namespace Retro {

  class RlinkPortFactory {
    public:
      static RlinkPort* New(const std::string& url, RerrMsg& emsg);
      static RlinkPort* Open(const std::string& url, RerrMsg& emsg);
  };
  
} // end namespace Retro

//#include "RlinkPortFactory.ipp"

#endif
