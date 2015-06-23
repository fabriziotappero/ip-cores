// $Id: ReventLoop.cpp 686 2015-06-04 21:08:08Z mueller $
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
// 2015-04-04   662   1.2    BUGFIX: fix race in Stop(), add UnStop,StopPending
// 2013-04-27   511   1.1.3  BUGFIX: logic in DoCall() fixed (loop range)
// 2013-03-05   495   1.1.2  add exception catcher to EventLoop
// 2013-03-01   493   1.1.1  DoCall(): remove handler on negative return
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2013-01-11   473   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: ReventLoop.cpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation of class ReventLoop.
*/

#include <string.h>
#include <poll.h>
#include <errno.h>

#include "boost/bind.hpp" 
#include "boost/thread/locks.hpp"

#include "librtools/Rexception.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosFill.hpp"
#include "librtools/RlogMsg.hpp"

#include "ReventLoop.hpp"

using namespace std;

/*!
  \class Retro::ReventLoop
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

ReventLoop::ReventLoop()
  : fStopPending(false),
    fUpdatePoll(false),
    fPollDscMutex(),
    fPollDsc(),
    fPollFd(),
    fPollHdl(),
    fTraceLevel(0),
    fspLog()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

ReventLoop::~ReventLoop()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

// by default handlers should start with: 
//     if (pfd.revents & (~pfd.events)) return -1;

void ReventLoop::AddPollHandler(const pollhdl_t& pollhdl,
                                int fd, short events)
{
  boost::lock_guard<boost::mutex> lock(fPollDscMutex);
  
  for (size_t i=0; i<fPollDsc.size(); i++) {
    if (fPollDsc[i].fFd     == fd &&
        fPollDsc[i].fEvents == events) {
      throw Rexception("ReventLoop::AddPollHandler()", 
                       "Bad args: duplicate handler");
    }
  }

  fPollDsc.push_back(PollDsc(pollhdl,fd,events));
  fUpdatePoll = true;

  if (fspLog && fTraceLevel >= 1) {
    RlogMsg lmsg(*fspLog, 'I');
    lmsg << "eloop: add handler: " << fd << "," << RosPrintf(events,"x");
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void ReventLoop::RemovePollHandler(int fd, short events, bool nothrow)
{
  boost::lock_guard<boost::mutex> lock(fPollDscMutex);

  for (size_t i=0; i<fPollDsc.size(); i++) {
    if (fPollDsc[i].fFd     == fd &&
        fPollDsc[i].fEvents == events) {
      fPollDsc.erase(fPollDsc.begin()+i);
      fUpdatePoll = true;
      if (fspLog && fTraceLevel >= 1) {
        RlogMsg lmsg(*fspLog, 'I');
        lmsg << "eloop: remove handler: " << fd << "," << RosPrintf(events,"x");
      }
      return;
    }
  }
  if (!nothrow) throw Rexception("ReventLoop::RemovePollHandler()", 
                                 "Bad args: unknown handler");
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool ReventLoop::TestPollHandler(int fd, short events)
{
  boost::lock_guard<boost::mutex> lock(fPollDscMutex);

  for (size_t i=0; i<fPollDsc.size(); i++) {
    if (fPollDsc[i].fFd     == fd &&
        fPollDsc[i].fEvents == events) {
      return true;
    }
  }
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void ReventLoop::RemovePollHandler(int fd)
{
  boost::lock_guard<boost::mutex> lock(fPollDscMutex);

  for (size_t i=0; i<fPollDsc.size(); i++) {
    if (fPollDsc[i].fFd == fd) {
      fPollDsc.erase(fPollDsc.begin()+i);
      fUpdatePoll = true;
      i--;                                  // re-probe this index
    }
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void ReventLoop::EventLoop()
{
  fUpdatePoll = true;

  try {
    while (!StopPending()) {   
      int irc = DoPoll();
      if (fPollFd.size() == 0) break;
      if (irc>0) DoCall();
    }
  } catch (exception& e) {
    if (fspLog) {
      RlogMsg lmsg(*fspLog, 'F');
      lmsg << "eloop: crashed with exception: " << e.what();
    }
    return; 
  }
 
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void ReventLoop::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "ReventLoop @ " << this << endl;
  os << bl << "  fStopPending:    " << fStopPending << endl;
  os << bl << "  fUpdatePoll:     " << fUpdatePoll << endl;
  {
    boost::lock_guard<boost::mutex> lock(((ReventLoop*)this)->fPollDscMutex);
    os << bl << "  fPollDsc.size    " << fPollDsc.size() << endl;
    os << bl << "  fPollFd.size     " << fPollFd.size()  << endl;
    os << bl << "  fPollHdl.size    " << fPollHdl.size() << endl;
    for (size_t i=0; i<fPollDsc.size(); i++) {
      os << bl << "    [" << RosPrintf(i,"d",3) << "]:"
         << " fd:" << RosPrintf(fPollDsc[i].fFd,"d",3)
         << " evt:" << RosPrintf(fPollDsc[i].fEvents,"x",2)
         << " hdl:" << (bool)fPollDsc[i].fHandler
         << endl;
    }
  }
  os << bl << "  fTraveLevel:     " << fTraceLevel << endl;
  os << bl << "  fspLog:          " << fspLog.get() << endl;
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int ReventLoop::DoPoll(int timeout)
{
  if (fUpdatePoll) {
    boost::lock_guard<boost::mutex> lock(fPollDscMutex);
    
    fPollFd.resize(fPollDsc.size());
    fPollHdl.resize(fPollDsc.size());
    for (size_t i=0; i<fPollDsc.size(); i++) {
      fPollFd[i].fd      = fPollDsc[i].fFd;
      fPollFd[i].events  = fPollDsc[i].fEvents;
      fPollFd[i].revents = 0;
      fPollHdl[i] = fPollDsc[i].fHandler;
    }
    fUpdatePoll = false;

    if (fspLog && fTraceLevel >= 1) {
      RlogMsg lmsg(*fspLog, 'I');
      lmsg << "eloop: redo pollfd list, size=" << fPollDsc.size() << endl;
    }
  }
  
  if (fPollFd.size() == 0) return 0;

  int irc = poll(fPollFd.data(), fPollFd.size(), timeout);
  if (irc < 0 && errno == EINTR) return 0;
  if (irc < 0) 
    throw Rexception("ReventLoop::EventLoop()", "poll() failed: ", errno);

  if (fspLog && fTraceLevel >= 2) {
    RlogMsg lmsg(*fspLog, 'I');
    lmsg << "eloop: poll(): rc=" << irc;
    for (size_t i=0; i<fPollFd.size(); i++) {
      if (fPollFd[i].revents == 0) continue;
      lmsg << " (" << fPollFd[i].fd 
           << "," << RosPrintf(fPollFd[i].events,"x") 
           << "," << RosPrintf(fPollFd[i].revents,"x") << ")";
    }
  }

  return irc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void ReventLoop::DoCall(void)
{
  for (size_t i=0; i<fPollFd.size(); i++) {
    if (fPollFd[i].revents) {      
      int irc = fPollHdl[i](fPollFd[i]);
      // remove handler negative return (nothrow=true to prevent remove race)
      if (irc < 0) {
        if (fspLog && fTraceLevel >= 1) {
          RlogMsg lmsg(*fspLog, 'I');
          lmsg << "eloop: handler(" << fPollFd[i].fd 
               << "," << RosPrintf(fPollFd[i].events,"x")
               << ") got " << RosPrintf(fPollFd[i].revents,"x")
               << " and requested removal";
        }
        RemovePollHandler(fPollFd[i].fd, fPollFd[i].events, true);
      }
    }
  }
  return;
}

} // end namespace Retro
