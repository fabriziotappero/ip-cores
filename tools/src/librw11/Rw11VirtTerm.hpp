// $Id: Rw11VirtTerm.hpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtTerm.hpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Declaration of class Rw11VirtTerm.
*/

#ifndef included_Retro_Rw11VirtTerm
#define included_Retro_Rw11VirtTerm 1

#include "boost/function.hpp"

#include "Rw11Virt.hpp"

namespace Retro {

  class Rw11VirtTerm : public Rw11Virt {
    public:
      typedef boost::function<bool(const uint8_t*, size_t)> rcvcbfo_t;

      explicit      Rw11VirtTerm(Rw11Unit* punit);
                   ~Rw11VirtTerm();

      virtual const std::string& ChannelId() const;

      void          SetupRcvCallback(const rcvcbfo_t& rcvcbfo);
      virtual bool  Snd(const uint8_t* data, size_t count, RerrMsg& emsg) = 0;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

      static Rw11VirtTerm* New(const std::string& url, Rw11Unit* punit,
                               RerrMsg& emsg);

    // statistics counter indices
      enum stats {
        kStatNVTRcvPoll = Rw11Virt::kDimStat,
        kStatNVTSnd,
        kStatNVTRcvByt,
        kStatNVTSndByt,
        kDimStat
      };    

    protected:
      std::string   fChannelId;             //!< channel id 
      rcvcbfo_t     fRcvCb;                 //!< receive callback fobj
  };
  
} // end namespace Retro

#include "Rw11VirtTerm.ipp"

#endif
