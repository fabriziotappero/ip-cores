// $Id: Rw11.cpp 625 2014-12-30 16:17:45Z mueller $
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
// 2014-12-30   625   1.1    adopt to Rlink V4 attn logic
// 2013-03-06   495   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11.cpp 625 2014-12-30 16:17:45Z mueller $
  \brief   Implemenation of Rw11.
*/

#include "librtools/Rexception.hpp"

#include "librtools/RosFill.hpp"
#include "Rw11Cpu.hpp"

#include "Rw11.hpp"

using namespace std;

/*!
  \class Retro::Rw11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const int      Rw11::kLam;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11::Rw11()
  : fspServ(),
    fNCpu(0),
    fStarted(false)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11::~Rw11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11::SetServer(const boost::shared_ptr<RlinkServer>& spserv)
{
  fspServ = spserv;
  fspServ->AddAttnHandler(boost::bind(&Rw11::AttnHandler, this, _1), 
                          uint16_t(1)<<kLam, (void*)this);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11::AddCpu(const boost::shared_ptr<Rw11Cpu>& spcpu)
{
  if (fNCpu >= 4)
    throw Rexception("Rw11::AddCpu", "Bad state: already 4 cpus registered");
  if (fNCpu > 0 && fspCpu[0]->Type() != spcpu->Type())
    throw Rexception("Rw11::AddCpu", "Bad state: type mismatch, new is " 
                     + spcpu->Type() + " first was " + fspCpu[0]->Type());

  fspCpu[fNCpu] = spcpu;
  fNCpu += 1;
  spcpu->Setup(this);

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rw11Cpu& Rw11::Cpu(size_t ind) const
{
  return *fspCpu[ind];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11::Start()
{
  if (fStarted) 
    throw Rexception("Rw11::Start()","alread started");
  
  for (size_t i=0; i<fNCpu; i++) fspCpu[i]->Start();

  if (!Server().IsActive()) Server().Start();

  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11 @ " << this << endl;

  os << bl << "  fspServ:         " << fspServ.get() << endl;
  os << bl << "  fNCpu:           " << fNCpu << endl;
  os << bl << "  fspCpu[4]:       ";
  for (size_t i=0; i<4; i++) os << fspCpu[i].get() << " ";
  os << endl;
  os << bl << "  fStarted:        " << fStarted << endl;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11::AttnHandler(RlinkServer::AttnArgs& args)
{
  Server().GetAttnInfo(args);

  for (size_t i=0; i<fNCpu; i++) fspCpu[i]->W11AttnHandler();
  return 0;
}
  
} // end namespace Retro
