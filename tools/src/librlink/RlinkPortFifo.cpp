// $Id: RlinkPortFifo.cpp 666 2015-04-12 21:17:54Z mueller $
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
// 2015-04-12   666   1.2    add xon,noinit attributes
// 2013-02-23   492   1.1    use RparseUrl
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPortFifo.cpp 666 2015-04-12 21:17:54Z mueller $
  \brief   Implemenation of RlinkPortFifo.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#include "RlinkPortFifo.hpp"

using namespace std;

/*!
  \class Retro::RlinkPortFifo
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkPortFifo::RlinkPortFifo()
  : RlinkPort()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkPortFifo::~RlinkPortFifo()
{
  // no need to call Close() here, no RlinkPortFifo::Close()
  // cleanup will be done by ~RlinkPort()
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPortFifo::Open(const std::string& url, RerrMsg& emsg)
{
  if (IsOpen()) Close();

  if (!fUrl.Set(url, "|keep|xon|noinit|", emsg)) return false;

  // Note: _rx fifo must be opened before the _tx fifo, otherwise the test
  //       bench might close with EOF on read prematurely (is a race condition).

  fFdWrite = OpenFifo(fUrl.Path() + "_rx", true, emsg);
  if (fFdWrite < 0) return false;
  
  fFdRead = OpenFifo(fUrl.Path() + "_tx", false, emsg);
  if (fFdRead < 0) {
    close(fFdWrite);
    fFdWrite = -1;
    return false;
  }

  fXon = fUrl.FindOpt("xon");
  fIsOpen = true;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RlinkPortFifo::OpenFifo(const std::string& name, bool snd, RerrMsg& emsg)
{
  struct stat stat_fifo;

  int irc;
  
  irc = stat(name.c_str(), &stat_fifo);
  if (irc == 0) {
    if ((stat_fifo.st_mode & S_IFIFO) == 0) {
      emsg.Init("RlinkPortFifo::OpenFiFo()",
                string("'") + name + "' exists but is not a pipe");
      return -1;
    }
  } else {
    mode_t mode = S_IRUSR | S_IWUSR;        // user read and write allowed
    irc = ::mkfifo(name.c_str(), mode);
    if (irc != 0) {
      emsg.InitErrno("RlinkPortFifo::OpenFifo()", 
                     string("mkfifo() for '") + name + "' failed: ",
                     errno);
      return -1;
    }    
  }

  irc = ::open(name.c_str(), snd ? O_WRONLY : O_RDONLY);
  if (irc < 0) {
    emsg.InitErrno("RlinkPortFifo::OpenFifo()", 
                   string("open() for '") + name + "' failed: ",
                   errno);
    return -1;
  }

  return irc;
}

} // end namespace Retro
