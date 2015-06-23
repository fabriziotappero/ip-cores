// $Id: Rw11VirtTermTcp.hpp 508 2013-04-20 18:43:28Z mueller $
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
// 2013-04-20   508   1.0.1  add fSndPreConQue handling
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11VirtTermTcp.hpp 508 2013-04-20 18:43:28Z mueller $
  \brief   Declaration of class Rw11VirtTermTcp.
*/

#ifndef included_Retro_Rw11VirtTermTcp
#define included_Retro_Rw11VirtTermTcp 1

#include <deque>

#include "Rw11VirtTerm.hpp"

namespace Retro {

  class Rw11VirtTermTcp : public Rw11VirtTerm {
    public:

      explicit      Rw11VirtTermTcp(Rw11Unit* punit);
                   ~Rw11VirtTermTcp();

      bool          Open(const std::string& url, RerrMsg& emsg);

      virtual bool  Snd(const uint8_t* data, size_t count, RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // statistics counter indices
      enum stats {
        kStatNVTPreConSave = Rw11VirtTerm::kDimStat,
        kStatNVTPreConDrop,
        kStatNVTListenPoll,
        kStatNVTAccept,
        kStatNVTRcvRaw,
        kStatNVTSndRaw,
        kDimStat
      };    

    protected:

      bool          Connected() const;
      int           ListenPollHandler(const pollfd& pfd);
      int           RcvPollHandler(const pollfd& pfd);

    // some constants (also defined in cpp)
      static const uint8_t  kCode_NULL =   0;
      static const uint8_t  kCode_LF   =  10;
      static const uint8_t  kCode_CR   =  13;
      static const uint8_t  kCode_ESC  =  27;
      static const uint8_t  kCode_SE   = 240;
      static const uint8_t  kCode_NOP  = 241;
      static const uint8_t  kCode_IP   = 244;
      static const uint8_t  kCode_GA   = 249;
      static const uint8_t  kCode_SB   = 250;
      static const uint8_t  kCode_WILL = 251;
      static const uint8_t  kCode_WONT = 252;
      static const uint8_t  kCode_DO   = 253;
      static const uint8_t  kCode_DONT = 254;
      static const uint8_t  kCode_IAC  = 255;

      static const uint8_t  kOpt_BIN   =   0;
      static const uint8_t  kOpt_ECHO  =   1;
      static const uint8_t  kOpt_SGA   =   3;
      static const uint8_t  kOpt_TTYP  =  24;
      static const uint8_t  kOpt_LINE  =  34;

      static const size_t   kPreConQue_limit = 65536;

      enum telnet_state {
        ts_Closed = 0,
        ts_Listen,
        ts_Stream,
        ts_Iac,
        ts_Cmd,
        ts_Subneg,
        ts_Subiac
      };
    
    protected:
      int           fFdListen;
      int           fFd;
      telnet_state  fState;
      bool          fTcpTrace;
      std::deque<uint8_t> fSndPreConQue;
  };
  
} // end namespace Retro

#include "Rw11VirtTermTcp.ipp"

#endif
