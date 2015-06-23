// $Id: Rw11VirtTerm.cpp 508 2013-04-20 18:43:28Z mueller $
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
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtTerm.cpp 508 2013-04-20 18:43:28Z mueller $
  \brief   Implemenation of Rw11VirtTerm.
*/
#include <memory>

#include "librtools/RparseUrl.hpp"
#include "librtools/RosFill.hpp"
#include "Rw11VirtTermPty.hpp"
#include "Rw11VirtTermTcp.hpp"

#include "Rw11VirtTerm.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtTerm
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtTerm::Rw11VirtTerm(Rw11Unit* punit)
  : Rw11Virt(punit),
    fChannelId(),
    fRcvCb()
{
  fStats.Define(kStatNVTRcvPoll,     "NVTRcvPoll", "VT RcvPollHandler() calls");
  fStats.Define(kStatNVTSnd,         "NVTSnd",       "VT Snd() calls");
  fStats.Define(kStatNVTRcvByt,      "NVTRcvByt",    "VT bytes received");
  fStats.Define(kStatNVTSndByt,      "NVTSndByt",    "VT bytes send");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtTerm::~Rw11VirtTerm()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rw11VirtTerm* Rw11VirtTerm::New(const std::string& url, Rw11Unit* punit,
                                RerrMsg& emsg)
{
  string scheme = RparseUrl::FindScheme(url, "tcp");
  unique_ptr<Rw11VirtTerm> p;
  
  if        (scheme == "pty") {             // scheme -> pty:
    p.reset(new Rw11VirtTermPty(punit));
    if (p->Open(url, emsg)) return p.release();

  } else if (scheme == "tcp") {             // scheme -> tcp:
    p.reset(new Rw11VirtTermTcp(punit));
    if (p->Open(url, emsg)) return p.release();

  } else {                                  // scheme -> no match
    emsg.Init("Rw11VirtTerm::New", string("Scheme '") + scheme +
              "' is not supported");

  }
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTerm::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtTerm @ " << this << endl;

  os << bl << "  fChannelId:      " << fChannelId << endl;
  Rw11Virt::Dump(os, ind, " ^");
  return;
}

} // end namespace Retro
