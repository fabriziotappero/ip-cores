// $Id: RtclRw11UnitRL11.cpp 561 2014-06-09 17:22:50Z mueller $
//
// Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-06-08   561   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitRL11.cpp 561 2014-06-09 17:22:50Z mueller $
  \brief   Implemenation of RtclRw11UnitRL11.
*/

#include "RtclRw11UnitRL11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitRL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitRL11::RtclRw11UnitRL11(
                    Tcl_Interp* interp, const std::string& unitcmd,
                    const boost::shared_ptr<Rw11UnitRL11>& spunit)
  : RtclRw11UnitBase<Rw11UnitRL11>("Rw11UnitRL11", spunit),
    RtclRw11UnitDisk(this, spunit.get())
{
  CreateObjectCmd(interp, unitcmd.c_str()); 
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitRL11::~RtclRw11UnitRL11()
{}

} // end namespace Retro
