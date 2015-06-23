// $Id: Rw11Cntl.cpp 682 2015-05-15 18:35:29Z mueller $
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
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Cntl.cpp 682 2015-05-15 18:35:29Z mueller $
  \brief   Implemenation of Rw11Cntl.
*/

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"

#include "Rw11Cntl.hpp"

using namespace std;

/*!
  \class Retro::Rw11Cntl
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11Cntl::Rw11Cntl(const std::string& type)
  : fpCpu(nullptr),
    fType(type),
    fName(),
    fBase(0),
    fLam(-1),
    fEnable(true),
    fStarted(false),
    fProbe(),
    fTraceLevel(0),
    fPrimClist(),
    fStats()
{
  fStats.Define(kStatNAttnHdl,  "NAttnHdl",  "AttnHandler() calls");
  fStats.Define(kStatNAttnNoAct,"NAttnNoAct","AttnHandler() no action return");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11Cntl::~Rw11Cntl()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cntl::SetEnable(bool ena)
{
  if (fStarted)
    throw Rexception("Rw11Cntl::SetEnable", "only allowed before Start()");
  fEnable = ena;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11Cntl::Probe()
{
  return Cpu().ProbeCntl(fProbe);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cntl::Start()
{
  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t Rw11Cntl::NUnit() const
{
  return 0;                                 // real values from devived classes
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11Cntl::BootCode(size_t unit, std::vector<uint16_t>& code, 
                        uint16_t& aload, uint16_t& astart)
{
  code.clear();
  aload  = 0;
  astart = 0;
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string Rw11Cntl::UnitName(size_t index) const
{
  string name = fName;
  if (index > 9) name += char('0' + index/10);
  name += char('0' + index%10);
  return name;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cntl::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11Cntl @ " << this << endl;

  os << bl << "  fpCpu:           " << fpCpu << endl;
  os << bl << "  fType:           " << fType << endl;
  os << bl << "  fName:           " << fName << endl;
  os << bl << "  fBase:           " << RosPrintf(fBase,"o0",6) << endl;
  os << bl << "  fLam:            " << fLam << endl;
  os << bl << "  fEnable:         " << fEnable << endl;
  os << bl << "  fStarted:        " << fStarted << endl;
  fProbe.Dump(os, ind+2, "fProbe: ");
  os << bl << "  fTraceLevel:     " << fTraceLevel << endl;
  fPrimClist.Dump(os, ind+2, "fPrimClist: ");
  fStats.Dump(os, ind+2, "fStats: ");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Cntl::ConfigCntl(const std::string& name, uint16_t base, int lam,
                          uint16_t probeoff, bool probeint, bool proberem)
{
  fName = name;
  fBase = base;
  fLam  = lam;
  fProbe.fAddr     = base + probeoff;
  fProbe.fProbeInt = probeint;
  fProbe.fProbeRem = proberem;
  return;
}  

} // end namespace Retro
