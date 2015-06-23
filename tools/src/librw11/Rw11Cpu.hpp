// $Id: Rw11Cpu.hpp 675 2015-05-08 21:05:08Z mueller $
//
// Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-05-08   675   1.2.3  w11a start/stop/suspend overhaul
// 2015-04-25   668   1.2.2  add AddRbibr(), AddWbibr()
// 2015-04-03   661   1.2.1  add kStat_M_* defs
// 2015-03-21   659   1.2    add RAddrMap; add AllRAddrMapInsert();
// 2015-01-01   626   1.1    Adopt for rlink v4 and 4k ibus window; add IAddrMap
// 2013-04-14   506   1.0.1  add AddLalh(),AddRMem(),AddWMem()
// 2013-04-12   504   1.0    Initial version
// 2013-01-27   478   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11Cpu.hpp 675 2015-05-08 21:05:08Z mueller $
  \brief   Declaration of class Rw11Cpu.
*/

#ifndef included_Retro_Rw11Cpu
#define included_Retro_Rw11Cpu 1

#include <string>
#include <vector>

#include "boost/utility.hpp"
#include "boost/shared_ptr.hpp"
#include "boost/thread/locks.hpp"
#include "boost/thread/condition_variable.hpp"

#include "librtools/Rstats.hpp"
#include "librtools/RerrMsg.hpp"
#include "librlink/RlinkConnect.hpp"
#include "librlink/RlinkAddrMap.hpp"

#include "Rw11Probe.hpp"

#include "librtools/Rbits.hpp"
#include "Rw11.hpp"

namespace Retro {

  class Rw11Cntl;                           // forw decl to avoid circular incl

  class Rw11Cpu : public Rbits, private boost::noncopyable {
    public:
      typedef std::map<std::string, boost::shared_ptr<Rw11Cntl>> cmap_t;
      typedef cmap_t::iterator         cmap_it_t;
      typedef cmap_t::const_iterator   cmap_cit_t;
      typedef cmap_t::value_type       cmap_val_t;


      explicit      Rw11Cpu(const std::string& type);
      virtual      ~Rw11Cpu();

      void          Setup(Rw11* pw11);
      Rw11&         W11() const;
      RlinkServer&  Server() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;

      const std::string&   Type() const;
      size_t        Index() const;
      uint16_t      Base() const;
      uint16_t      IBase() const;

      void          AddCntl(const boost::shared_ptr<Rw11Cntl>& spcntl);
      bool          TestCntl(const std::string& name) const;
      void          ListCntl(std::vector<std::string>& list) const;
      Rw11Cntl&     Cntl(const std::string& name) const;

      void          Start();

      std::string   NextCntlName(const std::string& base) const;

      int           AddMembe(RlinkCommandList& clist, uint16_t be, 
                             bool stick=false);
      int           AddRibr(RlinkCommandList& clist, uint16_t ibaddr);
      int           AddWibr(RlinkCommandList& clist, uint16_t ibaddr,
                            uint16_t data);

      int           AddRbibr(RlinkCommandList& clist, uint16_t ibaddr, 
                             size_t size);
      int           AddWbibr(RlinkCommandList& clist, uint16_t ibaddr, 
                             std::vector<uint16_t> block);

      int           AddLalh(RlinkCommandList& clist, uint32_t addr, 
                            uint16_t mode=kCPAH_M_22BIT);
      int           AddRMem(RlinkCommandList& clist, uint32_t addr,
                            uint16_t* buf, size_t size, 
                            uint16_t mode=kCPAH_M_22BIT, 
                            bool singleblk=false);
      int           AddWMem(RlinkCommandList& clist, uint32_t addr,
                            const uint16_t* buf, size_t size, 
                            uint16_t mode=kCPAH_M_22BIT,
                            bool singleblk=false);

      bool          MemRead(uint16_t addr, std::vector<uint16_t>& data, 
                            size_t nword, RerrMsg& emsg);
      bool          MemWrite(uint16_t addr, const std::vector<uint16_t>& data,
                             RerrMsg& emsg);

      bool          ProbeCntl(Rw11Probe& dsc);

      bool          LoadAbs(const std::string& fname, RerrMsg& emsg,
                            bool trace=false);
      bool          Boot(const std::string& uname, RerrMsg& emsg);

      void          SetCpuGoUp();
      void          SetCpuGoDown(uint16_t stat);
      double        WaitCpuGoDown(double tout);
      bool          CpuGo() const;
      uint16_t      CpuStat() const;

      uint16_t      IbusRemoteAddr(uint16_t ibaddr) const;
      void          AllIAddrMapInsert(const std::string& name, uint16_t ibaddr);
      void          AllRAddrMapInsert(const std::string& name, uint16_t rbaddr);

      bool          IAddrMapInsert(const std::string& name, uint16_t ibaddr);
      bool          IAddrMapErase(const std::string& name);
      bool          IAddrMapErase(uint16_t ibaddr);
      void          IAddrMapClear();
      const RlinkAddrMap& IAddrMap() const;

      bool          RAddrMapInsert(const std::string& name, uint16_t rbaddr);
      bool          RAddrMapErase(const std::string& name);
      bool          RAddrMapErase(uint16_t rbaddr);
      void          RAddrMapClear();
      const RlinkAddrMap& RAddrMap() const;

