// $Id: Rw11VirtTapeTap.cpp 686 2015-06-04 21:08:08Z mueller $
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
  \version $Id: Rw11VirtTapeTap.cpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation of Rw11VirtTapeTap.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "librtools/RosFill.hpp"
#include "librtools/Rtools.hpp"

#include "Rw11VirtTapeTap.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtTapeTap
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions

const uint32_t Rw11VirtTapeTap::kMetaEof;
const uint32_t Rw11VirtTapeTap::kMetaEom;
const uint32_t Rw11VirtTapeTap::kMeta_M_Perr;
const uint32_t Rw11VirtTapeTap::kMeta_M_Mbz;
const uint32_t Rw11VirtTapeTap::kMeta_B_Rlen;

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtTapeTap::Rw11VirtTapeTap(Rw11Unit* punit)
  : Rw11VirtTape(punit),
    fFd(0),
    fSize(0),
    fPos(0),
    fBad(true),
    fPadOdd(false),
    fTruncPend(false)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtTapeTap::~Rw11VirtTapeTap()
{
  if (fFd > 2) ::close(fFd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::Open(const std::string& url, RerrMsg& emsg)
{
  if (!fUrl.Set(url, "|wpro|e11|cap=|", emsg)) return false;

  fWProt  = fUrl.FindOpt("wpro");
  fPadOdd = fUrl.FindOpt("e11");

  string str_cap;
  unsigned long capacity=0;
  if (fUrl.FindOpt("cap",str_cap)) {
    if (str_cap.length() > 0) {
      unsigned long scale = 1;
      string str_conv = str_cap;
      char clast = str_cap[str_cap.length()-1];
      bool ok = true;

      if (! (clast >= '0' && clast <= '9') ) {
        str_conv = str_cap.substr(0,str_cap.length()-1);
        switch(str_cap[str_cap.length()-1]) {
        case 'k':
        case 'K':
          scale = 1024;
          break;
        case 'm':
        case 'M':
          scale = 1024*1024;
          break;
        default:
          ok = false;
          break;
        }
      }
      if (ok) {
        RerrMsg emsg_conv;
        ok = Rtools::String2Long(str_conv, capacity, emsg_conv);
      }
      if (!ok) {
        emsg.Init("Rw11VirtTapeTap::Open()", 
                  string("bad capacity option '")+str_cap+"'");
        return false;
      }
      capacity *= scale;
    }    
  }

  int fd = ::open(fUrl.Path().c_str(), fWProt ? O_RDONLY : O_CREAT|O_RDWR,
                  S_IRUSR|S_IWUSR|S_IRGRP);
  if (fd < 0) {
    emsg.InitErrno("Rw11VirtTapeTap::Open()", 
                   string("open() for '") + fUrl.Path() + "' failed: ", errno);
    return false;
  }

  struct stat sbuf;
  if (::fstat(fd, &sbuf) < 0) {
    emsg.InitErrno("Rw11VirtTapeTap::Open()", 
                   string("stat() for '") + fUrl.Path() + "' failed: ", errno);
    return false;
  }

  if ((sbuf.st_mode & S_IWUSR) == 0) fWProt = true;

  fFd   = fd;
  fSize = sbuf.st_size;
  fPos  = 0;
  fBad  = false;
  fTruncPend = true;

  fCapacity = capacity;
  fBot = true;
  fEot = false;
  fEom = false;
  fPosFile   = 0;
  fPosRecord = 0;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::ReadRecord(size_t nbyt, uint8_t* data, size_t& ndone, 
                                  int& opcode, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTReadRec);
  
  opcode = kOpCodeBadFormat;
  ndone  = 0;
  if (fBad) return BadTapeMsg("ReadRecord()", emsg);
  
  if (fPos == fSize) {
    fEom   = true;
    opcode = kOpCodeEom;
    return true;
  }

  uint32_t metabeg;
  uint32_t metaend;

  if (!CheckSizeForw(sizeof(metabeg), "missed metabeg", emsg)) return SetBad();
  if (!Read(sizeof(metabeg), reinterpret_cast<uint8_t*>(&metabeg), 
            emsg)) return SetBad();

  if (metabeg == kMetaEof) {
    fStats.Inc(kStatNVTReadEof);
    opcode = kOpCodeEof;
    fPosFile   += 1;
    fPosRecord  = 0;
    return true;
  }

  if (metabeg == kMetaEom) {
    if (!Seek(sizeof(metabeg), -1, emsg)) return SetBad();
    fStats.Inc(kStatNVTReadEom);
    fEom   = true;
    opcode = kOpCodeEom;
    return true;
  }

  size_t rlen;
  bool   perr;
  if (!ParseMeta(metabeg, rlen, perr, emsg)) return SetBad();
  size_t rlenpad = BytePadding(rlen);

  if (!CheckSizeForw(rlenpad, "missed data", emsg)) return SetBad();

  ndone = (rlen <= nbyt) ? rlen : nbyt;
  if (!Read(ndone, data, emsg)) return SetBad();
  if (ndone < rlenpad) {
    if (!Seek(rlenpad, +1, emsg)) return SetBad();
  }

  if (!CheckSizeForw(sizeof(metaend), "missed metaend", emsg)) return SetBad();
  if (!Read(sizeof(metaend), reinterpret_cast<uint8_t*>(&metaend), 
            emsg)) return SetBad();

  if (metabeg != metaend) {
    emsg.Init("Rw11VirtTapeTap::ReadRecord", "metabeg metaend mismatch");
    ndone = 0;
    return SetBad();
  }

  IncPosRecord(+1);
  opcode = kOpCodeOK;
  if (perr) {
    fStats.Inc(kStatNVTReadPErr);
    opcode = kOpCodeBadParity;
  }
  if (ndone < rlen) {
    fStats.Inc(kStatNVTReadLErr);
    opcode = kOpCodeRecLenErr;
  }
  
  fStats.Inc(kStatNVTReadByt, ndone);

  return true;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::WriteRecord(size_t nbyt, const uint8_t* data, 
                                int& opcode, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTWriteRec);
  fStats.Inc(kStatNVTWriteByt, nbyt);

  opcode = kOpCodeBadFormat;
  if (fBad) return BadTapeMsg("WriteRecord()", emsg);

  fEom   = false;

  uint32_t meta = nbyt;
  uint8_t  zero = 0x00;

  if (!Write(sizeof(meta), reinterpret_cast<uint8_t*>(&meta), 
             false, emsg)) return SetBad();

  if (!Write(nbyt, data, 
             false, emsg)) return SetBad();
  if (fPadOdd && (nbyt&0x01)) {
    if (!Write(sizeof(zero), &zero, false, emsg)) return SetBad();
  }
  
  if (!Write(sizeof(meta), reinterpret_cast<uint8_t*>(&meta), 
             false, emsg)) return SetBad();
  if (!Write(sizeof(kMetaEom), reinterpret_cast<const uint8_t*>(&kMetaEom), 
             true, emsg)) return SetBad();

  IncPosRecord(+1);
  opcode = kOpCodeOK;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::WriteEof(RerrMsg& emsg)
{
  fStats.Inc(kStatNVTWriteEof);

  if (fBad) return BadTapeMsg("WriteEof()", emsg);

  fEom   = false;

  if (!Write(sizeof(kMetaEof), reinterpret_cast<const uint8_t*>(&kMetaEof), 
             false, emsg)) return SetBad();
  if (!Write(sizeof(kMetaEom), reinterpret_cast<const uint8_t*>(&kMetaEom), 
             true, emsg)) return SetBad();

  fPosFile   += 1;
  fPosRecord  = 0;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::SpaceForw(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTSpaForw);

  opcode = kOpCodeBadFormat;
  ndone  = 0;
  if (fBad) return BadTapeMsg("SpaceForw()", emsg);

  while (nrec > 0) {

    if (fPos == fSize) {
      fEom   = true;
      opcode = kOpCodeEom;
      return true;
    }

    uint32_t metabeg;

    if (!CheckSizeForw(sizeof(metabeg), "missed metabeg", emsg)) return SetBad();
    if (!Read(sizeof(metabeg), reinterpret_cast<uint8_t*>(&metabeg), 
              emsg)) return SetBad();
    
    if (metabeg == kMetaEof) {
      opcode = kOpCodeEof;
      fPosFile   += 1;
      fPosRecord  = 0;
      return true;
    }

    if (metabeg == kMetaEom) {
      if (!Seek(sizeof(metabeg), -1, emsg)) return SetBad();
      fEom   = true;
      opcode = kOpCodeEom;
      return true;
    }

    size_t rlen;
    bool   perr;
    if (!ParseMeta(metabeg, rlen, perr, emsg)) return SetBad();
    size_t rlenpad = BytePadding(rlen);

    if (!CheckSizeForw(sizeof(metabeg)+rlenpad, "missed data or metaend", emsg))
      return SetBad();
    if (!Seek(sizeof(metabeg)+rlenpad, +1, emsg)) return SetBad();    

    IncPosRecord(+1);
    nrec  -= 1;
    ndone += 1;
  }

  opcode = kOpCodeOK;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::SpaceBack(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTSpaBack);

  opcode = kOpCodeBadFormat;
  ndone  = 0;
  if (fBad) return BadTapeMsg("SpaceBack()", emsg);

  fEom = false;
  fTruncPend = true;

  while (nrec > 0) {

    if (fPos == 0) {
      opcode = kOpCodeBot;
      fPosFile    = 0;
      fPosRecord  = 0;
      return true;
    }

    uint32_t metaend;

    if (!CheckSizeBack(sizeof(metaend), "missed metaend", emsg)) return SetBad();
    if (!Seek(sizeof(metaend), -1, emsg)) return SetBad();
    if (!Read(sizeof(metaend), reinterpret_cast<uint8_t*>(&metaend), 
              emsg)) return SetBad();
    
    if (metaend == kMetaEof) {
      if (!Seek(sizeof(metaend), -1, emsg)) return SetBad();
      opcode = kOpCodeEof;
      fPosFile   -= 1;
      fPosRecord  = -1;
      return true;
    }

    if (metaend == kMetaEom) {
      emsg.Init("Rw11VirtTapeTap::SpaceBack()","unexpected EOM marker");
      return SetBad();
    }

    size_t rlen;
    bool   perr;
    if (!ParseMeta(metaend, rlen, perr, emsg)) return SetBad();
    size_t rlenpad = BytePadding(rlen);
    
    if (!CheckSizeBack(2*sizeof(metaend)+rlenpad, 
                       "missed data or metabeg", emsg)) return SetBad();
    if (!Seek(2*sizeof(metaend)+rlenpad, -1, emsg)) return SetBad();    

    IncPosRecord(-1);
    nrec  -= 1;
    ndone += 1;
  }

  opcode = kOpCodeOK;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::Rewind(int& opcode, RerrMsg& emsg)
{
  fStats.Inc(kStatNVTRewind);

  opcode = kOpCodeBadFormat;
  if (Seek(0, 0, emsg) <0) return SetBad();

  fBot = true;
  fEot = false;
  fEom = false;
  fPosFile   = 0;
  fPosRecord = 0;
  fBad = false;
  fTruncPend = true;

  opcode = kOpCodeOK;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTapeTap::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtTapeTap @ " << this << endl;

  os << bl << "  fFd:             " << fFd << endl;
  os << bl << "  fSize:           " << fSize << endl;
  os << bl << "  fPos:            " << fPos << endl;
  os << bl << "  fBad:            " << fBad << endl;
  os << bl << "  fPadOdd:         " << fPadOdd << endl;
  Rw11VirtTape::Dump(os, ind, " ^");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::Seek(size_t seekpos, int dir, RerrMsg& emsg)
{
  off_t offset = seekpos;
  int   whence = SEEK_SET;
  if (dir > 0) {
    whence = SEEK_CUR;
  } else if (dir < 0) {
    whence = SEEK_CUR;
    offset = -offset;
  }
  if (::lseek(fFd, offset, whence) < 0) {
    emsg.InitErrno("Rw11VirtTapeTap::Seek()", "seek() failed: ", errno);
    return false;
  }

  UpdatePos(seekpos, dir);

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::Read(size_t nbyt, uint8_t* data, RerrMsg& emsg)
{
   ssize_t irc = ::read(fFd, data, nbyt);
  if (irc < 0) {
    emsg.InitErrno("Rw11VirtTapeTap::Read()", "read() failed: ", errno);
    return false;
  }
  UpdatePos(nbyt, +1);
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::Write(size_t nbyt, const uint8_t* data, bool back,
                               RerrMsg& emsg)
{
  if (fTruncPend) {
    if (ftruncate(fFd, fPos) < 0) {
      emsg.InitErrno("Rw11VirtTapeTap::Write()", "ftruncate() failed: ", errno);
      return false;
    }
    fTruncPend = false;    
    fSize = fPos;
  }

  ssize_t irc = ::write(fFd, data, nbyt);
  if (irc < 0) {
    emsg.InitErrno("Rw11VirtTapeTap::Write()", "write() failed: ", errno);
    return false;
  }

  UpdatePos(nbyt, +1);
  if (fPos > fSize) fSize = fPos;

  if (back) {
    if (!Seek(nbyt, -1, emsg)) return false;
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::CheckSizeForw(size_t nbyt, const char* text, 
                                     RerrMsg& emsg)
{
  if (fPos+nbyt <= fSize) return true;
  emsg.Init("Rw11VirtTapeTap::CheckSizeForw()", text);
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::CheckSizeBack(size_t nbyt, const char* text, 
                                     RerrMsg& emsg)
{
  if (nbyt <= fPos) return true;
  emsg.Init("Rw11VirtTapeTap::CheckSizeBack()", text);
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtTapeTap::UpdatePos(size_t nbyt, int dir)
{
  if (dir == 0) {
    fPos  = nbyt;
  } else if (dir > 0) {
    fPos += nbyt;
  } else {
    fPos -= nbyt;
  }

  fBot = (fPos == 0);
  fEot = (fCapacity == 0) ? false : (fPos > fCapacity);

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::ParseMeta(uint32_t meta, size_t& rlen, bool& perr, 
                                 RerrMsg& emsg)
{
  rlen = meta & kMeta_B_Rlen;
  perr = meta & kMeta_M_Perr;
  if (meta & kMeta_M_Mbz) {
    emsg.Init("Rw11VirtTapeTap::ParseMeta", "bad meta tag");
    return false;
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtTapeTap::BadTapeMsg(const char* meth, RerrMsg& emsg)
{
  emsg.Init(string("Rw11VirtTapeTap::")+meth, "bad tape format");
  return false;
}

} // end namespace Retro
