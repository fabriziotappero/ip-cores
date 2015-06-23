// $Id: Rw11CntlRHRP.hpp 680 2015-05-14 13:29:46Z mueller $
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
  \version $Id: Rw11CntlRHRP.hpp 680 2015-05-14 13:29:46Z mueller $
  \brief   Declaration of class Rw11CntlRHRP.
*/

#ifndef included_Retro_Rw11CntlRHRP
#define included_Retro_Rw11CntlRHRP 1

#include "Rw11CntlBase.hpp"
#include "Rw11UnitRHRP.hpp"
#include "Rw11RdmaDisk.hpp"

namespace Retro {

  class Rw11CntlRHRP : public Rw11CntlBase<Rw11UnitRHRP,4> {
    public:

                    Rw11CntlRHRP();
                   ~Rw11CntlRHRP();

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
      static const uint16_t kIbaddr = 0176700; //!< RHRP default address
      static const int      kLam    = 6;       //!< RHRP default lam

      static const uint16_t kRPCS1 = 000; //!< RPCS1     reg offset
      static const uint16_t kRPWC  = 002; //!< RPWC      reg offset
      static const uint16_t kRPBA  = 004; //!< RPBA      reg offset
      static const uint16_t kRPDA  = 006; //!< RPDA      reg offset
      static const uint16_t kRPCS2 = 010; //!< RPCS2     reg offset
      static const uint16_t kRPDS  = 012; //!< RPDS      reg offset
      static const uint16_t kRPER1 = 014; //!< RPER1     reg offset
      static const uint16_t kRPAS  = 016; //!< RPAS      reg offset
      static const uint16_t kRPLA  = 020; //!< RPLA      reg offset
      static const uint16_t kRPDB  = 022; //!< RPDB      reg offset
      static const uint16_t kRPMR1 = 024; //!< RPMR1     reg offset
      static const uint16_t kRPDT  = 026; //!< RPDT      reg offset
      static const uint16_t kRPSN  = 030; //!< RPSN      reg offset
      static const uint16_t kRPOF  = 032; //!< RPOF      reg offset
      static const uint16_t kRPDC  = 034; //!< RPDC      reg offset
      static const uint16_t kRxM13 = 036; //!< MB reg 13 reg offset
      static const uint16_t kRxM14 = 040; //!< MB reg 14 reg offset
      static const uint16_t kRxM15 = 042; //!< MB reg 15 reg offset
      static const uint16_t kRPEC1 = 044; //!< RPEC1     reg offset
      static const uint16_t kRPEC2 = 046; //!< RPEC2     reg offset
      static const uint16_t kRPBAE = 050; //!< RPBAE     reg offset
      static const uint16_t kRPCS3 = 052; //!< RPCS3     reg offset

      static const uint16_t kProbeOff = kRPCS2;//!< probe address offset (rxcs2)
      static const bool     kProbeInt = true;  //!< probe int active
      static const bool     kProbeRem = true;  //!< probr rem active

      static const uint16_t kRPCS1_M_SC    = kWBit15;
      static const uint16_t kRPCS1_M_TRE   = kWBit14;
      static const uint16_t kRPCS1_M_DVA   = kWBit11;
      static const uint16_t kRPCS1_M_BAE   = 001400;
      static const uint16_t kRPCS1_V_BAE   =  8;
      static const uint16_t kRPCS1_B_BAE   = 0003;
      static const uint16_t kRPCS1_M_RDY   = kWBit07;
      static const uint16_t kRPCS1_M_IE    = kWBit06;
      static const uint16_t kRPCS1_V_FUNC  =  1;
      static const uint16_t kRPCS1_B_FUNC  = 0037;
      static const uint16_t kRPCS1_M_GO    = kWBit00;

      // only function codes handled in backend are defined
      static const uint16_t kFUNC_WCD    = 024; //!< func: write chk data 
      static const uint16_t kFUNC_WCHD   = 025; //!< func: write chk head&data 
      static const uint16_t kFUNC_WRITE  = 030; //!< func: write 
      static const uint16_t kFUNC_WHD    = 031; //!< func: write head&data
      static const uint16_t kFUNC_READ   = 034; //!< func: read
      static const uint16_t kFUNC_RHD    = 035; //!< func: read head&data
      // remote function codes
      static const uint16_t kRFUNC_WUNIT = 001; //!< rfunc: write runit
      static const uint16_t kRFUNC_CUNIT = 002; //!< rfunc: copy funit->runit
      static const uint16_t kRFUNC_DONE  = 003; //!< rfunc: done (set rdy)
      static const uint16_t kRFUNC_WIDLY = 004; //!< rfunc: write idly

      // cs1 usage or rem func=wunit
      static const uint16_t kRPCS1_V_RUNIT =  8;
      static const uint16_t kRPCS1_B_RUNIT = 0003;
      // cs1 usage or rem func=done
      static const uint16_t kRPCS1_M_RATA  = kWBit08;    
      // cs1 usage or rem func=widly
      static const uint16_t kRPCS1_V_RIDLY =  8;
      static const uint16_t kRPCS1_B_RIDLY = 0377;

      static const uint16_t kRPDA_V_TA   =  8;
      static const uint16_t kRPDA_B_TA   = 0037;
      static const uint16_t kRPDA_B_SA   = 0077;

