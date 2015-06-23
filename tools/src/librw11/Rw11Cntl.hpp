// $Id: Rw11Cntl.hpp 682 2015-05-15 18:35:29Z mueller $
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
// 2015-05-15   680   1.1.1  add NUnit() as virtual
// 2014-12-30   625   1.1    adopt to Rlink V4 attn logic
// 2013-03-06   495   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11Cntl.hpp 682 2015-05-15 18:35:29Z mueller $
  \brief   Declaration of class Rw11Cntl.
*/

#ifndef included_Retro_Rw11Cntl
#define included_Retro_Rw11Cntl 1

#include <string>

#include "boost/utility.hpp"

#include "librtools/Rstats.hpp"
#include "librlink/RlinkConnect.hpp"
#include "librlink/RlinkServer.hpp"
#include "Rw11Probe.hpp"

#include "librtools/Rbits.hpp"
#include "Rw11Cpu.hpp"

namespace Retro {

  class Rw11Cntl : public Rbits, private boost::noncopyable {
    public:

      explicit      Rw11Cntl(const std::string& type);
      virtual      ~Rw11Cntl();

      void          SetCpu(Rw11Cpu* pcpu);
      Rw11Cpu&      Cpu() const;
      Rw11&         W11() const;
      RlinkServer&  Server() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;

      const std::string&   Type() const;
      const std::string&   Name() const;
      uint16_t      Base() const;
      int           Lam() const;

      void          SetEnable(bool ena);
      bool          Enable() const;

      virtual bool  Probe();
      const Rw11Probe& ProbeStatus() const;

      virtual void  Start();
      bool          IsStarted() const;

      virtual size_t NUnit() const;
      virtual bool  BootCode(size_t unit, std::vector<uint16_t>& code, 
                             uint16_t& aload, uint16_t& astart);

      void          SetTraceLevel(uint32_t level);
      uint32_t      TraceLevel() const;

      std::string   UnitName(size_t index) const;

      const Rstats& Stats() const;
      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // statistics counter indices
      enum stats {
        kStatNAttnHdl = 0,
        kStatNAttnNoAct,
        kDimStat
      };    

    protected:
      void          ConfigCntl(const std::string& name, uint16_t base, int lam,
                               uint16_t probeoff, bool probeint, bool proberem);

    private:
                    Rw11Cntl() {}           //!< default ctor blocker

    protected:
      Rw11Cpu*      fpCpu;                  //!< cpu back pointer
      std::string   fType;                  //!< controller type
      std::string   fName;                  //!< controller name
      uint16_t      fBase;                  //!< controller base address
      int           fLam;                   //!< attn bit number (-1 of none)
      bool          fEnable;                //!< enable flag
      bool          fStarted;               //!< true if Start() called
      Rw11Probe     fProbe;                 //!< controller probe context
      uint32_t      fTraceLevel;            //!< trace level; 0=off;1=cntl
      RlinkCommandList fPrimClist;          //!< clist for attn primary info 
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "Rw11Cntl.ipp"

#endif
