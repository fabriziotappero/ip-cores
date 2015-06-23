// $Id: RlinkServerEventLoop.cpp 662 2015-04-05 08:02:54Z mueller $
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
// 2015-04-04   662   1.2    BUGFIX: fix race in Stop(), use StopPending()
// 2013-03-05   495   1.1.1  add exception catcher to EventLoop
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2013-01-12   474   1.0    Initial Version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkServerEventLoop.cpp 662 2015-04-05 08:02:54Z mueller $
  \brief   Implemenation of RlinkServerEventLoop.
*/

#include <errno.h>

#include "RlinkServer.hpp"
#include "librtools/RlogMsg.hpp"

#include "RlinkServerEventLoop.hpp"

using namespace std;

/*!
  \class Retro::RlinkServerEventLoop
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkServerEventLoop::RlinkServerEventLoop(RlinkServer* pserv)
  : fpServer(pserv)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkServerEventLoop::~RlinkServerEventLoop()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkServerEventLoop::EventLoop()
{
  fUpdatePoll = true;

  if (fspLog && fTraceLevel>0) fspLog->Write("eloop: starting", 'I');

  try {
    while (!StopPending()) {
      int timeout = (fpServer->AttnPending() || 
                     fpServer->ActnPending()) ? 0 : -1;
      int irc = DoPoll(timeout);
      fpServer->fStats.Inc(timeout<0 ? RlinkServer::kStatNEloopWait : 
                           RlinkServer::kStatNEloopPoll);
      if (fPollFd.size() == 0) break;
      if (irc > 0) DoCall();
      
      if (fpServer->AttnPending()) fpServer->CallAttnHandler();
      if (fpServer->ActnPending()) fpServer->CallActnHandler();
    }
  } catch (exception& e) {
    if (fspLog) {
      RlogMsg lmsg(*fspLog, 'F');
      lmsg << "eloop: crashed with exception: " << e.what();
    }
    return;
  }

  if (fspLog && fTraceLevel>0) fspLog->Write("eloop: stopped", 'I');

  return;
}

} // end namespace Retro
