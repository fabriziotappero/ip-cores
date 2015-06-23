// $Id: RlinkPacketBufSnd.cpp 666 2015-04-12 21:17:54Z mueller $
//
// Copyright 2014-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-04-11   666   1.1    handle xon/xoff escaping, add (Set)XonEscape()
// 2014-12-25   621   1.0.1  Reorganize packet send/revd stats
// 2014-11-15   604   1.0    Initial version
// 2014-11-02   600   0.1    First draft (re-organize PacketBuf for rlink v4)
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPacketBufSnd.cpp 666 2015-04-12 21:17:54Z mueller $
  \brief   Implemenation of class RlinkPacketBuf.
 */

#include <sys/time.h>

#include "RlinkPacketBufSnd.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/Rexception.hpp"

using namespace std;

/*!
  \class Retro::RlinkPacketBufSnd
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkPacketBufSnd::RlinkPacketBufSnd()
  : fXonEscape(false),
    fRawBuf()
{
  // Statistic setup
  fStats.Define(kStatNTxPktByt, "NTxPktByt", "Tx packet bytes send");
  fStats.Define(kStatNTxEsc,    "NTxEsc",    "Tx esc escapes");
  fStats.Define(kStatNTxXEsc,   "NTxXEsc",   "Tx xon escapes");
}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkPacketBufSnd::~RlinkPacketBufSnd()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPacketBufSnd::Init()
{
  fPktBuf.clear();
  fRawBuf.clear();
  fCrc.Clear();
  fFlags = 0;
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPacketBufSnd::PutWithCrc(const uint16_t* pdata, size_t count)
{
  const uint16_t* pend = pdata + count;
  while (pdata < pend) PutWithCrc(*pdata++);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBufSnd::SndPacket(RlinkPort* port, RerrMsg& emsg)
{
  size_t nesc  = 0;
  size_t nxesc = 0;

  fRawBuf.reserve(2*fPktBuf.size()+4);      // max. size of raw data
  fRawBuf.clear();

  PutRawEsc(kEcSop);                        // <SOP>

  size_t   ni = fPktBuf.size();
  uint8_t* pi = fPktBuf.data();
  for (size_t i=0; i<ni; i++) {
    uint8_t c = *pi++;

    if (c == kSymEsc) {
      PutRawEsc(kEcEsc);
      nesc += 1;
      continue;
    }

    if (fXonEscape) {
      if (c == kSymXon) {
        PutRawEsc(kEcXon);
        nxesc += 1;
        continue;
      }
      if (c == kSymXoff) {
        PutRawEsc(kEcXoff);
        nxesc += 1;
        continue;
      }
    }

    fRawBuf.push_back(c);
  }

  PutRawEsc(kEcEop);                        // <EOP>
  fStats.Inc(kStatNTxEsc,    double(nesc));
  fStats.Inc(kStatNTxXEsc,   double(nxesc));

  bool sndok = SndRaw(port, emsg);
  if (sndok) fStats.Inc(kStatNTxPktByt, double(PktSize()));
  return sndok;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBufSnd::SndOob(RlinkPort* port, uint16_t addr, uint16_t data, 
                               RerrMsg& emsg)
{
  Init();

  fRawBuf.clear();
  fRawBuf.push_back(kSymEsc);                       // ESC
  fRawBuf.push_back(kSymEsc);                       // ESC
  fRawBuf.push_back(uint8_t( addr      & 0x000f));  // ADDR ( 3: 0)
  fRawBuf.push_back(uint8_t((addr>>4)  & 0x000f));  // ADDR ( 7: 4)
  fRawBuf.push_back(uint8_t( data      & 0x000f));  // DATA ( 3: 0)
  fRawBuf.push_back(uint8_t((data>>4)  & 0x000f));  // DATA ( 7: 4)
  fRawBuf.push_back(uint8_t((data>>8)  & 0x000f));  // DATA (11: 8)
  fRawBuf.push_back(uint8_t((data>>12) & 0x000f));  // DATA (15:12)
  fRawBuf.push_back(0);                 // send two filler zero's to ensure that
  fRawBuf.push_back(0);                 // comma handlers are in ground state

  return SndRaw(port, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBufSnd::SndKeep(RlinkPort* port, RerrMsg& emsg)
{
  Init();

  fRawBuf.clear();
  fRawBuf.push_back(kSymEsc);               // ESC
  fRawBuf.push_back(kSymEsc);               // ESC

  return SndRaw(port, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBufSnd::SndAttn(RlinkPort* port, RerrMsg& emsg)
{
  Init();

  fRawBuf.clear();
  PutRawEsc(kEcAttn);                       // <ATTN>
  return SndRaw(port, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBufSnd::SndNak(RlinkPort* port, RerrMsg& emsg)
{
  Init();

  fRawBuf.clear();
  PutRawEsc(kEcNak);                        // <NAK>
  return SndRaw(port, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBufSnd::SndUnJam(RlinkPort* port, RerrMsg& emsg)
{
  Init();

  fRawBuf.clear();
  PutRawEsc(kEcEop);                        // <EOP>
  return SndRaw(port, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPacketBufSnd::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkPacketBufSnd @ " << this << endl;

  os << bl << "  fXonEscape:      " << fXonEscape << endl;

  size_t rawbufsize = fRawBuf.size();
  os << bl << "  fRawBuf(size): " << RosPrintf(rawbufsize,"d",4);
  size_t ncol  = max(1, (80-ind-4-6)/(2+1));
  for (size_t i=0; i<rawbufsize; i++) {
    if (i%ncol == 0) os << "\n" << bl << "    " << RosPrintf(i,"d",4) << ": ";
    os << RosPrintBvi(fRawBuf[i],16) << " ";
  }
  os << endl;

  RlinkPacketBuf::Dump(os, ind, " ^");
 
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPacketBufSnd::SndRaw(RlinkPort* port, RerrMsg& emsg)
{
  if (port==0 || !port->IsOpen())
    throw Rexception("RlinkPacketBufSnd::SndRaw()", "Bad state: port not open");

  size_t rawbufsize = fRawBuf.size();
  int irc = port->Write(fRawBuf.data(), rawbufsize, emsg);
  if (irc < 0) return false;
  if ((size_t)irc != rawbufsize) {
    emsg.Init("RlinkPacketBufSnd::SndRaw()", "failed to write all data");
    return false;
  }

  return true;
}

} // end namespace Retro
