// $Id: RtclRw11CpuBase.ipp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-02-23   491   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11CpuBase.ipp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation (all inline) of RtclRw11CpuBase.
*/

/*!
  \class Retro::RtclRw11CpuBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TO>
inline RtclRw11CpuBase<TO>::RtclRw11CpuBase(Tcl_Interp* interp, 
                                            const char* name,
                                            const std::string& type)
  : RtclRw11Cpu(type),
    fspObj(new TO())
{
  CreateObjectCmd(interp, name);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclRw11CpuBase<TO>::~RtclRw11CpuBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline TO& RtclRw11CpuBase<TO>::Obj()
{
  return *fspObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline const boost::shared_ptr<TO>& RtclRw11CpuBase<TO>::ObjSPtr()
{
  return fspObj;
}


} // end namespace Retro
