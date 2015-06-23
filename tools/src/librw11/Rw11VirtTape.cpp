// $Id: Rw11VirtTape.cpp 686 2015-06-04 21:08:08Z mueller $
//
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtTape.cpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation of Rw11VirtTape.
*/
#include <memory>

#include "librtools/RosFill.hpp"
#include "librtools/RparseUrl.hpp"
#include "librtools/Rexception.hpp"
#include "Rw11VirtTapeTap.hpp"

#include "Rw11VirtTape.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtTape
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtTape::Rw11VirtTape(Rw11Unit* punit)
  : Rw11Virt(punit),
    fWProt(false),
    fCapacity(0),
    fBot(false),
    fEot(false),
    fEom(true),
    fPosFile(-1),
    fPosRecord(-1)
{
  fStats.Define(kStatNVTReadRec,  "NVTReadRec",  "ReadRecord() calls");
  fStats.Define(kStatNVTReadByt,  "NVTReadByt",  "bytes read");
  fStats.Define(kStatNVTReadEof,  "NVTReadEof",  "eof read");
  fStats.Define(kStatNVTReadEom,  "NVTReadEom",  "eom read");
  fStats.Define(kStatNVTReadPErr, "NVTReadPErr", "parity error read");
  fStats.Define(kStatNVTReadLErr, "NVTReadLErr", "length error read");
  fStats.Define(kStatNVTWriteRec, "NVTWriteRec", "WriteRecord() calls");
  fStats.Define(kStatNVTWriteByt, "NVTWriteByt", "bytes written");
  fStats.Define(kStatNVTWriteEof, "NVTWriteEof", "WriteEof() calls");
  fStats.Define(kStatNVTSpaForw,  "NVTSpaForw",  "SpaceForw() calls");
  fStats.Define(kStatNVTSpaBack,  "NVTSpaBack",  "SpaceBack() calls");
  fStats.Define(kStatNVTRewind,   "NVTRewind",   "Rewind() calls");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtTape::~Rw11VirtTape()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rw11VirtTape* Rw11VirtTape::New(const std::string& url, Rw11Unit* punit,
                                RerrMsg& emsg)
{
  string scheme = RparseUrl::FindScheme(url, "tap");
  unique_ptr<Rw11VirtTape> p;
  
  if (scheme == "tap") {                   // scheme -> tap:
    p.reset(new Rw11VirtTapeTap(punit));
    if (p->Open(url, emsg)) return p.release();

  } else {                                  // scheme -> no match
    emsg.Init("Rw11VirtTape::New", string("Scheme '") + scheme +
              "' is not supported");
  }

  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTape::SetPosFile(int posfile)
{
  if (posfile < 0) posfile = 0;

  RerrMsg emsg;
  int     opcode;
  size_t  ndone;
  bool    rc = Rewind(opcode, emsg);

  while (rc && posfile != fPosFile) {
    rc = SpaceForw(1000000000, ndone, opcode, emsg);
    if (rc && opcode == kOpCodeEom) return;
  }

  if (!rc) throw Rexception("Rw11VirtTape::SetPosFile", emsg.Text());

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTape::SetPosRecord(int posrec)
{
  if (posrec < 0) posrec = 0;

  RerrMsg emsg;
  int     opcode;
  size_t  ndone;

  // space back to begin of current file (works even when fPosRecord is -1!)
  bool rc = SpaceBack(1000000000, ndone, opcode, emsg);
  // if eof was spaced over backwards, space forward over eof
  if (rc && opcode == kOpCodeEof) rc = SpaceForw(1, ndone, opcode, emsg);
  // now space forward to find record
  if (rc && posrec != 0) {
    rc = SpaceForw(posrec, ndone, opcode, emsg);
    // if eof was spaced over, space backward over eof to stay in file
    // the number of records spaced is used to setup fPosRecord
    if (rc && opcode == kOpCodeEof) {
      size_t ndoneeof;
      rc = SpaceBack(1, ndoneeof, opcode, emsg);
      if (rc) fPosRecord = ndone;
    }
  }

  if (!rc) throw Rexception("Rw11VirtTape::SetPosFile", emsg.Text());

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTape::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtTape @ " << this << endl;

  os << bl << "  fWProt:          " << fWProt << endl;
  os << bl << "  fCapacity:       " << fCapacity << endl;
  os << bl << "  fBot:            " << fBot << endl;
  os << bl << "  fEot:            " << fEot << endl;
  os << bl << "  fEom:            " << fEom << endl;
  os << bl << "  fPosFile:        " << fPosFile << endl;
  os << bl << "  fPosRecord:      " << fPosRecord << endl;
  Rw11Virt::Dump(os, ind, " ^");
  return;
}


} // end namespace Retro
