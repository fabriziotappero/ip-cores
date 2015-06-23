// $Id: Rw11UnitDisk.cpp 659 2015-03-22 23:15:51Z mueller $
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
// 2015-03-21   659   1.0.1  add fEnabled, Enabled()
// 2013-04-19   507   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitDisk.cpp 659 2015-03-22 23:15:51Z mueller $
  \brief   Implemenation of Rw11UnitDisk.
*/

#include "librtools/Rexception.hpp"

#include "Rw11UnitDisk.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitDisk
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitDisk::Rw11UnitDisk(Rw11Cntl* pcntl, size_t index)
  : Rw11UnitVirt<Rw11VirtDisk>(pcntl, index),
    fType(),
    fEnabled(false),
    fNCyl(0),
    fNHead(0),
    fNSect(0),
    fBlksize(0),
    fNBlock(),
    fWProt(false)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitDisk::~Rw11UnitDisk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitDisk::SetType(const std::string& type)
{
  throw Rexception("Rw11UnitDisk::SetType", 
                   string("Bad args: only type '") + fType + "' supported");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitDisk::VirtRead(size_t lba, size_t nblk, uint8_t* data,
                            RerrMsg& emsg)
{
  if (!Virt()) {
    emsg.Init("Rw11UnitDisk::VirtRead", "no disk attached");
    return false;
  }
  return Virt()->Read(lba, nblk, data, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitDisk::VirtWrite(size_t lba, size_t nblk, const uint8_t* data, 
                             RerrMsg& emsg)
{
  if (!Virt()) {
    emsg.Init("Rw11UnitDisk::VirtWrite", "no disk attached");
    return false;
  }
  return Virt()->Write(lba, nblk, data, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitDisk::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitDisk @ " << this << endl;
  os << bl << "  fType:           " << fType  << endl;
  os << bl << "  fEnabled:        " << fEnabled << endl;
  os << bl << "  fNCyl:           " << fNCyl  << endl;
  os << bl << "  fNHead:          " << fNHead << endl;
  os << bl << "  fNSect:          " << fNSect << endl;
  os << bl << "  fBlksize:        " << fBlksize << endl;
  os << bl << "  fNBlock:         " << fNBlock  << endl;
  os << bl << "  fWProt:          " << fWProt << endl;

  Rw11UnitVirt<Rw11VirtDisk>::Dump(os, ind, " ^");
  return;
} 


} // end namespace Retro
