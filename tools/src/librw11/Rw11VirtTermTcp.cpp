// $Id: Rw11VirtTermTcp.cpp 632 2015-01-11 12:30:03Z mueller $
//
// Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-08-22   584   1.0.4  use nullptr
// 2013-05-17   512   1.0.3  use Rtools::String2Long
// 2013-05-05   516   1.0.2  fix mistakes in emsg generation with errno
// 2013-04-20   508   1.0.1  add fSndPreConQue handling
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtTermTcp.cpp 632 2015-01-11 12:30:03Z mueller $
  \brief   Implemenation of Rw11VirtTermTcp.
*/

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <string.h>

#include <sstream>

#include "librtools/RosFill.hpp"
#include "librtools/RlogMsg.hpp"

#include "Rw11VirtTermTcp.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtTermTcp
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint8_t  Rw11VirtTermTcp::kCode_NULL;
const uint8_t  Rw11VirtTermTcp::kCode_LF;   
const uint8_t  Rw11VirtTermTcp::kCode_CR;   
const uint8_t  Rw11VirtTermTcp::kCode_ESC;  
const uint8_t  Rw11VirtTermTcp::kCode_SE;   
const uint8_t  Rw11VirtTermTcp::kCode_NOP;  
const uint8_t  Rw11VirtTermTcp::kCode_IP;   
const uint8_t  Rw11VirtTermTcp::kCode_GA;   
const uint8_t  Rw11VirtTermTcp::kCode_SB;   
const uint8_t  Rw11VirtTermTcp::kCode_WILL; 
const uint8_t  Rw11VirtTermTcp::kCode_WONT; 
const uint8_t  Rw11VirtTermTcp::kCode_DO;   
const uint8_t  Rw11VirtTermTcp::kCode_DONT; 
const uint8_t  Rw11VirtTermTcp::kCode_IAC;  

const uint8_t  Rw11VirtTermTcp::kOpt_BIN;   
const uint8_t  Rw11VirtTermTcp::kOpt_ECHO;  
const uint8_t  Rw11VirtTermTcp::kOpt_SGA;   
const uint8_t  Rw11VirtTermTcp::kOpt_TTYP;  
const uint8_t  Rw11VirtTermTcp::kOpt_LINE;  

