// $Id: RosPrintBvi.ipp 488 2013-02-16 18:49:47Z mueller $
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
// 2011-03-05   366   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RosPrintBvi.ipp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation (inline) of RosPrintBvi.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
/*! 
  \relates RosPrintBvi
  \brief ostream insertion operator.
*/

inline std::ostream& operator<<(std::ostream& os, const RosPrintBvi& obj)
{
  obj.Print(os);
  return os;
}

//------------------------------------------+-----------------------------------
/*! 
  \relates RosPrintBvi
  \brief string insertion operator.
*/

inline std::string& operator<<(std::string& os, const RosPrintBvi& obj)
{
  obj.Print(os);
  return os;
}


} // end namespace Retro
