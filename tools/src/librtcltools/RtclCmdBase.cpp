// $Id: RtclCmdBase.cpp 584 2014-08-22 19:38:12Z mueller $
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
// 2014-08-22   584   1.0.3  use nullptr
// 2013-02-10   485   1.0.2  add static const defs
// 2013-02-05   483   1.0.1  remove 'unknown specified, full match only' logic
// 2013-02-02   480   1.0    Initial version (refactored out from ProxyBase)
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclCmdBase.cpp 584 2014-08-22 19:38:12Z mueller $
  \brief   Implemenation of RtclCmdBase.
*/

#include "RtclCmdBase.hpp"

#include "librtools/Rexception.hpp"
#include "Rtcl.hpp"

using namespace std;

/*!
  \class Retro::RtclCmdBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

typedef std::pair<RtclCmdBase::mmap_it_t, bool>  mmap_ins_t;

//------------------------------------------+-----------------------------------
// constants definitions

const int RtclCmdBase::kOK;
const int RtclCmdBase::kERR;

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclCmdBase::RtclCmdBase()
  : fMapMeth()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RtclCmdBase::~RtclCmdBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclCmdBase::DispatchCmd(RtclArgs& args)
{
  mmap_cit_t it_match;

  Tcl_Interp* interp = args.Interp();

  // no method name given
  if (args.Objc() <= 1) {                   // no args
    it_match = fMapMeth.find("$default");   // default method registered ?
    if (it_match != fMapMeth.end()) {
      return (it_match->second)(args);
    }
    Tcl_WrongNumArgs(interp, 1, args.Objv(), "option ?args?"); // or fail
    return kERR;
  }
  
  // here if at least method name given
  string name(Tcl_GetString(args[1]));

  it_match = fMapMeth.lower_bound(name);
    
  // no leading substring match
  if (it_match==fMapMeth.end() || 
      name!=it_match->first.substr(0,name.length())) {

    mmap_cit_t it_un = fMapMeth.find("$unknown"); // unknown method registered ?
    if (it_un!=fMapMeth.end()) {
      return (it_un->second)(args);
    }
    
    Tcl_AppendResult(interp, "-E: bad option '", name.c_str(),
                     "': must be ", nullptr);
    const char* delim = "";
    for (mmap_cit_t it1=fMapMeth.begin(); it1!=fMapMeth.end(); it1++) {
      if (it1->first.c_str()[0] != '$') {
        Tcl_AppendResult(interp, delim, it1->first.c_str(), nullptr);
        delim = ",";
      }        
    }
    return kERR;
  }
    
  // check for ambiguous substring match
  if (name != it_match->first) {
    mmap_cit_t it1 = it_match;
    it1++;
    if (it1!=fMapMeth.end() && name==it1->first.substr(0,name.length())) {
      Tcl_AppendResult(interp, "-E: ambiguous option '", 
                       name.c_str(), "': must be ", nullptr);
      const char* delim = "";
      for (it1=it_match; it1!=fMapMeth.end() &&
             name==it1->first.substr(0,name.length()); it1++) {
        Tcl_AppendResult(interp, delim, it1->first.c_str(), nullptr);
        delim = ",";
      }
      return kERR;
    }
  }
  
  return (it_match->second)(args);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclCmdBase::AddMeth(const std::string& name, const methfo_t& methfo)
{
  mmap_ins_t ret = fMapMeth.insert(mmap_val_t(name, methfo));
  if (ret.second == false)                  // or use !(ret.second)
    throw Rexception("RtclCmdBase::AddMeth:", 
                     string("Bad args: duplicate name: '") + name + "'");
  return;
}

} // end namespace Retro