const size_t   Rw11VirtTermTcp::kPreConQue_limit;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtTermTcp::Rw11VirtTermTcp(Rw11Unit* punit)
  : Rw11VirtTerm(punit),
    fFdListen(-1),
    fFd(-1),
    fState(ts_Closed),
    fTcpTrace(false),
    fSndPreConQue()
{
  fStats.Define(kStatNVTPreConSave , "NVTPreConSave" ,
                "VT snd bytes saved prior connect");
  fStats.Define(kStatNVTPreConDrop , "NVTPreConDrop" ,
                "VT snd bytes dropped prior connect");
  fStats.Define(kStatNVTListenPoll , "NVTListenPoll" ,
                "VT ListenPollHandler() calls");
  fStats.Define(kStatNVTAccept,      "NVTAccept",     "VT socket accepts");
  fStats.Define(kStatNVTRcvRaw,      "NVTRcvRaw",     "VT raw bytes received");
  fStats.Define(kStatNVTSndRaw,      "NVTSndRaw",     "VT raw bytes send");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtTermTcp::~Rw11VirtTermTcp()
{
  if (fFdListen > 2) {
    Server().RemovePollHandler(fFdListen);
    close(fFdListen);
  }
  if (Connected()) {
    Server().RemovePollHandler(fFd);
    close(fFd);
  }
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTermTcp::Open(const std::string& url, RerrMsg& emsg)
{
  if (!fUrl.Set(url, "|port=|trace|", emsg)) return false;
  if (!(fUrl.FindOpt("port"))) {
    emsg.Init("Rw11VirtTermTcp::Open", "port= option not specified");
    return false;
  }

  fTcpTrace = fUrl.FindOpt("trace");

  string port;
  fUrl.FindOpt("port",port);
  unsigned long portno;
  if (!Rtools::String2Long(port, portno, emsg)) return false;

  protoent* pe = getprotobyname("tcp");
  if (pe == nullptr) {
    emsg.Init("Rw11VirtTermTcp::Open","getprotobyname(\"tcp\") failed");
    return false;
  }

  int fd = socket(AF_INET, SOCK_STREAM|SOCK_NONBLOCK, pe->p_proto);
  if (fd < 0) {
    emsg.InitErrno("Rw11VirtTermTcp::Open","socket() failed: ", errno);
    return false;
  }

  int on = 1;
  if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) < 0) {
    emsg.InitErrno("Rw11VirtTermTcp::Open","setsockop() failed: ", errno);
    close(fd);
    return false;
  }

  sockaddr_in sa;
  memset(&sa, 0, sizeof(sa));
  sa.sin_family = AF_INET;
  sa.sin_port   = htons((unsigned short) portno);
  sa.sin_addr.s_addr = htonl(INADDR_ANY);

  // Note: ::bind needed below to avoid collision with std::bind... 
  if (::bind(fd, (sockaddr*) &sa, sizeof(sa)) < 0) {
    emsg.InitErrno("Rw11VirtTermTcp::Open","bind() failed: ", errno);
    close(fd);
    return false;
  }

  if (listen(fd, 1) <0) {
    emsg.InitErrno("Rw11VirtTermTcp::Open","listen() failed: ", errno);
    close(fd);
    return false;    
  }

  fFdListen = fd;
  fChannelId = port;
  fState = ts_Listen;

  if (fTcpTrace) {
    RlogMsg lmsg(LogFile(),'I');
    lmsg << "TermTcp: listen on " << fChannelId << " for " << Unit().Name();
  }

  Server().AddPollHandler(boost::bind(&Rw11VirtTermTcp::ListenPollHandler,
                                      this, _1), 
                          fFdListen, POLLIN);

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTermTcp::Snd(const uint8_t* data, size_t count, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTSnd);
  const uint8_t* pdata = data;
  const uint8_t* pdataend = data+count;
  if (count == 0) return true;              // quit if nothing to do

  if (!Connected()) {                       // if not connected keep last chars
    for (size_t i=0; i<count; i++) fSndPreConQue.push_back(data[i]);
    fStats.Inc(kStatNVTPreConSave, double(count));
    while (fSndPreConQue.size() > kPreConQue_limit) {
      fSndPreConQue.pop_front();
      fStats.Inc(kStatNVTPreConDrop);
    }
    return true;
  }

  uint8_t  obuf[1024];
  while (pdata < pdataend) {
    uint8_t* pobuf = obuf;
    uint8_t* pobufend = obuf+1024;
    while (pdata < pdataend && pobuf < pobufend-1) {
      if (*pdata == kCode_IAC) *pobuf++ = kCode_IAC;
      *pobuf++ = *pdata++;
    }

    int irc = write(fFd, obuf, pobuf-obuf);
    if (irc < 0) {
      RlogMsg lmsg(LogFile(),'E');
      RerrMsg emsg("Rw11VirtTermTcp::Snd", 
                   string("write() for port ") + fChannelId + " failed: ", 
                   errno);
      lmsg << emsg;
    } else {
      fStats.Inc(kStatNVTSndRaw, double(irc));
    }
  }

  fStats.Inc(kStatNVTSndByt, double(count));
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTermTcp::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtTermTcp @ " << this << endl;

  os << bl << "  fFdListen:       " << fFdListen << endl;
  os << bl << "  fFd:             " << fFd << endl;
  const char* t_state = "";
  switch (fState) {
  case ts_Closed: t_state = "ts_Closed";  break;
  case ts_Listen: t_state = "ts_Listen";  break;
  case ts_Stream: t_state = "ts_Stream";  break;
  case ts_Iac:    t_state = "ts_Iac";     break;
  case ts_Cmd:    t_state = "ts_Cmd";     break;
  case ts_Subneg: t_state = "ts_Subneg";  break;
  case ts_Subiac: t_state = "ts_Subiac";  break;
  default: t_state = "???";
  }
  os << bl << "  fState:          " << t_state    << endl;
  os << bl << "  fTcpTrace:       " << fTcpTrace  << endl;
  os << bl << "  fSndPreConQue.size" << fSndPreConQue.size()  << endl;
  Rw11VirtTerm::Dump(os, ind, " ^");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11VirtTermTcp::ListenPollHandler(const pollfd& pfd)
{
  // bail-out and cancel handler if poll returns an error event
  if (pfd.revents & (~pfd.events)) return -1;

  fFd = accept(fFdListen, nullptr, 0);

  if (fFd < 0) {
    RlogMsg lmsg(LogFile(),'E');
    RerrMsg emsg("Rw11VirtTermTcp::ListenPollHandler", 
                 string("accept() for port ") + fChannelId + " failed: ", 
                 errno);
    lmsg << emsg;    
    // FIXME_code: proper error handling
    return 0;
  } 

  fStats.Inc(kStatNVTAccept);

  uint8_t buf_1[3] = {kCode_IAC, kCode_WILL, kOpt_LINE};
  uint8_t buf_2[3] = {kCode_IAC, kCode_WILL, kOpt_SGA};
  uint8_t buf_3[3] = {kCode_IAC, kCode_WILL, kOpt_ECHO};
  uint8_t buf_4[3] = {kCode_IAC, kCode_WILL, kOpt_BIN};
  uint8_t buf_5[3] = {kCode_IAC, kCode_DO  , kOpt_BIN};

  int nerr = 0;

  // send initial negotiation WILLs and DOs
  if (write(fFd, buf_1, sizeof(buf_1)) < 0) nerr += 1;
  if (write(fFd, buf_2, sizeof(buf_2)) < 0) nerr += 1;
  if (write(fFd, buf_3, sizeof(buf_3)) < 0) nerr += 1;
  if (write(fFd, buf_4, sizeof(buf_4)) < 0) nerr += 1;
  if (write(fFd, buf_5, sizeof(buf_5)) < 0) nerr += 1;

  // send connect message
  if (nerr==0) {
    stringstream msg;
    msg << "\r\nconnect on port " << fChannelId 
        << " for " << Unit().Name() << "\r\n\r\n";
    string str = msg.str();
    if (write(fFd, str.c_str(), str.length()) < 0) nerr += 1;
  }

  // send chars buffered while attached but not connected
  if (nerr==0 && fSndPreConQue.size()) {
    stringstream msg;
    while (!fSndPreConQue.empty()) {
      msg << char(fSndPreConQue.front());
      fSndPreConQue.pop_front();
    }
    string str = msg.str();
    if (write(fFd, str.c_str(), str.length()) < 0) nerr += 1;
  }

  if (nerr) {
    close(fFd);
    fFd = -1;
    RlogMsg lmsg(LogFile(),'E');
    RerrMsg emsg("Rw11VirtTermTcp::ListenPollHandler", 
                 string("initial write()s for port ") + fChannelId + 
                 " failed: ", errno);
    lmsg << emsg;    
    return 0;
  }

  if (fTcpTrace) {
    RlogMsg lmsg(LogFile(),'I');
    lmsg << "TermTcp: accept on " << fChannelId << " for " << Unit().Name();
  }

  fState = ts_Stream;

  Server().RemovePollHandler(fFdListen);
  Server().AddPollHandler(boost::bind(&Rw11VirtTermTcp::RcvPollHandler,
                                      this, _1), 
                          fFd, POLLIN);
  return 0;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11VirtTermTcp::RcvPollHandler(const pollfd& pfd)
{
  fStats.Inc(kStatNVTRcvPoll);

  int irc = -1;

  if (pfd.revents & POLLIN) {
    uint8_t ibuf[1024];
    uint8_t obuf[1024];
    uint8_t* pobuf = obuf;

    irc = read(fFd, ibuf, 1024);

    if (irc < 0 && (errno == EAGAIN || errno == EWOULDBLOCK)) return 0;

    if (irc > 0) {
      fStats.Inc(kStatNVTRcvRaw, double(irc));
      for (int i=0; i<irc; i++) {
        uint8_t byt = ibuf[i];
        switch (fState) {
        case ts_Stream:
          if (byt == kCode_IAC) {
            fState = ts_Iac;
          } else {
            *pobuf++ = byt;
            fStats.Inc(kStatNVTRcvByt, 1.);
          }
          break;

        case ts_Iac:
          if (byt == kCode_WILL || byt == kCode_WONT ||
              byt == kCode_DO   || byt == kCode_DONT) {
            fState = ts_Cmd;
          } else if (byt == kCode_SB) {
            fState = ts_Subneg;
          } else {
            fState = ts_Stream;
          }
          break;

        case ts_Cmd:
          fState = ts_Stream;
          break;

        case ts_Subneg:
          if (byt == kCode_IAC) {
            fState = ts_Subiac;
          }
          break;

        case ts_Subiac:
          fState = ts_Stream;
          break;
        default:
          break;
        } 

      }
    }

    if (pobuf > obuf) fRcvCb(obuf, pobuf - obuf);
  }


  if (irc <= 0) {
    if (irc < 0) {
      RlogMsg lmsg(LogFile(),'E');
      RerrMsg emsg("Rw11VirtTermTcp::ListenPollHandler", 
                   string("read() for port ") + fChannelId + " failed: ", 
                   errno);
      lmsg << emsg;
    }
    if (fTcpTrace) {
      RlogMsg lmsg(LogFile(),'I');
      lmsg << "TermTcp: close on " << fChannelId << " for " << Unit().Name();
    }
    close(fFd);
    fFd = -1;
    Server().AddPollHandler(boost::bind(&Rw11VirtTermTcp::ListenPollHandler,
                                        this, _1), 
                            fFdListen, POLLIN);    
    fState = ts_Listen;
    return -1;
  }

  return 0;
}
  

} // end namespace Retro
