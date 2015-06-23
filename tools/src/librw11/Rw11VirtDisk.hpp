// $Id: Rw11VirtDisk.hpp 509 2013-04-21 20:46:20Z mueller $
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
// 2013-03-03   494   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11VirtDisk.hpp 509 2013-04-21 20:46:20Z mueller $
  \brief   Declaration of class Rw11VirtDisk.
*/

#ifndef included_Retro_Rw11VirtDisk
#define included_Retro_Rw11VirtDisk 1

#include "Rw11Virt.hpp"

namespace Retro {

  class Rw11VirtDisk : public Rw11Virt {
    public:
      explicit      Rw11VirtDisk(Rw11Unit* punit);
                   ~Rw11VirtDisk();

      void          Setup(size_t blksize, size_t nblock);
      size_t        BlockSize() const;
      size_t        NBlock() const;

      virtual bool  Read(size_t lba, size_t nblk, uint8_t* data, 
                         RerrMsg& emsg) = 0;
      virtual bool  Write(size_t lba, size_t nblk, const uint8_t* data, 
                          RerrMsg& emsg) = 0;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

      static Rw11VirtDisk* New(const std::string& url, Rw11Unit* punit,
                               RerrMsg& emsg);

    // statistics counter indices
      enum stats {
        kStatNVDRead = Rw11Virt::kDimStat,
        kStatNVDReadBlk,
        kStatNVDWrite,
        kStatNVDWriteBlk,
        kDimStat
      };    

    protected:
      size_t        fBlkSize;               //<! block size in byte
      size_t        fNBlock;                //<! disk size in blocks
  };
  
} // end namespace Retro

#include "Rw11VirtDisk.ipp"

#endif
