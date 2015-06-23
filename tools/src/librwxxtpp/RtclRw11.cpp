// $Id: RtclRw11.cpp 660 2015-03-29 22:10:16Z mueller $
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
// 2015-03-28   660   1.0.1  add M_get
// 2014-12-25   621   1.1    adopt to 4k word ibus window
// 2013-03-06   495   1.0    Initial version
// 2013-01-27   478   0.1    First Draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11.cpp 660 2015-03-29 22:10:16Z mueller $
  \brief   Implemenation of class RtclRw11.
 */

#include <ctype.h>

#include <iostream>
#include <string>

#include "boost/bind.hpp"

#include "librtools/RosPrintf.hpp"
#include "librtcltools/RtclContext.hpp"
#include "librlinktpp/RtclRlinkServer.hpp"
#include "RtclRw11CpuW11a.hpp"
#include "librw11/Rw11Cpu.hpp"
#include "librw11/Rw11Cntl.hpp"

#include "RtclRw11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11::RtclRw11(Tcl_Interp* interp, const char* name)
  : RtclProxyOwned<Rw11>("Rw11", interp, name, new Rw11()),
    fspServ(),
    fGets()
{
  AddMeth("get",      boost::bind(&RtclRw11::M_get,     this, _1));
  AddMeth("start",    boost::bind(&RtclRw11::M_start,   this, _1));
  AddMeth("dump",     boost::bind(&RtclRw11::M_dump,    this, _1));
  AddMeth("$default", boost::bind(&RtclRw11::M_default, this, _1));

  Rw11* pobj = &Obj();
  fGets.Add<bool>              ("started",boost::bind(&Rw11::IsStarted, pobj));  

}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11::~RtclRw11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11::ClassCmdConfig(RtclArgs& args)
{
  string parent;
  if (!args.GetArg("parent", parent)) return kERR;

  // locate RlinkServer proxy and object -> setup W11->Server linkage
  RtclProxyBase* pprox = RtclContext::Find(args.Interp()).FindProxy(
                           "RlinkServer", parent);

  if (pprox == nullptr) 
    return args.Quit(string("-E: object '") + parent +
                     "' not found or not type RlinkServer");

  // make RtclRlinkRw11 object be co-owner of RlinkServer object
  fspServ = dynamic_cast<RtclRlinkServer*>(pprox)->ObjSPtr();
  
  // set RlinkServer in Rw11 (make Rw11 also co-owner)
  Obj().SetServer(fspServ);

  // now configure cpu's
  string type;
  int    count = 1;
  if (!args.GetArg("type", type)) return kERR;
  if (!args.GetArg("?count", count, 1, 1)) return kERR;
  if (!args.AllDone()) return kERR;

  // 'factory section', create concrete w11Cpu objects
  if (type == "w11a") {                  // w11a --------------------------
    RtclRw11CpuW11a* pobj = new RtclRw11CpuW11a(args.Interp(), "cpu0");
    // configure cpu
    pobj->Obj().Setup(0,0,0x4000);          // ind=0,base=0,ibase=0x4000
    // install in w11
    Obj().AddCpu(dynamic_pointer_cast<Rw11Cpu>(pobj->ObjSPtr()));

  } else {                               // unknown cpu type --------------
    return args.Quit(string("-E: unknown cpu type '") + type + "'");
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11::M_get(RtclArgs& args)
{
  // synchronize with server thread
  boost::lock_guard<RlinkConnect> lock(Obj().Connect());
  return fGets.M_get(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11::M_start(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  if (Obj().IsStarted()) return args.Quit("-E: already started");
  Obj().Start();
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11::M_dump(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;

  ostringstream sos;
  Obj().Dump(sos, 0);
  args.SetResult(sos);
  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11::M_default(RtclArgs& args)
{
  if (!args.AllDone()) return kERR;
  ostringstream sos;

  sos << "cpu type base : cntl  type ibbase  probe  lam boot" << endl;

  for (size_t i=0; i<Obj().NCpu(); i++) {
    Rw11Cpu& cpu(Obj().Cpu(i));
    sos << " " << i << " "
        << " " << RosPrintf(cpu.Type().c_str(),"-s",4)
        << " " << RosPrintf(cpu.Base(),"x",4)
        << endl;
    vector<string> list;
    cpu.ListCntl(list);
    for (size_t j=0; j<list.size(); j++) {
      Rw11Cntl& cntl(cpu.Cntl(list[j]));
      const Rw11Probe& pstat(cntl.ProbeStatus());
      sos << "                 " << RosPrintf(cntl.Name().c_str(),"-s",4)
          << " " << RosPrintf(cntl.Type().c_str(),"-s",4)
          << " " << RosPrintf(cntl.Base(),"o0",6)
          << "  ir=" << pstat.IndicatorInt() << "," << pstat.IndicatorRem();
      if (cntl.Lam() > 0) sos << " " << RosPrintf(cntl.Lam(),"d",3);
      else sos << "   -";
      uint16_t aload;
      uint16_t astart;
      vector<uint16_t> code;
      bool bootok = cntl.BootCode(0, code, aload, astart);
      sos << "   " << (bootok ? "y" : "n");
      sos << endl;
    }
  }

  args.AppendResultLines(sos);
  return kOK;
}

} // end namespace Retro
