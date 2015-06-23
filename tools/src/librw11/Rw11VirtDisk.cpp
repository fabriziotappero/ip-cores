// $Id: Rw11VirtDisk.cpp 509 2013-04-21 20:46:20Z mueller $
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
// 2013-03-03   494   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtDisk.cpp 509 2013-04-21 20:46:20Z mueller $
  \brief   Implemenation of Rw11VirtDisk.
*/
#include <memory>

#include "librtools/RosFill.hpp"
#include "librtools/RparseUrl.hpp"
#include "Rw11VirtDiskFile.hpp"

#include "Rw11VirtDisk.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtDisk
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtDisk::Rw11VirtDisk(Rw11Unit* punit)
  : Rw11Virt(punit),
    fBlkSize(0),
    fNBlock(0)
{
  fStats.Define(kStatNVDRead,    "NVDRead",     "Read() calls");
  fStats.Define(kStatNVDReadBlk, "NVDReadBlk",  "blocks read");
  fStats.Define(kStatNVDWrite,   "NVDWrite",    "Write() calls");
  fStats.Define(kStatNVDWriteBlk,"NVDWriteBlk", "blocks written");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtDisk::~Rw11VirtDisk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rw11VirtDisk* Rw11VirtDisk::New(const std::string& url, Rw11Unit* punit,
                                RerrMsg& emsg)
{
  string scheme = RparseUrl::FindScheme(url, "file");
  unique_ptr<Rw11VirtDisk> p;
  
  if (scheme == "file") {                   // scheme -> file:
    p.reset(new Rw11VirtDiskFile(punit));
    if (p->Open(url, emsg)) return p.release();

  } else {                                  // scheme -> no match
    emsg.Init("Rw11VirtDisk::New", string("Scheme '") + scheme +
              "' is not supported");
  }

  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDisk::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtDisk @ " << this << endl;

  os << bl << "  fBlkSize:        " << fBlkSize << endl;
  os << bl << "  fNBlock:         " << fNBlock << endl;
  Rw11Virt::Dump(os, ind, " ^");
  return;
}


} // end namespace Retro
