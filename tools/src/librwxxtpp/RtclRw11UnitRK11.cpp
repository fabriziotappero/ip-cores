// $Id: RtclRw11UnitRK11.cpp 509 2013-04-21 20:46:20Z mueller $
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
// 2013-02-22   490   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitRK11.cpp 509 2013-04-21 20:46:20Z mueller $
  \brief   Implemenation of RtclRw11UnitRK11.
*/

#include "RtclRw11UnitRK11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitRK11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitRK11::RtclRw11UnitRK11(
                    Tcl_Interp* interp, const std::string& unitcmd,
                    const boost::shared_ptr<Rw11UnitRK11>& spunit)
  : RtclRw11UnitBase<Rw11UnitRK11>("Rw11UnitRK11", spunit),
    RtclRw11UnitDisk(this, spunit.get())
{
  CreateObjectCmd(interp, unitcmd.c_str()); 
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitRK11::~RtclRw11UnitRK11()
{}

} // end namespace Retro
