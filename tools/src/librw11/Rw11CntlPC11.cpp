// $Id: Rw11CntlPC11.cpp 659 2015-03-22 23:15:51Z mueller $
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
// 2014-12-25   621   1.1    adopt to 4k word ibus window
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11CntlPC11.cpp 659 2015-03-22 23:15:51Z mueller $
  \brief   Implemenation of Rw11CntlPC11.
*/

#include "boost/bind.hpp"
#include "boost/foreach.hpp"
#define foreach_ BOOST_FOREACH

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "Rw11CntlPC11.hpp"

using namespace std;

/*!
  \class Retro::Rw11CntlPC11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlPC11::kIbaddr;
const int      Rw11CntlPC11::kLam;

const uint16_t Rw11CntlPC11::kRCSR; 
const uint16_t Rw11CntlPC11::kRBUF; 
const uint16_t Rw11CntlPC11::kPCSR; 
const uint16_t Rw11CntlPC11::kPBUF; 

const uint16_t Rw11CntlPC11::kUnit_PR;
const uint16_t Rw11CntlPC11::kUnit_PP;

const uint16_t Rw11CntlPC11::kProbeOff;
const bool     Rw11CntlPC11::kProbeInt;
const bool     Rw11CntlPC11::kProbeRem;

const uint16_t Rw11CntlPC11::kRCSR_M_ERROR;
const uint16_t Rw11CntlPC11::kPCSR_M_ERROR;
const uint16_t Rw11CntlPC11::kPBUF_M_RBUSY;
const uint16_t Rw11CntlPC11::kPBUF_M_PVAL;
const uint16_t Rw11CntlPC11::kPBUF_M_BUF;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlPC11::Rw11CntlPC11()
  : Rw11CntlBase<Rw11UnitPC11,2>("pc11"),
    fPC_pbuf(0)
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitPC11(this, i));
  }
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlPC11::~Rw11CntlPC11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlPC11::Start",
                     "Bad state: started, no lam, not enable, not found");
  
  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".rcsr", Base() + kRCSR);
  Cpu().AllIAddrMapInsert(Name()+".rbuf", Base() + kRBUF);
  Cpu().AllIAddrMapInsert(Name()+".pcsr", Base() + kPCSR);
  Cpu().AllIAddrMapInsert(Name()+".pbuf", Base() + kPBUF);

  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_pbuf = Cpu().AddRibr(fPrimClist, fBase+kPBUF);

  // add attn handler
  Server().AddAttnHandler(boost::bind(&Rw11CntlPC11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, (void*)this);

  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11CntlPC11::BootCode(size_t unit, std::vector<uint16_t>& code, 
                            uint16_t& aload, uint16_t& astart)
{
  uint16_t kBOOT_START = 0017476;
  uint16_t bootcode[] = {      // papertape lda loader, from dec-11-l2pc-po
    0000000,                   // C000:   halt
    0010706,                   // astart: mov     pc,sp
    0024646,                   //         cmp     -(sp),-(sp)
    0010705,                   //         mov     pc,r5
    0062705, 0000112,          //         add     #000112,r5
    0005001,                   //         clr     r1
    0013716, 0177570,          // B000:   mov     @#cp.dsr,(sp)
    0006016,                   //         ror     (sp)
    0103402,                   //         bcs     B001
    0005016,                   //         clr     (sp)
    0000403,                   //         br      B002
    0006316,                   // B001:   asl     (sp)
    0001001,                   //         bne     B002
    0010116,                   //         mov     r1,(sp)
    0005000,                   // B002:   clr     r0
    0004715,                   //         jsr     pc,(r5)
    0105303,                   //         decb    r3
    0001374,                   //         bne     B002
    0004715,                   //         jsr     pc,(r5)
    0004767, 0000074,          //         jsr     pc,R000
    0010402,                   //         mov     r4,r2
    0162702, 0000004,          //         sub     #000004,r2
    0022702, 0000002,          //         cmp     #000002,r2
    0001441,                   //         beq     B007
    0004767, 0000054,          //         jsr     pc,R000
    0061604,                   //         add     (sp),r4
    0010401,                   //         mov     r4,r1
    0004715,                   // B003:   jsr     pc,(r5)
    0002004,                   //         bge     B005
    0105700,                   //         tstb    r0
    0001753,                   //         beq     B002
    0000000,                   // B004:   halt
    0000751,                   //         br      B002
    0110321,                   // B005:   movb    r3,(r1)+
    0000770,                   //         br      B003
    0016703, 0000152,          // ldchr:  mov     p.prcs,r3
    0105213,                   //         incb    (r3)
    0105713,                   // B006:   tstb    (r3)
    0100376,                   //         bpl     B006
    0116303, 0000002,          //         movb    000002(r3),r3
    0060300,                   //         add     r3,r0
    0042703, 0177400,          //         bic     #177400,r3
    0005302,                   //         dec     r2
    0000207,                   //         rts     pc
    0012667, 0000046,          // R000:   mov     (sp)+,D000
    0004715,                   //         jsr     pc,(r5)
    0010304,                   //         mov     r3,r4
    0004715,                   //         jsr     pc,(r5)
    0000303,                   //         swap    r3
    0050304,                   //         bis     r3,r4
    0016707, 0000030,          //         mov     D000,pc
    0004767, 0177752,          // B007:   jsr     pc,R000
    0004715,                   //         jsr     pc,(r5)
    0105700,                   //         tstb    r0
    0001342,                   //         bne     B004
    0006204,                   //         asr     r4
    0103002,                   //         bcc     B008
    0000000,                   //         halt
    0000700,                   //         br      B000
    0006304,                   // B008:   asl     r4
    0061604,                   //         add     (sp),r4
    0000114,                   //         jmp     (r4)
    0000000,                   // D000:   .word   000000
    0012767, 0000352, 0000020, // L000:   mov     #000352,B009+2
    0012767, 0000765, 0000034, //         mov     #000765,D001
    0000167, 0177532,          //         jmp     C000
    0016701, 0000026,          // bstart: mov     p.prcs,r1
    0012702, 0000352,          // B009:   mov     #000352,r2
    0005211,                   //         inc     (r1)
    0105711,                   // B010:   tstb    (r1)
    0100376,                   //         bpl     B010
    0116162, 0000002, 0157400, //         movb    000002(r1),157400(r2)
    0005267, 0177756,          //         inc     B009+2
    0000765,                   // D001:   br      B009
    0177550                    // p.prcs: .word   177550
  };
  
  code.clear();
  foreach_ (uint16_t& w, bootcode) code.push_back(w); 
  aload  = kBOOT_START;
  astart = kBOOT_START+2;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::UnitSetup(size_t ind)
{
  Rw11UnitPC11& unit = *fspUnit[ind];
  SetOnline(ind, unit.Virt());              // online if stream attached
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlPC11 @ " << this << endl;
  os << bl << "  fPC_pbuf:        " << fPC_pbuf << endl;

  Rw11CntlBase<Rw11UnitPC11,2>::Dump(os, ind, " ^");
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlPC11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  uint16_t pbuf = fPrimClist[fPC_pbuf].Data();
  bool pval     = pbuf & kPBUF_M_PVAL;
  bool rbusy    = pbuf & kPBUF_M_RBUSY;
  uint8_t ochr  = pbuf & kPBUF_M_BUF;

  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I PC11." << Name()
         << " pbuf=" << RosPrintBvi(pbuf,8)
         << " pval=" << pval
         << " rbusy=" << rbusy;
    if (pval) {
      lmsg << " char=";
      if (ochr>=040 && ochr<0177) {
        lmsg << "'" << char(ochr) << "'";
      } else {
        lmsg << RosPrintBvi(ochr,8);
      }
    }
  }
  
  if (pval) {
    RerrMsg emsg;
    bool rc = fspUnit[kUnit_PP]->VirtWrite(&ochr, 1, emsg);
    if (!rc) {
      RlogMsg lmsg(LogFile());
      lmsg << emsg;
      SetOnline(1, false);
    }
  }

  if (rbusy) {
    uint8_t ichr = 0;
    RerrMsg emsg;
    int irc = fspUnit[kUnit_PR]->VirtRead(&ichr, 1, emsg);
    if (irc < 0) {
      RlogMsg lmsg(LogFile());
      lmsg << emsg;
    }
    if (irc <= 0) {
      SetOnline(0, false);
    } else {
      RlinkCommandList clist;
      Cpu().AddWibr(clist, fBase+kRBUF, ichr);
      Server().Exec(clist);
    }
  }
  
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlPC11::SetOnline(size_t ind, bool online)
{
  Rw11Cpu& cpu  = Cpu();
  RlinkCommandList clist;
  if (ind == kUnit_PR) {                    // reader on/offline
    uint16_t rcsr  = online ? 0 : kRCSR_M_ERROR;
    cpu.AddWibr(clist, fBase+kRCSR, rcsr);
  } else {                                  // puncher on/offline
    uint16_t pcsr  = online ? 0 : kPCSR_M_ERROR;
    cpu.AddWibr(clist, fBase+kPCSR, pcsr);
  }
  Server().Exec(clist);
  return;
}
  
} // end namespace Retro
