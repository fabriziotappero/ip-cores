// $Id: Rw11CntlRHRP.cpp 686 2015-06-04 21:08:08Z mueller $
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
// 2015-06-04   686   1.0.2  check for spurious lams
// 2015-05-24   684   1.0.1  fixed rpcs2 update for wcheck and nem aborts
// 2015-05-14   680   1.0    Initial version
// 2015-03-21   659   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11CntlRHRP.cpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation of Rw11CntlRHRP.
*/

#include "boost/bind.hpp"
#include "boost/foreach.hpp"
#define foreach_ BOOST_FOREACH

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "Rw11CntlRHRP.hpp"

using namespace std;

/*!
  \class Retro::Rw11CntlRHRP
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlRHRP::kIbaddr;
const int      Rw11CntlRHRP::kLam;

const uint16_t Rw11CntlRHRP::kRPCS1;
const uint16_t Rw11CntlRHRP::kRPWC;
const uint16_t Rw11CntlRHRP::kRPBA;
const uint16_t Rw11CntlRHRP::kRPDA;
const uint16_t Rw11CntlRHRP::kRPCS2;
const uint16_t Rw11CntlRHRP::kRPDS;
const uint16_t Rw11CntlRHRP::kRPER1;
const uint16_t Rw11CntlRHRP::kRPAS;
const uint16_t Rw11CntlRHRP::kRPLA;
const uint16_t Rw11CntlRHRP::kRPDB;
const uint16_t Rw11CntlRHRP::kRPMR1;
const uint16_t Rw11CntlRHRP::kRPDT;
const uint16_t Rw11CntlRHRP::kRPSN;
const uint16_t Rw11CntlRHRP::kRPOF;
const uint16_t Rw11CntlRHRP::kRPDC;
const uint16_t Rw11CntlRHRP::kRxM13;
const uint16_t Rw11CntlRHRP::kRxM14;
const uint16_t Rw11CntlRHRP::kRxM15;
const uint16_t Rw11CntlRHRP::kRPEC1;
const uint16_t Rw11CntlRHRP::kRPEC2;
const uint16_t Rw11CntlRHRP::kRPBAE;
const uint16_t Rw11CntlRHRP::kRPCS3;

const uint16_t Rw11CntlRHRP::kProbeOff;
const bool     Rw11CntlRHRP::kProbeInt;
const bool     Rw11CntlRHRP::kProbeRem;

const uint16_t Rw11CntlRHRP::kRPCS1_M_SC;
const uint16_t Rw11CntlRHRP::kRPCS1_M_TRE;
const uint16_t Rw11CntlRHRP::kRPCS1_M_DVA;
const uint16_t Rw11CntlRHRP::kRPCS1_M_BAE;
const uint16_t Rw11CntlRHRP::kRPCS1_V_BAE;
const uint16_t Rw11CntlRHRP::kRPCS1_B_BAE;
const uint16_t Rw11CntlRHRP::kRPCS1_M_RDY;
const uint16_t Rw11CntlRHRP::kRPCS1_M_IE;
const uint16_t Rw11CntlRHRP::kRPCS1_V_FUNC;
const uint16_t Rw11CntlRHRP::kRPCS1_B_FUNC;
const uint16_t Rw11CntlRHRP::kRPCS1_M_GO;

const uint16_t Rw11CntlRHRP::kFUNC_WCD;
const uint16_t Rw11CntlRHRP::kFUNC_WCHD;
const uint16_t Rw11CntlRHRP::kFUNC_WRITE;
const uint16_t Rw11CntlRHRP::kFUNC_WHD;
const uint16_t Rw11CntlRHRP::kFUNC_READ;
const uint16_t Rw11CntlRHRP::kFUNC_RHD;

const uint16_t Rw11CntlRHRP::kRFUNC_WUNIT;
const uint16_t Rw11CntlRHRP::kRFUNC_CUNIT;
const uint16_t Rw11CntlRHRP::kRFUNC_DONE;
const uint16_t Rw11CntlRHRP::kRFUNC_WIDLY;

const uint16_t Rw11CntlRHRP::kRPCS1_V_RUNIT;
const uint16_t Rw11CntlRHRP::kRPCS1_B_RUNIT;
const uint16_t Rw11CntlRHRP::kRPCS1_M_RATA;
const uint16_t Rw11CntlRHRP::kRPCS1_V_RIDLY;
const uint16_t Rw11CntlRHRP::kRPCS1_B_RIDLY;

const uint16_t Rw11CntlRHRP::kRPDA_V_TA;
const uint16_t Rw11CntlRHRP::kRPDA_B_TA;
const uint16_t Rw11CntlRHRP::kRPDA_B_SA;

const uint16_t Rw11CntlRHRP::kRPCS2_M_RWCO;
const uint16_t Rw11CntlRHRP::kRPCS2_M_WCE;
const uint16_t Rw11CntlRHRP::kRPCS2_M_NED;
const uint16_t Rw11CntlRHRP::kRPCS2_M_NEM;
const uint16_t Rw11CntlRHRP::kRPCS2_M_PGE;
const uint16_t Rw11CntlRHRP::kRPCS2_M_MXF;
const uint16_t Rw11CntlRHRP::kRPCS2_M_OR;
const uint16_t Rw11CntlRHRP::kRPCS2_M_IR;
const uint16_t Rw11CntlRHRP::kRPCS2_M_CLR;
const uint16_t Rw11CntlRHRP::kRPCS2_M_PAT;
const uint16_t Rw11CntlRHRP::kRPCS2_M_BAI;
const uint16_t Rw11CntlRHRP::kRPCS2_M_UNIT2;
const uint16_t Rw11CntlRHRP::kRPCS2_B_UNIT;

const uint16_t Rw11CntlRHRP::kRPDS_M_ATA;
const uint16_t Rw11CntlRHRP::kRPDS_M_ERP;
const uint16_t Rw11CntlRHRP::kRPDS_M_MOL;
const uint16_t Rw11CntlRHRP::kRPDS_M_WRL;
const uint16_t Rw11CntlRHRP::kRPDS_M_LBT;
const uint16_t Rw11CntlRHRP::kRPDS_M_DPR;
const uint16_t Rw11CntlRHRP::kRPDS_M_DRY;
const uint16_t Rw11CntlRHRP::kRPDS_M_VV;
const uint16_t Rw11CntlRHRP::kRPDS_M_OM ;

const uint16_t Rw11CntlRHRP::kRPER1_M_UNS;
const uint16_t Rw11CntlRHRP::kRPER1_M_WLE;
const uint16_t Rw11CntlRHRP::kRPER1_M_IAE;
const uint16_t Rw11CntlRHRP::kRPER1_M_AOE;
const uint16_t Rw11CntlRHRP::kRPER1_M_RMR;
const uint16_t Rw11CntlRHRP::kRPER1_M_ILF;

const uint16_t Rw11CntlRHRP::kRPDC_B_CA;

const uint16_t Rw11CntlRHRP::kRPCS3_M_IE;
const uint16_t Rw11CntlRHRP::kRPCS3_M_RSEARDONE;
const uint16_t Rw11CntlRHRP::kRPCS3_M_RPACKDONE;
const uint16_t Rw11CntlRHRP::kRPCS3_M_RPOREDONE;
const uint16_t Rw11CntlRHRP::kRPCS3_M_RSEEKDONE;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlRHRP::Rw11CntlRHRP()
  : Rw11CntlBase<Rw11UnitRHRP,4>("rhrp"),
    fPC_rpcs1(0),
    fPC_rpcs2(0),
    fPC_rpcs3(0),
    fPC_rpwc(0),
    fPC_rpba(0),
    fPC_rpbae(0),
    fPC_cunit(0),
    fPC_rpds(0),
    fPC_rpda(0),
    fPC_rpdc(0),
    fRd_rpcs1(0),
    fRd_rpcs2(0),
    fRd_rpcs3(0),
    fRd_rpwc(0),
    fRd_rpba(0),
    fRd_rpbae(0),
    fRd_rpds(0),
    fRd_rpda(0),
    fRd_rpdc(0),
    fRd_addr(0),
    fRd_lba(0),
    fRd_nwrd(0),
    fRd_fu(0),
    fRd_ovr(false),
    fRdma(this,
          boost::bind(&Rw11CntlRHRP::RdmaPreExecCB,  this, _1, _2, _3, _4),
          boost::bind(&Rw11CntlRHRP::RdmaPostExecCB, this, _1, _2, _3, _4))
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitRHRP(this, i));
  }

  fStats.Define(kStatNFuncWchk   , "NFuncWchk"    , "func WCHK");
  fStats.Define(kStatNFuncWrite  , "NFuncWrite"   , "func WRITE");
  fStats.Define(kStatNFuncRead   , "NFuncRead"    , "func READ");
  fStats.Define(kStatNFuncSear   , "NFuncSear"    , "func SEARCH (loc)");
  fStats.Define(kStatNFuncPack   , "NFuncPack"    , "func PACK ACK (loc)");
  fStats.Define(kStatNFuncPore   , "NFuncPore"    , "func PORT REL (loc)");
  fStats.Define(kStatNFuncSeek   , "NFuncSeek"    , "func SEEK (loc)");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlRHRP::~Rw11CntlRHRP()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRHRP::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRHRP::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlRHRP::Start",
                     "Bad state: started, no lam, not enable, not found");

  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".cs1", Base() + kRPCS1);
  Cpu().AllIAddrMapInsert(Name()+".wc",  Base() + kRPWC);
  Cpu().AllIAddrMapInsert(Name()+".ba",  Base() + kRPBA);
  Cpu().AllIAddrMapInsert(Name()+".da",  Base() + kRPDA);
  Cpu().AllIAddrMapInsert(Name()+".cs2", Base() + kRPCS2);
  Cpu().AllIAddrMapInsert(Name()+".ds",  Base() + kRPDS);
  Cpu().AllIAddrMapInsert(Name()+".er1", Base() + kRPER1);
  Cpu().AllIAddrMapInsert(Name()+".as",  Base() + kRPAS);
  Cpu().AllIAddrMapInsert(Name()+".la",  Base() + kRPLA);
  Cpu().AllIAddrMapInsert(Name()+".db",  Base() + kRPDB);
  Cpu().AllIAddrMapInsert(Name()+".mr1", Base() + kRPMR1);
  Cpu().AllIAddrMapInsert(Name()+".dt",  Base() + kRPDT);
  Cpu().AllIAddrMapInsert(Name()+".sn",  Base() + kRPSN);
  Cpu().AllIAddrMapInsert(Name()+".of",  Base() + kRPOF);
  Cpu().AllIAddrMapInsert(Name()+".dc",  Base() + kRPDC);
  Cpu().AllIAddrMapInsert(Name()+".m13", Base() + kRxM13);
  Cpu().AllIAddrMapInsert(Name()+".m14", Base() + kRxM14);
  Cpu().AllIAddrMapInsert(Name()+".m15", Base() + kRxM15);
  Cpu().AllIAddrMapInsert(Name()+".ec1", Base() + kRPEC1);
  Cpu().AllIAddrMapInsert(Name()+".ec2", Base() + kRPEC2);
  Cpu().AllIAddrMapInsert(Name()+".bae", Base() + kRPBAE);
  Cpu().AllIAddrMapInsert(Name()+".cs3", Base() + kRPCS3);

  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_rpcs1 = Cpu().AddRibr(fPrimClist, fBase+kRPCS1);
  fPC_rpcs2 = Cpu().AddRibr(fPrimClist, fBase+kRPCS2);
  fPC_rpcs3 = Cpu().AddRibr(fPrimClist, fBase+kRPCS3);
  fPC_rpwc  = Cpu().AddRibr(fPrimClist, fBase+kRPWC);
  fPC_rpba  = Cpu().AddRibr(fPrimClist, fBase+kRPBA);
  fPC_rpbae = Cpu().AddRibr(fPrimClist, fBase+kRPBAE);

  fPC_cunit = Cpu().AddWibr(fPrimClist, fBase+kRPCS1,
                            (kRFUNC_CUNIT << kRPCS1_V_FUNC) );

  fPC_rpds  = Cpu().AddRibr(fPrimClist, fBase+kRPDS);
  fPC_rpda  = Cpu().AddRibr(fPrimClist, fBase+kRPDA);
  fPC_rpdc  = Cpu().AddRibr(fPrimClist, fBase+kRPDC);

  // add attn handler
  Server().AddAttnHandler(boost::bind(&Rw11CntlRHRP::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, (void*)this);

  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRHRP::UnitSetup(size_t ind)
{
  Rw11UnitRHRP& unit = *fspUnit[ind];
  RlinkCommandList clist;
  Rw11Cpu& cpu  = Cpu();

  // only two mayor drive states are used
  //  power medium  wlock : ds flags
  //   off    ---     --- : dpr=0  mol=0  wrl=0  (disabled, type=off)
  //    on    off     --- : dpr=1  mol=0  wrl=0  (enabled, no file attached)
  //    on     on      no : dpr=1  mol=1  wrl=0  (file attached)
  //    on     on     yes : dpr=1  mol=1  wrl=1  (file attached + wlock)

  uint16_t rpds = 0;

  if (unit.Type() != "off") {               // is enabled
    rpds |= kRPDS_M_DPR;
    if (unit.Virt()) {                        // file attached
      rpds |= kRPDS_M_MOL;                    // -> set MOL
      rpds |= kRPDS_M_ERP;                    // -> clear ER1 via ERP=1
      if (unit.WProt()) rpds |= kRPDS_M_WRL; // in case write protected
    }
    if ((unit.Rpds() ^ rpds) & kRPDS_M_MOL) { // mol state change ?
      rpds |= kRPDS_M_ATA;                      // cause attentions
      rpds |= kRPDS_M_VV;                       // reset volume valid
    }
  }
  
  unit.SetRpds(rpds);                       // remember new DS
  cpu.AddWibr(clist, fBase+kRPCS1,          // setup unit
              (ind << kRPCS1_V_RUNIT) | 
              (kRFUNC_WUNIT << kRPCS1_V_FUNC) );
  cpu.AddWibr(clist, fBase+kRPDT, unit.Rpdt()); // setup DT
  cpu.AddWibr(clist, fBase+kRPDS, rpds);        // setup DS
  Server().Exec(clist);

  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11CntlRHRP::BootCode(size_t unit, std::vector<uint16_t>& code, 
                            uint16_t& aload, uint16_t& astart)
{
  uint16_t kBOOT_START = 02000;
  uint16_t bootcode[] = {      // rh/rp boot loader - from simh pdp11_rp.c (v3.9)
    0042102,                   // "BD"
    0012706, kBOOT_START,      // mov #boot_start, sp
    0012700, uint16_t(unit),   // mov #unit, r0
    0012701, 0176700,          // mov #RPCS1, r1
    0012761, 0000040, 0000010, // mov #CS2_CLR, 10(r1) ; reset
    0010061, 0000010,          // mov r0, 10(r1)       ; set unit
    0012711, 0000021,          // mov #RIP+GO, (r1)    ; pack ack
    0012761, 0010000, 0000032, // mov #FMT16B, 32(r1)  ; 16b mode
    0012761, 0177000, 0000002, // mov #-512., 2(r1)    ; set wc
    0005061, 0000004,          // clr 4(r1)            ; clr ba
    0005061, 0000006,          // clr 6(r1)            ; clr da
    0005061, 0000034,          // clr 34(r1)           ; clr cyl
    0012711, 0000071,          // mov #READ+GO, (r1)   ; read 
    0105711,                   // tstb (r1)            ; wait
    0100376,                   // bpl .-2
    0005002,                   // clr R2
    0005003,                   // clr R3
    0012704, uint16_t(kBOOT_START+020), // mov #start+020, r4
    0005005,                   // clr R5
    0105011,                   // clrb (r1)
    0005007                    // clr PC
    };
  
  code.clear();
  foreach_ (uint16_t& w, bootcode) code.push_back(w); 
  aload  = kBOOT_START;
  astart = kBOOT_START+2;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRHRP::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlRHRP @ " << this << endl;
  os << bl << "  fPC_rpcs1:       " << RosPrintf(fPC_rpcs1,"d",6) << endl;
  os << bl << "  fPC_rpcs2:       " << RosPrintf(fPC_rpcs2,"d",6) << endl;
  os << bl << "  fPC_rpcs3:       " << RosPrintf(fPC_rpcs3,"d",6) << endl;
  os << bl << "  fPC_rpwc:        " << RosPrintf(fPC_rpwc,"d",6) << endl;
  os << bl << "  fPC_rpba:        " << RosPrintf(fPC_rpba,"d",6) << endl;
  os << bl << "  fPC_rpbae:       " << RosPrintf(fPC_rpbae,"d",6) << endl;
  os << bl << "  fPC_cunit:       " << RosPrintf(fPC_cunit,"d",6) << endl;
  os << bl << "  fPC_rpds:        " << RosPrintf(fPC_rpds,"d",6) << endl;
  os << bl << "  fPC_rpda:        " << RosPrintf(fPC_rpda,"d",6) << endl;
  os << bl << "  fPC_rpdc:        " << RosPrintf(fPC_rpdc,"d",6) << endl;
  os << bl << "  fRd_rpcs1:       " << RosPrintBvi(fRd_rpcs1) << endl;
  os << bl << "  fRd_rpcs2:       " << RosPrintBvi(fRd_rpcs2) << endl;
  os << bl << "  fRd_rpcs3:       " << RosPrintBvi(fRd_rpcs3) << endl;
  os << bl << "  fRd_rpwc:        " << RosPrintBvi(fRd_rpwc) << endl;
  os << bl << "  fRd_rpba:        " << RosPrintBvi(fRd_rpba) << endl;
  os << bl << "  fRd_rpbae:       " << RosPrintBvi(fRd_rpbae) << endl;
  os << bl << "  fRd_rpds:        " << RosPrintBvi(fRd_rpds) << endl;
  os << bl << "  fRd_rpda:        " << RosPrintBvi(fRd_rpda) << endl;
  os << bl << "  fRd_rpdc:        " << RosPrintBvi(fRd_rpdc) << endl;
  os << bl << "  fRd_addr:        " << RosPrintBvi(fRd_addr,8,22) << endl;
  os << bl << "  fRd_lba:         " << RosPrintf(fRd_lba,"d",6)  << endl;
  os << bl << "  fRd_nwrd:        " << RosPrintf(fRd_nwrd,"d",6) << endl;
  os << bl << "  fRd_fu:          " << RosPrintf(fRd_fu,"d",6) << endl;
  os << bl << "  fRd_ovr:         " << fRd_ovr  << endl;
  fRdma.Dump(os, ind+2, "fRdma: ");
  Rw11CntlBase<Rw11UnitRHRP,4>::Dump(os, ind, " ^");
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlRHRP::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  uint16_t rpcs1 = fPrimClist[fPC_rpcs1].Data();
  uint16_t rpcs2 = fPrimClist[fPC_rpcs2].Data();
  uint16_t rpcs3 = fPrimClist[fPC_rpcs3].Data();
  uint16_t rpwc  = fPrimClist[fPC_rpwc ].Data();
  uint16_t rpba  = fPrimClist[fPC_rpba ].Data();
  uint16_t rpbae = fPrimClist[fPC_rpbae].Data();
  uint16_t rpds  = fPrimClist[fPC_rpds ].Data();
  uint16_t rpda  = fPrimClist[fPC_rpda ].Data();
  uint16_t rpdc  = fPrimClist[fPC_rpdc ].Data();
 
  uint16_t unum  = rpcs2 & kRPCS2_B_UNIT;
  uint16_t fu    = (rpcs1>>kRPCS1_V_FUNC)  & kRPCS1_B_FUNC;

  uint32_t addr = uint32_t(rpbae)<<16 | uint32_t(rpba);

  uint16_t sa   =  rpda              & kRPDA_B_SA;
  uint16_t ta   = (rpda>>kRPDA_V_TA) & kRPDA_B_TA;
  uint16_t ca   =  rpdc              & kRPDC_B_CA;

  uint32_t nwrd = (~uint32_t(rpwc)&0xffff) + 1; // transfer size in words

  // all 4 units are always available, but check anyway
  if (unum > NUnit())
    throw Rexception("Rw11CntlRHRP::AttnHandler","Bad state: unum > NUnit()");

  Rw11UnitRHRP& unit = *fspUnit[unum];
  //Rw11Cpu& cpu = Cpu();
  RlinkCommandList clist;

  uint32_t lba  = unit.Chs2Lba(ca,ta,sa);
  uint32_t nblk = unit.Nwrd2Nblk(nwrd);

  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    static const char* fumnemo[32] = 
      {"00 ","01 ","02 ","03 ","04 ","05 ","06 ","07 ",    // 00---
       "10 ","11 ","12 ","13 ","14 ","15 ","16 ","17 ",    // 01---
       "20 ","21 ","22 ","23 ","wc ","wch","26 ","27 ",    // 10---
       "wr ","wrh","32 ","33 ","rd ","rdh","36 ","37 "};   // 11---
    lmsg << "-I RHRP"
         << " fu=" << fumnemo[fu&037]
         << " cs=" << RosPrintBvi(rpcs1,8)
         << "," << RosPrintBvi(rpcs2,8)
         << " ad=" << RosPrintBvi(addr,8,22)
         << " pa=" << unum
         << "," << RosPrintf(ca,"d",3) 
         << "," << RosPrintf(ta,"d",2)
         << "," << RosPrintf(sa,"d",2)
         << " la,nw=" << RosPrintf(lba,"d",6) 
         << ",";
    if (nwrd==65536) lmsg << "  (0)"; else lmsg << RosPrintf(nwrd,"d",5);
  }

  // handle cs3 done flags, just count them
  if (rpcs3 & kRPCS3_M_RSEARDONE) fStats.Inc(kStatNFuncSear);
  if (rpcs3 & kRPCS3_M_RPOREDONE) fStats.Inc(kStatNFuncPore);
  if (rpcs3 & kRPCS3_M_RPACKDONE) fStats.Inc(kStatNFuncPack);
  if (rpcs3 & kRPCS3_M_RSEEKDONE) fStats.Inc(kStatNFuncSeek);

  // check for spurious interrupts (either RDY=1 or RDY=0 and rdma busy)
  if ((rpcs1 & kRPCS1_M_RDY) || fRdma.IsActive()) {
    RlogMsg lmsg(LogFile());
    lmsg << "-E RHRP   err "
         << " cs=" << RosPrintBvi(rpcs1,8)
         << " spurious lam: "
         << (fRdma.IsActive() ? "RDY=0 and Rdma busy" : "RDY=1");
    return 0;
  }

  // check for overrun (read/write beyond last track
  // if found, truncate request length
  bool ovr = lba + nblk > unit.NBlock();
  if (ovr) nwrd = (unit.NBlock()-lba) * (unit.BlockSize()/2);

  // remember request parameters for call back and error exit handling

  fRd_rpcs1 = rpcs1;
  fRd_rpcs2 = rpcs2;
  fRd_rpcs3 = rpcs3;
  fRd_rpwc  = rpwc;
  fRd_rpba  = rpba;
  fRd_rpbae = rpbae;
  fRd_rpds  = rpds;
  fRd_rpda  = rpda;
  fRd_rpdc  = rpdc;
  fRd_addr  = addr;
  fRd_lba   = lba;
  fRd_nwrd  = nwrd;
  fRd_fu    = fu;
  fRd_ovr   = ovr;

  // check for general abort conditions
  // note: only 'data transfer' functions handled via backend
  //       SEEK and others are done in ibdr_rhrp autonomously

  // not attached --> signal drive unsave status
  if (! unit.Virt()) {                      // not attached
    AddErrorExit(clist, kRPER1_M_UNS);      // signal UNS (drive unsafe)
    Server().Exec(clist);                   // doit
    return 0;
  }

  // invalid disk address
  if (ca > unit.NCylinder() || ta > unit.NHead() || sa > unit.NSector()) {
    AddErrorExit(clist, kRPER1_M_IAE);      // signal IAE (invalid address err)
    Server().Exec(clist);                   // doit
    return 0;
  }
  
  // now handle the functions
  if (fu == kFUNC_WRITE) {                  // Write -------------------------
    fStats.Inc(kStatNFuncWrite);
    if (unit.WProt()) {                     // write on write locked drive ?
      AddErrorExit(clist, kRPER1_M_WLE);    // signal WLE (write lock error)
    } else {
      fRdma.QueueDiskWrite(addr, nwrd, Rw11Cpu::kCPAH_M_22BIT, lba, &unit);
    }

  } else if (fu == kFUNC_WCD) {             // Write Check -------------------
    fStats.Inc(kStatNFuncWchk );
    fRdma.QueueDiskWriteCheck(addr, nwrd, Rw11Cpu::kCPAH_M_22BIT, lba, &unit);
    
  } else if (fu == kFUNC_READ ) {           // Read --------------------------
    fStats.Inc(kStatNFuncRead);
    fRdma.QueueDiskRead(addr, nwrd, Rw11Cpu::kCPAH_M_22BIT, lba, &unit);

  } else {
    // FIXME: handle other special functions (currently simply error out !!)
    AddErrorExit(clist, kRPER1_M_ILF);      // signal ILF (invalid function)
    Server().Exec(clist);                   // doit
    return 0;
  }

  if (clist.Size()) {                       // if handled directly
    Server().Exec(clist);                   // doit
  }

  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRHRP::RdmaPreExecCB(int stat, size_t nwdone, size_t nwnext,
                                 RlinkCommandList& clist)
{
  // if last chunk and not doing WCD add a labo and normal exit csr update
  if (stat == Rw11Rdma::kStatusBusyLast && fRd_fu != kFUNC_WCD) {
    clist.AddLabo();
    AddNormalExit(clist, nwdone+nwnext, 0, 0);
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRHRP::RdmaPostExecCB(int stat, size_t ndone,
                                  RlinkCommandList& clist, size_t ncmd)
{
  if (stat == Rw11Rdma::kStatusBusy) return;

  uint16_t rper1 = 0;
  uint16_t rpcs2 = 0;

  if (fRd_fu == kFUNC_WCD) {
    size_t nwcok = fRdma.WriteCheck(ndone);
    if (nwcok != ndone) {                   // if mismatch found
      rpcs2 |= kRPCS2_M_WCE;
      if (ndone & 0x1) rpcs2 |= kRPCS2_M_RWCO; // failed in odd word !
      ndone = nwcok;                        // truncate word count
    }
  }

  // handle Rdma aborts
  if (stat == Rw11Rdma::kStatusFailRdma) rpcs2 |= kRPCS2_M_NEM;

  // check for fused csr updates
  if (clist.Size() > ncmd) {
    uint8_t  ccode = clist[ncmd].Command();
    uint16_t cdata = clist[ncmd].Data();
    if (ccode != RlinkCommand::kCmdLabo || (rper1 != 0 && cdata == 0))
      throw Rexception("Rw11CntlRHRP::RdmaPostExecCB",
                       "Bad state: Labo not found or missed abort");
    if (cdata == 0) return;
  }

  // finally to RHRP register update
  RlinkCommandList clist1;
  AddNormalExit(clist1, ndone, rper1, rpcs2);
  Server().Exec(clist1);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRHRP::AddErrorExit(RlinkCommandList& clist, uint16_t rper1)
{
  Rw11Cpu& cpu  = Cpu();
  
  cpu.AddWibr(clist, fBase+kRPCS1, (kRFUNC_CUNIT<<kRPCS1_V_FUNC) );
  cpu.AddWibr(clist, fBase+kRPER1, rper1);

  // use ATA termination ! Comes late, but should be ok
  cpu.AddWibr(clist, fBase+kRPCS1, kRPCS1_M_RATA|(kRFUNC_DONE<<kRPCS1_V_FUNC) );

  if (fTraceLevel>1) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I RHRP"
         << "   err "
         << " cs1=" << RosPrintBvi(fRd_rpcs1,8)
         << " er1=" << RosPrintBvi(rper1,2,16);
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRHRP::AddNormalExit(RlinkCommandList& clist, size_t ndone,
                                 uint16_t rper1, uint16_t rpcs2)
{
  Rw11Cpu& cpu  = Cpu();
  uint16_t unum  = fRd_rpcs2 & kRPCS2_B_UNIT;
  Rw11UnitRHRP& unit = *fspUnit[unum];

  size_t nblk    = unit.Nwrd2Nblk(ndone);
  uint32_t addr  = fRd_addr + 2*ndone;
  size_t   lba   = fRd_lba  + nblk;

  uint16_t ba   = addr & 0177776;           // get lower 16 bits
  uint16_t bae  = (addr>>16) & 077;         // get upper  6 bits

  uint16_t sa;
  uint16_t ta;
  uint16_t ca;
  unit.Lba2Chs(lba, ca,ta,sa);
  uint16_t da   = (ta<<kRPDA_V_TA) | sa;
  uint16_t wc   = fRd_rpwc + uint16_t(ndone);

  if (fRd_ovr) rper1 |= kRPER1_M_AOE;

  cpu.AddWibr(clist, fBase+kRPWC,  wc);
  cpu.AddWibr(clist, fBase+kRPBA,  ba);
  cpu.AddWibr(clist, fBase+kRPBAE, bae);

  cpu.AddWibr(clist, fBase+kRPCS1, (kRFUNC_CUNIT<<kRPCS1_V_FUNC) );
  cpu.AddWibr(clist, fBase+kRPDA,  da);
  cpu.AddWibr(clist, fBase+kRPDC,  ca);

  if (rper1)  cpu.AddWibr(clist, fBase+kRPER1, rper1);
  if (rpcs2)  cpu.AddWibr(clist, fBase+kRPER1, rpcs2);

  cpu.AddWibr(clist, fBase+kRPCS1, (kRFUNC_DONE<<kRPCS1_V_FUNC) );

  if (fTraceLevel>1) {
    RlogMsg lmsg(LogFile());
    if (rper1 || rpcs2) {
      lmsg << "-I RHRP"
           << "   err "
           << " er1=" << RosPrintBvi(rper1,2,16)
           << " cs2=" << RosPrintBvi(rpcs2,2,8)
           << endl;
    }
    lmsg << "-I RHRP"
         << (rper1==0 ? "    ok " :"   err ")
         << " we=" << RosPrintBvi(wc,8) << "," << RosPrintBvi(rper1,8)
         << " ad=" << RosPrintBvi(addr,8,22)
         << " pa=" << unum
         << "," << RosPrintf(ca,"d",3)
         << "," << RosPrintf(ta,"d",2)
         << "," << RosPrintf(sa,"d",2)
         << " ca,da=" << RosPrintBvi(ca,8,10) << "," << RosPrintBvi(da,8);
  }

  return;
}
  

} // end namespace Retro
