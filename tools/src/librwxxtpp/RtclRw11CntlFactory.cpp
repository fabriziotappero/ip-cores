// $Id: RtclRw11CntlFactory.cpp 683 2015-05-17 21:54:35Z mueller $
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
// 2015-03-21   659   1.1.3  add RPRM (later renamed to RHRP)
// 2015-01-04   630   1.1.2  RL11 back in
// 2014-06-27   565   1.1.1  temporarily hide RL11
// 2014-06-08   561   1.1.0  add RL11
// 2013-05-01   513   1.0.1  add LP11
// 2013-03-06   495   1.0    Initial version
// 2013-02-09   489   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11CntlFactory.cpp 683 2015-05-17 21:54:35Z mueller $
  \brief   Implemenation of global function RtclRw11CntlFactory.
*/

#include "tcl.h"

#include "RtclRw11CntlFactory.hpp"

#include "RtclRw11CntlDL11.hpp"
#include "RtclRw11CntlRK11.hpp"
#include "RtclRw11CntlRL11.hpp"
#include "RtclRw11CntlRHRP.hpp"
#include "RtclRw11CntlTM11.hpp"
#include "RtclRw11CntlLP11.hpp"
#include "RtclRw11CntlPC11.hpp"

using namespace std;

// all method definitions in namespace Retro (avoid using in includes...)
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclRw11CntlFactory(RtclArgs& args, RtclRw11Cpu& cpu)
{
  string type;
  if (!args.GetArg("type", type)) return TCL_ERROR;

  // 'factory section', create concrete Rw11Cntl objects
  if        (type == "dl11") {              // dl11 --------------------------
    unique_ptr<RtclRw11CntlDL11> pobj(new RtclRw11CntlDL11());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else if (type == "rk11") {              // rk11 --------------------------
    unique_ptr<RtclRw11CntlRK11> pobj(new RtclRw11CntlRK11());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else if (type == "rl11") {              // rl11 --------------------------
    unique_ptr<RtclRw11CntlRL11> pobj(new RtclRw11CntlRL11());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else if (type == "rhrp") {              // rhrp --------------------------
    unique_ptr<RtclRw11CntlRHRP> pobj(new RtclRw11CntlRHRP());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else if (type == "tm11") {              // tm11 --------------------------
    unique_ptr<RtclRw11CntlTM11> pobj(new RtclRw11CntlTM11());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else if (type == "lp11") {              // lp11 --------------------------
    unique_ptr<RtclRw11CntlLP11> pobj(new RtclRw11CntlLP11());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else if (type == "pc11") {              // pc11 --------------------------
    unique_ptr<RtclRw11CntlPC11> pobj(new RtclRw11CntlPC11());
    if(pobj->FactoryCmdConfig(args, cpu) != TCL_OK) return TCL_ERROR;
    pobj.release();
    
  } else {                                  // unknown cntl type -------------
    return args.Quit(string("-E: unknown controller type '") + type + "'");
  }

  return TCL_OK;
}

} // end namespace Retro
