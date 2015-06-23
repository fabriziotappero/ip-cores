// $Id: Rw11CntlRL11.hpp 665 2015-04-07 07:13:49Z mueller $
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
// 2015-03-01   653   1.0    Initial version
// 2014-06-08   561   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11CntlRL11.hpp 665 2015-04-07 07:13:49Z mueller $
  \brief   Declaration of class Rw11CntlRL11.
*/

#ifndef included_Retro_Rw11CntlRL11
#define included_Retro_Rw11CntlRL11 1

#include "Rw11CntlBase.hpp"
#include "Rw11UnitRL11.hpp"
#include "Rw11RdmaDisk.hpp"

namespace Retro {

  class Rw11CntlRL11 : public Rw11CntlBase<Rw11UnitRL11,4> {
    public:

                    Rw11CntlRL11();
                   ~Rw11CntlRL11();

      void          Config(const std::string& name, uint16_t base, int lam);

      virtual void  Start();

      virtual bool  BootCode(size_t unit, std::vector<uint16_t>& code, 
                             uint16_t& aload, uint16_t& astart);

      virtual void  UnitSetup(size_t ind);

      void          SetChunkSize(size_t chunk);
      size_t        ChunkSize() const;

      const Rstats& RdmaStats() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants (also defined in cpp)
      static const uint16_t kIbaddr = 0174400; //!< RL11 default address
      static const int      kLam    = 5;       //!< RL11 default lam

      static const uint16_t kRLCS = 000; //!< RLCS reg offset
      static const uint16_t kRLBA = 002; //!< RLBA reg offset
      static const uint16_t kRLDA = 004; //!< RLDA reg offset
      static const uint16_t kRLMP = 006; //!< RLMP reg offset

      static const uint16_t kProbeOff = kRLCS; //!< probe address offset (rlcs)
      static const bool     kProbeInt = true;  //!< probe int active
      static const bool     kProbeRem = true;  //!< probr rem active

      static const uint16_t kRLCS_M_ERR   = kWBit15;
      static const uint16_t kRLCS_M_DE    = kWBit14;
      static const uint16_t kRLCS_V_E     = 10;
      static const uint16_t kRLCS_B_E     = 0017;
      static const uint16_t kRLCS_V_DS    = 8;
      static const uint16_t kRLCS_B_DS    = 0003;
      static const uint16_t kRLCS_M_CRDY  = kWBit07;
      static const uint16_t kRLCS_M_IE    = kWBit06;
      static const uint16_t kRLCS_M_BAE   = 000060;
      static const uint16_t kRLCS_V_BAE   = 4;
      static const uint16_t kRLCS_B_BAE   = 0003;
      static const uint16_t kRLCS_V_FUNC  = 1;
      static const uint16_t kRLCS_B_FUNC  = 0007;
      static const uint16_t kRLCS_M_DRDY  = kWBit00;

      static const uint16_t kFUNC_NOOP    = 0;         // done in ibdr
      static const uint16_t kFUNC_WCHK    = 1;
      static const uint16_t kFUNC_GS      = 2;         // done in ibdr 
      static const uint16_t kFUNC_SEEK    = 3;         // done in ibdr 
      static const uint16_t kFUNC_RHDR    = 4;
      static const uint16_t kFUNC_WRITE   = 5;
      static const uint16_t kFUNC_READ    = 6;
      static const uint16_t kFUNC_RNHC    = 7;

      static const uint16_t kERR_M_DE   = kWBit04; // drive error flag
      static const uint16_t kERR_OPI    = 1; // OPI Operation Incomplete
      static const uint16_t kERR_WCHK   = 2; // Read Data CRC or Write Check
      static const uint16_t kERR_HCRC   = 3; // Header CRC
      static const uint16_t kERR_DLATE  = 4; // Data Late
      static const uint16_t kERR_HNFND  = 5; // Header not found
      static const uint16_t kERR_NXM    = 8; // Non-Existant Memory

      // rem usage of rlcs
      static const uint16_t kRLCS_V_MPREM   = 11;
      static const uint16_t kRLCS_B_MPREM   = 0037;
      static const uint16_t kRLCS_V_MPLOC   =  8;
      static const uint16_t kRLCS_B_MPLOC   = 0007;
      static const uint16_t kRLCS_ENA_MPREM = kWBit05;
      static const uint16_t kRLCS_ENA_MPLOC = kWBit04;

      static const uint16_t kRFUNC_WCS    = 1;
      static const uint16_t kRFUNC_WMP    = 2;

      static const uint16_t kMPREM_M_MAP  = kWBit04;
      static const uint16_t kMPREM_M_SEQ  = kWBit03;
      static const uint16_t kMPREM_S_MP   = 0000;      // MP+STA+POS sequence
      static const uint16_t kMPREM_S_STA  = 0001;
      static const uint16_t kMPREM_S_POS  = 0002;

      static const uint16_t kMPREM_MP  = 0003; // mem: mp 
      static const uint16_t kMPREM_CRC = 0004; // mem: crc 
      static const uint16_t kMPREM_STA = 0010; // mem: sta array (4 units)
      static const uint16_t kMPREM_POS = 0014; // mem: pos array (4 units)

      static const uint16_t kMPREM_SEQ_MPSTAPOS = kMPREM_M_MAP|
                                                  kMPREM_M_SEQ|kMPREM_S_MP;

      static const uint16_t kMPLOC_MP   = 0000; // 000: return imem(mp)
      static const uint16_t kMPLOC_STA  = 0001; // 001: return sta(ds)
      static const uint16_t kMPLOC_POS  = 0002; // 010: return pos(ds)  -> ZERO
      static const uint16_t kMPLOC_ZERO = 0003; // 011: return 0        -> CRC
      static const uint16_t kMPLOC_CRC  = 0004; // 100: return imem(crc)

