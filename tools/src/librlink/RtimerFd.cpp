// $Id: RtimerFd.cpp 488 2013-02-16 18:49:47Z mueller $
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
// 2013-01-11   473   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtimerFd.cpp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation of class RtimerFd.
*/

#include <errno.h>
#include <unistd.h>
#include <sys/timerfd.h>

#include "RtimerFd.hpp"

#include "librtools/Rexception.hpp"

using namespace std;

/*!
  \class Retro::RtimerFd
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtimerFd::RtimerFd()
{
  fFd = timerfd_create(CLOCK_MONOTONIC,0);  // use MONOTONIC; no flags
  if (fFd < 0) 
    throw Rexception("RtimerFd::<ctor>", "timerfd() failed: ", errno);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtimerFd::~RtimerFd()
{
  close(fFd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtimerFd::SetRelTimer(boost::posix_time::time_duration interval,
                           boost::posix_time::time_duration initial)
{
  itimerspec  its;
  itimerspec  old;
  long sf = 1000000000/interval.ticks_per_second();
  its.it_interval.tv_sec  = interval.total_seconds();
  its.it_interval.tv_nsec = interval.fractional_seconds() * sf;
  its.it_value.tv_sec     = initial.total_seconds();
  its.it_value.tv_nsec    = initial.fractional_seconds() * sf;
  int irc = timerfd_settime(fFd, 0, &its, &old);
  if (irc < 0) 
    throw Rexception("RtimerFd::SetRelTimer()", "timerfd() failed: ", errno);
  return;
}

} // end namespace Retro
