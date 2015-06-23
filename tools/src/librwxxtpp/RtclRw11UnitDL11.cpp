// $Id: RtclRw11UnitDL11.cpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-03-01   493   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitDL11.cpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation of RtclRw11UnitDL11.
*/

#include "RtclRw11UnitDL11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitDL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitDL11::RtclRw11UnitDL11(Tcl_Interp* interp,
                              const std::string& unitcmd,
                              const boost::shared_ptr<Rw11UnitDL11>& spunit)
  : RtclRw11UnitBase<Rw11UnitDL11>("Rw11UnitDL11", spunit),
    RtclRw11UnitTerm(this, spunit.get())
{
  CreateObjectCmd(interp, unitcmd.c_str()); 
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitDL11::~RtclRw11UnitDL11()
{}

} // end namespace Retro