      static const uint16_t kRLDA_SE_M_DF  = 0177600;
      static const uint16_t kRLDA_SE_V_DF  =  7;
      static const uint16_t kRLDA_SE_B_DF  = 0777;
      static const uint16_t kRLDA_SE_M_HS  = kWBit04;
      static const uint16_t kRLDA_SE_M_DIR = kWBit02;
      static const uint16_t kRLDA_SE_X_MSK = 0000153;
      static const uint16_t kRLDA_SE_X_VAL = 0000001;

      static const uint16_t kRLDA_RW_M_CA  = 0177600;
      static const uint16_t kRLDA_RW_V_CA  =  7;
      static const uint16_t kRLDA_RW_B_CA  = 0777;
      static const uint16_t kRLDA_RW_M_HS  = kWBit06;
      static const uint16_t kRLDA_RW_V_HS  =  6;
      static const uint16_t kRLDA_RW_B_HS  = 001;
      static const uint16_t kRLDA_RW_B_SA  = 077;

      static const uint16_t kRLDA_GS_M_RST = kWBit03;
      static const uint16_t kRLDA_GS_X_MSK = 0000367;
      static const uint16_t kRLDA_GS_X_VAL = 0000003;

      static const uint16_t kSTA_M_WDE = kWBit15; // Write data error   - 0!
      static const uint16_t kSTA_M_CHE = kWBit14; // Current head error - 0!
      static const uint16_t kSTA_M_WL  = kWBit13; // Write lock
      static const uint16_t kSTA_M_STO = kWBit12; // Seek time out
      static const uint16_t kSTA_M_SPE = kWBit11; // Spin error 
      static const uint16_t kSTA_M_WGE = kWBit10; // Write gate error
      static const uint16_t kSTA_M_VCE = kWBit09; // Volume check
      static const uint16_t kSTA_M_DSE = kWBit08; // Drive select error
      static const uint16_t kSTA_M_DT  = kWBit07; // Drive type 1=RL02
      static const uint16_t kSTA_M_HS  = kWBit06; // Head select
      static const uint16_t kSTA_M_CO  = kWBit05; // Cover open
      static const uint16_t kSTA_M_HO  = kWBit04; // Heads out
      static const uint16_t kSTA_M_BH  = kWBit03; // Brush home         - 1!
      static const uint16_t kSTA_B_ST  = 0007;    // Drive state

      static const uint16_t kST_LOAD   = 0;     // Load(ing) cartidge -    used
      static const uint16_t kST_SPIN   = 1;     // Spin(ing) up       - !unused!
      static const uint16_t kST_BRUSH  = 2;     // Brush(ing) cycle   - !unused!
      static const uint16_t kST_HLOAD  = 3;     // Load(ing) heads    - !unused!
      static const uint16_t kST_SEEK   = 4;     // Seek(ing)          - ?maybe?
      static const uint16_t kST_LOCK   = 5;     // Lock(ed) on        -    used
      static const uint16_t kST_UNL    = 6;     // Unload(ing) heads  - !unused!
      static const uint16_t kST_DOWN   = 7;     // Spin(ing) down     - !unused!

    // statistics counter indices
      enum stats {
        kStatNFuncWchk = Rw11Cntl::kDimStat,
        kStatNFuncRhdr,
        kStatNFuncWrite,
        kStatNFuncRead,
        kStatNFuncRnhc,
        kDimStat
      };    

    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
      void          RdmaPreExecCB(int stat, size_t nwdone, size_t nwnext,
                                  RlinkCommandList& clist);
      void          RdmaPostExecCB(int stat, size_t ndone,
                                   RlinkCommandList& clist, size_t ncmd);
      void          LogRler(uint16_t rlerr);
      void          AddSetStatus(RlinkCommandList& clist, size_t ind, 
                                 uint16_t sta);
      void          AddSetPosition(RlinkCommandList& clist, size_t ind, 
                                   uint16_t pos);
      void          AddErrorExit(RlinkCommandList& clist, uint16_t rlerr);
      void          AddNormalExit(RlinkCommandList& clist, size_t ndone,
                                  uint16_t rlerr=0);  
      uint16_t      CalcCrc(size_t size, const uint16_t* data);

    protected:
      size_t        fPC_rlcs;               //!< PrimClist: rlcs index
      size_t        fPC_rlba;               //!< PrimClist: rlba index
      size_t        fPC_rlda;               //!< PrimClist: rlda index
      size_t        fPC_imp;                //!< PrimClist: imp  index
      size_t        fPC_wc;                 //!< PrimClist: wc   index
      size_t        fPC_sta;                //!< PrimClist: sta  index
      size_t        fPC_pos;                //!< PrimClist: pos  index

      uint16_t      fRd_rlcs;               //!< Rdma: request rlcs
      uint16_t      fRd_rlda;               //!< Rdma: request rlda
      uint16_t      fRd_rlmp;               //!< Rdma: request rlmp (~wc)
      uint16_t      fRd_sta;                //!< Rdma: initial drive status 
      uint16_t      fRd_pos;                //!< Rdma: initial drive position
      uint32_t      fRd_addr;               //!< Rdma: current addr
      uint32_t      fRd_lba;                //!< Rdma: current lba
      uint32_t      fRd_nwrd;               //!< Rdma: current nwrd
      uint16_t      fRd_fu;                 //!< Rdma: request fu code
      bool          fRd_ovr;                //!< Rdma: overrun condition found
      Rw11RdmaDisk  fRdma;                  //!< Rdma controller
  };
  
} // end namespace Retro

#include "Rw11CntlRL11.ipp"

#endif