      void          W11AttnHandler();

      const Rstats& Stats() const;
      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants (also defined in cpp)
      static const uint16_t  kCPCONF  = 0x0000; //!< CPCONF  reg offset
      static const uint16_t  kCPCNTL  = 0x0001; //!< CPADDR  reg offset
      static const uint16_t  kCPSTAT  = 0x0002; //!< CPSTAT  reg offset
      static const uint16_t  kCPPSW   = 0x0003; //!< CPPSW   reg offset
      static const uint16_t  kCPAL    = 0x0004; //!< CPAL    reg offset
      static const uint16_t  kCPAH    = 0x0005; //!< CPAH    reg offset
      static const uint16_t  kCPMEM   = 0x0006; //!< CPMEM   reg offset
      static const uint16_t  kCPMEMI  = 0x0007; //!< CPMEMI  reg offset
      static const uint16_t  kCPR0    = 0x0008; //!< CPR0    reg offset
      static const uint16_t  kCPPC    = 0x000f; //!< CPPC    reg offset
      static const uint16_t  kCPMEMBE = 0x0010; //!< CPMEMBE reg offset

      static const uint16_t  kCPFUNC_NOOP    = 0x0000; //!< 
      static const uint16_t  kCPFUNC_START   = 0x0001; //!< 
      static const uint16_t  kCPFUNC_STOP    = 0x0002; //!< 
      static const uint16_t  kCPFUNC_STEP    = 0x0003; //!< 
      static const uint16_t  kCPFUNC_CRESET  = 0x0004; //!< 
      static const uint16_t  kCPFUNC_BRESET  = 0x0005; //!<
      static const uint16_t  kCPFUNC_SUSPEND = 0x0006; //!<
      static const uint16_t  kCPFUNC_RESUME  = 0x0007; //!<

      static const uint16_t  kCPSTAT_M_SuspExt = kWBit09; //!<
      static const uint16_t  kCPSTAT_M_SuspInt = kWBit08; //!<
      static const uint16_t  kCPSTAT_M_CpuRust = 0x00f0;  //!<
      static const uint16_t  kCPSTAT_V_CpuRust = 4;       //!<
      static const uint16_t  kCPSTAT_B_CpuRust = 0x000f;  //!<
      static const uint16_t  kCPSTAT_M_CpuSusp = kWBit03; //!<
      static const uint16_t  kCPSTAT_M_CpuGo   = kWBit02; //!<
      static const uint16_t  kCPSTAT_M_CmdMErr = kWBit01; //!<
      static const uint16_t  kCPSTAT_M_CmdErr  = kWBit00; //!<

      static const uint16_t  kCPURUST_INIT   = 0x0;  //!< cpu in init state
      static const uint16_t  kCPURUST_HALT   = 0x1;  //!< cpu executed HALT
      static const uint16_t  kCPURUST_RESET  = 0x2;  //!< cpu was reset
      static const uint16_t  kCPURUST_STOP   = 0x3;  //!< cpu was stopped
      static const uint16_t  kCPURUST_STEP   = 0x4;  //!< cpu was stepped
      static const uint16_t  kCPURUST_SUSP   = 0x5;  //!< cpu was suspended
      static const uint16_t  kCPURUST_RUNS   = 0x7;  //!< cpu running
      static const uint16_t  kCPURUST_VECFET = 0x8;  //!< vector fetch halt
      static const uint16_t  kCPURUST_RECRSV = 0x9;  //!< rec red-stack halt
      static const uint16_t  kCPURUST_SFAIL  = 0xa;  //!< sequencer failure
      static const uint16_t  kCPURUST_VFAIL  = 0xb;  //!< vmbox failure

      static const uint16_t  kCPAH_M_ADDR  = 0x003f;  //!< 
      static const uint16_t  kCPAH_M_22BIT = kWBit06; //!< 
      static const uint16_t  kCPAH_M_UBMAP = kWBit07; //!<

      static const uint16_t  kCPMEMBE_M_STICK = kWBit02; //!< 
      static const uint16_t  kCPMEMBE_M_BE    = 0x0003;  //!< 

    // defs for the four status bits defined by w11 rbus iface
      static const uint8_t   kStat_M_CmdErr  = kBBit07; //!< stat: cmderr  flag
      static const uint8_t   kStat_M_CmdMErr = kBBit06; //!< stat: cmdmerr flag
      static const uint8_t   kStat_M_CpuHalt = kBBit05; //!< stat: cpuhalt flag
      static const uint8_t   kStat_M_CpuGo   = kBBit04; //!< stat: cpugo   flag

    private:
                    Rw11Cpu() {}            //!< default ctor blocker

    protected:
      Rw11*         fpW11;
      std::string   fType;
      size_t        fIndex;
      uint16_t      fBase;
      uint16_t      fIBase;
      bool          fCpuGo;
      uint16_t      fCpuStat;
      boost::mutex               fCpuGoMutex;
      boost::condition_variable  fCpuGoCond;
      cmap_t        fCntlMap;               //!< name->cntl map
      RlinkAddrMap  fIAddrMap;              //!< ibus name<->address mapping
      RlinkAddrMap  fRAddrMap;              //!< rbus name<->address mapping
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "Rw11Cpu.ipp"

#endif
