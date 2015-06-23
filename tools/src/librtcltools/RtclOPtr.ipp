// $Id: RtclOPtr.ipp 488 2013-02-16 18:49:47Z mueller $
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
// 2011-02-20   363   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclOPtr.ipp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation (inline) of RtclOPtr.
*/

/*!
  \class Retro::RtclOPtr
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

inline RtclOPtr::RtclOPtr()
  : fpObj(0)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclOPtr::RtclOPtr(Tcl_Obj* pobj)
  : fpObj(pobj)
{
  if (fpObj) Tcl_IncrRefCount(fpObj);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclOPtr::RtclOPtr(const RtclOPtr& rhs)
  : fpObj(rhs.fpObj)
{
  if (fpObj) Tcl_IncrRefCount(fpObj);
}

//------------------------------------------+-----------------------------------
//! Destructor

inline RtclOPtr::~RtclOPtr()
{
  if (fpObj) Tcl_DecrRefCount(fpObj);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclOPtr::operator Tcl_Obj*() const
{
  return fpObj;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RtclOPtr::operator !() const
{
  return fpObj==0;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclOPtr& RtclOPtr::operator=(const RtclOPtr& rhs)
{
  if (&rhs == this) return *this;
  return operator=(rhs.fpObj);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline RtclOPtr& RtclOPtr::operator=(Tcl_Obj* pobj)
{
  if (fpObj) Tcl_DecrRefCount(fpObj);
  fpObj = pobj;
  if (fpObj) Tcl_IncrRefCount(fpObj);
  return *this;
}

} // end namespace Retro
