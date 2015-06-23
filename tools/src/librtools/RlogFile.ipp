// $Id: RlogFile.ipp 492 2013-02-24 22:14:47Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-23   492   2.1    add Name(), keep log file name
// 2013-02-22   491   2.0    add Write(),IsNew(), RlogMsg iface; use lockable
// 2011-01-30   357   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlogFile.ipp 492 2013-02-24 22:14:47Z mueller $
  \brief   Implemenation (inline) of RlogFile.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlogFile::IsNew() const
{
  return fNew;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& RlogFile::Name() const
{
  return fName;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline std::ostream& RlogFile::Stream()
{
  return fpExtStream ? *fpExtStream : fIntStream;
}

} // end namespace Retro
