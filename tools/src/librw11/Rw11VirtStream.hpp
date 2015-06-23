// $Id: Rw11VirtStream.hpp 515 2013-05-04 17:28:59Z mueller $
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
// 2013-05-04   515   1.0    Initial version
// 2013-05-01   513   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtStream.hpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Declaration of class Rw11VirtStream.
*/

#ifndef included_Retro_Rw11VirtStream
#define included_Retro_Rw11VirtStream 1

#include <stdio.h>

#include "Rw11Virt.hpp"

namespace Retro {

  class Rw11VirtStream : public Rw11Virt {
    public:

      explicit      Rw11VirtStream(Rw11Unit* punit);
                   ~Rw11VirtStream();

      bool          Open(const std::string& url, RerrMsg& emsg);
      int           Read(uint8_t* data, size_t count, RerrMsg& emsg);
      bool          Write(const uint8_t* data, size_t count, RerrMsg& emsg);
      bool          Flush(RerrMsg& emsg);
      int           Tell(RerrMsg& emsg);
      bool          Seek(int pos, RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

      static Rw11VirtStream* New(const std::string& url, Rw11Unit* punit,
                                 RerrMsg& emsg);

    // statistics counter indices
      enum stats {
        kStatNVSRead = Rw11Virt::kDimStat,
        kStatNVSReadByt,
        kStatNVSWrite,
        kStatNVSWriteByt,
        kStatNVSFlush,
        kStatNVSTell,
        kStatNVSSeek,
        kDimStat
      };    

    protected:
      bool          fIStream;               //<! is input (read only) stream
      bool          fOStream;               //<! is output (write only) stream
      FILE*         fFile;                  //<! file ptr
  };
  
} // end namespace Retro

//#include "Rw11VirtStream.ipp"

#endif
