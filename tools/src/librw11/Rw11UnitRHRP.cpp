// $Id: Rw11UnitRHRP.cpp 680 2015-05-14 13:29:46Z mueller $
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
// 2015-05-14   680   1.0    Initial version
// 2015-03-21   659   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitRHRP.cpp 680 2015-05-14 13:29:46Z mueller $
  \brief   Implemenation of Rw11UnitRHRP.
*/

#include "boost/bind.hpp"

#include "librtools/Rexception.hpp"
#include "librtools/RosFill.hpp"
#include "Rw11CntlRHRP.hpp"

#include "Rw11UnitRHRP.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitRHRP
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11UnitRHRP::kDTE_M_RM;
const uint16_t Rw11UnitRHRP::kDTE_RP04;
const uint16_t Rw11UnitRHRP::kDTE_RP06;
const uint16_t Rw11UnitRHRP::kDTE_RM03;
const uint16_t Rw11UnitRHRP::kDTE_RM80;
const uint16_t Rw11UnitRHRP::kDTE_RM05;
const uint16_t Rw11UnitRHRP::kDTE_RP07;

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitRHRP::Rw11UnitRHRP(Rw11CntlRHRP* pcntl, size_t index)
  : Rw11UnitDiskBase<Rw11CntlRHRP>(pcntl, index),
    fRpdt(0),
    fRpds(0)
{
  // setup disk geometry: default off
  fType    = "off";
  fEnabled = false;
  fBlksize = 512;
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitRHRP::~Rw11UnitRHRP()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitRHRP::SetType(const std::string& type)
{
  if (Virt()) {
    throw Rexception("Rw11UnitRHRP::SetType", 
                     string("Bad state: file attached"));
  }
  
  if (type == "off") {
    fRpdt    =   0;
    fNCyl    =   0;
    fNHead   =   0;
    fNSect   =   0;
  } else if (type == "rp04") {
    fRpdt    = kDTE_RP04;
    fNCyl    = 411;
    fNHead   =  19;
    fNSect   =  22;
  } else if (type == "rp06") {
    fRpdt    = kDTE_RP06;
    fNCyl    = 815;
    fNHead   =  19;
    fNSect   =  22;
  } else if (type == "rm03") {
    fRpdt    = kDTE_RM03;
    fNCyl    = 823;
    fNHead   =   5;
    fNSect   =  32;
  } else if (type == "rm80") {
    fRpdt    = kDTE_RM80;
    fNCyl    = 559;
    fNHead   =  14;
    fNSect   =  31;
  } else if (type == "rm05") {
    fRpdt    = kDTE_RM05;
    fNCyl    = 823;
    fNHead   =  19;
    fNSect   =  32;
  } else if (type == "rp07") {
    fRpdt    = kDTE_RP07;
    fNCyl    = 630;
    fNHead   =  32;
    fNSect   =  50;
  } else {
    throw Rexception("Rw11UnitRHRP::SetType",
      string("Bad args: only off or rp04,rp06,rm03,rm80,rm05,rp07 supported"));
  }

  fType    = type;
  fEnabled = fNCyl != 0;
  fNBlock  = fNCyl*fNHead*fNSect;

  Cntl().UnitSetup(Index());                // update hardware

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitRHRP::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitRHRP @ " << this << endl;
  os << bl << "  fRpdt:           " << RosPrintf(fRpdt,"o",6)   << endl;
  os << bl << "  fRpds:           " << RosPrintf(fRpds,"o",6)   << endl;

  Rw11UnitDiskBase<Rw11CntlRHRP>::Dump(os, ind, " ^");
  return;
}
  
} // end namespace Retro
