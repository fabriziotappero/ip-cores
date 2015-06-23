// $Id: RlinkPort.cpp 666 2015-04-12 21:17:54Z mueller $
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
// 2015-04-11   666   1.3    add fXon, XonEnable()
// 2014-12-10   611   1.2.4  add time stamps for Read/Write for logs
// 2014-11-29   607   1.2.3  BUGFIX: fix time handling on RawRead()
// 2014-11-23   606   1.2.2  use Rtools::TimeOfDayAsDouble()
// 2014-08-22   584   1.2.1  use nullptr
// 2013-02-23   492   1.2    use RparseUrl
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2013-02-10   485   1.0.5  add static const defs
// 2013-02-03   481   1.0.4  use Rexception
// 2013-01-27   477   1.0.3  add RawRead(),RawWrite() methods
// 2012-12-28   466   1.0.2  allow Close() even when not open
// 2012-12-26   465   1.0.1  add CloseFd() method
// 2011-03-27   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPort.cpp 666 2015-04-12 21:17:54Z mueller $
  \brief   Implemenation of RlinkPort.
*/

#include <errno.h>
#include <unistd.h>
#include <poll.h>

#include <iostream>

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RlogMsg.hpp"
#include "librtools/Rtools.hpp"

#include "RlinkPort.hpp"

using namespace std;

