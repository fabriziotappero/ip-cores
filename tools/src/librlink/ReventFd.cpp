// $Id: ReventFd.cpp 529 2013-08-02 17:15:43Z mueller $
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
// 2013-01-14   475   1.0    Initial version
// 2013-01-11   473   0.5    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: ReventFd.cpp 529 2013-08-02 17:15:43Z mueller $
  \brief   Implemenation of class ReventFd.
*/

#include <errno.h>
#include <unistd.h>
#include <sys/eventfd.h>

#include "ReventFd.hpp"

#include "librtools/Rexception.hpp"

using namespace std;

/*!
  \class Retro::ReventFd
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

ReventFd::ReventFd()
{
  fFd = ::eventfd(0,0);                    // ini value = 0; no flags
  if (fFd < 0) 
    throw Rexception("ReventFd::ctor", "eventfd() failed: ", errno);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

ReventFd::~ReventFd()
{
  ::close(fFd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int ReventFd::SignalFd(int fd)
{
  uint64_t one(1);
  int irc = ::write(fd, &one, sizeof(one));
  return irc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int ReventFd::WaitFd(int fd)
{
  uint64_t buf;
  int irc = ::read(fd, &buf, sizeof(buf));
  return (irc <= 0) ? irc : (int)buf;
}

} // end namespace Retro
