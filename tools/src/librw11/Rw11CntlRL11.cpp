// $Id: Rw11CntlRL11.cpp 686 2015-06-04 21:08:08Z mueller $
//
// Copyright 2014-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
// Other credits: 
//   the boot code is from the simh project and Copyright Robert M Supnik
//   CalcCrc() is adopted from the simh project and Copyright Robert M Supnik
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
// 2015-06-04   686   1.0.2  check for spurious lams
// 2015-03-04   655   1.0.1  use original boot code again
// 2015-03-01   653   1.0    Initial version
// 2014-06-08   561   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11CntlRL11.cpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation of Rw11CntlRL11.
*/

#include "boost/bind.hpp"
#include "boost/foreach.hpp"
#define foreach_ BOOST_FOREACH

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "Rw11CntlRL11.hpp"

using namespace std;

/*!
  \class Retro::Rw11CntlRL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlRL11::kIbaddr;
const int      Rw11CntlRL11::kLam;

const uint16_t Rw11CntlRL11::kRLCS; 
const uint16_t Rw11CntlRL11::kRLBA; 
const uint16_t Rw11CntlRL11::kRLDA; 
const uint16_t Rw11CntlRL11::kRLMP; 

const uint16_t Rw11CntlRL11::kProbeOff;
const bool     Rw11CntlRL11::kProbeInt;
const bool     Rw11CntlRL11::kProbeRem;

const uint16_t Rw11CntlRL11::kRLCS_M_ERR;
const uint16_t Rw11CntlRL11::kRLCS_M_DE;
const uint16_t Rw11CntlRL11::kRLCS_V_E;
const uint16_t Rw11CntlRL11::kRLCS_B_E;
const uint16_t Rw11CntlRL11::kRLCS_V_DS;
const uint16_t Rw11CntlRL11::kRLCS_B_DS;
const uint16_t Rw11CntlRL11::kRLCS_M_CRDY;
const uint16_t Rw11CntlRL11::kRLCS_M_IE;
const uint16_t Rw11CntlRL11::kRLCS_M_BAE;
const uint16_t Rw11CntlRL11::kRLCS_V_BAE;
const uint16_t Rw11CntlRL11::kRLCS_B_BAE;
const uint16_t Rw11CntlRL11::kRLCS_V_FUNC;
const uint16_t Rw11CntlRL11::kRLCS_B_FUNC;
const uint16_t Rw11CntlRL11::kRLCS_M_DRDY;

const uint16_t Rw11CntlRL11::kFUNC_NOOP;
const uint16_t Rw11CntlRL11::kFUNC_WCHK;
const uint16_t Rw11CntlRL11::kFUNC_GS;
const uint16_t Rw11CntlRL11::kFUNC_SEEK;
const uint16_t Rw11CntlRL11::kFUNC_RHDR;
const uint16_t Rw11CntlRL11::kFUNC_WRITE;
const uint16_t Rw11CntlRL11::kFUNC_READ;
const uint16_t Rw11CntlRL11::kFUNC_RNHC;

const uint16_t Rw11CntlRL11::kERR_M_DE;
const uint16_t Rw11CntlRL11::kERR_OPI;
const uint16_t Rw11CntlRL11::kERR_WCHK;
const uint16_t Rw11CntlRL11::kERR_HCRC;
const uint16_t Rw11CntlRL11::kERR_DLATE;
const uint16_t Rw11CntlRL11::kERR_HNFND;
const uint16_t Rw11CntlRL11::kERR_NXM;

const uint16_t Rw11CntlRL11::kRLCS_V_MPREM;
const uint16_t Rw11CntlRL11::kRLCS_B_MPREM;
const uint16_t Rw11CntlRL11::kRLCS_V_MPLOC;
const uint16_t Rw11CntlRL11::kRLCS_B_MPLOC;
const uint16_t Rw11CntlRL11::kRLCS_ENA_MPREM;
const uint16_t Rw11CntlRL11::kRLCS_ENA_MPLOC;

const uint16_t Rw11CntlRL11::kRFUNC_WCS;
const uint16_t Rw11CntlRL11::kRFUNC_WMP;

const uint16_t Rw11CntlRL11::kMPREM_M_MAP;
const uint16_t Rw11CntlRL11::kMPREM_M_SEQ;
const uint16_t Rw11CntlRL11::kMPREM_S_MP;
const uint16_t Rw11CntlRL11::kMPREM_S_STA;
const uint16_t Rw11CntlRL11::kMPREM_S_POS;

const uint16_t Rw11CntlRL11::kMPREM_MP;
const uint16_t Rw11CntlRL11::kMPREM_CRC;
const uint16_t Rw11CntlRL11::kMPREM_STA;
const uint16_t Rw11CntlRL11::kMPREM_POS;

const uint16_t Rw11CntlRL11::kMPREM_SEQ_MPSTAPOS;

const uint16_t Rw11CntlRL11::kMPLOC_MP;
const uint16_t Rw11CntlRL11::kMPLOC_STA;
const uint16_t Rw11CntlRL11::kMPLOC_POS;
const uint16_t Rw11CntlRL11::kMPLOC_ZERO;
const uint16_t Rw11CntlRL11::kMPLOC_CRC;

const uint16_t Rw11CntlRL11::kRLDA_SE_M_DF;
const uint16_t Rw11CntlRL11::kRLDA_SE_V_DF;
const uint16_t Rw11CntlRL11::kRLDA_SE_B_DF;
const uint16_t Rw11CntlRL11::kRLDA_SE_M_HS;
const uint16_t Rw11CntlRL11::kRLDA_SE_M_DIR;
const uint16_t Rw11CntlRL11::kRLDA_SE_X_MSK;
const uint16_t Rw11CntlRL11::kRLDA_SE_X_VAL;

const uint16_t Rw11CntlRL11::kRLDA_RW_M_CA;
const uint16_t Rw11CntlRL11::kRLDA_RW_V_CA;
const uint16_t Rw11CntlRL11::kRLDA_RW_B_CA;
const uint16_t Rw11CntlRL11::kRLDA_RW_M_HS;
const uint16_t Rw11CntlRL11::kRLDA_RW_V_HS;
const uint16_t Rw11CntlRL11::kRLDA_RW_B_HS;
const uint16_t Rw11CntlRL11::kRLDA_RW_B_SA;

const uint16_t Rw11CntlRL11::kRLDA_GS_M_RST;
const uint16_t Rw11CntlRL11::kRLDA_GS_X_MSK;
const uint16_t Rw11CntlRL11::kRLDA_GS_X_VAL;

const uint16_t Rw11CntlRL11::kSTA_M_WDE;
const uint16_t Rw11CntlRL11::kSTA_M_CHE;
const uint16_t Rw11CntlRL11::kSTA_M_WL;
const uint16_t Rw11CntlRL11::kSTA_M_STO;
const uint16_t Rw11CntlRL11::kSTA_M_SPE;
const uint16_t Rw11CntlRL11::kSTA_M_WGE;
const uint16_t Rw11CntlRL11::kSTA_M_VCE;
const uint16_t Rw11CntlRL11::kSTA_M_DSE;
const uint16_t Rw11CntlRL11::kSTA_M_DT;
const uint16_t Rw11CntlRL11::kSTA_M_HS;
const uint16_t Rw11CntlRL11::kSTA_M_CO;
const uint16_t Rw11CntlRL11::kSTA_M_HO;
const uint16_t Rw11CntlRL11::kSTA_M_BH;
const uint16_t Rw11CntlRL11::kSTA_B_ST;

const uint16_t Rw11CntlRL11::kST_LOAD;
const uint16_t Rw11CntlRL11::kST_SPIN;
const uint16_t Rw11CntlRL11::kST_BRUSH;
const uint16_t Rw11CntlRL11::kST_HLOAD;
const uint16_t Rw11CntlRL11::kST_SEEK;
const uint16_t Rw11CntlRL11::kST_LOCK;
const uint16_t Rw11CntlRL11::kST_UNL;
const uint16_t Rw11CntlRL11::kST_DOWN;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlRL11::Rw11CntlRL11()
  : Rw11CntlBase<Rw11UnitRL11,4>("rl11"),
    fPC_rlcs(0),
    fPC_rlba(0),
    fPC_rlda(0),
    fPC_imp(0),
    fPC_wc(0),
    fPC_sta(0),
    fPC_pos(0),
    fRd_rlcs(0),
    fRd_rlda(0),
    fRd_rlmp(0),
    fRd_sta(0),
    fRd_pos(0),
    fRd_addr(0),
    fRd_lba(0),
    fRd_nwrd(0),
    fRd_fu(0),
    fRd_ovr(false),
    fRdma(this,
          boost::bind(&Rw11CntlRL11::RdmaPreExecCB,  this, _1, _2, _3, _4),
          boost::bind(&Rw11CntlRL11::RdmaPostExecCB, this, _1, _2, _3, _4))
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitRL11(this, i));
  }

  fStats.Define(kStatNFuncWchk   , "NFuncWchk"    , "func WCHK");
  fStats.Define(kStatNFuncRhdr   , "NFuncRhdr"    , "func RHDR");
  fStats.Define(kStatNFuncWrite  , "NFuncWrite"   , "func WRITE");
  fStats.Define(kStatNFuncRead   , "NFuncRead"    , "func READ");
  fStats.Define(kStatNFuncRnhc   , "NFuncRnhc"    , "func RNHC");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlRL11::~Rw11CntlRL11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRL11::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRL11::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlRL11::Start",
                     "Bad state: started, no lam, not enable, not found");

  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".cs", Base() + kRLCS);
  Cpu().AllIAddrMapInsert(Name()+".ba", Base() + kRLBA);
  Cpu().AllIAddrMapInsert(Name()+".da", Base() + kRLDA);
  Cpu().AllIAddrMapInsert(Name()+".mp", Base() + kRLMP);

  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_rlcs = Cpu().AddRibr(fPrimClist, fBase+kRLCS);
  fPC_rlba = Cpu().AddRibr(fPrimClist, fBase+kRLBA);
  fPC_rlda = Cpu().AddRibr(fPrimClist, fBase+kRLDA);
  fPC_imp  = Cpu().AddWibr(fPrimClist, fBase+kRLCS,
                           (kMPREM_SEQ_MPSTAPOS << kRLCS_V_MPREM) |
                           kRLCS_ENA_MPREM |
                           (kRFUNC_WMP << kRLCS_V_FUNC) );
  fPC_wc   = Cpu().AddRibr(fPrimClist, fBase+kRLMP);
  fPC_sta  = Cpu().AddRibr(fPrimClist, fBase+kRLMP);
  fPC_pos  = Cpu().AddRibr(fPrimClist, fBase+kRLMP);

  // add attn handler
  Server().AddAttnHandler(boost::bind(&Rw11CntlRL11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, (void*)this);

  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRL11::UnitSetup(size_t ind)
{
  Rw11UnitRL11& unit = *fspUnit[ind];
  RlinkCommandList clist;

  // only two mayor drive states are used
  //   on: st=lock; ho=1; bh=1; co=0; wl=?   (   file attached)
  //  off: st=load; ho=0; bh=1; co=1;        (no file attached)

  uint16_t sta = 0;
  if (unit.Type() == "rl02")                // is it RL02
    sta |= kSTA_M_DT;                       //   set DT bit (1=RL02,0=RL01)

  if (unit.Virt()) {                        // file attached
    sta |= kSTA_M_HO | kSTA_M_BH | kST_LOCK; //   HO=1; BH=1; ST=LOCK
    if (unit.WProt())                       // in case write protected
      sta |= kSTA_M_WL;                     //   WL=1
  } else {                                  // no file attached
    sta |= kSTA_M_CO | kSTA_M_BH | kST_LOAD; //   CO=1; BH=1; ST=LOAD
    AddSetPosition(clist, ind, 0);          // well defined value to pos
  }

  unit.SetRlsta(sta);
  AddSetStatus(clist, ind, sta);
  Server().Exec(clist);

  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs ????

bool Rw11CntlRL11::BootCode(size_t unit, std::vector<uint16_t>& code, 
                            uint16_t& aload, uint16_t& astart)
{
  uint16_t kBOOT_START = 02000;
  uint16_t bootcode[] = {      // rl11 boot loader - from simh pdp11_rl.c (v3.9)
    0042114,                   // "LD"
    0012706, kBOOT_START,      // MOV #boot_start, SP
    0012700, uint16_t(unit),   // MOV #unit, R0
    0010003,                   // MOV R0, R3
    0000303,                   // SWAB R3
    0012701, 0174400,          // MOV #RLCS, R1        ; csr 
    0012761, 0000013, 0000004, // MOV #13, 4(R1)       ; clr err 
    0052703, 0000004,          // BIS #4, R3           ; unit+gstat 
    0010311,                   // MOV R3, (R1)         ; issue cmd 
    0105711,                   // TSTB (R1)            ; wait 
    0100376,                   // BPL .-2 
    0105003,                   // CLRB R3 
    0052703, 0000010,          // BIS #10, R3          ; unit+rdhdr 
    0010311,                   // MOV R3, (R1)         ; issue cmd 
    0105711,                   // TSTB (R1)            ; wait 
    0100376,                   // BPL .-2 
    0016102, 0000006,          // MOV 6(R1), R2        ; get hdr 
    0042702, 0000077,          // BIC #077, R2         ; clr head+sector 
    0005202,                   // INC R2               ; magic bit 
    0010261, 0000004,          // MOV R2, 4(R1)        ; seek to 0 
    0105003,                   // CLRB R3 
    0052703, 0000006,          // BIS #6, R3           ; unit+seek 
    0010311,                   // MOV R3, (R1)         ; issue cmd 
    0105711,                   // TSTB (R1)            ; wait 
    0100376,                   // BPL .-2 
    0005061, 0000002,          // CLR 2(R1)            ; clr ba 
    0005061, 0000004,          // CLR 4(R1)            ; clr da 
    0012761, 0177000, 0000006, // MOV #-512., 6(R1)    ; set wc 
    0105003,                   // CLRB R3 
    0052703, 0000014,          // BIS #14, R3          ; unit+read 
    0010311,                   // MOV R3, (R1)         ; issue cmd 
    0105711,                   // TSTB (R1)            ; wait 
    0100376,                   // BPL .-2 
    0042711, 0000377,          // BIC #377, (R1) 
    0005002,                   // CLR R2 
    0005003,                   // CLR R3 
    0012704, uint16_t(kBOOT_START+020),   // MOV #START+20, R4 ; load #rlcs
    0005005,                   // CLR R5 
    0005007                    // CLR PC 
    };
  
  code.clear();
  foreach_ (uint16_t& w, bootcode) code.push_back(w); 
  aload  = kBOOT_START;
  astart = kBOOT_START+2;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRL11::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlRL11 @ " << this << endl;
  os << bl << "  fPC_rlcs:        " << RosPrintf(fPC_rlcs,"d",6) << endl;
  os << bl << "  fPC_rlba:        " << RosPrintf(fPC_rlba,"d",6) << endl;
  os << bl << "  fPC_rlda:        " << RosPrintf(fPC_rlda,"d",6) << endl;
  os << bl << "  fPC_imp:         " << RosPrintf(fPC_imp,"d",6)  << endl;
  os << bl << "  fPC_wc:          " << RosPrintf(fPC_wc,"d",6)   << endl;
  os << bl << "  fPC_sta:         " << RosPrintf(fPC_sta,"d",6)  << endl;
  os << bl << "  fPC_pos:         " << RosPrintf(fPC_pos,"d",6)  << endl;
  os << bl << "  fRd_rlcs:        " << RosPrintBvi(fRd_rlcs,8) << endl;
  os << bl << "  fRd_rlda:        " << RosPrintBvi(fRd_rlda,8) << endl;
  os << bl << "  fRd_rlmp:        " << RosPrintBvi(fRd_rlmp,8) << endl;
  os << bl << "  fRd_sta:         " << RosPrintBvi(fRd_sta,8)  << endl;
  os << bl << "  fRd_pos:         " << RosPrintBvi(fRd_pos,8)  << endl;
  os << bl << "  fRd_addr:        " << RosPrintBvi(fRd_addr,8,22) << endl;
  os << bl << "  fRd_lba:         " << RosPrintf(fRd_lba,"d",6)  << endl;
  os << bl << "  fRd_nwrd:        " << RosPrintf(fRd_nwrd,"d",6) << endl;
  os << bl << "  fRd_fu:          " << RosPrintf(fRd_fu,"d",6) << endl;
  os << bl << "  fRd_ovr:         " << fRd_ovr  << endl;
  fRdma.Dump(os, ind+2, "fRdma: ");
  Rw11CntlBase<Rw11UnitRL11,4>::Dump(os, ind, " ^");
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlRL11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  uint16_t rlcs = fPrimClist[fPC_rlcs].Data();
  uint16_t rlba = fPrimClist[fPC_rlba].Data();
  uint16_t rlda = fPrimClist[fPC_rlda].Data();
  uint16_t wc   = fPrimClist[fPC_wc  ].Data();
  uint16_t sta  = fPrimClist[fPC_sta ].Data();
  uint16_t pos  = fPrimClist[fPC_pos ].Data();

  uint16_t ds   = (rlcs>>kRLCS_V_DS)    & kRLCS_B_DS;
  uint16_t fu   = (rlcs>>kRLCS_V_FUNC)  & kRLCS_B_FUNC;
  uint16_t bae  = (rlcs>>kRLCS_V_BAE)   & kRLCS_B_BAE;

  uint32_t addr = uint32_t(bae)<<16 | uint32_t(rlba);

  uint16_t sa   =  rlda                 & kRLDA_RW_B_SA;
  uint16_t hs   = (rlda>>kRLDA_RW_V_HS) & kRLDA_RW_B_HS;
  uint16_t ca   = (rlda>>kRLDA_RW_V_CA) & kRLDA_RW_B_CA;

  uint32_t nwrd = (~uint32_t(wc)&0xffff) + 1; // transfer size in words

  // all 4 units are always available, but check anyway
  if (ds > NUnit())
    throw Rexception("Rw11CntlRL11::AttnHandler","Bad state: ds > NUnit()");

  Rw11UnitRL11& unit = *fspUnit[ds];
  Rw11Cpu& cpu = Cpu();
  RlinkCommandList clist;

  uint32_t lba  = unit.Chs2Lba(ca,hs,sa);
  uint32_t nblk = unit.Nwrd2Nblk(nwrd);

  // check for overrun (read/write beyond track)
  // if found, truncate request length
  bool ovr = false;
  if (fu==kFUNC_WRITE || fu==kFUNC_WCHK || fu==kFUNC_READ || fu==kFUNC_RNHC) {
    ovr = sa + nblk > unit.NSector();
    if (ovr) nwrd = (unit.NSector()-sa) * (unit.BlockSize()/2);
  }
  
  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    static const char* fumnemo[8] = {"no","wc","gs","se","rh","w ","r ","rn"};
    lmsg << "-I RL11 cs=" << RosPrintBvi(rlcs,8)
         << " da=" << RosPrintBvi(rlda,8)
         << " ad=" << RosPrintBvi(addr,8,18)
         << " fu=" << fumnemo[fu&0x7]
         << " pa=" << ds
         << "," << RosPrintf(ca,"d",3) 
         << "," << hs 
         << "," << RosPrintf(sa,"d",2)
         << " la,nw=" << RosPrintf(lba,"d",5) 
         << ",";
    if (nwrd==65536) lmsg << " (0)"; else lmsg << RosPrintf(nwrd,"d",4);
    if (ovr) lmsg << "!";
  }

  // check for spurious interrupts (either RDY=1 or RDY=0 and rdma busy)
  if ((rlcs & kRLCS_M_CRDY) || fRdma.IsActive()) {
    RlogMsg lmsg(LogFile());
    lmsg << "-E RL11   err "
         << " cr=" << RosPrintBvi(rlcs,8)
         << " spurious lam: "
         << (fRdma.IsActive() ? "RDY=0 and Rdma busy" : "RDY=1");
    return 0;
  }

  // remember request parameters for call back and error exit handling
  fRd_rlcs  = rlcs;
  fRd_rlda  = rlda;
  fRd_rlmp  = wc;
  fRd_sta   = sta;
  fRd_pos   = pos;
  fRd_addr  = addr;
  fRd_lba   = lba;
  fRd_nwrd  = nwrd;
  fRd_ovr   = ovr;
  fRd_fu    = fu;

  // check for general abort conditions
  // note: only 'data transfer' functions handled via backend
  //       SEEK and GSTA are done in ibdr_rl11 autonomously

  // not attached --> assumed Offline, status = load
  if (! unit.Virt()) {                      // not attached
    AddErrorExit(clist, kERR_OPI);          // just signal OPI
                                            // drive stat is LOAD anyway
    Server().Exec(clist);                   // doit
    return 0;
  }

  // handle Read Header
  // no data transfer, done here to keep crc calc out of firmware
  if (fu == kFUNC_RHDR) {
    fStats.Inc(kStatNFuncRhdr);
    uint16_t buf[2] = {pos, 0};
    uint16_t crc    = CalcCrc(2, buf);

    cpu.AddWibr(clist, fBase+kRLCS, 
                (kMPREM_CRC << kRLCS_V_MPREM) |
                (kMPLOC_POS << kRLCS_V_MPLOC) |
                kRLCS_ENA_MPREM |
                kRLCS_ENA_MPLOC |
                (kRFUNC_WMP << kRLCS_V_FUNC));
    cpu.AddWibr(clist, fBase+kRLMP, crc);

    // simulate rotation, inc sector number, wrap at end of track 
    uint16_t sa  = (pos & kRLDA_RW_B_SA) + 1;
    if (sa >= unit.NSector()) sa = 0;    // wrap to begin of track
    uint16_t posn = (pos & (kRLDA_RW_M_CA|kRLDA_RW_M_HS)) + sa; 
    AddSetPosition(clist, ds, posn);

    uint16_t cs = kRLCS_M_CRDY |            // signal command done
                  (rlcs & kRLCS_M_BAE) |    // keep BAE
                  (kRFUNC_WCS << kRLCS_V_FUNC);

    cpu.AddWibr(clist, fBase+kRLCS, cs);

    if (fTraceLevel>1) {
      RlogMsg lmsg(LogFile());
      lmsg << "-I RL11   ok "
           << " cs=" << RosPrintBvi(cs,8)
           << " mp=" << RosPrintBvi(crc,8)
           << " pos=" << RosPrintBvi(pos,8)
           << "->" << RosPrintBvi(posn,8);
    }
    Server().Exec(clist);                   // doit
    return 0;
  }

  // now only data transfer functions to handle

  // check track number and proper head positioning
  bool poserr = sa >= unit.NSector();       // track number valid ?
  if (fu != kFUNC_RNHC) {                   // unless RNHC: check proper head pos
    uint16_t pos_ch  = pos  & (kRLDA_RW_M_CA|kRLDA_RW_M_HS); // pos: cyl+hd 
    uint16_t rlda_ch = rlda & (kRLDA_RW_M_CA|kRLDA_RW_M_HS); //  da: cyl+hd 
    poserr |= pos_ch != rlda_ch;
  }
  if (true && poserr) {
    AddErrorExit(clist, kERR_HNFND);
    Server().Exec(clist);                   // doit
    return 0;
  }  

  // now handle the functions
  
  if (fu == kFUNC_WRITE) {                  // Write -------------------------
    fStats.Inc(kStatNFuncWrite);
    if (unit.WProt()) {                     // write on write locked drive ?
      AddSetStatus(clist, ds, sta | kSTA_M_WGE);
      AddErrorExit(clist, kERR_M_DE); 
    } else {
      fRdma.QueueDiskWrite(addr, nwrd, 
                           Rw11Cpu::kCPAH_M_22BIT|Rw11Cpu::kCPAH_M_UBMAP,
                           lba, &unit);
    }

  } else if (fu == kFUNC_WCHK) {            // Write Check -------------------
    fStats.Inc(kStatNFuncWchk );
    fRdma.QueueDiskWriteCheck(addr, nwrd, 
                              Rw11Cpu::kCPAH_M_22BIT|Rw11Cpu::kCPAH_M_UBMAP,
                              lba, &unit);
    
  } else if (fu == kFUNC_READ ||            // Read or 
             fu == kFUNC_RNHC) {            // Read No Header Check ----------
    fStats.Inc(fu==kFUNC_READ ? kStatNFuncRead : kStatNFuncRnhc);

    fRdma.QueueDiskRead(addr, nwrd, 
                        Rw11Cpu::kCPAH_M_22BIT|Rw11Cpu::kCPAH_M_UBMAP,
                        lba, &unit);
  }

  if (clist.Size()) {                       // if handled directly
    Server().Exec(clist);                   // doit
  }
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRL11::RdmaPreExecCB(int stat, size_t nwdone, size_t nwnext,
                                 RlinkCommandList& clist)
{
  // if last chunk and not doing WCHK add a labo and normal exit csr update
  if (stat == Rw11Rdma::kStatusBusyLast && fRd_fu != kFUNC_WCHK) {
    clist.AddLabo();
    AddNormalExit(clist, nwdone+nwnext, 0);
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRL11::RdmaPostExecCB(int stat, size_t ndone,
                                  RlinkCommandList& clist, size_t ncmd)
{
  if (stat == Rw11Rdma::kStatusBusy) return;

  uint16_t rlerr = 0;

  // handle write check
  if (fRd_fu == kFUNC_WCHK) {
    size_t nwcok = fRdma.WriteCheck(ndone);
    if (nwcok != ndone) {                   // if mismatch found
      rlerr = kERR_WCHK;                    // set error
      ndone = nwcok;                        // truncate word count
    }
  }

  // handle Rdma aborts
  if (stat == Rw11Rdma::kStatusFailRdma && rlerr == 0) rlerr = kERR_NXM;

  // check for fused csr updates
  if (clist.Size() > ncmd) {
    uint8_t  ccode = clist[ncmd].Command();
    uint16_t cdata = clist[ncmd].Data();
    if (ccode != RlinkCommand::kCmdLabo || (rlerr != 0 && cdata == 0))
      throw Rexception("Rw11CntlRL11::RdmaPostExecCB",
                       "Bad state: Labo not found or missed abort");
    if (cdata == 0) return;
  }

  // finally to RL11 register update
  RlinkCommandList clist1;
  AddNormalExit(clist1, ndone, rlerr);
  Server().Exec(clist1);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs ????

void Rw11CntlRL11::LogRler(uint16_t rlerr)
{
  RlogMsg lmsg(LogFile());
  lmsg << "-E RL11 err=" << RosPrintBvi(rlerr,2,5) << "  ERROR ABORT";
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRL11::AddSetPosition(RlinkCommandList& clist, size_t ind,
                                  uint16_t pos)
{
  Rw11Cpu& cpu  = Cpu();
  cpu.AddWibr(clist, fBase+kRLCS, 
              ((kMPREM_POS+ind)<<kRLCS_V_MPREM) | // address pos(unit)
              kRLCS_ENA_MPREM |                   // update MPREM
              (kRFUNC_WMP << kRLCS_V_FUNC) );     // write MP
  cpu.AddWibr(clist, fBase+kRLMP, pos);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRL11::AddSetStatus(RlinkCommandList& clist, size_t ind,
                                uint16_t sta)
{
  Rw11Cpu& cpu  = Cpu();
  cpu.AddWibr(clist, fBase+kRLCS, 
              ((kMPREM_STA+ind)<<kRLCS_V_MPREM) | // address sta(unit)
              kRLCS_ENA_MPREM |                   // update MPREM
              (kRFUNC_WMP << kRLCS_V_FUNC) );     // write MP
  cpu.AddWibr(clist, fBase+kRLMP, sta);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRL11::AddErrorExit(RlinkCommandList& clist, uint16_t rlerr)
{
  Rw11Cpu& cpu  = Cpu();
  uint16_t cs = kRLCS_M_ERR |               // set ERR flag
                (rlerr << kRLCS_V_E) |      // set DE and E fields
                kRLCS_M_CRDY |              // signal command done
                (fRd_rlcs & kRLCS_M_BAE) |  // keep BAE
                (kRFUNC_WCS << kRLCS_V_FUNC); // write CS
  cpu.AddWibr(clist, fBase+kRLCS, cs);

  if (fTraceLevel>1) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I RL11   err"
         << " cs=" << RosPrintBvi(cs,8)
         << " err=" << RosPrintBvi(rlerr,2,5)
         << " pos=" << RosPrintBvi(fRd_pos,8);
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRL11::AddNormalExit(RlinkCommandList& clist, size_t ndone,
                                 uint16_t rlerr)
{
  Rw11Cpu& cpu  = Cpu();
  uint16_t ds   = (fRd_rlcs>>kRLCS_V_DS) & kRLCS_B_DS;
  Rw11UnitRL11& unit = *fspUnit[ds];

  size_t nblk    = unit.Nwrd2Nblk(ndone);

  uint32_t addr  = fRd_addr + 2*ndone;

  uint16_t ba   = addr & 0177776;           // get lower 16 bits
  uint16_t bae  = (addr>>16) & 03;          // get upper  2 bits

  uint16_t da   = fRd_rlda+uint16_t(nblk);

  uint16_t rlmp = fRd_rlmp + uint16_t(ndone);

  if (fRd_ovr && rlerr == 0) rlerr = kERR_HNFND;

  cpu.AddWibr(clist, fBase+kRLBA, ba);
  cpu.AddWibr(clist, fBase+kRLDA, da);
  cpu.AddWibr(clist, fBase+kRLCS, 
              (kMPREM_MP << kRLCS_V_MPREM) |
              (kMPLOC_MP << kRLCS_V_MPLOC) |
              kRLCS_ENA_MPREM |
              kRLCS_ENA_MPLOC |
              (kRFUNC_WMP << kRLCS_V_FUNC));
  cpu.AddWibr(clist, fBase+kRLMP, rlmp);

  // set drive position to one sector past the last the read sector 
  // Note: take sa from rlda, and ca+hs from fRd_pos (controller context!)
  //       in case of errors this probably the best solution
  uint16_t sa  = (fRd_rlda & kRLDA_RW_B_SA) + uint16_t(nblk);
  if (sa >= unit.NSector()) sa = 0;    // wrap to begin of track
  uint16_t posn = (fRd_pos & (kRLDA_RW_M_CA|kRLDA_RW_M_HS)) + sa; 
  AddSetPosition(clist, ds, posn);

  uint16_t cs = kRLCS_M_CRDY | 
                (bae << kRLCS_V_BAE) |
                (kRFUNC_WCS << kRLCS_V_FUNC);
  if (rlerr) cs |= (rlerr << kRLCS_V_E);
  cpu.AddWibr(clist, fBase+kRLCS, cs);

  if (fTraceLevel>1) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I RL11   " << (rlerr==0 ? " ok" : "err")
         << " cs=" << RosPrintBvi(cs,8)
         << " ba=" << RosPrintBvi(ba,8)
         << " da=" << RosPrintBvi(da,8)
         << " mp=" << RosPrintBvi(rlmp,8);
    if (rlerr) lmsg << " err=" << RosPrintBvi(rlerr,2,5);
    lmsg << " pos=" << RosPrintBvi(fRd_pos,8)
         << "->" << RosPrintBvi(posn,8);
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
// Note:
//   CalcCrc() is adopted from the simh project and Copyright Robert M Supnik

uint16_t Rw11CntlRL11::CalcCrc(size_t size, const uint16_t* data)
{
  uint32_t  crc=0;

  for (size_t i = 0; i < size; i++) {
    uint32_t d = *data++;
    /* cribbed from KG11-A */
    for (size_t j = 0; j < 16; j++) {
      crc = (crc & ~01) | ((crc & 01) ^ (d & 01));
      crc = (crc & 01) ? (crc >> 1) ^ 0120001 : crc >> 1;
      d >>= 1;
    }
  }
  return crc;
}
  

} // end namespace Retro
