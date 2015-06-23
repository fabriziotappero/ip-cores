// $Id: RlinkPacketBuf.cpp 606 2014-11-24 07:08:51Z mueller $
//
// Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-11-23   606   2.0    re-organize for rlink v4
// 2013-04-21   509   1.0.4  add SndAttn() method
// 2013-02-03   481   1.0.3  use Rexception
// 2013-01-13   474   1.0.2  add PollAttn() method
// 2013-01-04   469   1.0.1  SndOob(): Add filler 0 to ensure escape state
// 2011-04-02   375   1.0    Initial version
// 2011-03-05   366   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPacketBuf.cpp 606 2014-11-24 07:08:51Z mueller $
  \brief   Implemenation of class RlinkPacketBuf.
 */

#include "RlinkPacketBuf.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"

using namespace std;

/*!
  \class Retro::RlinkPacketBuf
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint32_t RlinkPacketBuf::kFlagSopSeen;
const uint32_t RlinkPacketBuf::kFlagEopSeen;
const uint32_t RlinkPacketBuf::kFlagNakSeen;
const uint32_t RlinkPacketBuf::kFlagAttnSeen;
const uint32_t RlinkPacketBuf::kFlagErrTout;
const uint32_t RlinkPacketBuf::kFlagErrIO;
const uint32_t RlinkPacketBuf::kFlagErrFrame;
const uint32_t RlinkPacketBuf::kFlagErrClobber;

const uint8_t RlinkPacketBuf::kSymEsc;
const uint8_t RlinkPacketBuf::kSymFill;
const uint8_t RlinkPacketBuf::kSymXon;
const uint8_t RlinkPacketBuf::kSymXoff;
const uint8_t RlinkPacketBuf::kSymEdPref;
const uint8_t RlinkPacketBuf::kEcSop;
const uint8_t RlinkPacketBuf::kEcEop;
const uint8_t RlinkPacketBuf::kEcNak;
const uint8_t RlinkPacketBuf::kEcAttn;
const uint8_t RlinkPacketBuf::kEcXon;
const uint8_t RlinkPacketBuf::kEcXoff;
const uint8_t RlinkPacketBuf::kEcFill;
const uint8_t RlinkPacketBuf::kEcEsc;
const uint8_t RlinkPacketBuf::kEcClobber;

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkPacketBuf::RlinkPacketBuf()
  : fPktBuf(),
    fCrc(),
    fFlags(0),
    fStats()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkPacketBuf::~RlinkPacketBuf()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPacketBuf::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkPacketBuf @ " << this << endl;
  os << bl << "  fCrc:          " << RosPrintBvi(fCrc.Crc(), 0) << endl;
  os << bl << "  fFlags:        " << RosPrintBvi(fFlags, 0) << endl;
  fStats.Dump(os, ind+2, "fStats: ");

  os << bl << "  fPktBuf(size): " << RosPrintf(fPktBuf.size(),"d",4);
  size_t ncol  = max(1, (80-ind-4-6)/(2+1));
  for (size_t i=0; i< fPktBuf.size(); i++) {
    if (i%ncol == 0) os << "\n" << bl << "    " << RosPrintf(i,"d",4) << ": ";
    os << RosPrintBvi(fPktBuf[i],16) << " ";
  }
  os << endl;

  return;
}

} // end namespace Retro