/*!
  \class Retro::RlinkPort
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const int  RlinkPort::kEof;
const int  RlinkPort::kTout;
const int  RlinkPort::kErr;
   
//------------------------------------------+-----------------------------------
//! Default constructor

RlinkPort::RlinkPort()
  : fIsOpen(false),
    fUrl(),
    fXon(false),
    fFdRead(-1),
    fFdWrite(-1),
    fspLog(),
    fTraceLevel(0),
    fTsLastRead(-1.),
    fTsLastWrite(-1.),
    fStats()
{
  fStats.Define(kStatNPortWrite,    "NPortWrite", "Port::Write() calls");
  fStats.Define(kStatNPortRead,     "NPortRead",  "Port::Read() calls");
  fStats.Define(kStatNPortTxByt,    "NPortTxByt", "Port Tx bytes send");
  fStats.Define(kStatNPortRxByt,    "NPortRxByt", "Port Rx bytes rcvd");
  fStats.Define(kStatNPortRawWrite, "NPortRawWrite", "Port::RawWrite() calls");
  fStats.Define(kStatNPortRawRead,  "NPortRawRead",  "Port::RawRead() calls");
}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkPort::~RlinkPort()
{
  if (IsOpen()) RlinkPort::Close();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPort::Close()
{
  if (!IsOpen()) return;

  if (fFdWrite == fFdRead) fFdWrite = -1;
  CloseFd(fFdWrite);
  CloseFd(fFdRead);

  fIsOpen  = false;
  fUrl.Clear();
    
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RlinkPort::Read(uint8_t* buf, size_t size, double timeout, RerrMsg& emsg)
{
  if (!IsOpen())
    throw Rexception("RlinkPort::Read()","Bad state: port not open");
  if (buf == nullptr) 
    throw Rexception("RlinkPort::Read()","Bad args: buf==nullptr");
  if (size == 0) 
    throw Rexception("RlinkPort::Read()","Bad args: size==0");

  fStats.Inc(kStatNPortRead);

  bool rdpoll = PollRead(timeout);
  if (!rdpoll) return kTout;

  int irc = -1;
  while (irc < 0) {
    irc = ::read(fFdRead, (void*) buf, size);
    if (irc < 0 && errno != EINTR) {
      emsg.InitErrno("RlinkPort::Read()", "read() failed : ", errno);
      if (fspLog && fTraceLevel>0) fspLog->Write(emsg.Message(), 'E');
      return kErr;
    }
  }

  if (fspLog && fTraceLevel>0) {
    RlogMsg lmsg(*fspLog, 'I');
    lmsg << "port  read nchar=" << RosPrintf(irc,"d",4);
    double now = Rtools::TimeOfDayAsDouble();
    if (fTsLastRead  > 0.) 
      lmsg << "  dt_rd=" << RosPrintf(now-fTsLastRead,"f",8,6);
    if (fTsLastWrite > 0.) 
      lmsg << "  dt_wr=" << RosPrintf(now-fTsLastWrite,"f",8,6);
    fTsLastRead = now;
    if (fTraceLevel>1) {
      size_t ncol = (80-5-6)/(2+1);
      for (int i=0; i<irc; i++) {
        if ((i%ncol)==0) lmsg << "\n     " << RosPrintf(i,"d",4) << ": ";
        lmsg << RosPrintBvi(buf[i],16) << " ";
      }
    }
  } 

  fStats.Inc(kStatNPortRxByt, double(irc));

  return irc;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RlinkPort::Write(const uint8_t* buf, size_t size, RerrMsg& emsg)
{
  if (!IsOpen()) 
    throw Rexception("RlinkPort::Write()","Bad state: port not open");
  if (buf == nullptr) 
    throw Rexception("RlinkPort::Write()","Bad args: buf==nullptr");
  if (size == 0) 
    throw Rexception("RlinkPort::Write()","Bad args: size==0");

  fStats.Inc(kStatNPortWrite);

  if (fspLog && fTraceLevel>0) {
    RlogMsg lmsg(*fspLog, 'I');
    lmsg << "port write nchar=" << RosPrintf(size,"d",4);
    double now = Rtools::TimeOfDayAsDouble();
    if (fTsLastRead  > 0.) 
      lmsg << "  dt_rd=" << RosPrintf(now-fTsLastRead,"f",8,6);
    if (fTsLastWrite > 0.) 
      lmsg << "  dt_wr=" << RosPrintf(now-fTsLastWrite,"f",8,6);
    fTsLastWrite = now;
    if (fTraceLevel>1) {
      size_t ncol = (80-5-6)/(2+1);
      for (size_t i=0; i<size; i++) {
        if ((i%ncol)==0) lmsg << "\n     " << RosPrintf(i,"d",4) << ": ";
        lmsg << RosPrintBvi(buf[i],16) << " ";
      }
    }
  }

  size_t ndone = 0;
  while (ndone < size) {
    int irc = -1;
    while (irc < 0) {
      irc = ::write(fFdWrite, (void*) (buf+ndone), size-ndone);
      if (irc < 0 && errno != EINTR) {
        emsg.InitErrno("RlinkPort::Write()", "write() failed : ", errno);
        if (fspLog && fTraceLevel>0) fspLog->Write(emsg.Message(), 'E');
        return kErr;
      }
    }
    // FIXME_code: handle eof ??
    ndone += irc;
  }

  fStats.Inc(kStatNPortTxByt, double(ndone));

  return ndone;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPort::PollRead(double timeout)
{
  if (! IsOpen())
    throw Rexception("RlinkPort::PollRead()","Bad state: port not open");
  if (timeout < 0.)
    throw Rexception("RlinkPort::PollRead()","Bad args: timeout < 0");

  int ito = 1000.*timeout + 0.1;

  struct pollfd fds[1] = {{fFdRead,         // fd
                           POLLIN,          // events
                           0}};             // revents


  int irc = -1;
  while (irc < 0) {
    irc = ::poll(fds, 1, ito);
    if (irc < 0 && errno != EINTR)
      throw Rexception("RlinkPort::PollRead()","poll() failed: rc<0: ", errno);
  }

  if (irc == 0) return false;

  if (fds[0].revents == POLLERR)
    throw Rexception("RlinkPort::PollRead()", "poll() failed: POLLERR");

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
int RlinkPort::RawRead(uint8_t* buf, size_t size, bool exactsize,
                       double timeout, double& tused, RerrMsg& emsg)
{
  if (timeout <= 0.)
    throw Rexception("RlinkPort::RawRead()", "Bad args: timeout <= 0.");
  if (size <= 0)
    throw Rexception("RlinkPort::RawRead()", "Bad args: size <= 0");

  fStats.Inc(kStatNPortRawRead);
  tused = 0.;

  double tnow = Rtools::TimeOfDayAsDouble();
  double tend = tnow + timeout;
  double tbeg = tnow;

  size_t ndone = 0;
  while (tnow < tend && ndone<size) {
    int irc = Read(buf+ndone, size-ndone, tend-tnow, emsg);
    tnow  = Rtools::TimeOfDayAsDouble();
    tused = tnow - tbeg;
    if (irc <= 0) return irc;
    if (!exactsize) break;
    ndone += irc;
  }
  
  return (int)ndone;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
int RlinkPort::RawWrite(const uint8_t* buf, size_t size, RerrMsg& emsg)
{
  fStats.Inc(kStatNPortRawWrite);  
  return Write(buf, size, emsg);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPort::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkPort @ " << this << endl;

  os << bl << "  fIsOpen:         " << (int)fIsOpen << endl;
  fUrl.Dump(os, ind+2, "fUrl: ");
  os << bl << "  fXon:            " << fXon << endl;
  os << bl << "  fFdRead:         " << fFdRead << endl;
  os << bl << "  fFdWrite:        " << fFdWrite << endl;
  os << bl << "  fspLog:          " << fspLog.get() << endl;
  os << bl << "  fTraceLevel:     " << fTraceLevel << endl;
  //FIXME_code: fTsLastRead, fTsLastWrite not yet in Dump (get formatter...)
  fStats.Dump(os, ind+2, "fStats: ");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPort::CloseFd(int& fd)
{
  if (fd >= 0) {
    ::close(fd);
    fd  = -1;
  }
  return;
}

} // end namespace Retro
