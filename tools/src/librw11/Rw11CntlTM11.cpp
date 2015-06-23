// $Id: Rw11CntlTM11.cpp 686 2015-06-04 21:08:08Z mueller $
//
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// Other credits: 
//   the boot code is from the simh project and Copyright Robert M Supnik
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
  \version $Id: Rw11CntlTM11.cpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation of Rw11CntlTM11.
*/

#include "boost/bind.hpp"
#include "boost/foreach.hpp"
#define foreach_ BOOST_FOREACH

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "Rw11CntlTM11.hpp"

using namespace std;

/*!
  \class Retro::Rw11CntlTM11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlTM11::kIbaddr;
const int      Rw11CntlTM11::kLam;

const uint16_t Rw11CntlTM11::kTMSR; 
const uint16_t Rw11CntlTM11::kTMCR; 
const uint16_t Rw11CntlTM11::kTMBC; 
const uint16_t Rw11CntlTM11::kTMBA; 
const uint16_t Rw11CntlTM11::kTMDB; 
const uint16_t Rw11CntlTM11::kTMRL; 

const uint16_t Rw11CntlTM11::kProbeOff;
const bool     Rw11CntlTM11::kProbeInt;
const bool     Rw11CntlTM11::kProbeRem;

const uint16_t Rw11CntlTM11::kTMSR_M_ICMD;
const uint16_t Rw11CntlTM11::kTMSR_M_EOF;
const uint16_t Rw11CntlTM11::kTMSR_M_PAE;
const uint16_t Rw11CntlTM11::kTMSR_M_EOT;
const uint16_t Rw11CntlTM11::kTMSR_M_RLE;
const uint16_t Rw11CntlTM11::kTMSR_M_BTE;
const uint16_t Rw11CntlTM11::kTMSR_M_NXM;
const uint16_t Rw11CntlTM11::kTMSR_M_ONL;
const uint16_t Rw11CntlTM11::kTMSR_M_BOT;
const uint16_t Rw11CntlTM11::kTMSR_M_WRL;
const uint16_t Rw11CntlTM11::kTMSR_M_REW;
const uint16_t Rw11CntlTM11::kTMSR_M_TUR;

const uint16_t Rw11CntlTM11::kTMCR_V_ERR;
const uint16_t Rw11CntlTM11::kTMCR_V_DEN;
const uint16_t Rw11CntlTM11::kTMCR_B_DEN;
const uint16_t Rw11CntlTM11::kTMCR_V_UNIT;
const uint16_t Rw11CntlTM11::kTMCR_B_UNIT;
const uint16_t Rw11CntlTM11::kTMCR_M_RDY;
const uint16_t Rw11CntlTM11::kTMCR_V_EA;
const uint16_t Rw11CntlTM11::kTMCR_B_EA;
const uint16_t Rw11CntlTM11::kTMCR_V_FUNC;
const uint16_t Rw11CntlTM11::kTMCR_B_FUNC;
const uint16_t Rw11CntlTM11::kTMCR_M_GO;

const uint16_t Rw11CntlTM11::kFUNC_UNLOAD;
const uint16_t Rw11CntlTM11::kFUNC_READ;
const uint16_t Rw11CntlTM11::kFUNC_WRITE ;
const uint16_t Rw11CntlTM11::kFUNC_WEOF;
const uint16_t Rw11CntlTM11::kFUNC_SFORW;
const uint16_t Rw11CntlTM11::kFUNC_SBACK;
const uint16_t Rw11CntlTM11::kFUNC_WEIRG;
const uint16_t Rw11CntlTM11::kFUNC_REWIND;

const uint16_t Rw11CntlTM11::kRFUNC_WUNIT;
const uint16_t Rw11CntlTM11::kRFUNC_DONE;

const uint16_t Rw11CntlTM11::kTMCR_M_RICMD;
const uint16_t Rw11CntlTM11::kTMCR_M_RPAE;
const uint16_t Rw11CntlTM11::kTMCR_M_RRLE;
const uint16_t Rw11CntlTM11::kTMCR_M_RBTE;
const uint16_t Rw11CntlTM11::kTMCR_M_RNXM;
const uint16_t Rw11CntlTM11::kTMCR_M_REAENA;
const uint16_t Rw11CntlTM11::kTMCR_V_REA;
const uint16_t Rw11CntlTM11::kTMCR_B_REA;

const uint16_t Rw11CntlTM11::kTMRL_M_EOF;
const uint16_t Rw11CntlTM11::kTMRL_M_EOT;
const uint16_t Rw11CntlTM11::kTMRL_M_ONL;
const uint16_t Rw11CntlTM11::kTMRL_M_BOT;
const uint16_t Rw11CntlTM11::kTMRL_M_WRL;
const uint16_t Rw11CntlTM11::kTMRL_M_REW;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlTM11::Rw11CntlTM11()
  : Rw11CntlBase<Rw11UnitTM11,4>("tm11"),
    fPC_tmcr(0),
    fPC_tmsr(0),
    fPC_tmbc(0),
    fPC_tmba(0),
    fRd_tmcr(0),
    fRd_tmsr(0), 
    fRd_tmbc(0), 
    fRd_tmba(0), 
    fRd_bc(0),
    fRd_addr(0),
    fRd_nwrd(0),
    fRd_fu(0),
    fRd_opcode(0),
    fBuf(),
    fRdma(this,
          boost::bind(&Rw11CntlTM11::RdmaPreExecCB,  this, _1, _2, _3, _4),
          boost::bind(&Rw11CntlTM11::RdmaPostExecCB, this, _1, _2, _3, _4))
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitTM11(this, i));
  }

  fStats.Define(kStatNFuncUnload , "NFuncUnload"  , "func UNLOAD");
  fStats.Define(kStatNFuncRead   , "NFuncRead"    , "func READ");
  fStats.Define(kStatNFuncWrite  , "NFuncWrite"   , "func WRITE");
  fStats.Define(kStatNFuncWeof   , "NFuncWeof"    , "func WEOF");
  fStats.Define(kStatNFuncSforw  , "NFuncSforw"   , "func SFORW");
  fStats.Define(kStatNFuncSback  , "NFuncSback"   , "func SBACK");
  fStats.Define(kStatNFuncWrteg  , "NFuncWrteg"   , "func WRTEG");
  fStats.Define(kStatNFuncRewind , "NFuncRewind"  , "func REWIND");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlTM11::~Rw11CntlTM11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlTM11::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlTM11::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlTM11::Start",
                     "Bad state: started, no lam, not enable, not found");

  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".sr", Base() + kTMSR);
  Cpu().AllIAddrMapInsert(Name()+".cr", Base() + kTMCR);
  Cpu().AllIAddrMapInsert(Name()+".bc", Base() + kTMBC);
  Cpu().AllIAddrMapInsert(Name()+".ba", Base() + kTMBA);
  Cpu().AllIAddrMapInsert(Name()+".db", Base() + kTMDB);
  Cpu().AllIAddrMapInsert(Name()+".rl", Base() + kTMRL);

  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_tmcr = Cpu().AddRibr(fPrimClist, fBase+kTMCR);
  fPC_tmsr = Cpu().AddRibr(fPrimClist, fBase+kTMSR);
  fPC_tmbc = Cpu().AddRibr(fPrimClist, fBase+kTMBC);
  fPC_tmba = Cpu().AddRibr(fPrimClist, fBase+kTMBA);

  // add attn handler
  Server().AddAttnHandler(boost::bind(&Rw11CntlTM11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, (void*)this);

  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlTM11::UnitSetup(size_t ind)
{
  Rw11UnitTM11& unit = *fspUnit[ind];
  Rw11Cpu& cpu  = Cpu();
  RlinkCommandList clist;

  uint16_t tmds = 0;
  if (unit.Virt()) {                        // file attached
    tmds |= kTMRL_M_ONL;
    if (unit.Virt()->WProt()) tmds |= kTMRL_M_WRL;
    if (unit.Virt()->Bot())   tmds |= kTMRL_M_BOT;
  }
  unit.SetTmds(tmds);
  cpu.AddWibr(clist, fBase+kTMCR, (uint16_t(ind)<<kTMCR_V_RUNIT)|
                                  (kRFUNC_WUNIT<<kTMCR_V_FUNC) );
  cpu.AddWibr(clist, fBase+kTMRL, tmds);
  Server().Exec(clist);

  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11CntlTM11::BootCode(size_t unit, std::vector<uint16_t>& code, 
                            uint16_t& aload, uint16_t& astart)
{
  uint16_t kBOOT_START = 02000;
  uint16_t bootcode[] = {      // tm11 boot loader - from simh pdp11_tm.c (v3.9)
    0046524,                   // boot_start: "TM" 
    0012706, kBOOT_START,      // mov #boot_start, sp 
    0012700, uint16_t(unit),   // mov #unit_num, r0 
    0012701, 0172526,          // mov #172526, r1      ; mtcma 
    0005011,                   // clr (r1) 
    0012741, 0177777,          // mov #-1, -(r1)       ; mtbrc 
    0010002,                   // mov r0,r2 
    0000302,                   // swab r2 
    0062702, 0060011,          // add #60011, r2 
    0010241,                   // mov r2, -(r1)        ; space + go 
    0105711,                   // tstb (r1)            ; mtc 
    0100376,                   // bpl .-2 
    0010002,                   // mov r0,r2 
    0000302,                   // swab r2 
    0062702, 0060003,          // add #60003, r2 
    0010211,                   // mov r2, (r1)         ; read + go 
    0105711,                   // tstb (r1)            ; mtc 
    0100376,                   // bpl .-2 
    0005002,                   // clr r2 
    0005003,                   // clr r3 
    0012704, uint16_t(kBOOT_START+020),   // mov #boot_start+20, r4 
    0005005,                   // clr r5 
    0005007                    // clr r7 
  };
  
  code.clear();
  foreach_ (uint16_t& w, bootcode) code.push_back(w); 
  aload  = kBOOT_START;
  astart = kBOOT_START+2;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlTM11::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlTM11 @ " << this << endl;
  os << bl << "  fPC_tmcr:        " << RosPrintf(fPC_tmcr,"d",6) << endl;
  os << bl << "  fPC_tmsr:        " << RosPrintf(fPC_tmsr,"d",6) << endl;
  os << bl << "  fPC_tmbc:        " << RosPrintf(fPC_tmbc,"d",6) << endl;
  os << bl << "  fPC_tmba:        " << RosPrintf(fPC_tmba,"d",6) << endl;
  os << bl << "  fRd_tmcr:        " << RosPrintBvi(fRd_tmcr,8) << endl;
  os << bl << "  fRd_tmsr:        " << RosPrintBvi(fRd_tmsr,8) << endl;
  os << bl << "  fRd_tmbc:        " << RosPrintBvi(fRd_tmbc,8) << endl;
  os << bl << "  fRd_tmba:        " << RosPrintBvi(fRd_tmba,8) << endl;
  os << bl << "  fRd_bc:          " << RosPrintf(fRd_bc,"d",6) << endl;
  os << bl << "  fRd_addr:        " << RosPrintBvi(fRd_addr,8,18) << endl;
  os << bl << "  fRd_nwrd:        " << RosPrintf(fRd_nwrd,"d",6) << endl;
  os << bl << "  fRd_fu:          " << fRd_fu  << endl;
  os << bl << "  fRd_opcode:      " << fRd_opcode  << endl;
  os << bl << "  fBuf.size()      " << RosPrintf(fBuf.size(),"d",6) << endl;
  fRdma.Dump(os, ind+2, "fRdma: ");
  Rw11CntlBase<Rw11UnitTM11,4>::Dump(os, ind, " ^");
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlTM11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  uint16_t tmcr = fPrimClist[fPC_tmcr].Data();
  uint16_t tmsr = fPrimClist[fPC_tmsr].Data();
  uint16_t tmbc = fPrimClist[fPC_tmbc].Data();
  uint16_t tmba = fPrimClist[fPC_tmba].Data();

  uint16_t unum = (tmcr>>kTMCR_V_UNIT)  & kTMCR_B_UNIT;
  uint16_t ea   = (tmcr>>kTMCR_V_EA)    & kTMCR_B_EA;
  uint16_t fu   = (tmcr>>kTMCR_V_FUNC)  & kTMCR_B_FUNC;

  uint32_t addr = uint32_t(ea)<<16 | uint32_t(tmba);

  uint32_t nbyt = (~uint32_t(tmbc)&0xffff) + 1; // transfer size in bytes

  //Rw11Cpu& cpu = Cpu();
  RlinkCommandList clist;

  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    static const char* fumnemo[8] = 
      {"un ","rd ","wr ","we ","sf ","sb ","wi ","re "};
    lmsg << "-I TM11"
         << " fu=" << fumnemo[fu&07]
         << " un=" << unum
         << " cr=" << RosPrintBvi(tmcr,8)
         << " ad=" << RosPrintBvi(addr,8,18)
         << " bc=" << RosPrintBvi(tmbc,8)
         << " nb=";
    if (nbyt==65536) lmsg << "  (0)"; else lmsg << RosPrintf(nbyt,"d",5);
  }

  // check for spurious interrupts (either RDY=1 or RDY=0 and rdma busy)
  if ((tmcr & kTMCR_M_RDY) || fRdma.IsActive()) {
    RlogMsg lmsg(LogFile());
    lmsg << "-E TM11   err "
         << " cr=" << RosPrintBvi(tmcr,8)
         << " spurious lam: "
         << (fRdma.IsActive() ? "RDY=0 and Rdma busy" : "RDY=1");
    return 0;
  }

  // check for general abort conditions: invalid unit number
  if (unum > NUnit()) {
    AddErrorExit(clist, kTMCR_M_RICMD);
    Server().Exec(clist);
    return 0;
  }

  Rw11UnitTM11& unit = *fspUnit[unum];

  // check for general abort conditions: 
  //  - unit not attached
  //  - write to a write locked unit
  bool wcmd = fu == kFUNC_WRITE ||
              fu == kFUNC_WEIRG ||
              fu == kFUNC_WEOF;
  
  if ((!unit.Virt()) || (wcmd && unit.Virt()->WProt()) ) {
    AddErrorExit(clist, kTMCR_M_RICMD);
    Server().Exec(clist);
    return 0;
  }

  // remember request parameters for call back and error exit handling
  fRd_tmcr = tmcr;
  fRd_tmsr = tmsr;
  fRd_tmbc = tmbc;
  fRd_tmba = tmba;
  fRd_addr = addr;
  fRd_fu   = fu;

  // now handle the functions
  int      opcode = Rw11VirtTape::kOpCodeOK;
  RerrMsg  emsg;

  if (fu == kFUNC_UNLOAD) {                 // Unload ------------------------
    fStats.Inc(kStatNFuncUnload);
    unit.Detach();
    AddFastExit(clist, opcode, 0);
    RlogMsg lmsg(LogFile());
    lmsg << "-I TM11"
         << " unit " << unum << "unload";

  } else if (fu == kFUNC_READ) {            // Read --------------------------
    fStats.Inc(kStatNFuncRead);
    size_t nwalloc = (nbyt+1)/2;
    if (fBuf.size() < nwalloc) fBuf.resize(nwalloc);
    size_t ndone;
    bool rc = unit.VirtReadRecord(nbyt, reinterpret_cast<uint8_t*>(fBuf.data()),
                                  ndone, fRd_opcode, emsg);
    if (!rc) WriteLog("read", emsg);
    if ((!rc) || ndone == 0) {
      AddFastExit(clist, fRd_opcode, 0);
    } else if (ndone&0x1) {                 // FIXME_code: add odd rlen handling
      AddErrorExit(clist, kTMCR_M_RICMD|kTMSR_M_BTE);   // now just bail out !!
    } else {
      size_t nwdma = ndone/2;
      fRdma.QueueWMem(addr, fBuf.data(), nwdma, 
                      Rw11Cpu::kCPAH_M_22BIT|Rw11Cpu::kCPAH_M_UBMAP);
    }

  } else if (fu == kFUNC_WRITE ||           // Write -------------------------
             fu == kFUNC_WEIRG) {
    fStats.Inc((fu==kFUNC_WRITE) ? kStatNFuncWrite : kStatNFuncWrteg);
    size_t nwdma = (nbyt+1)/2;
    if (fBuf.size() < nwdma) fBuf.resize(nwdma);
    if (nbyt&0x1) {                         // FIXME_code: add odd rlen handling
      AddErrorExit(clist, kTMCR_M_RICMD|kTMSR_M_BTE);   // now just bail out !!
    } else {
      fRdma.QueueRMem(addr, fBuf.data(), nwdma, 
                      Rw11Cpu::kCPAH_M_22BIT|Rw11Cpu::kCPAH_M_UBMAP);
    }

  } else if (fu == kFUNC_WEOF) {            // Write Eof ---------------------
    fStats.Inc(kStatNFuncWeof);
    if (!unit.VirtWriteEof(emsg)) WriteLog("weof", emsg);
    AddFastExit(clist, opcode, 0);

  } else if (fu == kFUNC_SFORW) {           // Space forward -----------------
    fStats.Inc(kStatNFuncSforw);
    size_t ndone;
    if (!unit.VirtSpaceForw(nbyt, ndone, opcode, emsg)) WriteLog("sback", emsg);
    AddFastExit(clist, opcode, ndone);

  } else if (fu == kFUNC_SBACK) {           // Space Backward ----------------
    fStats.Inc(kStatNFuncSback);
    size_t ndone;
    if (!unit.VirtSpaceBack(nbyt, ndone, opcode, emsg)) WriteLog("sback", emsg);
    AddFastExit(clist, opcode, ndone);

  } else if (fu == kFUNC_REWIND) {          // Rewind ------------------------
    fStats.Inc(kStatNFuncRewind);
    if (!unit.VirtRewind(opcode, emsg)) WriteLog("rewind", emsg);
    AddFastExit(clist, opcode, 0);
  }

  if (clist.Size()) {                       // if handled directly
    Server().Exec(clist);                   // doit
  }

  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlTM11::RdmaPreExecCB(int stat, size_t nwdone, size_t nwnext,
                                 RlinkCommandList& clist)
{
  // noop for TM11
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlTM11::RdmaPostExecCB(int stat, size_t ndone,
                                  RlinkCommandList& clist, size_t ncmd)
{
  if (stat == Rw11Rdma::kStatusBusy) return;

  uint16_t tmcr = 0;
  // handle Rdma aborts
  if (stat == Rw11Rdma::kStatusFailRdma) tmcr |= kTMCR_M_RNXM;

  // finally to TM11 register update
  RlinkCommandList clist1;
  AddNormalExit(clist1, ndone, tmcr);
  Server().Exec(clist1);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlTM11::AddErrorExit(RlinkCommandList& clist, uint16_t tmcr)
{
  Rw11Cpu& cpu = Cpu();

  tmcr |= (kRFUNC_DONE<<kTMCR_V_FUNC);
  cpu.AddWibr(clist, fBase+kTMCR, tmcr);
  if (fTraceLevel>1) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I TM11"
         << "   err "
         << "     "
         << " cr=" << RosPrintBvi(tmcr,8);
  }

  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlTM11::AddFastExit(RlinkCommandList& clist, int opcode, size_t ndone)
{
  uint16_t unum = (fRd_tmcr>>kTMCR_V_UNIT)  & kTMCR_B_UNIT;
  Rw11UnitTM11& unit = *fspUnit[unum];
  Rw11Cpu& cpu = Cpu();

  uint16_t tmcr = 0;
  uint16_t tmds = kTMRL_M_ONL;
  if (unit.Virt()->WProt()) tmds |= kTMRL_M_WRL;
  if (unit.Virt()->Bot())   tmds |= kTMRL_M_BOT;
  if (unit.Virt()->Eot())   tmds |= kTMRL_M_EOT;

  switch (opcode) {

  case Rw11VirtTape::kOpCodeOK: 
  case Rw11VirtTape::kOpCodeBot:
    break;

  case Rw11VirtTape::kOpCodeEof:
    tmds |= kTMRL_M_EOF;
    break;

  default:
    tmcr |= kTMCR_M_RBTE;
    break;
  }

  uint16_t tmbc = fRd_tmbc + uint16_t(ndone);

  unit.SetTmds(tmds);
  cpu.AddWibr(clist, fBase+kTMCR, (uint16_t(unum)<<kTMCR_V_RUNIT)|
                                  (kRFUNC_WUNIT<<kTMCR_V_FUNC) );
  cpu.AddWibr(clist, fBase+kTMRL, tmds);
  if (ndone) cpu.AddWibr(clist, fBase+kTMBC, tmbc);
  tmcr |= (kRFUNC_DONE<<kTMCR_V_FUNC);
  cpu.AddWibr(clist, fBase+kTMCR, tmcr);

 if (fTraceLevel>1) {
    RlogMsg lmsg(LogFile());
    bool err = tmcr & (kTMCR_M_RBTE);
    lmsg << "-I TM11"
         << (err ? "   err " :"    ok ")
         << " un=" << unum
         << " cr=" << RosPrintBvi(tmcr,8)
         << " ds=" << RosPrintBvi(tmds,8) 
         << " bc=" << RosPrintBvi(tmbc,8);
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlTM11::AddNormalExit(RlinkCommandList& clist, size_t ndone,
                                 uint16_t tmcr)
{
  uint16_t unum = (fRd_tmcr>>kTMCR_V_UNIT)  & kTMCR_B_UNIT;
  Rw11UnitTM11& unit = *fspUnit[unum];
  Rw11Cpu& cpu = Cpu();

  uint16_t tmds = kTMRL_M_ONL;
  if (unit.Virt()->WProt()) tmds |= kTMRL_M_WRL;
  if (unit.Virt()->Bot())   tmds |= kTMRL_M_BOT;
  if (unit.Virt()->Eot())   tmds |= kTMRL_M_EOT;

  uint32_t addr = fRd_addr + 2*ndone;
  uint16_t tmbc = fRd_tmbc + 2*uint16_t(ndone);

  if (fRd_fu == kFUNC_READ) {               // handle READ
    switch (fRd_opcode) {

    case Rw11VirtTape::kOpCodeOK: 
      break;

    case Rw11VirtTape::kOpCodeRecLenErr:
      tmcr |= kTMCR_M_RRLE;
      break;

    case Rw11VirtTape::kOpCodeBadParity:
      tmcr |= kTMCR_M_RPAE;
      break;

    default:
      tmcr |= kTMCR_M_RBTE;
      break;
    }

  } else {                                  // handle WRITE or WEIRG
    int opcode;
    RerrMsg emsg;
    size_t nbyt = 2*ndone;
    if (!unit.VirtWriteRecord(nbyt, reinterpret_cast<uint8_t*>(fBuf.data()), 
                              opcode, emsg)) 
      WriteLog("write", emsg);
  }

  uint16_t tmba = uint16_t(addr & 0xfffe);
  uint16_t ea   = uint16_t((addr>>16)&0x0003);
  tmcr |= kTMCR_M_REAENA | (ea<<kTMCR_V_REA);

  unit.SetTmds(tmds);
  cpu.AddWibr(clist, fBase+kTMCR, (uint16_t(unum)<<kTMCR_V_RUNIT)|
                                  (kRFUNC_WUNIT<<kTMCR_V_FUNC) );
  cpu.AddWibr(clist, fBase+kTMRL, tmds);
  cpu.AddWibr(clist, fBase+kTMBC, tmbc);
  cpu.AddWibr(clist, fBase+kTMBA, tmba);
  tmcr |= (kRFUNC_DONE<<kTMCR_V_FUNC);
  cpu.AddWibr(clist, fBase+kTMCR, tmcr);

 if (fTraceLevel>1) {
    RlogMsg lmsg(LogFile());
    bool err = tmcr & (kTMCR_M_RPAE|kTMCR_M_RRLE|kTMCR_M_RBTE|kTMCR_M_RNXM);
    lmsg << "-I TM11"
         << (err ? "   err " :"    ok ")
         << " un=" << unum
         << " cr=" << RosPrintBvi(tmcr,8)
         << " ad=" << RosPrintBvi(addr,8,18)
         << " bc=" << RosPrintBvi(tmbc,8) 
         << " ds=" << RosPrintBvi(tmds,8);
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlTM11::WriteLog(const char* func, RerrMsg&  emsg)
{
  RlogMsg lmsg(LogFile());
  lmsg << "-E TM11"
       << " error for func=" << func
       << ":" << emsg;

  return;
}


} // end namespace Retro
