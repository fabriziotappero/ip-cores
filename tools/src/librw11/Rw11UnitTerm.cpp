// $Id: Rw11UnitTerm.cpp 516 2013-05-05 21:24:52Z mueller $
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
// 2013-05-03   515   1.1    use AttachDone(),DetachCleanup(),DetachDone()
// 2013-04-13   504   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitTerm.cpp 516 2013-05-05 21:24:52Z mueller $
  \brief   Implemenation of Rw11UnitTerm.
*/

#include "boost/thread/locks.hpp"
#include "boost/bind.hpp"

#include "librtools/RparseUrl.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"

#include "Rw11UnitTerm.hpp"

using namespace std;

/*!
  \class Retro::Rw11UnitTerm
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11UnitTerm::Rw11UnitTerm(Rw11Cntl* pcntl, size_t index)
  : Rw11UnitVirt<Rw11VirtTerm>(pcntl, index),
    fTo7bit(false),
    fToEnpc(false),
    fTi7bit(false),
    fRcvQueue(),
    fLogFname(),
    fLogStream(),
    fLogOptCrlf(false),
    fLogCrPend(false),
    fLogLfLast(false)
{
  fStats.Define(kStatNPreAttDrop,    "NPreAttDrop",
                "snd bytes dropped prior attach");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11UnitTerm::~Rw11UnitTerm()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const std::string& Rw11UnitTerm::ChannelId() const
{
  if (fpVirt) return fpVirt->ChannelId();
  static string nil;
  return nil;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTerm::SetLog(const std::string& fname)
{
  if (fLogStream.is_open()) {
    if (fLogCrPend) fLogStream << "\r";
    fLogCrPend = false;
    fLogStream.close();
  }
  
  fLogFname.clear();
  if (fname.length() == 0) return;

  RparseUrl purl;
  RerrMsg emsg;
  if (!purl.Set(fname, "|app|bck=|crlf|", emsg)) 
    throw Rexception(emsg);
  if (!Rtools::CreateBackupFile(purl, emsg))
    throw Rexception(emsg);

  ios_base::openmode mode = ios_base::out;
  if (purl.FindOpt("app")) mode |= ios_base::app;

  fLogStream.open(purl.Path(), mode);
  if (!fLogStream.is_open()) {
    throw Rexception("Rw11UnitTerm::SetLog",
                     string("failed to open '")+purl.Path()+"'");
  }

  fLogFname = fname;
  fLogOptCrlf = purl.FindOpt("crlf");
  fLogCrPend = false;
  fLogLfLast = false;

  return;
}  

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTerm::RcvQueueEmpty()
{
  return fRcvQueue.empty();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t Rw11UnitTerm::RcvQueueSize()
{
  return fRcvQueue.size();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

uint8_t Rw11UnitTerm::RcvNext()
{
  if (RcvQueueEmpty()) return 0;
  uint8_t ochr = fRcvQueue.front();
  fRcvQueue.pop_front();
  return ochr;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t Rw11UnitTerm::Rcv(uint8_t* buf, size_t count)
{
  uint8_t* p = buf;
  for (size_t i=0; i<count && !fRcvQueue.empty(); i++) {
    *p++ = fRcvQueue.front();
    fRcvQueue.pop_front();
  }
  return p - buf;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTerm::Snd(const uint8_t* buf, size_t count)
{
  bool ok = true;
  vector<uint8_t> bufmod;
  const uint8_t* bufout = buf;
  size_t bufcnt = count;

  if (fTo7bit || fToEnpc) {
    for (size_t i=0; i<count; i++) {
      uint8_t ochr = buf[i];
      if (fTo7bit) ochr &= 0177;
      if (fToEnpc) {
        if ((ochr>=040 && ochr<177) ||
             ochr=='\t' || ochr=='\n' || ochr=='\r') {
          bufmod.push_back(ochr);
        } else {
          if (ochr != 0) {
            bufmod.push_back('<');
            bufmod.push_back('0' + ((ochr>>6)&07) );
            bufmod.push_back('0' + ((ochr>>3)&07) );
            bufmod.push_back('0' +  (ochr    &07) );
            bufmod.push_back('>');
          }
        }
        
      } else {
        bufmod.push_back(ochr);
      }
    }
    bufout = bufmod.data();
    bufcnt = bufmod.size();
  }

  if (fLogStream.is_open()) {
    for (size_t i=0; i<bufcnt; i++) {
      uint8_t ochr = bufout[i];
      // the purpose of the 'crlf' filter is to map
      //   \r\n   -> \n
      //   \r\r\n -> \n  (any number of \r)
      //   \n\r   -> \n
      //   \n\r\r -> \n  (any number of \r)
      // and to ignore \0 chars
      if (fLogOptCrlf) {                    // crlf filtering on
        if (ochr == 0) continue;              // ignore \0 chars
        if (fLogCrPend) {
          if (ochr == '\r') continue;         // collapes multiple \r
          if (ochr != '\n') fLogStream << '\r'; // log \r if not followed by \n
          fLogCrPend = false;
        }
        if (ochr == '\r') {                   // \r seen 
          fLogCrPend = !fLogLfLast;           // remember \r if last wasn't \n 
          continue;
        }
      }
      fLogStream << char(ochr);
      fLogLfLast = (ochr == '\n');
    }
  }

  if (fpVirt) {                             // if virtual device attached
    RerrMsg emsg;
    ok = fpVirt->Snd(bufout, bufcnt, emsg);
    // FIXME_code: handler errors
    
  } else {                                  // no virtual device attached
    if (Name() == "tta0") {                 // is it main console ?
      for (size_t i=0; i<bufcnt; i++) {       // than print to stdout 
        cout << char(bufout[i]) << flush;
      }
    } else {                                // otherwise discard
      fStats.Inc(kStatNPreAttDrop);         // and count at least...
    }
  }
  return ok;
}


//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rw11UnitTerm::RcvCallback(const uint8_t* buf, size_t count)
{
  // lock connect to protect rxqueue
  boost::lock_guard<RlinkConnect> lock(Connect());

  bool que_empty_old = fRcvQueue.empty();
  for (size_t i=0; i<count; i++) {
    uint8_t ichr = buf[i];
    if (fTi7bit) ichr &= 0177;
    fRcvQueue.push_back(ichr);
  }
  bool que_empty_new = fRcvQueue.empty();
  if (que_empty_old && !que_empty_new) WakeupCntl();
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTerm::WakeupCntl()
{
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTerm::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11UnitTerm @ " << this << endl;

  os << bl << "  fTo7bit:         " << fTo7bit << endl;
  os << bl << "  fToEnpc:         " << fToEnpc << endl;
  os << bl << "  fTi7bit:         " << fTi7bit << endl;
  {
    boost::lock_guard<RlinkConnect> lock(Connect());
    size_t size = fRcvQueue.size();
    os << bl << "  fRcvQueue.size:  " << fRcvQueue.size() << endl;
    if (size > 0) {
      os << bl << "  fRcvQueue:       \"";
      size_t ocount = 0;
      for (size_t i=0; i<size; i++) {
        if (ocount >= 50) {
          os << "...";
          break;
        }
        uint8_t byt = fRcvQueue[i];
        if (byt >= 040 && byt <= 0176) {
          os << char(byt);
          ocount += 1;
        } else {
          os << "<" << RosPrintf(byt,"o0",3) << ">";
          ocount += 5;
        }
      }
      os << "\"" << endl;
    }
  }
  
  os << bl << "  fLogFname:       " << fLogFname << endl;
  os << bl << "  fLogStream.is_open: " << fLogStream.is_open() << endl;
  os << bl << "  fLogOptCrlf:     " << fLogOptCrlf << endl;
  os << bl << "  fLogCrPend:      " << fLogCrPend << endl;
  os << bl << "  fLogLfLast:      " << fLogLfLast << endl;

  Rw11UnitVirt<Rw11VirtTerm>::Dump(os, ind, " ^");
  return;
} 

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11UnitTerm::AttachDone()
{
  fpVirt->SetupRcvCallback(boost::bind(&Rw11UnitTerm::RcvCallback,
                                           this, _1, _2));
  return;
}


} // end namespace Retro
