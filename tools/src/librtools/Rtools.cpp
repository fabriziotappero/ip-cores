// $Id: Rtools.cpp 606 2014-11-24 07:08:51Z mueller $
//
// Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-11-23   606   1.0.4  add TimeOfDayAsDouble()
// 2014-11-08   602   1.0.5  add (int) cast in snprintf to match %d type
// 2014-08-22   584   1.0.4  use nullptr
// 2013-05-04   516   1.0.3  add CreateBackupFile()
// 2013-02-13   481   1.0.2  remove Throw(Logic|Runtime)(); use Rexception
// 2011-04-10   376   1.0.1  add ThrowLogic(), ThrowRuntime()
// 2011-03-12   368   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rtools.cpp 606 2014-11-24 07:08:51Z mueller $
  \brief   Implemenation of Rtools .
*/

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>

#include <iostream>
#include <vector>

#include "Rexception.hpp"

#include "Rtools.hpp"

using namespace std;

/*!
  \namespace Retro::Rtools
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {
namespace Rtools {

//------------------------------------------+-----------------------------------
//! FIXME_docs

std::string Flags2String(uint32_t flags, const RflagName* fnam, char delim)
{
  if (fnam == nullptr)
    throw Rexception("Rtools::Flags2String()","Bad args: fnam==nullptr");

  string rval;
  while (fnam->mask) {
    if (flags & fnam->mask) {
      if (!rval.empty()) rval += delim;
      rval += fnam->name;
    }
    fnam++;
  }
  return rval;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool String2Long(const std::string& str, long& res, RerrMsg& emsg, int base)
{
  char* endptr;
  res = ::strtol(str.c_str(), &endptr, base);
  if (*endptr == 0) return true;

  emsg.Init("Rtools::String2Long", 
            string("conversion error in '") + str +"'");
  res = 0;
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool String2Long(const std::string& str, unsigned long& res,
                 RerrMsg& emsg, int base)
{
  char* endptr;
  res = ::strtoul(str.c_str(), &endptr, base);
  if (*endptr == 0) return true;

  emsg.Init("Rtools::String2Long", 
            string("conversion error in '") + str +"'");
  res = 0;
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool CreateBackupFile(const std::string& fname, size_t nbackup, RerrMsg& emsg)
{
  if (nbackup == 0) return true;
  
  size_t dotpos = fname.find_last_of('.');
  string fbase = fname.substr(0,dotpos);
  string fext  = fname.substr(dotpos);
  
  if (nbackup > 99) {
    emsg.Init("Rtools::CreateBackupFile", 
              "only up to 99 backup levels supported");
    return false;
  }
  
  vector<string> fnames;
  fnames.push_back(fname);
  for (size_t i=1; i<=nbackup; i++) {
    char fnum[4];
    snprintf(fnum, 4, "%d", (int)i);
    fnames.push_back(fbase + "_" + fnum + fext);
  }
  
  for (size_t i=nbackup; i>0; i--) {
    string fnam_new = fnames[i];
    string fnam_old = fnames[i-1];

    struct stat sbuf;
    int irc = ::stat(fnam_old.c_str(), &sbuf);
    if (irc < 0) {
      if (errno == ENOENT) continue;
      emsg.InitErrno("Rtools::CreateBackupFile", 
                     string("stat() for '") + fnam_old + "'failed: ", errno);
      return false;
    }
    if (S_ISREG(sbuf.st_mode) == 0) {
      emsg.Init("Rtools::CreateBackupFile", 
                "backups only supported for regular files");
      return false;
    }
    // here we know old file exists and is a regular file
    irc = ::rename(fnam_old.c_str(), fnam_new.c_str());
    if (irc < 0) {
      emsg.InitErrno("Rtools::CreateBackupFile", 
                     string("rename() for '") + fnam_old + "' -> '" +
                     fnam_new + "'failed: ", errno);
      return false;
    }
  }

  return true;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

bool CreateBackupFile(const RparseUrl& purl, RerrMsg& emsg)
{
  string bck;
  if (!purl.FindOpt("app") && purl.FindOpt("bck", bck)) {
    unsigned long nbck;
    if (!Rtools::String2Long(bck, nbck, emsg)) return false;
    if (nbck > 0) {
      if (!Rtools::CreateBackupFile(purl.Path(), nbck, emsg)) return false;
    }
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! Returns the time-of-day as \c double value
/*!
  Calls \c gettimeofday() and returns the current time as a \c double.
  This is convenient for calculations with time values.

  \returns time is seconds as \a double with micro second resolution.
  \throws Rexception in case \c gettimeofday() fails.
 */

double TimeOfDayAsDouble()
{
  struct timeval tval;
  int irc = ::gettimeofday(&tval, 0);
  if (irc < 0) {
    throw Rexception("Rtools::TimeOfDayAsDouble()",
                     "gettimeofday failed with ", errno);
  }
  
  return double(tval.tv_sec) + 1.e-6*double(tval.tv_usec);
}

} // end namespace Rtools
} // end namespace Retro
