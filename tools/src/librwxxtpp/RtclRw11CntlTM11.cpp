// $Id: RtclRw11CntlTM11.cpp 686 2015-06-04 21:08:08Z mueller $
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
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11CntlTM11.cpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation of RtclRw11CntlTM11.
*/

#include "librtcltools/RtclNameSet.hpp"

#include "RtclRw11CntlTM11.hpp"
#include "RtclRw11UnitTM11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11CntlTM11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11CntlTM11::RtclRw11CntlTM11()
  : RtclRw11CntlBase<Rw11CntlTM11>("Rw11CntlTM11")
{  
  Rw11CntlTM11* pobj = &Obj();
  fGets.Add<size_t>  ("chunksize", 
                      boost::bind(&Rw11CntlTM11::ChunkSize,    pobj));
  fSets.Add<size_t>  ("chunksize",
                      boost::bind(&Rw11CntlTM11::SetChunkSize, pobj, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11CntlTM11::~RtclRw11CntlTM11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlTM11::FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu)
{
  static RtclNameSet optset("-base|-lam");

  string cntlname(cpu.Obj().NextCntlName("tm"));
  string cntlcmd = cpu.CommandName() + cntlname;

  uint16_t base = Rw11CntlTM11::kIbaddr;
  int      lam  = Rw11CntlTM11::kLam;
  
  string opt;
  while (args.NextOpt(opt, optset)) {
    if        (opt == "-base") {
      if (!args.GetArg("base", base, 0177776, 0160000)) return kERR;
    } else if (opt == "-lam") {
      if (!args.GetArg("lam",  lam,  0, 15)) return kERR;
    }
  }
  if (!args.AllDone()) return kERR;

  // configure controller
  Obj().Config(cntlname, base, lam);

  // install in CPU
  cpu.Obj().AddCntl(dynamic_pointer_cast<Rw11Cntl>(ObjSPtr()));
  // finally create tcl command
  CreateObjectCmd(args.Interp(), cntlcmd.c_str()); 

  // and create unit commands
  for (size_t i=0; i<Obj().NUnit(); i++) {
    string unitcmd = cpu.CommandName() + Obj().UnitName(i);
    new RtclRw11UnitTM11(args.Interp(), unitcmd, Obj().UnitSPtr(i));
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlTM11::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Collect(args, cntx, Obj().Stats())) return kERR;
  if (!RtclStats::Collect(args, cntx, Obj().RdmaStats())) return kERR;
  return kOK;
}


} // end namespace Retro
