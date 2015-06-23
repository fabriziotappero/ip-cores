// $Id: Rw11CntlRK11.cpp 686 2015-06-04 21:08:08Z mueller $
//
// Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-06-04   686   2.0.2  check for spurious lams
// 2015-02-17   647   2.0.1  use Nwrd2Nblk(); BUGFIX: revise RdmaPostExecCB()
// 2015-01-04   628   2.0    use Rw11RdmaDisk
// 2014-12-30   625   1.2    adopt to Rlink V4 attn logic
// 2014-12-25   621   1.1    adopt to 4k word ibus window
// 2014-06-14   562   1.0.1  Add stats
// 2013-04-20   508   1.0    Initial version
// 2013-02-10   485   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11CntlRK11.cpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation of Rw11CntlRK11.
*/

#include "boost/bind.hpp"
#include "boost/foreach.hpp"
#define foreach_ BOOST_FOREACH

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"

#include "Rw11CntlRK11.hpp"

using namespace std;

/*!
  \class Retro::Rw11CntlRK11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint16_t Rw11CntlRK11::kIbaddr;
const int      Rw11CntlRK11::kLam;

const uint16_t Rw11CntlRK11::kRKDS; 
const uint16_t Rw11CntlRK11::kRKER; 
const uint16_t Rw11CntlRK11::kRKCS; 
const uint16_t Rw11CntlRK11::kRKWC; 
const uint16_t Rw11CntlRK11::kRKBA; 
const uint16_t Rw11CntlRK11::kRKDA; 
const uint16_t Rw11CntlRK11::kRKMR; 

const uint16_t Rw11CntlRK11::kProbeOff;
const bool     Rw11CntlRK11::kProbeInt;
const bool     Rw11CntlRK11::kProbeRem;

const uint16_t Rw11CntlRK11::kRKDS_M_ID;
const uint16_t Rw11CntlRK11::kRKDS_V_ID;
const uint16_t Rw11CntlRK11::kRKDS_B_ID;
const uint16_t Rw11CntlRK11::kRKDS_M_HDEN;
const uint16_t Rw11CntlRK11::kRKDS_M_DRU;
const uint16_t Rw11CntlRK11::kRKDS_M_SIN;
const uint16_t Rw11CntlRK11::kRKDS_M_SOK;
const uint16_t Rw11CntlRK11::kRKDS_M_DRY;
const uint16_t Rw11CntlRK11::kRKDS_M_ADRY;
const uint16_t Rw11CntlRK11::kRKDS_M_WPS;
const uint16_t Rw11CntlRK11::kRKDS_B_SC;

const uint16_t Rw11CntlRK11::kRKER_M_DRE;
const uint16_t Rw11CntlRK11::kRKER_M_OVR;
const uint16_t Rw11CntlRK11::kRKER_M_WLO;
const uint16_t Rw11CntlRK11::kRKER_M_PGE;
const uint16_t Rw11CntlRK11::kRKER_M_NXM;
const uint16_t Rw11CntlRK11::kRKER_M_NXD;
const uint16_t Rw11CntlRK11::kRKER_M_NXC;
const uint16_t Rw11CntlRK11::kRKER_M_NXS;
const uint16_t Rw11CntlRK11::kRKER_M_CSE;
const uint16_t Rw11CntlRK11::kRKER_M_WCE;

const uint16_t Rw11CntlRK11::kRKCS_M_MAINT;
const uint16_t Rw11CntlRK11::kRKCS_M_IBA;
const uint16_t Rw11CntlRK11::kRKCS_M_FMT;
const uint16_t Rw11CntlRK11::kRKCS_M_RWA;
const uint16_t Rw11CntlRK11::kRKCS_M_SSE;
const uint16_t Rw11CntlRK11::kRKCS_M_RDY;
const uint16_t Rw11CntlRK11::kRKCS_M_MEX;
const uint16_t Rw11CntlRK11::kRKCS_V_MEX;
const uint16_t Rw11CntlRK11::kRKCS_B_MEX;
const uint16_t Rw11CntlRK11::kRKCS_V_FUNC;
const uint16_t Rw11CntlRK11::kRKCS_B_FUNC;
const uint16_t Rw11CntlRK11::kRKCS_M_GO;

const uint16_t Rw11CntlRK11::kFUNC_CRESET;
const uint16_t Rw11CntlRK11::kFUNC_WRITE;
const uint16_t Rw11CntlRK11::kFUNC_READ;
const uint16_t Rw11CntlRK11::kFUNC_WCHK;
const uint16_t Rw11CntlRK11::kFUNC_SEEK;
const uint16_t Rw11CntlRK11::kFUNC_RCHK;
const uint16_t Rw11CntlRK11::kFUNC_DRESET;
const uint16_t Rw11CntlRK11::kFUNC_WLOCK;

const uint16_t Rw11CntlRK11::kRKDA_M_DRSEL;
const uint16_t Rw11CntlRK11::kRKDA_V_DRSEL;
const uint16_t Rw11CntlRK11::kRKDA_B_DRSEL;
const uint16_t Rw11CntlRK11::kRKDA_M_CYL;
const uint16_t Rw11CntlRK11::kRKDA_V_CYL;
const uint16_t Rw11CntlRK11::kRKDA_B_CYL;
const uint16_t Rw11CntlRK11::kRKDA_M_SUR;
const uint16_t Rw11CntlRK11::kRKDA_V_SUR;
const uint16_t Rw11CntlRK11::kRKDA_B_SUR;
const uint16_t Rw11CntlRK11::kRKDA_B_SC;

const uint16_t Rw11CntlRK11::kRKMR_M_RID;
const uint16_t Rw11CntlRK11::kRKMR_V_RID;
const uint16_t Rw11CntlRK11::kRKMR_M_CRDONE;
const uint16_t Rw11CntlRK11::kRKMR_M_SBCLR;
const uint16_t Rw11CntlRK11::kRKMR_M_CRESET;
const uint16_t Rw11CntlRK11::kRKMR_M_FDONE;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11CntlRK11::Rw11CntlRK11()
  : Rw11CntlBase<Rw11UnitRK11,8>("rk11"),
    fPC_rkwc(0),
    fPC_rkba(0),
    fPC_rkda(0),
    fPC_rkmr(0),
    fPC_rkcs(0),
    fRd_rkcs(0),
    fRd_rkda(0),
    fRd_addr(0),
    fRd_lba(0),
    fRd_nwrd(0),
    fRd_fu(0),
    fRd_ovr(false),
    fRdma(this,
          boost::bind(&Rw11CntlRK11::RdmaPreExecCB,  this, _1, _2, _3, _4),
          boost::bind(&Rw11CntlRK11::RdmaPostExecCB, this, _1, _2, _3, _4))
{
  // must be here because Units have a back-ptr (not available at Rw11CntlBase)
  for (size_t i=0; i<NUnit(); i++) {
    fspUnit[i].reset(new Rw11UnitRK11(this, i));
  }

  fStats.Define(kStatNFuncCreset , "NFuncCreset"  , "func CRESET");
  fStats.Define(kStatNFuncWrite  , "NFuncWrite"   , "func WRITE");
  fStats.Define(kStatNFuncRead   , "NFuncRead"    , "func READ");
  fStats.Define(kStatNFuncWchk   , "NFuncWchk"    , "func WCHK");
  fStats.Define(kStatNFuncSeek   , "NFuncSeek"    , "func SEEK");
  fStats.Define(kStatNFuncRchk   , "NFuncRchk"    , "func RCHK");
  fStats.Define(kStatNFuncDreset , "NFuncDreset"  , "func DRESET");
  fStats.Define(kStatNFuncWlock  , "NFuncWlock "  , "func WLOCK");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11CntlRK11::~Rw11CntlRK11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::Config(const std::string& name, uint16_t base, int lam)
{
  ConfigCntl(name, base, lam, kProbeOff, kProbeInt, kProbeRem);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::Start()
{
  if (fStarted || fLam<0 || !fEnable || !fProbe.Found())
    throw Rexception("Rw11CntlRK11::Start",
                     "Bad state: started, no lam, not enable, not found");

  // add device register address ibus and rbus mappings
  // done here because now Cntl bound to Cpu and Cntl probed
  Cpu().AllIAddrMapInsert(Name()+".ds", Base() + kRKDS);
  Cpu().AllIAddrMapInsert(Name()+".er", Base() + kRKER);
  Cpu().AllIAddrMapInsert(Name()+".cs", Base() + kRKCS);
  Cpu().AllIAddrMapInsert(Name()+".wc", Base() + kRKWC);
  Cpu().AllIAddrMapInsert(Name()+".ba", Base() + kRKBA);
  Cpu().AllIAddrMapInsert(Name()+".da", Base() + kRKDA);
  Cpu().AllIAddrMapInsert(Name()+".mr", Base() + kRKMR);

  // setup primary info clist
  fPrimClist.Clear();
  fPrimClist.AddAttn();
  fPC_rkwc = Cpu().AddRibr(fPrimClist, fBase+kRKWC);
  fPC_rkba = Cpu().AddRibr(fPrimClist, fBase+kRKBA);
  fPC_rkda = Cpu().AddRibr(fPrimClist, fBase+kRKDA);
  fPC_rkmr = Cpu().AddRibr(fPrimClist, fBase+kRKMR); // read to monitor CRDONE
  fPC_rkcs = Cpu().AddRibr(fPrimClist, fBase+kRKCS);

  // add attn handler
  Server().AddAttnHandler(boost::bind(&Rw11CntlRK11::AttnHandler, this, _1), 
                          uint16_t(1)<<fLam, (void*)this);

  fStarted = true;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::UnitSetup(size_t ind)
{
  Rw11UnitRK11& unit = *fspUnit[ind];
  Rw11Cpu& cpu  = Cpu();
  RlinkCommandList clist;

  uint16_t rkds = ind<<kRKDS_V_ID;
  if (unit.Virt()) {                        // file attached
    rkds |= kRKDS_M_HDEN;                   // always high density
    rkds |= kRKDS_M_SOK;                    // always sector counter OK ?FIXME?
    rkds |= kRKDS_M_DRY;                    // drive available
    rkds |= kRKDS_M_ADRY;                   // access available
    if (unit.WProt())                       // in case write protected
      rkds |= kRKDS_M_WPS;
  }
  unit.SetRkds(rkds);
  cpu.AddWibr(clist, fBase+kRKDS, rkds);
  Server().Exec(clist);

  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11CntlRK11::BootCode(size_t unit, std::vector<uint16_t>& code, 
                            uint16_t& aload, uint16_t& astart)
{
  uint16_t kBOOT_START = 02000;
  uint16_t bootcode[] = {      // rk11 boot loader - from simh pdp11_rk.c (v3.9)
    0042113,                   // "KD"
    0012706, kBOOT_START,      // MOV #boot_start, SP
    0012700, uint16_t(unit),   // MOV #unit, R0        ; unit number
    0010003,                   // MOV R0, R3
    0000303,                   // SWAB R3
    0006303,                   // ASL R3
    0006303,                   // ASL R3
    0006303,                   // ASL R3
    0006303,                   // ASL R3
    0006303,                   // ASL R3
    0012701, 0177412,          // MOV #RKDA, R1        ; rkda
    0010311,                   // MOV R3, (R1)         ; load da
    0005041,                   // CLR -(R1)            ; clear ba
    0012741, 0177000,          // MOV #-256.*2, -(R1)  ; load wc
    0012741, 0000005,          // MOV #READ+GO, -(R1)  ; read & go
    0005002,                   // CLR R2
    0005003,                   // CLR R3
    0012704, uint16_t(kBOOT_START+020),  // MOV #START+20, R4 ; ?? unclear ??
    0005005,                   // CLR R5
    0105711,                   // TSTB (R1)
    0100376,                   // BPL .-4
    0105011,                   // CLRB (R1)
    0005007                    // CLR PC     (5007)
  };
  
  code.clear();
  foreach_ (uint16_t& w, bootcode) code.push_back(w); 
  aload  = kBOOT_START;
  astart = kBOOT_START+2;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlRK11 @ " << this << endl;
  os << bl << "  fPC_rkwc:        " << fPC_rkwc << endl;
  os << bl << "  fPC_rkba:        " << fPC_rkba << endl;
  os << bl << "  fPC_rkda:        " << fPC_rkda << endl;
  os << bl << "  fPC_rkmr:        " << fPC_rkmr << endl;
  os << bl << "  fPC_rkcs:        " << fPC_rkcs << endl;
  os << bl << "  fRd_rkcs:        " << fRd_rkcs << endl;
  os << bl << "  fRd_rkda:        " << fRd_rkda << endl;
  os << bl << "  fRd_addr:        " << fRd_addr << endl;
  os << bl << "  fRd_lba:         " << fRd_lba  << endl;
  os << bl << "  fRd_nwrd:        " << fRd_nwrd << endl;
  os << bl << "  fRd_fu:          " << fRd_fu  << endl;
  os << bl << "  fRd_ovr:         " << fRd_ovr  << endl;
  fRdma.Dump(os, ind+2, "fRdma: ");
  Rw11CntlBase<Rw11UnitRK11,8>::Dump(os, ind, " ^");
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11CntlRK11::AttnHandler(RlinkServer::AttnArgs& args)
{
  fStats.Inc(kStatNAttnHdl);
  Server().GetAttnInfo(args, fPrimClist);

  uint16_t rkwc = fPrimClist[fPC_rkwc].Data();
  uint16_t rkba = fPrimClist[fPC_rkba].Data();
  uint16_t rkda = fPrimClist[fPC_rkda].Data();
  //uint16_t rkmr = fPrimClist[fPC_rkmr].Data();
  uint16_t rkcs = fPrimClist[fPC_rkcs].Data();

  uint16_t se   =  rkda                 & kRKDA_B_SC;
  uint16_t hd   = (rkda>>kRKDA_V_SUR)   & kRKDA_B_SUR;
  uint16_t cy   = (rkda>>kRKDA_V_CYL)   & kRKDA_B_CYL;
  uint16_t dr   = (rkda>>kRKDA_V_DRSEL) & kRKDA_B_DRSEL;
 
  bool go       =  rkcs & kRKCS_M_GO;
  uint16_t fu   = (rkcs>>kRKCS_V_FUNC)  & kRKCS_B_FUNC;
  uint16_t mex  = (rkcs>>kRKCS_V_MEX)   & kRKCS_B_MEX;
  uint32_t addr = uint32_t(mex)<<16 | uint32_t(rkba);

  // Note: apparently are operands first promoted to 32 bit -> mask after ~ !
  uint32_t nwrd = (~uint32_t(rkwc)&0xffff) + 1; // transfer size in words

  if (!go) {
    RlogMsg lmsg(LogFile());
    lmsg << "-I RK11 cs=" << RosPrintBvi(rkcs,8)
         << "  go=0, spurious attn, dropped";
    return 0;
  }
  
  // all 8 units are always available, but check anyway
  if (dr > NUnit())
    throw Rexception("Rw11CntlRK11::AttnHandler","Bad state: dr > NUnit()");

  Rw11UnitRK11& unit = *fspUnit[dr];
  Rw11Cpu& cpu = Cpu();
  RlinkCommandList clist;

  uint32_t lba  = unit.Chs2Lba(cy,hd,se);
  uint32_t nblk = unit.Nwrd2Nblk(nwrd);

  uint16_t rker = 0;
  uint16_t rkds = unit.Rkds();

  if (fTraceLevel>0) {
    RlogMsg lmsg(LogFile());
    static const char* fumnemo[8] = {"cr","w ","r ","wc","sk","rc","dr","wl"};
    
    lmsg << "-I RK11 cs=" << RosPrintBvi(rkcs,8)
         << " da=" << RosPrintBvi(rkda,8)
         << " ad=" << RosPrintBvi(addr,8,18)
         << " fu=" << fumnemo[fu&0x7]
         << " pa=" << dr 
         << "," << RosPrintf(cy,"d",3) 
         << "," << hd 
         << "," << RosPrintf(se,"d",2)
         << " la,nw=" << RosPrintf(lba,"d",4) 
         << "," << RosPrintf(nwrd,"d",5);
  }

  // check for spurious interrupts (either RDY=1 or RDY=0 and rdma busy)
  if ((rkcs & kRKCS_M_RDY) || fRdma.IsActive()) {
    RlogMsg lmsg(LogFile());
    lmsg << "-E RK11   err "
         << " cr=" << RosPrintBvi(rkcs,8)
         << " spurious lam: "
         << (fRdma.IsActive() ? "RDY=0 and Rdma busy" : "RDY=1");
    return 0;
  }

  // check for general abort conditions
  if (fu != kFUNC_CRESET &&                 // function not control reset
      (!unit.Virt())) {                     //   and drive not attached
    rker = kRKER_M_NXD;                     //   --> abort with NXD error

  } else if (fu != kFUNC_WRITE &&           // function neither write
             fu != kFUNC_READ &&            //   nor read
             (rkcs & (kRKCS_M_FMT|kRKCS_M_RWA))) { // and FMT or RWA set 
    rker = kRKER_M_PGE;                     //   --> abort with PGE error
  } else if (rkcs & kRKCS_M_RWA) {          // RWA not supported
    rker = kRKER_M_DRE;                     //   --> abort with DRE error
  }
  
  if (rker) {
    cpu.AddWibr(clist, fBase+kRKER, rker);
    if (fu == kFUNC_SEEK || fu == kFUNC_DRESET) 
      cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_SBCLR | (1u<<dr));
    cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
    LogRker(rker);
    Server().Exec(clist);
    return 0;
  }

  // check for overrun (read/write beyond cylinder 203)
  // if found, truncate request length
  bool ovr = lba + nblk > unit.NBlock();
  if (ovr) nwrd = (unit.NBlock()-lba) * (unit.BlockSize()/2);

  // remember request parameters for call back
  fRd_rkcs  = rkcs;
  fRd_rkda  = rkda;
  fRd_addr  = addr;
  fRd_lba   = lba;
  fRd_nwrd  = nwrd;
  fRd_ovr   = ovr;
  fRd_fu    = fu;

  // now handle the functions
  if (fu == kFUNC_CRESET) {                 // Control reset -----------------
    fStats.Inc(kStatNFuncCreset);
    cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_CRESET);

  } else if (fu == kFUNC_WRITE) {           // Write -------------------------
                                            //   Note: WRITE+FMT is just WRITE
    fStats.Inc(kStatNFuncWrite);
    if (se >= unit.NSector())   rker |= kRKER_M_NXS;
    if (cy >= unit.NCylinder()) rker |= kRKER_M_NXC;
    if (unit.WProt())           rker |= kRKER_M_WLO;
    if (rkcs & kRKCS_M_IBA) rker |= kRKER_M_DRE;  // IBA not supported
    if (rker) {
      AddErrorExit(clist, rker);
    } else {
      fRdma.QueueDiskWrite(addr, nwrd, 
                           Rw11Cpu::kCPAH_M_22BIT|Rw11Cpu::kCPAH_M_UBMAP,
                           lba, &unit);
    }

  } else if (fu == kFUNC_READ) {            // Read --------------------------
    fStats.Inc(kStatNFuncRead);
    if (se >= unit.NSector())   rker |= kRKER_M_NXS;
    if (cy >= unit.NCylinder()) rker |= kRKER_M_NXC;
    if (rkcs & kRKCS_M_IBA) rker |= kRKER_M_DRE;  // IBA not supported
    if (rker) {
      AddErrorExit(clist, rker);
    } else {
      fRdma.QueueDiskRead(addr, nwrd, 
                          Rw11Cpu::kCPAH_M_22BIT|Rw11Cpu::kCPAH_M_UBMAP,
                          lba, &unit);
    }

  } else if (fu == kFUNC_WCHK) {            // Write Check -------------------
    fStats.Inc(kStatNFuncWchk);
    if (se >= unit.NSector())   rker |= kRKER_M_NXS;
    if (cy >= unit.NCylinder()) rker |= kRKER_M_NXC;
    if (rkcs & kRKCS_M_IBA) rker |= kRKER_M_DRE;  // IBA not supported
    if (rker) {
      AddErrorExit(clist, rker);
    } else {
      fRdma.QueueDiskWriteCheck(addr, nwrd, 
                                Rw11Cpu::kCPAH_M_22BIT|Rw11Cpu::kCPAH_M_UBMAP,
                                lba, &unit);
    }

  } else if (fu == kFUNC_SEEK) {            // Seek --------------------------
    fStats.Inc(kStatNFuncSeek);
    if (se >= unit.NSector())   rker |= kRKER_M_NXS;
    if (cy >= unit.NCylinder()) rker |= kRKER_M_NXC;
    if (rker) {
      cpu.AddWibr(clist, fBase+kRKER, rker);
      cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_SBCLR | (1u<<dr));
      cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
      LogRker(rker);
    } else {
      cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
      rkds &= ~kRKDS_B_SC;                  // replace current sector number
      rkds |= se;
      unit.SetRkds(rkds);
      cpu.AddWibr(clist, fBase+kRKDS, rkds);
      cpu.AddWibr(clist, fBase+kRKMR, 1u<<dr); // issue seek done
    }

  } else if (fu == kFUNC_RCHK) {            // Read Check --------------------
    fStats.Inc(kStatNFuncRchk);
    if (se >= unit.NSector())   rker |= kRKER_M_NXS;
    if (cy >= unit.NCylinder()) rker |= kRKER_M_NXC;
    if (rkcs & kRKCS_M_IBA) rker |= kRKER_M_DRE;  // IBA not supported
    if (rker) {
      AddErrorExit(clist, rker);
    } else {
      AddNormalExit(clist, nwrd, 0);        // no action, virt disks don't err
    }
    
  } else if (fu == kFUNC_DRESET) {          // Drive Reset -------------------
    fStats.Inc(kStatNFuncDreset);
    cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
    cpu.AddWibr(clist, fBase+kRKMR, 1u<<dr);   // issue seek done
    
  } else if (fu == kFUNC_WLOCK) {           // Write Lock --------------------
    fStats.Inc(kStatNFuncWlock);
    rkds |= kRKDS_M_WPS;                    // set RKDS write protect flag
    unit.SetRkds(rkds);
    unit.SetWProt(true);
    cpu.AddWibr(clist, fBase+kRKDS, rkds);
    cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
  }

  if (clist.Size()) {                       // if handled directly
    Server().Exec(clist);                   // doit
  }
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::RdmaPreExecCB(int stat, size_t nwdone, size_t nwnext,
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

void Rw11CntlRK11::RdmaPostExecCB(int stat, size_t ndone,
                                  RlinkCommandList& clist, size_t ncmd)
{
  if (stat == Rw11Rdma::kStatusBusy) return;

  uint16_t rker = 0;

  // handle write check
  if (fRd_fu == kFUNC_WCHK) {
    size_t nwcok = fRdma.WriteCheck(ndone);
    if (nwcok != ndone) {                   // if mismatch found
      rker |= kRKER_M_WCE;                  // set error flag
      if (fRd_rkcs & kRKCS_M_SSE) {         // if 'stop-on-soft' requested
        ndone = nwcok;                      // truncate word count
      }
    }
  }
  
  // handle Rdma aborts
  if (stat == Rw11Rdma::kStatusFailRdma) rker |= kRKER_M_NXM;

  // check for fused csr updates
  if (clist.Size() > ncmd) {
    uint8_t  ccode = clist[ncmd].Command();
    uint16_t cdata = clist[ncmd].Data();
    if (ccode != RlinkCommand::kCmdLabo || (rker != 0 && cdata == 0))
      throw Rexception("Rw11CntlRK11::RdmaPostExecCB",
                       "Bad state: Labo not found or missed abort");
    if (cdata == 0) return;
  }

  // finally to RK11 register update
  RlinkCommandList clist1;
  AddNormalExit(clist1, ndone, rker);
  Server().Exec(clist1);

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::LogRker(uint16_t rker)
{
  RlogMsg lmsg(LogFile());
  lmsg << "-E RK11 er=" << RosPrintBvi(rker,8) << "  ERROR ABORT";
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::AddErrorExit(RlinkCommandList& clist, uint16_t rker)
{
  Rw11Cpu& cpu = Cpu();
  cpu.AddWibr(clist, fBase+kRKER, rker);
  cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);
  LogRker(rker);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11CntlRK11::AddNormalExit(RlinkCommandList& clist, size_t ndone,
                                 uint16_t rker)
{
  Rw11Cpu& cpu  = Cpu();
  uint16_t dr   = (fRd_rkda>>kRKDA_V_DRSEL) & kRKDA_B_DRSEL;
  Rw11UnitRK11& unit = *fspUnit[dr];

  size_t nblk   = unit.Nwrd2Nblk(ndone);

  uint32_t addr = fRd_addr + 2*ndone;
  size_t   lba  = fRd_lba  + nblk;
  uint32_t nrest = fRd_nwrd - ndone;

  uint16_t ba   = addr & 0177776;           // get lower 16 bits
  uint16_t mex  = (addr>>16) & 03;          // get upper  2 bits
  uint16_t cs   = (fRd_rkcs & ~kRKCS_M_MEX) | (mex << kRKCS_V_MEX);
  uint16_t se;
  uint16_t hd;
  uint16_t cy;
  unit.Lba2Chs(lba, cy,hd,se);
  uint16_t da   = (fRd_rkda & kRKDA_M_DRSEL) | (cy<<kRKDA_V_CYL) |
                  (hd<<kRKDA_V_SUR) | se;

  if (fRd_ovr) rker |= kRKER_M_OVR;

  if (rker) {
    cpu.AddWibr(clist, fBase+kRKER, rker);
    LogRker(rker);
  }
  cpu.AddWibr(clist, fBase+kRKWC, uint16_t((-nrest)&0177777));
  cpu.AddWibr(clist, fBase+kRKBA, ba);
  cpu.AddWibr(clist, fBase+kRKDA, da);
  if (cs != fRd_rkcs) 
    cpu.AddWibr(clist, fBase+kRKCS, cs);
  cpu.AddWibr(clist, fBase+kRKMR, kRKMR_M_FDONE);

  return;
}


} // end namespace Retro
