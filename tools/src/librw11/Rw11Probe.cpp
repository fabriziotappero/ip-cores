// $Id: Rw11Probe.cpp 495 2013-03-06 17:13:48Z mueller $
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
// 2013-03-05   495   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Probe.cpp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation of Rw11Probe.
*/

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"

#include "librlink/RlinkServer.hpp"

#include "Rw11Probe.hpp"

using namespace std;

/*!
  \class Retro::Rw11Probe
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11Probe::Rw11Probe(uint16_t addr, bool probeint, bool proberem)
  : fAddr(addr),
    fProbeInt(probeint),
    fProbeRem(proberem),
    fProbeDone(false),
    fFoundInt(false),
    fFoundRem(false)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11Probe::Found() const
{
  if (!fProbeDone) return false;
  if (fProbeInt && ! fFoundInt) return false;
  if (fProbeRem && ! fFoundRem) return false;
  return true;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

char Rw11Probe::IndicatorInt() const
{
  if (!fProbeDone) return '?';
  if (!fProbeInt)  return '-';
  return fFoundInt ? 'y' : 'n';
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

char Rw11Probe::IndicatorRem() const
{
  if (!fProbeDone) return '?';
  if (!fProbeRem)  return '-';
  return fFoundRem ? 'y' : 'n';
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Probe::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11Probe @ " << this << endl;

  os << bl << "  fAddr:           " << RosPrintf(fAddr,"o0",6) << endl;
  os << bl << "  fProbeInt,Rem:   " << fProbeInt << ", " << fProbeInt<< endl;
  os << bl << "  fProbeDone:      " << fProbeDone << endl;
  os << bl << "  fFoundInt,Rem    " << fFoundInt << ", " << fFoundInt<< endl;
  return;
}

} // end namespace Retro
