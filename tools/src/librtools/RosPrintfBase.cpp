// $Id: RosPrintfBase.cpp 488 2013-02-16 18:49:47Z mueller $
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
// 2011-02-25   364   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RosPrintfBase.cpp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation of RosPrintfBase .
*/

#include <sstream>

#include "RosPrintfBase.hpp"

using namespace std;

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
/*!
  \relates RosPrintfBase
  \brief string insertion
*/

std::string& operator<<(std::string& os, const RosPrintfBase& obj)
{
  std::ostringstream sos;
  obj.ToStream(sos);
  os += sos.str();
  return os;
}

} // end namespace Retro
