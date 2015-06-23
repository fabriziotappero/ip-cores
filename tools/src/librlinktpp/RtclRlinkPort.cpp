// $Id: RtclRlinkPort.cpp 632 2015-01-11 12:30:03Z mueller $
//
// Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-01-09   632   1.0.4  add M_get, M_set, remove M_config
// 2014-08-22   584   1.0.3  use nullptr
// 2013-02-23   492   1.0.2  use RlogFile.Name();
// 2013-02-22   491   1.0.1  use new RlogFile/RlogMsg interfaces
// 2013-01-27   478   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRlinkPort.cpp 632 2015-01-11 12:30:03Z mueller $
  \brief   Implemenation of class RtclRlinkPort.
 */

#include <ctype.h>

#include <iostream>

#include "boost/bind.hpp"

#include "librtcltools/Rtcl.hpp"
#include "librtcltools/RtclOPtr.hpp"
#include "librtcltools/RtclNameSet.hpp"
#include "librtcltools/RtclStats.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RlogFile.hpp"
#include "librlink/RlinkPortFactory.hpp"

#include "RtclRlinkPort.hpp"

using namespace std;

/*!
  \class Retro::RtclRlinkPort
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RtclRlinkPort::RtclRlinkPort(Tcl_Interp* interp, const char* name)
  : RtclProxyBase("RlinkPort"),
    fpObj(nullptr),
    fspLog(new RlogFile(&cout)),
    fTraceLevel(0),
    fErrCnt(0)
{
  CreateObjectCmd(interp, name);
  AddMeth("open",     boost::bind(&RtclRlinkPort::M_open,    this, _1));
  AddMeth("close",    boost::bind(&RtclRlinkPort::M_close,   this, _1));
  AddMeth("errcnt",   boost::bind(&RtclRlinkPort::M_errcnt,  this, _1));
  AddMeth("rawio",    boost::bind(&RtclRlinkPort::M_rawio,   this, _1));
  AddMeth("stats",    boost::bind(&RtclRlinkPort::M_stats,   this, _1));
  AddMeth("log",      boost::bind(&RtclRlinkPort::M_log,     this, _1));
  AddMeth("dump",     boost::bind(&RtclRlinkPort::M_dump,    this, _1));
  AddMeth("get",      boost::bind(&RtclRlinkPort::M_get,     this, _1));
  AddMeth("set",      boost::bind(&RtclRlinkPort::M_set,     this, _1));
  AddMeth("$default", boost::bind(&RtclRlinkPort::M_default, this, _1));

  SetupGetSet();
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRlinkPort::~RtclRlinkPort()
{
  delete fpObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_open(RtclArgs& args)
{
  string path;

  if (!args.GetArg("?path", path)) return kERR;
  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  if (args.NOptMiss() == 0) {               // open path
    delete fpObj;
    fpObj = RlinkPortFactory::Open(path, emsg);
    SetupGetSet();
    if (!fpObj) return args.Quit(emsg);
    fpObj->SetLogFile(fspLog);
    fpObj->SetTraceLevel(fTraceLevel);
  } else {                                  // open
    string name = (fpObj && fpObj->IsOpen()) ? fpObj->Url().Url() : string();
    args.SetResult(name);
  }
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_close(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  if (!TestOpen(args)) return kERR;
  delete fpObj;
  fpObj = nullptr;
  SetupGetSet();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_errcnt(RtclArgs& args)
{
  static RtclNameSet optset("-clear");
  string opt;
  bool fclear = false;
  
  while (args.NextOpt(opt, optset)) {
    if (opt == "-clear") fclear = true;
  }
  if (!args.AllDone()) return kERR;

  args.SetResult(int(fErrCnt));
  if (fclear) fErrCnt = 0;

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_rawio(RtclArgs& args)
{
  return DoRawio(args, fpObj, fErrCnt);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;

  if (!TestOpen(args)) return kERR;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Collect(args, cntx, fpObj->Stats())) return kERR;
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_log(RtclArgs& args)
{
  string msg;
  if (!args.GetArg("msg", msg)) return kERR;
  if (!args.AllDone()) return kERR;
  if (fTraceLevel != 0) fspLog->Write(string("# ") + msg);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_dump(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  if (!TestOpen(args)) return kERR;

  ostringstream sos;
  fpObj->Dump(sos, 0);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_get(RtclArgs& args)
{
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_set(RtclArgs& args)
{
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;

  sos << "logfile:     " << fspLog->Name()
      << "   tracelevel " << fTraceLevel; 

  args.AppendResultLines(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRlinkPort::SetupGetSet()
{
  fGets.Clear();
  fSets.Clear();

  fGets.Add<const string&>  ("logfile", 
                        boost::bind(&RtclRlinkPort::LogFileName, this));
  fSets.Add<const string&>  ("logfile", 
                        boost::bind(&RtclRlinkPort::SetLogFileName, this, _1));

  if (fpObj == nullptr) return;

  fGets.Add<uint32_t>  ("tracelevel", 
                        boost::bind(&RlinkPort::TraceLevel, fpObj));
  fSets.Add<uint32_t>  ("tracelevel", 
                        boost::bind(&RlinkPort::SetTraceLevel, fpObj, _1));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclRlinkPort::TestOpen(RtclArgs& args)
{
  if (fpObj) return true;
  args.AppendResult("-E: port not open", nullptr);
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclRlinkPort::SetLogFileName(const std::string& name)
{
  RerrMsg emsg;
  if (!fspLog->Open(name, emsg)) {
    fspLog->UseStream(&cout);
    throw Rexception("RtclRlinkPort::SetLogFile", 
                     emsg.Text() + "', using stdout");
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline std::string RtclRlinkPort::LogFileName() const
{
  return fspLog->Name();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRlinkPort::DoRawio(RtclArgs& args, RlinkPort* pport, size_t& errcnt)
{
  static RtclNameSet optset("-rblk|-wblk|-edata|-timeout");

  if (!pport || !pport->IsOpen()) args.Quit("-E: port not open");

  string opt;
  char mode = 0;

  int32_t rsize;
  string rvname;
  vector<uint8_t> rdata;
  vector<uint8_t> wdata;
  vector<uint8_t> edata;
  vector<uint8_t> emask;
  double timeout = 1.;

  while (args.NextOpt(opt, optset)) {
    if        (opt == "-rblk") {            // -rblk size ?varData ------------
      if (mode) return args.Quit("-E: only one -rblk or -wblk allowed");
      mode = 'r';
      if (!args.GetArg("bsize", rsize, 1, 256)) return kERR;
      if (!args.GetArg("??varData", rvname)) return kERR;

    } else if (opt == "-wblk") {            // -wblk block --------------------
      if (mode) return args.Quit("-E: only one -rblk or -wblk allowed");
      mode = 'w';
      if (!args.GetArg("data", wdata, 1, 256)) return kERR;

    } else if (opt == "-edata") {           // -edata data ?mask --------------
      if (mode != 'r') return args.Quit("-E: -edata only allowed after -rblk");
      if (!args.GetArg("data", edata, 0, rsize)) return kERR;
      if (!args.GetArg("??mask", emask, 0, rsize)) return kERR;

    } else if (opt == "-timeout") {         // -timeout tsec ------------------
      if (!args.GetArg("tsec", timeout, 0.)) return kERR;
    }
  }
  
  if (!args.AllDone()) return kERR;

  if (!mode) return args.Quit("-E: no -rblk or -wblk given");

  if (mode == 'r') {                        // handle -rblk ------------------
    RerrMsg emsg;
    double tused = 0.;
    rdata.resize(rsize);
    int irc = pport->RawRead(rdata.data(), rdata.size(), true, timeout, 
                             tused, emsg);
    if (irc == RlinkPort::kErr) return args.Quit("-E: timeout on -rblk");
    if (irc != (int)rdata.size()) return args.Quit(emsg);
    if (rvname.length()) {
      RtclOPtr pres(Rtcl::NewListIntObj(rdata));
      if(!Rtcl::SetVar(args.Interp(), rvname, pres)) return kERR;
    }
    if (edata.size()) {
      size_t nerr=0;
      for (size_t i=0; i<rdata.size(); i++) {
        if (i >= edata.size()) break;
        uint8_t eval = edata[i];
        uint8_t emsk = (i < emask.size()) ? emask[i] : 0x0000;
        if ((rdata[i]|emsk) != (eval|emsk)) nerr += 1;
      }
      if (nerr) errcnt += 1;
    }
    args.SetResult(tused);

  } else {                                  // handle -wblk ------------------
    RerrMsg emsg;
    int irc = pport->RawWrite(wdata.data(), wdata.size(), emsg);
    if (irc != (int)wdata.size()) return args.Quit(emsg);
  }

  return kOK;
}

} // end namespace Retro
