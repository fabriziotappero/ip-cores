// $Id: RtclClassOwned.ipp 488 2013-02-16 18:49:47Z mueller $
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
// 2013-01-13   474   1.0.1  ClassCmdCreate(): fix configuration failed logic
// 2011-02-20   363   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclClassOwned.ipp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation (inline) of class RtclClassOwned.
*/

#include <iostream>
#include <string>

#include "RtclProxyBase.hpp"
#include "RtclArgs.hpp"

/*!
  \class Retro::RtclClassOwned
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

template <class TP>
inline RtclClassOwned<TP>::RtclClassOwned(const std::string& type)
  : RtclClassBase(type)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TP>
inline RtclClassOwned<TP>::~RtclClassOwned()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline int RtclClassOwned<TP>::ClassCmdCreate(Tcl_Interp* interp, int objc, 
                                              Tcl_Obj* const objv[])
{
  RtclArgs  args(interp, objc, objv, 1);
  std::string name;
  if (!args.GetArg("name", name)) return kERR;
  
  // create new proxy object
  TP* pobj = new TP(interp, name.c_str());
  // execute configure, delete command in case configure failed
  //   Note: deleting the command will implicitely delete the object..
  if (pobj->ClassCmdConfig(args) != kOK) {
    ClassCmdDelete(interp, name.c_str());
    return kERR;
  }
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline void RtclClassOwned<TP>::CreateClass(Tcl_Interp* interp, 
                                            const char* name, 
                                            const std::string& type)
{
  RtclClassOwned<TP>* p = new RtclClassOwned<TP>(type);
  p->CreateClassCmd(interp, name);
  return;
}

} // end namespace Retro
