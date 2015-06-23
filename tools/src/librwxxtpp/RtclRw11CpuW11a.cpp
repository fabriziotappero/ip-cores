// $Id: RtclRw11CpuW11a.cpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-02-16   488   1.0    Initial version
// 2013-02-02   480   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11CpuW11a.cpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation of RtclRw11CpuW11a.
*/

#include <iostream>

#include "RtclRw11CpuW11a.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11CpuW11a
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11CpuW11a::RtclRw11CpuW11a(Tcl_Interp* interp, const char* name)
  : RtclRw11CpuBase<Rw11CpuW11a>(interp, name, "Rw11CpuW11a")
{
  SetupGetSet();
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11CpuW11a::~RtclRw11CpuW11a()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRw11CpuW11a::SetupGetSet()
{
  RtclRw11Cpu::SetupGetSet();
  return;
}

} // end namespace Retro