      static const uint16_t kRPCS2_M_RWCO  = kWBit15;
      static const uint16_t kRPCS2_M_WCE   = kWBit14;
      static const uint16_t kRPCS2_M_NED   = kWBit12;
      static const uint16_t kRPCS2_M_NEM   = kWBit11;
      static const uint16_t kRPCS2_M_PGE   = kWBit10;
      static const uint16_t kRPCS2_M_MXF   = kWBit09;
      static const uint16_t kRPCS2_M_OR    = kWBit07;
      static const uint16_t kRPCS2_M_IR    = kWBit06;
      static const uint16_t kRPCS2_M_CLR   = kWBit05;
      static const uint16_t kRPCS2_M_PAT   = kWBit04;
      static const uint16_t kRPCS2_M_BAI   = kWBit03;
      static const uint16_t kRPCS2_M_UNIT2 = kWBit02;
      static const uint16_t kRPCS2_B_UNIT  = 0003;

      static const uint16_t kRPDS_M_ATA    = kWBit15;
      static const uint16_t kRPDS_M_ERP    = kWBit14;
      static const uint16_t kRPDS_M_MOL    = kWBit12;
      static const uint16_t kRPDS_M_WRL    = kWBit11;
      static const uint16_t kRPDS_M_LBT    = kWBit10;
      static const uint16_t kRPDS_M_DPR    = kWBit08;
      static const uint16_t kRPDS_M_DRY    = kWBit07;
      static const uint16_t kRPDS_M_VV     = kWBit06;
      static const uint16_t kRPDS_M_OM     = kWBit00;

      static const uint16_t kRPER1_M_UNS   = kWBit14;
      static const uint16_t kRPER1_M_WLE   = kWBit11;
      static const uint16_t kRPER1_M_IAE   = kWBit10;
      static const uint16_t kRPER1_M_AOE   = kWBit09;
      static const uint16_t kRPER1_M_RMR   = kWBit02;
      static const uint16_t kRPER1_M_ILF   = kWBit00;

      static const uint16_t kRPDC_B_CA     = 01777;

      static const uint16_t kRPCS3_M_IE        = kWBit06;
      static const uint16_t kRPCS3_M_RSEARDONE = kWBit03;
      static const uint16_t kRPCS3_M_RPACKDONE = kWBit02;
      static const uint16_t kRPCS3_M_RPOREDONE = kWBit01;
      static const uint16_t kRPCS3_M_RSEEKDONE = kWBit00;

    // statistics counter indices
      enum stats {
        kStatNFuncWchk = Rw11Cntl::kDimStat,
        kStatNFuncWrite,
        kStatNFuncRead,
        kStatNFuncSear,
        kStatNFuncPack,
        kStatNFuncPore,
        kStatNFuncSeek,
        kDimStat
      };    

    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
      void          RdmaPreExecCB(int stat, size_t nwdone, size_t nwnext,
                                  RlinkCommandList& clist);
      void          RdmaPostExecCB(int stat, size_t ndone,
                                   RlinkCommandList& clist, size_t ncmd);
      void          AddErrorExit(RlinkCommandList& clist, uint16_t rper1);
      void          AddNormalExit(RlinkCommandList& clist, size_t ndone,
                                  uint16_t rper1=0, uint16_t rpcs2=0);  

    protected:
      size_t        fPC_rpcs1;              //!< PrimClist: rpcs1 index
      size_t        fPC_rpcs2;              //!< PrimClist: rpcs2 index
      size_t        fPC_rpcs3;              //!< PrimClist: rpcs3 index
      size_t        fPC_rpwc;               //!< PrimClist: rpwc  index
      size_t        fPC_rpba;               //!< PrimClist: rpba  index
      size_t        fPC_rpbae;              //!< PrimClist: rpbae index
      size_t        fPC_cunit;              //!< PrimClist: copy unit
      size_t        fPC_rpds;               //!< PrimClist: rpds  index
      size_t        fPC_rpda;               //!< PrimClist: rpda  index
      size_t        fPC_rpdc;               //!< PrimClist: rpdc  index

      uint16_t      fRd_rpcs1;              //!< Rdma: request rpcs1
      uint16_t      fRd_rpcs2;              //!< Rdma: request rpcs2
      uint16_t      fRd_rpcs3;              //!< Rdma: request rpcs3
      uint16_t      fRd_rpwc;               //!< Rdma: request rpwc
      uint16_t      fRd_rpba;               //!< Rdma: request rpba
      uint16_t      fRd_rpbae;              //!< Rdma: request rpbae
      uint16_t      fRd_rpds;               //!< Rdma: request rpds
      uint16_t      fRd_rpda;               //!< Rdma: request rpda
      uint16_t      fRd_rpdc;               //!< Rdma: request rpdc
      uint32_t      fRd_addr;               //!< Rdma: current addr
      uint32_t      fRd_lba;                //!< Rdma: current lba
      uint32_t      fRd_nwrd;               //!< Rdma: current nwrd
      uint16_t      fRd_fu;                 //!< Rdma: request fu code
      bool          fRd_ovr;                //!< Rdma: overrun condition found
      Rw11RdmaDisk  fRdma;                  //!< Rdma controller
  };
  
} // end namespace Retro

#include "Rw11CntlRHRP.ipp"

#endif
