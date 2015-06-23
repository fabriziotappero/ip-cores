// $Id: RtclSetList.cpp 631 2015-01-09 21:36:51Z mueller $
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
// 2015-01-08   631   1.1    add Clear(), add '?' (key list)
// 2014-08-22   584   1.0.1  use nullptr
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclSetList.cpp 631 2015-01-09 21:36:51Z mueller $
  \brief   Implemenation of class RtclSetList.
*/

#include <iostream>

#include "librtools/Rexception.hpp"

#include "RtclSet.hpp"
#include "RtclSetList.hpp"
#include "RtclOPtr.hpp"

using namespace std;

/*!
  \class Retro::RtclSetList
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclSetList::RtclSetList()
  : fMap()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclSetList::~RtclSetList()
{
  for (map_cit_t it=fMap.begin(); it != fMap.end(); it++) {
    delete (it->second);
  }
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclSetList::Add(const std::string& name, RtclSetBase* pset)
{
  typedef std::pair<Retro::RtclSetList::map_it_t, bool>  map_ins_t;
  map_ins_t ret = fMap.insert(map_val_t(name, pset));
  if (ret.second == false) 
    throw Rexception("RtclSetList::Add:", 
                     string("Bad args: duplicate name: '") + name + "'");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclSetList::Clear()
{
  fMap.clear();
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclSetList::M_set(RtclArgs& args)
{
  Tcl_Interp* interp = args.Interp();
  string pname;
  if (!args.GetArg("pname", pname)) return TCL_ERROR;

  if (pname == "?") {
    if (!args.AllDone()) return TCL_ERROR;
    RtclOPtr rlist(Tcl_NewListObj(0,nullptr));
    for (const auto& kv : fMap) {
      RtclOPtr pele(Tcl_NewStringObj(kv.first.c_str(), -1));
      Tcl_ListObjAppendElement(nullptr, rlist, pele);
    }
    Tcl_SetObjResult(interp, rlist);
    return TCL_OK;
  }

  map_cit_t it = fMap.lower_bound(pname);

  // complain if not found
  if (it == fMap.end() || pname != it->first.substr(0,pname.length())) {
    Tcl_AppendResult(interp, "-E: unknown property '", pname.c_str(), 
                     "': must be ", nullptr);
    const char* delim = "";
    for (map_cit_t it1=fMap.begin(); it1!=fMap.end(); it1++) {
      Tcl_AppendResult(interp, delim, it1->first.c_str(), nullptr);
      delim = ",";
    }
    return TCL_ERROR;
  }

  // check for ambiguous substring match
  map_cit_t it1 = it;
  it1++;
  if (it1!=fMap.end() && pname==it1->first.substr(0,pname.length())) {
    Tcl_AppendResult(interp, "-E: ambiguous property name '", pname.c_str(),
                     "': must be ", nullptr);
    const char* delim = "";
    for (it1=it; it1!=fMap.end() &&
           pname==it1->first.substr(0,pname.length()); it1++) {
      Tcl_AppendResult(interp, delim, it1->first.c_str(), nullptr);
      delim = ",";
    }

    return TCL_ERROR;
  }

  Tcl_Obj* pobj;
  if (!args.GetArg("val", pobj)) return TCL_ERROR;
  if (!args.AllDone()) return TCL_ERROR;

  try {
    (it->second)->operator()(args);
  } catch (Rexception& e) {
    Tcl_AppendResult(args.Interp(), "-E: ", e.ErrMsg().Text().c_str(), nullptr);
    return TCL_ERROR;
  } catch (exception& e) {
    Tcl_AppendResult(args.Interp(), "-E: ", e.what(), nullptr);
    return TCL_ERROR;
  }
  
  return TCL_OK;
}

} // end namespace Retro
