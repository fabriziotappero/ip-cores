// $Id: RtclArgs.ipp 495 2013-03-06 17:13:48Z mueller $
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
// 2013-03-05   495   1.0.8  add SetResult(bool)
// 2013-03-02   494   1.0.7  add Quit() method
// 2013-02-01   479   1.0.5  add Objv() method
// 2011-03-26   373   1.0.2  add SetResult(string)
// 2011-03-05   366   1.0.1  add NDone(), NOptMiss(), SetResult();
// 2011-02-26   364   1.0    Initial version
// 2011-02-18   362   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclArgs.ipp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation (inline) of RtclArgs.
*/

#include "Rtcl.hpp"

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Tcl_Interp* RtclArgs::Interp() const
{
  return fpInterp;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RtclArgs::Objc() const
{
  return fObjc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Tcl_Obj* const * RtclArgs::Objv() const
{
  return fObjv;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RtclArgs::OptValid() const
{
  return !fOptErr;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RtclArgs::NDone() const
{
  return fNDone;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RtclArgs::NOptMiss() const
{
  return fNOptMiss;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtclArgs::SetResult(const std::string& str)
{
  Rtcl::SetResult(fpInterp, str);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtclArgs::SetResult(std::ostringstream& sos)
{
  Rtcl::SetResult(fpInterp, sos);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtclArgs::SetResult(bool val)
{
  Tcl_SetObjResult(fpInterp, Tcl_NewBooleanObj(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtclArgs::SetResult(int val)
{
  Tcl_SetObjResult(fpInterp, Tcl_NewIntObj(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtclArgs::SetResult(double val)
{
  Tcl_SetObjResult(fpInterp, Tcl_NewDoubleObj(val));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtclArgs::SetResult(Tcl_Obj* pobj)
{
  Tcl_SetObjResult(fpInterp, pobj);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtclArgs::AppendResult(const std::string& str)
{
  Tcl_AppendResult(fpInterp, str.c_str(), NULL);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtclArgs::AppendResult(std::ostringstream& sos)
{
  AppendResult(sos.str());
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RtclArgs::AppendResultLines(std::ostringstream& sos)
{
  AppendResultLines(sos.str());
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RtclArgs::Quit(const std::string& str)
{
  Tcl_AppendResult(fpInterp, str.c_str(), NULL);
  return TCL_ERROR;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline Tcl_Obj* RtclArgs::operator[](size_t ind) const
{
  return fObjv[ind];
}

} // end namespace Retro
