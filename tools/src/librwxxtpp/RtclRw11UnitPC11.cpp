// $Id: RtclRw11UnitPC11.cpp 584 2014-08-22 19:38:12Z mueller $
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
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitPC11.cpp 584 2014-08-22 19:38:12Z mueller $
  \brief   Implemenation of RtclRw11UnitPC11.
*/

#include "RtclRw11UnitPC11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11UnitPC11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitPC11::RtclRw11UnitPC11(Tcl_Interp* interp,
                              const std::string& unitcmd,
                              const boost::shared_ptr<Rw11UnitPC11>& spunit)
  : RtclRw11UnitBase<Rw11UnitPC11>("Rw11UnitPC11", spunit),
    RtclRw11UnitStream(this, spunit.get())
{
  // create default unit command
  CreateObjectCmd(interp, unitcmd.c_str());

  // for 1st PC11, create also alias
  //   cpuxpca0 -> cpuxpr
  //   cpuxpca1 -> cpuxpp
  if (unitcmd.length() == 8) {
    size_t ind = spunit->Index();
    if (unitcmd.length() == 8 && unitcmd.substr(4,3) == "pca") {
      string alias = unitcmd.substr(0,4);
      alias += (ind==Rw11CntlPC11::kUnit_PR) ? "pr" : "pp";
      Tcl_CreateAlias(interp, alias.c_str(), interp, unitcmd.c_str(), 
                      0, nullptr);
    }
  }
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11UnitPC11::~RtclRw11UnitPC11()
{}

} // end namespace Retro
