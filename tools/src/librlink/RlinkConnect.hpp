// $Id: RlinkConnect.hpp 666 2015-04-12 21:17:54Z mueller $
//
// Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-04-12   666   2.3    add LinkInit,LinkInitDone; transfer xon
// 2015-04-02   661   2.2    expect logic: stat expect in Command, invert mask
// 2015-01-06   631   2.1    full rlink v4 implementation
// 2014-12-25   621   2.0.2  Reorganize packet send/revd stats
// 2014-12-20   616   2.0.1  add BlockDone expect checks
// 2014-12-10   611   2.0    re-organize for rlink v4
// 2013-04-21   509   1.3.3  add SndAttn() method
// 2013-03-05   495   1.3.2  add Exec() without emsg (will send emsg to LogFile)
// 2013-03-01   493   1.3.1  add Server(Active..|SignalAttn)() methods
// 2013-02-23   492   1.3    use scoped_ptr for Port; Close allways allowed
//                           use RlinkContext, add Context(), Exec(..., cntx)
// 2013-02-22   491   1.2    use new RlogFile/RlogMsg interfaces
// 2013-02-03   481   1.1.3  add SetServer(),Server()
// 2013-01-13   474   1.1.2  add PollAttn() method
// 2011-11-28   434   1.1.1  struct LogOpts: use uint32_t for lp64 compatibility
// 2011-04-24   380   1.1    use boost::noncopyable (instead of private dcl's);
//                           use boost::(mutex&lock), implement Lockable IF
// 2011-04-22   379   1.0.1  add Lock(), Unlock()
// 2011-04-02   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkConnect.hpp 666 2015-04-12 21:17:54Z mueller $
  \brief   Declaration of class \c RlinkConnect.
*/

#ifndef included_Retro_RlinkConnect
#define included_Retro_RlinkConnect 1

#include <cstdint>
#include <string>
#include <vector>
#include <ostream>

#include "boost/utility.hpp"
#include "boost/thread/recursive_mutex.hpp"
#include "boost/shared_ptr.hpp"
#include "boost/scoped_ptr.hpp"

#include "librtools/RerrMsg.hpp"
#include "librtools/Rstats.hpp"
#include "librtools/RlogFile.hpp"

#include "RlinkPort.hpp"
#include "RlinkCommandList.hpp"
#include "RlinkPacketBufSnd.hpp"
#include "RlinkPacketBufRcv.hpp"
#include "RlinkAddrMap.hpp"
#include "RlinkContext.hpp"

#include "librtools/Rbits.hpp"

namespace Retro {

  class RlinkServer;                        // forw decl to avoid circular incl

  class RlinkConnect : public Rbits, private boost::noncopyable {
    public:

                    RlinkConnect();
                   ~RlinkConnect();

      bool          Open(const std::string& name, RerrMsg& emsg);
      void          Close();
      bool          IsOpen() const;
      RlinkPort*    Port() const;

      bool          LinkInit(RerrMsg& emsg);
      bool          LinkInitDone() const;
    
      RlinkContext& Context();  

      void          SetServer(RlinkServer* pserv);
      RlinkServer*  Server() const;
      bool          ServerActive() const;
      bool          ServerActiveInside() const;
      bool          ServerActiveOutside() const;

      // provide boost Lockable interface
      void          lock();
      bool          try_lock();
      void          unlock();

      bool          Exec(RlinkCommandList& clist, RerrMsg& emsg);
      bool          Exec(RlinkCommandList& clist, RlinkContext& cntx,
                         RerrMsg& emsg);
      void          Exec(RlinkCommandList& clist);
      void          Exec(RlinkCommandList& clist, RlinkContext& cntx);

      double        WaitAttn(double timeout, uint16_t& apat, RerrMsg& emsg);
      bool          SndOob(uint16_t addr, uint16_t data, RerrMsg& emsg);
      bool          SndAttn(RerrMsg& emsg);

      uint32_t      SysId() const;
      size_t        RbufSize() const;
      size_t        BlockSizeMax() const;
      size_t        BlockSizePrudent() const;

      bool          AddrMapInsert(const std::string& name, uint16_t addr);
      bool          AddrMapErase(const std::string& name);
      bool          AddrMapErase(uint16_t addr);
      void          AddrMapClear();
      const RlinkAddrMap& AddrMap() const;

      const Rstats& Stats() const;
      const Rstats& SndStats() const;
      const Rstats& RcvStats() const;

      void          SetLogBaseAddr(uint32_t base);
      void          SetLogBaseData(uint32_t base);
      void          SetLogBaseStat(uint32_t base);
      void          SetPrintLevel(uint32_t lvl);
      void          SetDumpLevel(uint32_t lvl);
      void          SetTraceLevel(uint32_t lvl);

      uint32_t      LogBaseAddr() const;
      uint32_t      LogBaseData() const;
      uint32_t      LogBaseStat() const;
      uint32_t      PrintLevel() const;
      uint32_t      DumpLevel() const;
      uint32_t      TraceLevel() const;

      bool          LogOpen(const std::string& name, RerrMsg& emsg);
      void          LogUseStream(std::ostream* pstr, 
                                 const std::string& name = "");
      RlogFile&     LogFile() const;
      const boost::shared_ptr<RlogFile>&   LogFileSPtr() const;

      void          SetLogFileName(const std::string& name);
      std::string   LogFileName() const;

      void          Print(std::ostream& os) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

      void          HandleUnsolicitedData();

