// $Id: Rw11CntlDL11.cpp 659 2015-03-22 23:15:51Z mueller $
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
// 2014-12-30   625   1.2    adopt to Rlink V4 attn logic
// 2014-12-25   621   1.1    adopt to 4k word ibus window and 
// 2013-05-04   516   1.0.2  add RxRlim support (receive interrupt rate limit)
// 2013-04-20   508   1.0.1  add trace support
// 2013-03-06   495   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11CntlDL11.cpp 659 2015-03-22 23:15:51Z mueller $
  \brief   Implemenation of Rw11CntlDL11.
*/

#include "boost/bind.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "Rw11CntlDL11.hpp"

using namespace std;

/*!
  \class Retro::Rw11CntlDL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlDL11::kIbaddr;
const int      Rw11CntlDL11::kLam;

const uint16_t Rw11CntlDL11::kRCSR; 
const uint16_t Rw11CntlDL11::kRBUF; 
const uint16_t Rw11CntlDL11::kXCSR; 
const uint16_t Rw11CntlDL11::kXBUF; 

const uint16_t Rw11CntlDL11::kProbeOff;
const bool     Rw11CntlDL11::kProbeInt;
const bool     Rw11CntlDL11::kProbeRem;

const uint16_t Rw11CntlDL11::kRCSR_M_RXRLIM;
const uint16_t Rw11CntlDL11::kRCSR_V_RXRLIM;
const uint16_t Rw11CntlDL11::kRCSR_B_RXRLIM;
const uint16_t Rw11CntlDL11::kRCSR_M_RDONE;
const uint16_t Rw11CntlDL11::kXCSR_M_XRDY;
const uint16_t Rw11CntlDL11::kXBUF_M_RRDY;
const uint16_t Rw11CntlDL11::kXBUF_M_XVAL;
const uint16_t Rw11CntlDL11::kXBUF_M_XBUF;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlDL11::Rw11CntlDL11()
  : Rw11CntlBase<Rw11UnitDL11,1>("dl11"),
    fPC_xbuf(0),
    fRxRlim(0)
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitDL11(this, i));
  }
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlDL11::~Rw11CntlDL11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlDL11::Start",
                     "Bad state: started, no lam, not enable, not found");
  
  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".rcsr", Base() + kRCSR);
  Cpu().AllIAddrMapInsert(Name()+".rbuf", Base() + kRBUF);
  Cpu().AllIAddrMapInsert(Name()+".xcsr", Base() + kXCSR);
  Cpu().AllIAddrMapInsert(Name()+".xbuf", Base() + kXBUF);

  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_xbuf = Cpu().AddRibr(fPrimClist, fBase+kXBUF);

  // add attn handler
  Server().AddAttnHandler(boost::bind(&Rw11CntlDL11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, (void*)this);
  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::UnitSetup(size_t ind)
{
  Rw11Cpu& cpu  = Cpu();
  uint16_t rcsr = (fRxRlim<<kRCSR_V_RXRLIM) & kRCSR_M_RXRLIM;
  RlinkCommandList clist;
  cpu.AddWibr(clist, fBase+kRCSR, rcsr);
  Server().Exec(clist);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Wakeup()
{
  if (!fspUnit[0]->RcvQueueEmpty()) {
    RlinkCommandList clist;
    size_t ircsr = Cpu().AddRibr(clist, fBase+kRCSR);
    Server().Exec(clist);
    uint16_t rcsr = clist[ircsr].Data();
    if ((rcsr & kRCSR_M_RDONE) == 0) {      // RBUF not full
      uint8_t ichr = fspUnit[0]->RcvNext();
      clist.Clear();
      Cpu().AddWibr(clist, fBase+kRBUF, ichr);
      Server().Exec(clist);
    }
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::SetRxRlim(uint16_t rlim)
{
  if (rlim > kRCSR_B_RXRLIM)
    throw Rexception("Rw11CntlDL11::SetRxRlim","Bad args: rlim too large");

  fRxRlim = rlim;
  UnitSetup(0);
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

uint16_t Rw11CntlDL11::RxRlim() const
{
  return fRxRlim;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlDL11::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlDL11 @ " << this << endl;
  os << bl << "  fPC_xbuf:        " << fPC_xbuf << endl;
  os << bl << "  fRxRlim:         " << fRxRlim  << endl;

  Rw11CntlBase<Rw11UnitDL11,1>::Dump(os, ind, " ^");
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlDL11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  uint16_t xbuf = fPrimClist[fPC_xbuf].Data();

  uint8_t ochr = xbuf & kXBUF_M_XBUF;
  bool xval = xbuf & kXBUF_M_XVAL;
  bool rrdy = xbuf & kXBUF_M_RRDY;

  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I DL11." << Name()
         << " xbuf=" << RosPrintBvi(xbuf,8)
         << " xval=" << xval
         << " rrdy=" << rrdy
         << " rcvq=" << RosPrintf(fspUnit[0]->RcvQueueSize(),"d",3);
    if (xval) {
      lmsg << " char=";
      if (ochr>=040 && ochr<0177) {
        lmsg << "'" << char(ochr) << "'";
      } else {
        lmsg << RosPrintBvi(ochr,8);
        lmsg << " " << ((ochr&0200) ? "|" : " ");
        uint8_t ochr7 = ochr & 0177;
        if (ochr7 < 040) {
          switch (ochr7) {
          case 010: lmsg << "BS"; break;
          case 011: lmsg << "HT"; break;
          case 012: lmsg << "LF"; break;
          case 013: lmsg << "VT"; break;
          case 014: lmsg << "FF"; break;
          case 015: lmsg << "CR"; break;
          default:  lmsg << "^" << char('A'+ochr7);
          }
        } else {
          if (ochr7 < 0177) {
            lmsg << "'" << char(ochr7) << "'";
          } else {
            lmsg << "DEL";
          }
        }
      }
    }
  }

  if (xval) {
    fspUnit[0]->Snd(&ochr, 1);
  }

  if (rrdy && !fspUnit[0]->RcvQueueEmpty()) {
    uint8_t ichr = fspUnit[0]->RcvNext();
    RlinkCommandList clist;
    Cpu().AddWibr(clist, fBase+kRBUF, ichr);
    Server().Exec(clist);
  }

  return 0;
}

} // end namespace Retro
