// $Id: Rw11UnitStream.cpp 515 2013-05-04 17:28:59Z mueller $
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
// 2013-05-04   515   1.0    Initial version
// 2013-05-01   513   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitStream.cpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Implemenation of Rw11UnitStream.
*/

#include "librtools/Rexception.hpp"

#include "Rw11UnitStream.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitStream
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitStream::Rw11UnitStream(Rw11Cntl* pcntl, size_t index)
  : Rw11UnitVirt<Rw11VirtStream>(pcntl, index)
{
  fStats.Define(kStatNPreAttDrop,    "NPreAttDrop",
                "output bytes dropped prior attach");
  fStats.Define(kStatNPreAttMiss,    "NPreAttMiss",
                "input bytes missed prior attach");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitStream::~Rw11UnitStream()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitStream::SetPos(int pos)
{
  if (!Virt()) 
    throw Rexception("Rw11UnitStream::SetPos", "no stream attached");

  RerrMsg emsg;
  if (!Virt()->Seek(pos, emsg)) throw Rexception(emsg);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11UnitStream::Pos() const
{
  if (!Virt()) 
    throw Rexception("Rw11UnitStream::Pos", "no stream attached");

  RerrMsg emsg;
  int irc = Virt()->Tell(emsg);
  if (irc < 0) throw Rexception(emsg);
  return irc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11UnitStream::VirtRead(uint8_t* data, size_t count, RerrMsg& emsg)
{
  if (!Virt()) {
    fStats.Inc(kStatNPreAttMiss);
    emsg.Init("Rw11UnitStream::VirtRead", "no stream attached");
    return -1;
  }
  return Virt()->Read(data, count, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitStream::VirtWrite(const uint8_t* data, size_t count, RerrMsg& emsg)
{
  if (!Virt()) {
    fStats.Inc(kStatNPreAttDrop, double(count));
    emsg.Init("Rw11UnitStream::VirtWrite", "no stream attached");
    return false;
  }
  return Virt()->Write(data, count, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitStream::VirtFlush(RerrMsg& emsg)
{
  if (!Virt()) {
    emsg.Init("Rw11UnitStream::VirtFlush", "no stream attached");
    return false;
  }
  return Virt()->Flush(emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitStream::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitStream @ " << this << endl;
  Rw11UnitVirt<Rw11VirtStream>::Dump(os, ind, " ^");
  return;
} 


} // end namespace Retro
