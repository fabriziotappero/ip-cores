// $Id: RtclRw11Unit.cpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11Unit.cpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Implemenation of RtclRw11Unit.
*/

#include "boost/thread/locks.hpp"
#include "boost/bind.hpp"

#include "librtcltools/RtclStats.hpp"

#include "RtclRw11Unit.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11Unit
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RtclRw11Unit::RtclRw11Unit(const std::string& type, Rw11Cpu* pcpu)
  : RtclProxyBase(type),
    fpCpu(pcpu),
    fGets(),
    fSets()
{
  AddMeth("get",      boost::bind(&RtclRw11Unit::M_get,     this, _1));
  AddMeth("set",      boost::bind(&RtclRw11Unit::M_set,     this, _1));
  AddMeth("attach",   boost::bind(&RtclRw11Unit::M_attach,  this, _1));
  AddMeth("detach",   boost::bind(&RtclRw11Unit::M_detach,  this, _1));
  AddMeth("dump",     boost::bind(&RtclRw11Unit::M_dump,    this, _1));
  AddMeth("$default", boost::bind(&RtclRw11Unit::M_default, this, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11Unit::~RtclRw11Unit()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_get(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(fpCpu->Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_set(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(fpCpu->Connect());
  return fSets.M_set(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_attach(RtclArgs& args)
{
  string url;
  if (!args.GetArg("url", url)) return kERR;

  if (!args.AllDone()) return kERR;

  RerrMsg emsg;
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(fpCpu->Connect());
  if (!Obj().Attach(url, emsg)) return args.Quit(emsg);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_detach(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(fpCpu->Connect());
  Obj().Detach();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_dump(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  ostringstream sos;
  Obj().Dump(sos, 0);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11Unit::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;
  sos << "no default output defined yet...\n";
  args.AppendResultLines(sos);
  return kOK;
}

} // end namespace Retro
