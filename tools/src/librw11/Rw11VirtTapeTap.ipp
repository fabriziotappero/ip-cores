// $Id: Rw11VirtTapeTap.ipp 686 2015-06-04 21:08:08Z mueller $
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
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtTapeTap.ipp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation (inline) of Rw11VirtTapeTap.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11VirtTapeTap::BytePadding(size_t rlen)
{
  return fPadOdd ? ((rlen+1) & 0xfffe) : rlen;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11VirtTapeTap::SetBad()
{
  fBad = true;
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11VirtTapeTap::IncPosRecord(int delta)
{
  if (fPosRecord != -1) fPosRecord += delta;
  return;
}  


} // end namespace Retro
