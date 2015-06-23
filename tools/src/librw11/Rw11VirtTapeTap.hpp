// $Id: Rw11VirtTapeTap.hpp 686 2015-06-04 21:08:08Z mueller $
//
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11VirtTapeTap.hpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Declaration of class Rw11VirtTapeTap.
*/

#ifndef included_Retro_Rw11VirtTapeTap
#define included_Retro_Rw11VirtTapeTap 1

#include "Rw11VirtTape.hpp"

namespace Retro {

  class Rw11VirtTapeTap : public Rw11VirtTape {
    public:

      explicit      Rw11VirtTapeTap(Rw11Unit* punit);
                   ~Rw11VirtTapeTap();

      bool          Open(const std::string& url, RerrMsg& emsg);

      virtual bool  ReadRecord(size_t nbyt, uint8_t* data, size_t& ndone, 
                               int& opcode, RerrMsg& emsg);
      virtual bool  WriteRecord(size_t nbyt, const uint8_t* data, 
                                int& opcode, RerrMsg& emsg);
      virtual bool  WriteEof(RerrMsg& emsg);
      virtual bool  SpaceForw(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg);
      virtual bool  SpaceBack(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg);
      virtual bool  Rewind(int& opcode, RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants (also defined in cpp)
      static const uint32_t kMetaEof = 0x00000000; //!< EOF marker
      static const uint32_t kMetaEom = 0xffffffff; //!< EOM marker
      static const uint32_t kMeta_M_Perr = 0x80000000;
      static const uint32_t kMeta_M_Mbz  = 0x7fff0000;
      static const uint32_t kMeta_B_Rlen = 0x0000ffff;

    protected:
      bool          Seek(size_t seekpos, int dir, RerrMsg& emsg);
      bool          Read(size_t nbyt, uint8_t* data, RerrMsg& emsg);
      bool          Write(size_t nbyt, const uint8_t* data, bool back,
                          RerrMsg& emsg);
      bool          CheckSizeForw(size_t nbyt, const char* text, RerrMsg& emsg);
      bool          CheckSizeBack(size_t nbyt, const char* text, RerrMsg& emsg);
      void          UpdatePos(size_t nbyt, int dir);
      bool          ParseMeta(uint32_t meta, size_t& rlen, bool& perr, 
                              RerrMsg& emsg);
      size_t        BytePadding(size_t rlen);
      bool          SetBad();
      bool          BadTapeMsg(const char* meth, RerrMsg& emsg);
      void          IncPosRecord(int delta);

    protected:
      int           fFd;                    //!< file number
      size_t        fSize;                  //!< file size
      size_t        fPos;                   //!< file position
      bool          fBad;                   //!< BAD file format flag
      bool          fPadOdd;                //!< do odd byte padding
      bool          fTruncPend;             //!< truncate on next write
  };
  
} // end namespace Retro

#include "Rw11VirtTapeTap.ipp"

#endif
