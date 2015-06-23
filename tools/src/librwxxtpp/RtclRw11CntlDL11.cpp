// $Id: RtclRw11CntlDL11.cpp 516 2013-05-05 21:24:52Z mueller $
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
// 2013-05-04   516   1.0.1  add RxRlim support (receive interrupt rate limit)
// 2013-03-06   495   1.0    Initial version
// 2013-02-02   480   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11CntlDL11.cpp 516 2013-05-05 21:24:52Z mueller $
  \brief   Implemenation of RtclRw11CntlDL11.
*/

#include "librtcltools/RtclNameSet.hpp"

#include "RtclRw11CntlDL11.hpp"
#include "RtclRw11UnitDL11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11CntlDL11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11CntlDL11::RtclRw11CntlDL11()
  : RtclRw11CntlBase<Rw11CntlDL11>("Rw11CntlDL11")
{
  Rw11CntlDL11* pobj = &Obj();
  fGets.Add<uint16_t>  ("rxrlim", 
                        boost::bind(&Rw11CntlDL11::RxRlim,  pobj));
  fSets.Add<uint16_t>  ("rxrlim",
                        boost::bind(&Rw11CntlDL11::SetRxRlim,pobj, _1));
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11CntlDL11::~RtclRw11CntlDL11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlDL11::FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu)
{
  static RtclNameSet optset("-base|-lam");

  string cntlname(cpu.Obj().NextCntlName("tt"));
  string cntlcmd = cpu.CommandName() + cntlname;

  uint16_t base = Rw11CntlDL11::kIbaddr;
  int      lam  = Rw11CntlDL11::kLam;
  
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
    new RtclRw11UnitDL11(args.Interp(), unitcmd, Obj().UnitSPtr(i));
  }

  return kOK;
}

} // end namespace Retro
