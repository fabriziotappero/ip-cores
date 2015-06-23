// $Id: Rw11UnitTape.cpp 686 2015-06-04 21:08:08Z mueller $
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
  \version $Id: Rw11UnitTape.cpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation of Rw11UnitTape.
*/

#include "librtools/Rexception.hpp"

#include "Rw11UnitTape.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitTape
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitTape::Rw11UnitTape(Rw11Cntl* pcntl, size_t index)
  : Rw11UnitVirt<Rw11VirtTape>(pcntl, index),
    fType(),
    fEnabled(false),
    fWProt(false),
    fCapacity(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitTape::~Rw11UnitTape()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTape::SetType(const std::string& type)
{
  throw Rexception("Rw11UnitTape::SetType", 
                   string("Bad args: only type '") + fType + "' supported");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTape::SetWProt(bool wprot)
{
  if (Virt()) throw Rexception("Rw11UnitTape::SetWProt",
                               "not allowed when tape attached");
  fWProt = wprot;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTape::SetCapacity(size_t nbyte)
{
  if (Virt()) throw Rexception("Rw11UnitTape::SetCapacity",
                               "not allowed when tape attached");
  fCapacity = nbyte;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTape::SetPosFile(int posfile)
{
  if (!Virt()) throw Rexception("Rw11UnitTape::SetPosFile", 
                                "no tape attached");
  Virt()->SetPosFile(posfile);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTape::SetPosRecord(int posrec)
{
  if (!Virt()) throw Rexception("Rw11UnitTape::SetPosRecord", 
                                "no tape attached");
  Virt()->SetPosRecord(posrec);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTape::Bot() const
{
  if (!Virt()) return false;
  return Virt()->Bot();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTape::Eot() const
{
  if (!Virt()) return false;
  return Virt()->Eot();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTape::Eom() const
{
  if (!Virt()) return false;
  return Virt()->Eom();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11UnitTape::PosFile() const
{
  if (!Virt()) return -1;
  return Virt()->PosFile();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11UnitTape::PosRecord() const
{
  if (!Virt()) return -1;
  return Virt()->PosRecord();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTape::VirtReadRecord(size_t nbyte, uint8_t* data, size_t& ndone, 
                                  int& opcode, RerrMsg& emsg)
{
  if (!Virt()) {
    emsg.Init("Rw11UnitTape::VirtReadRecord", "no tape attached");
    return false;
  }
  return Virt()->ReadRecord(nbyte, data, ndone, opcode, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTape::VirtWriteRecord(size_t nbyte, const uint8_t* data, 
                                   int& opcode, RerrMsg& emsg)
{
  if (!Virt()) {
    emsg.Init("Rw11UnitTape::VirtWriteRecord", "no tape attached");
    return false;
  }
  return Virt()->WriteRecord(nbyte, data, opcode, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTape::VirtWriteEof(RerrMsg& emsg)
{
  if (!Virt()) {
    emsg.Init("Rw11UnitTape::VirtWriteEof", "no tape attached");
    return false;
  }
  return Virt()->WriteEof(emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTape::VirtSpaceForw(size_t nrec, size_t& ndone, 
                                 int& opcode, RerrMsg& emsg)
{
  if (!Virt()) {
    emsg.Init("Rw11UnitTape::VirtSpaceForw", "no tape attached");
    return false;
  }
  return Virt()->SpaceForw(nrec, ndone, opcode, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTape::VirtSpaceBack(size_t nrec, size_t& ndone, 
                                 int& opcode, RerrMsg& emsg)
{
  if (!Virt()) {
    emsg.Init("Rw11UnitTape::VirtSpaceBack", "no tape attached");
    return false;
  }
  return Virt()->SpaceBack(nrec, ndone, opcode, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTape::VirtRewind(int& opcode, RerrMsg& emsg)
{
  if (!Virt()) {
    emsg.Init("Rw11UnitTape::VirtRewind", "no tape attached");
    return false;
  }
  return Virt()->Rewind(opcode, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTape::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitTape @ " << this << endl;
  os << bl << "  fType:           " << fType  << endl;
  os << bl << "  fEnabled:        " << fEnabled << endl;
  os << bl << "  fWProt:          " << fWProt << endl;
  os << bl << "  fCapacity:       " << fCapacity << endl;

  Rw11UnitVirt<Rw11VirtTape>::Dump(os, ind, " ^");
  return;
} 


} // end namespace Retro
