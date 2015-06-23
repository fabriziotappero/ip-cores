// $Id: Rwxxtpp_Init.cpp 584 2014-08-22 19:38:12Z mueller $
//
// Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-08-22   584   1.0.1  use nullptr
// 2013-02-10   485   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rwxxtpp_Init.cpp 584 2014-08-22 19:38:12Z mueller $
  \brief   Implemenation of Rwxxtpp_Init .
*/

#include "tcl.h"

#include <stdexcept>

#include "librtcltools/RtclClassOwned.hpp"
#include "RtclRw11.hpp"

using namespace std;
using namespace Retro;

//------------------------------------------+-----------------------------------
extern "C" int Rwxxtpp_Init(Tcl_Interp* interp) 
{
  int irc;

  // declare package name and version
  irc = Tcl_PkgProvide(interp, "rwxxtpp", "1.0.0");
  if (irc != TCL_OK) return irc;

  try {
    // register class commands
    RtclClassOwned<RtclRw11>::CreateClass(interp, "rw11", "Rw11");
    return TCL_OK;

  } catch (exception& e) {
    Tcl_AppendResult(interp, "-E: exception caught in Rwxxtpp_Init: '", 
                     e.what(), "'", nullptr);
  }
  return TCL_ERROR;
}

