// $Id: Rw11CntlTM11.hpp 686 2015-06-04 21:08:08Z mueller $
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
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11CntlTM11.hpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Declaration of class Rw11CntlTM11.
*/

#ifndef included_Retro_Rw11CntlTM11
#define included_Retro_Rw11CntlTM11 1

#include "Rw11CntlBase.hpp"
#include "Rw11UnitTM11.hpp"
#include "Rw11Rdma.hpp"

namespace Retro {

  class Rw11CntlTM11 : public Rw11CntlBase<Rw11UnitTM11,4> {
    public:

                    Rw11CntlTM11();
                   ~Rw11CntlTM11();

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
      static const uint16_t kIbaddr = 0172520; //!< TM11 default address
      static const int      kLam    = 7;       //!< TM11 default lam

      static const uint16_t kTMSR = 000; //!< TMSR reg offset
      static const uint16_t kTMCR = 002; //!< TMCR reg offset
      static const uint16_t kTMBC = 004; //!< TMBC reg offset
      static const uint16_t kTMBA = 006; //!< TMBA reg offset
      static const uint16_t kTMDB = 010; //!< TMDB reg offset
      static const uint16_t kTMRL = 012; //!< TMRL reg offset

      static const uint16_t kProbeOff = kTMCR; //!< probe address offset (tmcr)
      static const bool     kProbeInt = true;  //!< probe int active
      static const bool     kProbeRem = true;  //!< probr rem active

      static const uint16_t kTMSR_M_ICMD = kWBit15; //!< ICMD: invalid cmd
      static const uint16_t kTMSR_M_EOF  = kWBit14; //!< EOF: end-of-file seen
      static const uint16_t kTMSR_M_PAE  = kWBit12; //!< PAE: parity error
      static const uint16_t kTMSR_M_EOT  = kWBit10; //!< EOT: end-of-tape seen
      static const uint16_t kTMSR_M_RLE  = kWBit09; //!< RLE: record lgth error
      static const uint16_t kTMSR_M_BTE  = kWBit08; //!< BTE: bad tape error
      static const uint16_t kTMSR_M_NXM  = kWBit07; //!< NXM: non-existant mem
      static const uint16_t kTMSR_M_ONL  = kWBit06; //!< ONL: online
      static const uint16_t kTMSR_M_BOT  = kWBit05; //!< BOT: at begin-of-tape
      static const uint16_t kTMSR_M_WRL  = kWBit02; //!< WRL: write locked
      static const uint16_t kTMSR_M_REW  = kWBit01; //!< REW: tape rewound
      static const uint16_t kTMSR_M_TUR  = kWBit00; //!< TUR: unit ready

      static const uint16_t kTMCR_V_ERR  = 15;
      static const uint16_t kTMCR_V_DEN  = 13;
      static const uint16_t kTMCR_B_DEN  = 0003;
      static const uint16_t kTMCR_V_UNIT =  8;
      static const uint16_t kTMCR_B_UNIT = 0007;
      static const uint16_t kTMCR_M_RDY  = kWBit07;
      static const uint16_t kTMCR_V_EA   =  4;
      static const uint16_t kTMCR_B_EA   = 0003;
      static const uint16_t kTMCR_V_FUNC =  1;
      static const uint16_t kTMCR_B_FUNC = 0007;
      static const uint16_t kTMCR_M_GO   = kWBit00;

      static const uint16_t kFUNC_UNLOAD = 0;
      static const uint16_t kFUNC_READ   = 1;
      static const uint16_t kFUNC_WRITE  = 2;
      static const uint16_t kFUNC_WEOF   = 3;
      static const uint16_t kFUNC_SFORW  = 4;
      static const uint16_t kFUNC_SBACK  = 5;
      static const uint16_t kFUNC_WEIRG  = 6;
      static const uint16_t kFUNC_REWIND = 7;
      // remote function codes
      static const uint16_t kRFUNC_WUNIT = 1;
      static const uint16_t kRFUNC_DONE  = 2;

