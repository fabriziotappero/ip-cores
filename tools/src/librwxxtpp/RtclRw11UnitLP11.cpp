// $Id: RtclRw11UnitLP11.cpp 515 2013-05-04 17:28:59Z mueller $
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
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitLP11.cpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Implemenation of RtclRw11UnitLP11.
*/

#include "RtclRw11UnitLP11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitLP11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitLP11::RtclRw11UnitLP11(Tcl_Interp* interp,
                              const std::string& unitcmd,
                              const boost::shared_ptr<Rw11UnitLP11>& spunit)
  : RtclRw11UnitBase<Rw11UnitLP11>("Rw11UnitLP11", spunit),
    RtclRw11UnitStream(this, spunit.get())
{
  CreateObjectCmd(interp, unitcmd.c_str()); 
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitLP11::~RtclRw11UnitLP11()
{}

} // end namespace Retro
