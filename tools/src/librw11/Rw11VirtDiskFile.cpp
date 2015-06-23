// $Id: Rw11VirtDiskFile.cpp 684 2015-05-24 14:10:59Z mueller $
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
  \version $Id: Rw11VirtDiskFile.cpp 684 2015-05-24 14:10:59Z mueller $
  \brief   Implemenation of Rw11VirtDiskFile.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "librtools/RosFill.hpp"

#include "Rw11VirtDiskFile.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtDiskFile
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtDiskFile::Rw11VirtDiskFile(Rw11Unit* punit)
  : Rw11VirtDisk(punit),
    fFd(0)
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtDiskFile::~Rw11VirtDiskFile()
{
  if (fFd > 2) ::close(fFd);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskFile::Open(const std::string& url, RerrMsg& emsg)
{
  if (!fUrl.Set(url, "|wpro|", emsg)) return false;

  bool wpro = fUrl.FindOpt("wpro");
  
  int fd = ::open(fUrl.Path().c_str(), wpro ? O_RDONLY : O_RDWR);
  if (fd < 0) {
    emsg.InitErrno("Rw11VirtDiskFile::Open()", 
                   string("open() for '") + fUrl.Path() + "' failed: ", errno);
    return false;
  }

  struct stat sbuf;
  if (::fstat(fd, &sbuf) < 0) {
    emsg.InitErrno("Rw11VirtDiskFile::Open()", 
                   string("stat() for '") + fUrl.Path() + "' failed: ", errno);
    return false;
  }

  fFd = fd;
  fSize = sbuf.st_size;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskFile::Read(size_t lba, size_t nblk, uint8_t* data, 
                            RerrMsg& emsg)
{
  fStats.Inc(kStatNVDRead);
  fStats.Inc(kStatNVDReadBlk, double(nblk));

  size_t seekpos = fBlkSize * lba;
  size_t nbyt    = fBlkSize * nblk;

  if (seekpos >= fSize) {
    uint8_t* p = data;
    for (size_t i=0; i<nbyt; i++) *p++ = 0;
    return true;
  }

  if (!Seek(seekpos, emsg)) return false;
  
  ssize_t irc = ::read(fFd, data, nbyt);
  if (irc < 0) {
    emsg.InitErrno("Rw11VirtDiskFile::Read()", "read() failed: ", errno);
    return false;
  }

  if (irc < ssize_t(nbyt)) {
    uint8_t* p = data+irc;
    for (size_t i=irc; i<nbyt; i++) *p++ = 0;    
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskFile::Write(size_t lba, size_t nblk, const uint8_t* data, 
                             RerrMsg& emsg)
{
  fStats.Inc(kStatNVDWrite);
  fStats.Inc(kStatNVDWriteBlk, double(nblk));

  size_t seekpos = fBlkSize * lba;
  size_t nbyt    = fBlkSize * nblk;

  if (!Seek(seekpos, emsg)) return false;

  ssize_t irc = ::write(fFd, data, nbyt);
  if (irc < ssize_t(nbyt)) {
    emsg.InitErrno("Rw11VirtDiskFile::Write()", "write() failed: ", errno);
    return false;
  }

  if (seekpos+nbyt > fSize) fSize = seekpos+nbyt;

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtDiskFile::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtDiskFile @ " << this << endl;

  os << bl << "  fFd:             " << fFd << endl;
  os << bl << "  fSize:           " << fSize << endl;
  Rw11VirtDisk::Dump(os, ind, " ^");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtDiskFile::Seek(size_t seekpos, RerrMsg& emsg)
{
  if (::lseek(fFd, seekpos, SEEK_SET) < 0) {
    emsg.InitErrno("Rw11VirtDiskFile::Seek()", "seek() failed: ", errno);
    return false;
  }

  return true;
}

} // end namespace Retro
