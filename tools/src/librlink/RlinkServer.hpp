// $Id: RlinkServer.hpp 632 2015-01-11 12:30:03Z mueller $
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
// 2015-01-10   632   2.2    Exec() without emsg now void, will throw
// 2014-12-30   625   2.1    adopt to Rlink V4 attn logic
// 2014-11-30   607   2.0    re-organize for rlink v4
// 2013-05-01   513   1.0.2  fTraceLevel now uint32_t
// 2013-04-21   509   1.0.1  add Resume(), reorganize server start handling
// 2013-03-06   495   1.0    Initial version
// 2013-01-12   474   0.5    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkServer.hpp 632 2015-01-11 12:30:03Z mueller $
  \brief   Declaration of class \c RlinkServer.
*/

#ifndef included_Retro_RlinkServer
#define included_Retro_RlinkServer 1

#include <poll.h>

#include <cstdint>
#include <vector>
#include <list>

#include "boost/utility.hpp"
#include "boost/thread/thread.hpp"
#include "boost/shared_ptr.hpp"

#include "librtools/Rstats.hpp"

#include "ReventFd.hpp"
#include "RlinkConnect.hpp"
#include "RlinkContext.hpp"
#include "RlinkServerEventLoop.hpp"

namespace Retro {

  class RlinkServer : private boost::noncopyable {
    public:

      struct AttnArgs {
        uint16_t    fAttnPatt;              //<! in: current attention pattern
        uint16_t    fAttnMask;              //<! in: handler attention mask
        uint16_t    fAttnHarvest;           //<! out: harvested attentions
        bool        fHarvestDone;           //<! out: set true when harvested
                    AttnArgs();
                    AttnArgs(uint16_t apatt, uint16_t amask);
      };

      typedef ReventLoop::pollhdl_t            pollhdl_t;
      typedef boost::function<int(AttnArgs&)>  attnhdl_t;
      typedef boost::function<int()>           actnhdl_t;

      explicit      RlinkServer();
      virtual      ~RlinkServer();

      void          SetConnect(const boost::shared_ptr<RlinkConnect>& spconn);
      const boost::shared_ptr<RlinkConnect>& ConnectSPtr() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;
      RlinkContext& Context();  

      bool          Exec(RlinkCommandList& clist, RerrMsg& emsg);
      void          Exec(RlinkCommandList& clist);

      void          AddAttnHandler(const attnhdl_t& attnhdl, uint16_t mask,
                                   void* cdata = nullptr);
      void          RemoveAttnHandler(uint16_t mask, void* cdata = nullptr);
      void          GetAttnInfo(AttnArgs& args, RlinkCommandList& clist);
      void          GetAttnInfo(AttnArgs& args);

      void          QueueAction(const actnhdl_t& actnhdl);

      void          AddPollHandler(const pollhdl_t& pollhdl,
                                   int fd, short events=POLLIN);
      bool          TestPollHandler(int fd, short events=POLLIN);
      void          RemovePollHandler(int fd, short events, bool nothrow=false);
      void          RemovePollHandler(int fd);

      void          Start();
      void          Stop();
      void          Resume();
      void          Wakeup();
      void          SignalAttnNotify(uint16_t apat);

      bool          IsActive() const;
      bool          IsActiveInside() const;
      bool          IsActiveOutside() const;

      void          SetTraceLevel(uint32_t level);
      uint32_t      TraceLevel() const;

      const Rstats& Stats() const;

      void          Print(std::ostream& os) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // statistics counter indices
      enum stats {
        kStatNEloopWait = 0,                //!< event loop turns (wait)
        kStatNEloopPoll,                    //!< event loop turns (poll)
        kStatNWakeupEvt,                    //!< Wakeup events
        kStatNRlinkEvt,                     //!< Rlink data events
        kStatNAttnHdl,                      //<! Attn handler calls
        kStatNAttnNoti,                     //<! Attn notifies processed
        kStatNAttnHarv,                     //<! Attn handler restarts
        kStatNAttn00,                       //!< Attn bit  0 set
        kStatNAttn01,                       //!< Attn bit  1 set
        kStatNAttn02,                       //!< Attn bit  2 set
        kStatNAttn03,                       //!< Attn bit  3 set
        kStatNAttn04,                       //!< Attn bit  4 set
        kStatNAttn05,                       //!< Attn bit  5 set
        kStatNAttn06,                       //!< Attn bit  6 set
        kStatNAttn07,                       //!< Attn bit  7 set
        kStatNAttn08,                       //!< Attn bit  8 set
        kStatNAttn09,                       //!< Attn bit  9 set
        kStatNAttn10,                       //!< Attn bit 10 set
        kStatNAttn11,                       //!< Attn bit 11 set
        kStatNAttn12,                       //!< Attn bit 12 set
        kStatNAttn13,                       //!< Attn bit 13 set
        kStatNAttn14,                       //!< Attn bit 14 set
        kStatNAttn15,                       //!< Attn bit 15 set
        kDimStat
      };

      friend class RlinkServerEventLoop;

    protected:
      void          StartOrResume(bool resume);
      bool          AttnPending() const;
      bool          ActnPending() const;
      void          CallAttnHandler();
      void          CallActnHandler();
      int           WakeupHandler(const pollfd& pfd);
      int           RlinkHandler(const pollfd& pfd);

    protected:
      struct AttnId {
        uint16_t    fMask;
        void*       fCdata;
                    AttnId();
                    AttnId(uint16_t mask, void* cdata);
        bool        operator==(const AttnId& rhs) const;
      };

      struct AttnDsc {
        attnhdl_t   fHandler;
        AttnId      fId;
                    AttnDsc();
                    AttnDsc(attnhdl_t hdl, const AttnId& id);
      };

      boost::shared_ptr<RlinkConnect>  fspConn;
      RlinkContext  fContext;               //!< default server context
      std::vector<AttnDsc>  fAttnDsc;
      std::list<actnhdl_t>  fActnList;
      ReventFd      fWakeupEvent;
      RlinkServerEventLoop fELoop;
      boost::thread fServerThread;
      uint16_t      fAttnPatt;              //!< current attn pattern
      uint16_t      fAttnNotiPatt;          //!< attn notifier pattern
      uint32_t      fTraceLevel;            //!< trace level
      Rstats        fStats;                 //!< statistics
};
  
} // end namespace Retro

#include "RlinkServer.ipp"

#endif
