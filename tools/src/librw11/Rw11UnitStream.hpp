// $Id: Rw11UnitStream.hpp 515 2013-05-04 17:28:59Z mueller $
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
  \version $Id: Rw11UnitStream.hpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Declaration of class Rw11UnitStream.
*/

#ifndef included_Retro_Rw11UnitStream
#define included_Retro_Rw11UnitStream 1

#include "Rw11VirtStream.hpp"

#include "Rw11UnitVirt.hpp"

namespace Retro {

  class Rw11UnitStream : public Rw11UnitVirt<Rw11VirtStream> {
    public:
                    Rw11UnitStream(Rw11Cntl* pcntl, size_t index);
                   ~Rw11UnitStream();

      void          SetPos(int pos);
      int           Pos() const;

      int           VirtRead(uint8_t* data, size_t count, RerrMsg& emsg);
      bool          VirtWrite(const uint8_t* data, size_t count, RerrMsg& emsg);
      bool          VirtFlush(RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // statistics counter indices
      enum stats {
        kStatNPreAttDrop = Rw11Unit::kDimStat,
        kStatNPreAttMiss,
        kDimStat
      };

    protected:
  };
  
} // end namespace Retro

//#include "Rw11UnitStream.ipp"

#endif