      // cr usage or rem func=wunit
      static const uint16_t kTMCR_V_RUNIT  =  4;
      static const uint16_t kTMCR_B_RUNIT  = 0003;
      // cr usage or rem func=done
      static const uint16_t kTMCR_M_RICMD  = kWBit15;
      static const uint16_t kTMCR_M_RPAE   = kWBit12;
      static const uint16_t kTMCR_M_RRLE   = kWBit09;
      static const uint16_t kTMCR_M_RBTE   = kWBit08;
      static const uint16_t kTMCR_M_RNXM   = kWBit07;
      static const uint16_t kTMCR_M_REAENA = kWBit06;
      static const uint16_t kTMCR_V_REA    =  4;
      static const uint16_t kTMCR_B_REA    = 0003;

      // rem usage of TMRL (used to access unit specific TMSR fields)
      static const uint16_t kTMRL_M_EOF  = kWBit10; //!< EOF: end-of-file seen
      static const uint16_t kTMRL_M_EOT  = kWBit09; //!< EOT: end-of-tape seen
      static const uint16_t kTMRL_M_ONL  = kWBit08; //!< ONL: online
      static const uint16_t kTMRL_M_BOT  = kWBit07; //!< BOT: at begin-of-tape
      static const uint16_t kTMRL_M_WRL  = kWBit06; //!< WRL: write locked
      static const uint16_t kTMRL_M_REW  = kWBit05; //!< REW: tape rewinding

    // statistics counter indices
      enum stats {
        kStatNFuncUnload= Rw11Cntl::kDimStat, //!< func UNLOAD
        kStatNFuncRead,                     //!< func READ
        kStatNFuncWrite,                    //!< func WRITE
        kStatNFuncWeof,                     //!< func WEOF
        kStatNFuncSforw,                    //!< func SFORW
        kStatNFuncSback,                    //!< func SBACK
        kStatNFuncWrteg,                    //!< func WRTEG
        kStatNFuncRewind,                   //!< func REWIND
        kDimStat
      };    

    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
      void          RdmaPreExecCB(int stat, size_t nwdone, size_t nwnext,
                                  RlinkCommandList& clist);
      void          RdmaPostExecCB(int stat, size_t ndone,
                                   RlinkCommandList& clist, size_t ncmd);
      void          AddErrorExit(RlinkCommandList& clist, uint16_t tmcr);
      void          AddFastExit(RlinkCommandList& clist, int opcode, 
                                size_t ndone);
      void          AddNormalExit(RlinkCommandList& clist, size_t ndone,
                                  uint16_t tmcr=0);
      void          WriteLog(const char* func, RerrMsg&  emsg);

    protected:
      size_t        fPC_tmcr;               //!< PrimClist: tmcr index
      size_t        fPC_tmsr;               //!< PrimClist: tmsr index
      size_t        fPC_tmbc;               //!< PrimClist: tmbc index
      size_t        fPC_tmba;               //!< PrimClist: tmba index

      uint16_t      fRd_tmcr;               //!< Rdma: request tmcr
      uint16_t      fRd_tmsr;               //!< Rdma: request tmsr
      uint16_t      fRd_tmbc;               //!< Rdma: request tmbc
      uint16_t      fRd_tmba;               //!< Rdma: request tmba
      uint32_t      fRd_bc;                 //!< Rdma: request bc
      uint32_t      fRd_addr;               //!< Rdma: current addr
      uint32_t      fRd_nwrd;               //!< Rdma: current nwrd
      uint16_t      fRd_fu;                 //!< Rdma: request fu code
      int           fRd_opcode;             //!< Rdma: read opcode
      std::vector<uint16_t>  fBuf;          //!< data buffer
      Rw11Rdma      fRdma;                  //!< Rdma controller
  };
  
} // end namespace Retro

#include "Rw11CntlTM11.ipp"

#endif
