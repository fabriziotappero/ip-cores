// $Id: RlinkChannel.cpp 492 2013-02-24 22:14:47Z mueller $
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
// 2013-02-23   492   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkChannel.cpp 492 2013-02-24 22:14:47Z mueller $
  \brief   Implemenation of class RlinkChannel.
 */

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/Rexception.hpp"

#include "RlinkChannel.hpp"

using namespace std;

/*!
  \class Retro::RlinkChannel
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkChannel::RlinkChannel(const boost::shared_ptr<RlinkConnect>& spconn)
  : fContext(),
    fspConn(spconn)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkChannel::~RlinkChannel()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkChannel::Exec(RlinkCommandList& clist, RerrMsg& emsg)
{
  if (!fspConn)
    throw Rexception("RlinkChannel::Exec", "Bad state: fspConn == 0");
  
  return fspConn->Exec(clist, emsg);
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkChannel::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkChannel @ " << this << endl;

  fContext.Dump(os, ind+2, "fContext: ");
  if (fspConn) {
    fspConn->Dump(os, ind+2, "fspConn: ");
  } else {
    os << bl << "  fspConn:         " <<  fspConn.get() << endl;
  }
  
  return;
}

} // end namespace Retro
