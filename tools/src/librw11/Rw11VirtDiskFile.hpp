// $Id: Rw11VirtDiskFile.hpp 509 2013-04-21 20:46:20Z mueller $
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
// 2013-04-14   506   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11VirtDiskFile.hpp 509 2013-04-21 20:46:20Z mueller $
  \brief   Declaration of class Rw11VirtDiskFile.
*/

#ifndef included_Retro_Rw11VirtDiskFile
#define included_Retro_Rw11VirtDiskFile 1

#include "Rw11VirtDisk.hpp"

namespace Retro {

  class Rw11VirtDiskFile : public Rw11VirtDisk {
    public:

      explicit      Rw11VirtDiskFile(Rw11Unit* punit);
                   ~Rw11VirtDiskFile();

      bool          Open(const std::string& url, RerrMsg& emsg);

      virtual bool  Read(size_t lba, size_t nblk, uint8_t* data, 
                         RerrMsg& emsg);
      virtual bool  Write(size_t lba, size_t nblk, const uint8_t* data, 
                          RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      bool          Seek(size_t seekpos, RerrMsg& emsg);

    protected:
      int           fFd;
      size_t        fSize;
  };
  
} // end namespace Retro

//#include "Rw11VirtDiskFile.ipp"

#endif
