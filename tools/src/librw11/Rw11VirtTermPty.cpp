// $Id: Rw11VirtTermPty.cpp 632 2015-01-11 12:30:03Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-03-06   495   1.0    Initial version
// 2013-02-24   492   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtTermPty.cpp 632 2015-01-11 12:30:03Z mueller $
  \brief   Implemenation of Rw11VirtTermPty.
*/
#define _XOPEN_SOURCE 600

#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>

#include "boost/bind.hpp"

#include "librtools/RosFill.hpp"
#include "Rw11VirtTermPty.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtTermPty
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtTermPty::Rw11VirtTermPty(Rw11Unit* punit)
  : Rw11VirtTerm(punit),
    fFd(-1)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtTermPty::~Rw11VirtTermPty()
{
  if (fFd>=2) {
    Server().RemovePollHandler(fFd);
    close(fFd);
  }
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTermPty::Open(const std::string& url, RerrMsg& emsg)
{
  int fd = posix_openpt(O_RDWR);
  if (fd < 0) {
    emsg.InitErrno("Rw11VirtTermPty::Open", "posix_openpt() failed: ", errno);
    return false;
  }

  int irc = grantpt(fd);
  if (irc < 0) {
    emsg.InitErrno("Rw11VirtTermPty::Open", "grantpt() failed: ", errno);
    close(fd);
    return false;
  }
  
  irc = unlockpt(fd);
  if (irc < 0) {
    emsg.InitErrno("Rw11VirtTermPty::Open", "unlockpt() failed: ", errno);
    close(fd);
    return false;
  }
  
  char* pname = ptsname(fd);
  if (pname == nullptr) {
    emsg.InitErrno("Rw11VirtTermPty::Open", "ptsname() failed: ", errno);
    close(fd);
    return false;
  }
  
  fFd = fd;
  fChannelId = pname;

  Server().AddPollHandler(boost::bind(&Rw11VirtTermPty::RcvPollHandler,
                                      this, _1), 
                          fFd, POLLIN);

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTermPty::Snd(const uint8_t* data, size_t count, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTSnd);
  ssize_t irc = write(fFd, data, count);
  if (irc != ssize_t(count)) {
    emsg.InitErrno("Rw11VirtTermPty::Snd", "write() failed: ", errno);
    return false;
  }
  fStats.Inc(kStatNVTSndByt, double(count));
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11VirtTermPty::RcvPollHandler(const pollfd& pfd)
{
  fStats.Inc(kStatNVTRcvPoll);
  // bail-out and cancel handler if poll returns an error event
  if (pfd.revents & (~pfd.events)) return -1;

  uint8_t buf[1024];
  ssize_t irc = read(fFd, buf, 1024);

  if (irc > 0) {
    fRcvCb(buf, size_t(irc));
    fStats.Inc(kStatNVTRcvByt, double(irc));
  }
  
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTermPty::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtTermPty @ " << this << endl;

  os << bl << "  fFd:             " << fFd << endl;
  Rw11VirtTerm::Dump(os, ind+2, "");
  return;
}


} // end namespace Retro
