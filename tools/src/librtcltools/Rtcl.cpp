// $Id: Rtcl.cpp 632 2015-01-11 12:30:03Z mueller $
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
// 2014-08-22   584   1.0.5  use nullptr
// 2013-01-06   473   1.0.4  add NewListIntObj(const uint(8|16)_t, ...)
// 2011-03-13   369   1.0.2  add NewListIntObj(vector<uint8_t>)
// 2011-03-05   366   1.0.1  add AppendResultNewLines()
// 2011-02-26   364   1.0    Initial version
// 2011-02-13   361   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rtcl.cpp 632 2015-01-11 12:30:03Z mueller $
  \brief   Implemenation of Rtcl.
*/

#include "Rtcl.hpp"

using namespace std;

/*!
  \class Retro::Rtcl
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* Rtcl::NewLinesObj(const std::string& str)
{
  const char* data = str.data();
  int size         = str.length();
  if (size>0 && data[size-1]=='\n') size -= 1;
  return Tcl_NewStringObj(data, size);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* Rtcl::NewListIntObj(const uint8_t* data, size_t size)
{
  if (size == 0) return Tcl_NewListObj(0, nullptr);
  
  vector<Tcl_Obj*> vobj;
  vobj.reserve(size);
  
  for (size_t i=0; i<size; i++) {
    vobj.push_back(Tcl_NewIntObj((int)data[i]));
  }
  return Tcl_NewListObj(vobj.size(), vobj.data());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* Rtcl::NewListIntObj(const uint16_t* data, size_t size)
{
  if (size == 0) return Tcl_NewListObj(0, nullptr);
  
  vector<Tcl_Obj*> vobj;
  vobj.reserve(size);
  
  for (size_t i=0; i<size; i++) {
    vobj.push_back(Tcl_NewIntObj((int)data[i]));
  }
  return Tcl_NewListObj(vobj.size(), vobj.data());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* Rtcl::NewListIntObj(const std::vector<uint8_t>& vec)
{
  return NewListIntObj(vec.data(), vec.size());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* Rtcl::NewListIntObj(const std::vector<uint16_t>& vec)
{
  return NewListIntObj(vec.data(), vec.size());
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rtcl::SetVar(Tcl_Interp* interp, const std::string& varname, Tcl_Obj* pobj)
{
  Tcl_Obj* pret = nullptr;
  
  size_t pos_pbeg = varname.find_first_of('(');
  size_t pos_pend = varname.find_first_of(')');
  if (pos_pbeg != string::npos || pos_pend != string::npos) {
    if (pos_pbeg == string::npos || pos_pbeg == 0 ||  
        pos_pend == string::npos || pos_pend != varname.length()-1 ||
        pos_pend-pos_pbeg <= 1) {
      Tcl_AppendResult(interp, "illformed array name '", varname.c_str(), 
                       "'", nullptr);
      return false;
    }
    string arrname(varname.substr(0,pos_pbeg));
    string elename(varname.substr(pos_pbeg+1, pos_pend-pos_pbeg-1));
    
    pret = Tcl_SetVar2Ex(interp, arrname.c_str(), elename.c_str(), pobj, 
                         TCL_LEAVE_ERR_MSG);
  } else {
    pret = Tcl_SetVar2Ex(interp, varname.c_str(), nullptr, pobj, 
                         TCL_LEAVE_ERR_MSG);
  }

  return pret!=0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool Rtcl::SetVarOrResult(Tcl_Interp* interp, const std::string& varname, 
                          Tcl_Obj* pobj)
{
  if (varname != "-") {
    return SetVar(interp, varname, pobj);
  }
  Tcl_SetObjResult(interp, pobj);
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rtcl::AppendResultNewLines(Tcl_Interp* interp)
{
  // check whether ObjResult is non-empty, in that case add an '\n'
  // that allows to append output from multiple AppendResultLines properly
  const char* res =  Tcl_GetStringResult(interp);
  if (res && res[0]) {
    Tcl_AppendResult(interp, "\n", nullptr);
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rtcl::SetResult(Tcl_Interp* interp, const std::string& str)
{
  Tcl_SetObjResult(interp, NewLinesObj(str));
  return;
}

} // end namespace Retro
