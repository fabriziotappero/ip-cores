// $Id: RtclRw11Cntl.cpp 660 2015-03-29 22:10:16Z mueller $
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
// 2015-03-27   660   1.0.1  add M_start
// 2013-03-06   495   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11Cntl.cpp 660 2015-03-29 22:10:16Z mueller $
  \brief   Implemenation of RtclRw11Cntl.
*/

#include "boost/thread/locks.hpp"
#include "boost/bind.hpp"

#include "librtcltools/RtclStats.hpp"

#include "RtclRw11Cntl.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11Cntl
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11Cntl::RtclRw11Cntl(const std::string& type)
  : RtclProxyBase(type),
    fGets(),
    fSets()
{
  AddMeth("get",      boost::bind(&RtclRw11Cntl::M_get,     this, _1));
  AddMeth("set",      boost::bind(&RtclRw11Cntl::M_set,     this, _1));
  AddMeth("probe",    boost::bind(&RtclRw11Cntl::M_probe,   this, _1));
  AddMeth("start",    boost::bind(&RtclRw11Cntl::M_start,   this, _1));
  AddMeth("stats",    boost::bind(&RtclRw11Cntl::M_stats,   this, _1));
  AddMeth("dump",     boost::bind(&RtclRw11Cntl::M_dump,    this, _1));
  AddMeth("$default", boost::bind(&RtclRw11Cntl::M_default, this, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11Cntl::~RtclRw11Cntl()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_get(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Obj().Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_set(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Obj().Connect());
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_probe(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  args.SetResult(Obj().Probe());
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_start(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  Obj().Probe();
  Obj().Start();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Collect(args, cntx, Obj().Stats())) return kERR;
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_dump(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  ostringstream sos;
  Obj().Dump(sos, 0);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Cntl::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;
  sos << "no default output defined yet...\n";
  args.AppendResultLines(sos);
  return kOK;
}

} // end namespace Retro