    // some constants (also defined in cpp)
      static const uint16_t kRbaddr_RLCNTL = 0xffff; //!< rlink core reg RLCNTL
      static const uint16_t kRbaddr_RLSTAT = 0xfffe; //!< rlink core reg RLSTAT
      static const uint16_t kRbaddr_RLID1  = 0xfffd; //!< rlink core reg RLID1
      static const uint16_t kRbaddr_RLID0  = 0xfffc; //!< rlink core reg RLID0

      static const uint16_t kRLCNTL_M_AnEna = kWBit15;//!< RLCNTL: an  enable
      static const uint16_t kRLCNTL_M_AtoEna= kWBit14;//!< RLCNTL: ato enable
      static const uint16_t kRLCNTL_M_AtoVal= 0x00ff; //!< RLCNTL: ato value

      static const uint16_t kRLSTAT_V_LCmd  =  8;     //!< RLSTAT: lcmd
      static const uint16_t kRLSTAT_B_LCmd  = 0x00ff; //!< RLSTAT: lcmd
      static const uint16_t kRLSTAT_M_BAbo  = kWBit07;//!< RLSTAT: babo
      static const uint16_t kRLSTAT_M_RBSize= 0x0007; //!< RLSTAT: rbuf size

      static const uint16_t kSBCNTL_V_RLMON = 15; //!< SBCNTL: rlmon enable bit
      static const uint16_t kSBCNTL_V_RLBMON= 14; //!< SBCNTL: rlbmon enable bit
      static const uint16_t kSBCNTL_V_RBMON = 13; //!< SBCNTL: rbmon enable bit

      // space beyond data for rblk =  8 :cmd(1) cnt(2) dcnt(2) stat(1) crc(2)
      //                   and wblk =  3 :cmd(1) cnt(2)
      static const uint16_t kRbufBlkDelta=16; //!< rbuf needed for rblk or wblk
      // 512 byte are enough space for a prudent amount of non-blk commands
      static const uint16_t kRbufPrudentDelta=512; //!< Rbuf space reserve

    // statistics counter indices
      enum stats {
        kStatNExec = 0,                     //!< Exec() calls
        kStatNExecPart,                     //!< ExecPart() calls
        kStatNCmd,                          //!< commands executed
        kStatNRreg,                         //!< rreg commands
        kStatNRblk,                         //!< rblk commands
        kStatNWreg,                         //!< wreg commands
        kStatNWblk,                         //!< wblk commands
        kStatNLabo,                         //!< labo commands
        kStatNAttn,                         //!< attn commands
        kStatNInit,                         //!< init commands
        kStatNRblkWord,                     //!< words rcvd with rblk
        kStatNWblkWord,                     //!< words send with wblk
        kStatNExpData,                      //!< expect for data defined
        kStatNExpDone,                      //!< expect for done defined
        kStatNExpStat,                      //!< expect for stat explicit
        kStatNNoExpStat,                    //!< no expect for stat
        kStatNChkData,                      //!< expect data failed
        kStatNChkDone,                      //!< expect done failed
        kStatNChkStat,                      //!< expect stat failed
        kStatNSndOob,                       //!< SndOob() calls
        kStatNErrMiss,                      //!< decode: missing data
        kStatNErrCmd,                       //!< decode: command mismatch
        kStatNErrLen,                       //!< decode: length mismatch
        kStatNErrCrc,                       //!< decode: crc mismatch
        kDimStat
      };

    protected: 
      bool          ExecPart(RlinkCommandList& clist, size_t ibeg, size_t iend, 
                             RerrMsg& emsg);

      void          EncodeRequest(RlinkCommandList& clist, size_t ibeg, 
                                  size_t iend);
      int           DecodeResponse(RlinkCommandList& clist, size_t ibeg,
                                   size_t iend);
      bool          DecodeAttnNotify(uint16_t& apat);
      bool          ReadResponse(double timeout, RerrMsg& emsg);
      void          AcceptResponse();
      void          ProcessUnsolicitedData();
      void          ProcessAttnNotify();

    protected: 
      boost::scoped_ptr<RlinkPort> fpPort;  //!< ptr to port
      bool          fLinkInitDeferred;      //!< noinit attr seen on Open
      bool          fLinkInitDone;          //!< LinkInit done
      RlinkServer*  fpServ;                 //!< ptr to server (optional)
      uint8_t       fSeqNumber[8];          //!< command sequence number
      RlinkPacketBufSnd fSndPkt;            //!< send    packet buffer
      RlinkPacketBufRcv fRcvPkt;            //!< receive packet buffer
      RlinkContext  fContext;               //!< default context
      RlinkAddrMap  fAddrMap;               //!< name<->address mapping
      Rstats        fStats;                 //!< statistics
      uint32_t      fLogBaseAddr;           //!< log: base for addr
      uint32_t      fLogBaseData;           //!< log: base for data
      uint32_t      fLogBaseStat;           //!< log: base for stat
      uint32_t      fPrintLevel;            //!< print 0=off,1=err,2=chk,3=all
      uint32_t      fDumpLevel;             //!< dump  0=off,1=err,2=chk,3=all
      uint32_t      fTraceLevel;            //!< trace 0=off,1=buf,2=char
      boost::shared_ptr<RlogFile> fspLog;   //!< log file ptr
      boost::recursive_mutex fConnectMutex; //!< mutex to lock whole connect
      uint16_t      fAttnNotiPatt;          //!< attn notifier pattern
      double        fTsLastAttnNoti;        //!< time stamp last attn notify
      uint32_t      fSysId;                 //!< SYSID of connected device
      size_t        fRbufSize;              //!< Rbuf size (in bytes)
  };
  
} // end namespace Retro

#include "RlinkConnect.ipp"

#endif
