// $Id: RtclProxyOwned.ipp 491 2013-02-23 12:41:18Z mueller $
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
// 2013-02-05   482   1.1    use shared_ptr to TO*; add ObjPtr();
// 2011-02-13   361   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id:  
  \brief   Implemenation (all inline) of class RtclProxyOwned.
*/

/*!
  \class Retro::RtclProxyOwned
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TO>
inline RtclProxyOwned<TO>::RtclProxyOwned()
  : RtclProxyBase(),
    fspObj()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclProxyOwned<TO>::RtclProxyOwned(const std::string& type)
  : RtclProxyBase(type),
    fspObj()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclProxyOwned<TO>::RtclProxyOwned(const std::string& type,
                                          Tcl_Interp* interp, const char* name, 
                                          TO* pobj)
  : RtclProxyBase(type),
    fspObj(pobj)
{
  CreateObjectCmd(interp, name);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclProxyOwned<TO>::~RtclProxyOwned()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline TO& RtclProxyOwned<TO>::Obj()
{
  return *fspObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline const boost::shared_ptr<TO>& RtclProxyOwned<TO>::ObjSPtr()
{
  return fspObj;
}

} // end namespace Retro
