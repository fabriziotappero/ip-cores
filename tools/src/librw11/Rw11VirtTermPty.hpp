// $Id: Rw11VirtTermPty.hpp 504 2013-04-13 15:37:24Z mueller $
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
  \version $Id: Rw11VirtTermPty.hpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Declaration of class Rw11VirtTermPty.
*/

#ifndef included_Retro_Rw11VirtTermPty
#define included_Retro_Rw11VirtTermPty 1

#include <poll.h>

#include "Rw11VirtTerm.hpp"

namespace Retro {

  class Rw11VirtTermPty : public Rw11VirtTerm {
    public:

      explicit      Rw11VirtTermPty(Rw11Unit* punit);
                   ~Rw11VirtTermPty();

      bool          Open(const std::string& url, RerrMsg& emsg);

      virtual bool  Snd(const uint8_t* data, size_t count, RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      int           RcvPollHandler(const pollfd& pfd);

    protected:
      int           fFd;                    //<! fd for pty master side 
  };
  
} // end namespace Retro

//#include "Rw11VirtTermPty.ipp"

#endif
