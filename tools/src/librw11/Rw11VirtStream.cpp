// $Id: Rw11VirtStream.cpp 516 2013-05-05 21:24:52Z mueller $
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
// 2013-05-05   516   1.0.1  Open(): support ?app and ?bck=n options
// 2013-05-04   515   1.0    Initial version
// 2013-05-01   513   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11VirtStream.cpp 516 2013-05-05 21:24:52Z mueller $
  \brief   Implemenation of Rw11VirtStream.
*/
#include <memory>

#include "librtools/Rtools.hpp"
#include "librtools/Rexception.hpp"
#include "librtools/RparseUrl.hpp"
#include "librtools/RosFill.hpp"

#include "Rw11VirtStream.hpp"

using namespace std;

/*!
  \class Retro::Rw11VirtStream
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rw11VirtStream::Rw11VirtStream(Rw11Unit* punit)
  : Rw11Virt(punit),
    fIStream(false),
    fOStream(false),
    fFile(0)
{
  fStats.Define(kStatNVSRead,    "NVSRead",     "Read() calls");
  fStats.Define(kStatNVSReadByt, "NVSReadByt",  "bytes read");
  fStats.Define(kStatNVSWrite,   "NVSWrite",    "Write() calls");
  fStats.Define(kStatNVSWriteByt,"NVSWriteByt", "bytes written");
  fStats.Define(kStatNVSFlush,   "NVSFlush",    "Flush() calls");
  fStats.Define(kStatNVSTell,    "NVSTell",     "Tell() calls");
  fStats.Define(kStatNVSSeek,    "NVSSeek",     "Seek() calls");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11VirtStream::~Rw11VirtStream()
{
  if (fFile) ::fclose(fFile);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtStream::Open(const std::string& url, RerrMsg& emsg)
{
  RparseUrl  opts;
  if (!opts.Set(fpUnit->AttachOpts(), "|ronly|wonly|", emsg)) return false;
  fIStream = opts.FindOpt("ronly");
  fOStream = opts.FindOpt("wonly");
  if (!(fIStream ^ fOStream)) 
    throw Rexception("Rw11VirtStream::Open", 
                     "Bad state: neither ronly nor wonly seen");

  if (fOStream) {                           // handle output streams
    if (!fUrl.Set(url, "|app|bck=|", emsg)) return false;
    if (!Rtools::CreateBackupFile(fUrl, emsg)) return false;
        
    fFile = ::fopen(fUrl.Path().c_str(), fUrl.FindOpt("app") ? "a" : "w");

  } else {                                  // handle input  streams
    if (!fUrl.Set(url, "", emsg)) return false;
    fFile = ::fopen(fUrl.Path().c_str(), "r");
  }

  if (!fFile) {
    emsg.InitErrno("Rw11VirtStream::Open()", 
                   string("fopen() for '") + fUrl.Path() + "' failed: ",
                   errno);
    return false;
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11VirtStream::Read(uint8_t* data, size_t count, RerrMsg& emsg)
{
  if (!fIStream)
    throw Rexception("Rw11VirtStream::Read", 
                     "Bad state: Read() called but fIStream=false");
  if (!fFile) 
    throw Rexception("Rw11VirtStream::Read", "Bad state: file not open");

  fStats.Inc(kStatNVSRead);
  size_t irc = ::fread(data, 1, count, fFile);
  if (irc == 0 && ferror(fFile)) {
    emsg.InitErrno("Rw11VirtStream::Read()", "fread() failed: ", errno);
    return -1;
  }
  
  fStats.Inc(kStatNVSReadByt, double(irc));
  return int(irc);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtStream::Write(const uint8_t* data, size_t count, RerrMsg& emsg)
{
  if (!fOStream)
    throw Rexception("Rw11VirtStream::Write", 
                     "Bad state: Write() called but fOStream=false");
  if (!fFile) 
    throw Rexception("Rw11VirtStream::Write", "Bad state: file not open");

  fStats.Inc(kStatNVSWrite);
  size_t irc = ::fwrite(data, 1, count, fFile);
  if (irc != count) {
    emsg.InitErrno("Rw11VirtStream::Write()", "fwrite() failed: ", errno);
    return false;
  }

  fStats.Inc(kStatNVSWriteByt, double(count));
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtStream::Flush(RerrMsg& emsg)
{
  if (!fOStream) return true;
  if (!fFile) 
    throw Rexception("Rw11VirtStream::Write", "Bad state: file not open");

  fStats.Inc(kStatNVSFlush);
  size_t irc = ::fflush(fFile);
  if (irc != 0) {
    emsg.InitErrno("Rw11VirtStream::Flush()", "fflush() failed: ", errno);
    return false;
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11VirtStream::Tell(RerrMsg& emsg)
{
  if (!fFile) 
    throw Rexception("Rw11VirtStream::Tell", "Bad state: file not open");

  fStats.Inc(kStatNVSTell);
  long irc = ::ftell(fFile);
  if (irc < 0) {
    emsg.InitErrno("Rw11VirtStream::Tell()", "ftell() failed: ", errno);
    return -1;
  }

  return int(irc);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11VirtStream::Seek(int pos, RerrMsg& emsg)
{
  if (!fFile) 
    throw Rexception("Rw11VirtStream::Seek", "Bad state: file not open");

  fStats.Inc(kStatNVSSeek);
  int whence = SEEK_SET;
  if (pos < 0) {
    pos = 0;
    whence = SEEK_END;
  }
  int irc = ::fseek(fFile, pos, whence);

  if (irc < 0) {
    emsg.InitErrno("Rw11VirtStream::Seek()", "fseek() failed: ", errno);
    return false;
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11VirtStream::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11VirtStream @ " << this << endl;

  os << bl << "  fIStream:        " << fIStream << endl;
  os << bl << "  fOStream:        " << fOStream << endl;
  os << bl << "  fFile:           " << fFile << endl;
  Rw11Virt::Dump(os, ind, " ^");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rw11VirtStream* Rw11VirtStream::New(const std::string& url, Rw11Unit* punit,
                                RerrMsg& emsg)
{
  unique_ptr<Rw11VirtStream> p;
  p.reset(new Rw11VirtStream(punit));
  if (p->Open(url, emsg)) return p.release();
  return 0;
}


} // end namespace Retro
