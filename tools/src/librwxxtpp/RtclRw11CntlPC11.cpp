// $Id: RtclRw11CntlPC11.cpp 515 2013-05-04 17:28:59Z mueller $
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
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11CntlPC11.cpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Implemenation of RtclRw11CntlPC11.
*/

#include "librtcltools/RtclNameSet.hpp"

#include "RtclRw11CntlPC11.hpp"
#include "RtclRw11UnitPC11.hpp"

using namespace std;

/*!
  \class Retro::RtclRw11CntlPC11
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11CntlPC11::RtclRw11CntlPC11()
  : RtclRw11CntlBase<Rw11CntlPC11>("Rw11CntlPC11")
{
  //Rw11CntlPC11* pobj = &Obj();
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclRw11CntlPC11::~RtclRw11CntlPC11()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlPC11::FactoryCmdConfig(RtclArgs& args, RtclRw11Cpu& cpu)
{
  static RtclNameSet optset("-base|-lam");

  string cntlname(cpu.Obj().NextCntlName("pc"));
  string cntlcmd = cpu.CommandName() + cntlname;

  uint16_t base = Rw11CntlPC11::kIbaddr;
  int      lam  = Rw11CntlPC11::kLam;
  
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
    new RtclRw11UnitPC11(args.Interp(), unitcmd, Obj().UnitSPtr(i));
  }

  return kOK;
}

} // end namespace Retro
