// $Id: RtclArgs.cpp 632 2015-01-11 12:30:03Z mueller $
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
// 2014-08-22   584   1.0.8  use nullptr
// 2013-05-19   521   1.0.7  add NextSubOpt() method, pass optset's as const
// 2013-02-12   487   1.0.6  add CurrentArg() method
// 2013-02-03   481   1.0.5  use Rexception
// 2011-03-26   373   1.0.4  add GetArg(float/double)
// 2011-03-13   369   1.0.3  add GetArg(vector<unit8_t>); NextOpt clear NOptMiss
// 2011-03-06   367   1.0.2  add Config() methods;
// 2011-03-05   366   1.0.1  fObjc,fNDone now size_t; add NDone(), SetResult();
//                           add GetArg(Tcl_Obj), PeekArgString();
// 2011-02-26   364   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclArgs.cpp 632 2015-01-11 12:30:03Z mueller $
  \brief   Implemenation of RtclArgs.
*/

//debug
#include <iostream>

#include <ctype.h>
#include <stdarg.h>

#include "RtclArgs.hpp"

#include "Rtcl.hpp"
#include "librtools/Rexception.hpp"

using namespace std;

/*!
  \class Retro::RtclArgs
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RtclArgs::RtclArgs()
  : fpInterp(nullptr),
    fObjc(0),
    fObjv(0),
    fNDone(0),
    fNOptMiss(0),
    fNConfigRead(0),
    fOptErr(false),
    fArgErr(false)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclArgs::RtclArgs(Tcl_Interp* interp, int objc, Tcl_Obj* const objv[],
                   size_t nskip)
  : fpInterp(interp),
    fObjc((size_t)objc),
    fObjv(objv),
    fNDone((nskip<=(size_t)objc) ? nskip : (size_t)objc),
    fNOptMiss(0),
    fNConfigRead(0),
    fOptErr(false),
    fArgErr(false)
{
  if (objc < 0)
    throw Rexception("RtclArgs::<ctor>","Bad args: objc must be >= 0");
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclArgs::RtclArgs(const RtclArgs& rhs)
  : fpInterp(rhs.fpInterp),
    fObjc(rhs.fObjc),
    fObjv(rhs.fObjv),
    fNDone(rhs.fNDone),
    fNOptMiss(rhs.fNOptMiss),
    fOptErr(rhs.fOptErr),
    fArgErr(rhs.fArgErr)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RtclArgs::~RtclArgs()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* RtclArgs::Objv(size_t ind) const
{
  if (ind >= (size_t)fObjc)
    throw Rexception("RtclArgs::Objv()","Bad args: index out-of-range");
  return fObjv[ind];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, Tcl_Obj*& pval)
{
  Tcl_Obj* pobj;
  if (!NextArg(name, pobj)) return false;
  if (pobj==0) return true;
  pval = pobj;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, const char*& val)
{
  Tcl_Obj* pobj;
  if (!NextArg(name, pobj)) return false;
  if (pobj==0) return true;
  val = Tcl_GetString(pobj);
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, std::string& val)
{
  Tcl_Obj* pobj;
  if (!NextArg(name, pobj)) return false;
  if (pobj==0) return true;
  val = Tcl_GetString(pobj);
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, int8_t& val, int8_t min, int8_t max)
{
  int32_t val32 = (int32_t)val;
  bool ret = GetArg(name, val32, (int32_t)min, (int32_t)max);
  val = (int8_t) val32;
  return ret;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, uint8_t& val, uint8_t max, uint8_t min)
{
  uint32_t val32 = (uint32_t)val;
  bool ret = GetArg(name, val32, (uint32_t)max, (uint32_t)min);
  val = (uint8_t) val32;
  return ret;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, int16_t& val, int16_t min, int16_t max)
{
  int32_t val32 = (int32_t)val;
  bool ret = GetArg(name, val32, (int32_t)min, (int32_t)max);
  val = (int16_t) val32;
  return ret;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, uint16_t& val, uint16_t max, 
                      uint16_t min)
{
  uint32_t val32 = (uint32_t)val;
  bool ret = GetArg(name, val32, (uint32_t)max, (uint32_t)min);
  val = (uint16_t) val32;
  return ret;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, int32_t& val, int32_t min, int32_t max)
{
  Tcl_Obj* pobj;
  if (!NextArg(name, pobj)) return false;
  if (pobj==0) return true;
  int objval;
  if (Tcl_GetIntFromObj(fpInterp, pobj, &objval) != TCL_OK) return false;
  if (objval < min || objval > max) {
    ostringstream sos;
    sos << "-E: value '" << objval << "' for '" << name << "' out of range "
        << min << "..." << max;
    AppendResult(sos);
    return false;
  }
  val = (int32_t) objval;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, uint32_t& val, uint32_t max,
                      uint32_t min)
{
  Tcl_Obj* pobj;
  if (!NextArg(name, pobj)) return false;
  if (pobj==0) return true;
  int objval;
  if (Tcl_GetIntFromObj(fpInterp, pobj, &objval) != TCL_OK) return false;
  unsigned int objuval = objval;
  if (objuval < min || objuval > max) {
    ostringstream sos;
    sos << "-E: value '" << objuval << "' for '" << name << "' out of range "
        << min << "..." << max;
    AppendResult(sos);
    return false;
  }
  val = (uint32_t) objval;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, float& val, float min, float max)
{
  double vald = (double)val;
  bool ret = GetArg(name, vald, (double)max, (double)min);
  val = (float) vald;
  return ret;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, double& val, double min, double max)
{
  Tcl_Obj* pobj;
  if (!NextArg(name, pobj)) return false;
  if (pobj==0) return true;
  double objval;
  if (Tcl_GetDoubleFromObj(fpInterp, pobj, &objval) != TCL_OK) return false;
  if (objval < min || objval > max) {
    ostringstream sos;
    sos << "-E: value '" << objval << "' for '" << name << "' out of range "
        << min << "..." << max;
    AppendResult(sos);
    return false;
  }
  val = objval;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, std::vector<uint8_t>& val,
                      size_t lmin, size_t lmax)
{
  int objc = 0;
  Tcl_Obj** objv = nullptr;
  if (!NextArgList(name, objc, objv, lmin, lmax)) return false;
  if (objv==0) return true;

  val.clear();
  val.reserve(objc);

  for (int i=0; i<objc; i++) {
    int ival;
    if (Tcl_GetIntFromObj(fpInterp, objv[i], &ival) != TCL_OK) return false;
    int ivalmsb = ival>>8;
    if (ivalmsb != 0 && ivalmsb != -1) {
      ostringstream sos;
      sos << "-E: list element '" << Tcl_GetString(objv[i]) 
          << "' for '" << name 
          << "' out of range " << "0...0xff";
      AppendResult(sos);
      return false;
    }
    val.push_back((uint8_t)ival);
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::GetArg(const char* name, std::vector<uint16_t>& val,
                      size_t lmin, size_t lmax)
{
  int objc = 0;
  Tcl_Obj** objv = nullptr;
  if (!NextArgList(name, objc, objv, lmin, lmax)) return false;
  if (objv==0) return true;

  val.clear();
  val.reserve(objc);

  for (int i=0; i<objc; i++) {
    int ival;
    if (Tcl_GetIntFromObj(fpInterp, objv[i], &ival) != TCL_OK) return false;
    int ivalmsb = ival>>16;
    if (ivalmsb != 0 && ivalmsb != -1) {
      ostringstream sos;
      sos << "-E: list element '" << Tcl_GetString(objv[i]) 
          << "' for '" << name 
          << "' out of range " << "0...0xffff";
      AppendResult(sos);
      return false;
    }
    val.push_back((uint16_t)ival);
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::Config(const char* name, std::string& val)
{
  ConfigNameCheck(name);
  string tmp = val;
  if (!GetArg(name, tmp)) return false;
  if (fNOptMiss == 0) {                     // config write
    val = tmp;
  } else {                                  // config read
    if (!ConfigReadCheck()) return false;
    SetResult(Tcl_NewStringObj(val.data(), val.length()));
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::Config(const char* name, uint32_t& val, uint32_t max, 
                      uint32_t min)
{
  ConfigNameCheck(name);
  uint32_t tmp = val;
  if (!GetArg(name, tmp, max, min)) return false;
  if (fNOptMiss == 0) {                     // config write
    val = tmp;
  } else {                                  // config read
    if (!ConfigReadCheck()) return false;
    SetResult(Tcl_NewIntObj((int)val));
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::NextOpt(std::string& val)
{
  fNOptMiss = 0;
  val.clear();
  fOptErr = false;

  if (fNDone == fObjc) return false;

  const char* str = PeekArgString(0);

  if (str[0]=='-' && str[1] && !isdigit(str[1])) {
    fNDone += 1;
    // '--' seen (eat it, and say no Opt's found)
    if (str[1]=='-' && str[2]==0) {
      return false;
    }
    val = str;
    return true;
  }
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::NextOpt(std::string& val, const RtclNameSet& optset)
{
  val.clear();
  string opt;
  if (!NextOpt(opt) || opt.empty()) return false;

  fOptErr = !optset.Check(fpInterp, val, opt);
  return !fOptErr;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs
//  irc = 1 -> match
//        0 -> ambiguous match  --> tcl err
//       -1 -> no match         --> no tcl err

int RtclArgs::NextSubOpt(std::string& val, const RtclNameSet& optset)
{
  val.clear();
  fNOptMiss = 0;
  fOptErr = false;

  if (fNDone == fObjc) return -1;

  const char* str = PeekArgString(0);
  
  // does next arg look like an option
  if (str[0]=='-' && str[1]  && str[1]!='-' && !isdigit(str[1])) {
    // and matches one of optset
    int irc = optset.CheckMatch(fpInterp, val, string(str), false);
    if (irc >= 0) {
      fNDone += 1;
      fOptErr = (irc == 0);
      return irc;
    }
  }
  return -1;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* RtclArgs::CurrentArg() const
{
  if (fNDone == 0)
    throw Rexception("RtclArgs::CurrentArg()",
                     "Bad state: no argument processed yet");

  return fObjv[fNDone-1];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::AllDone()
{
  if (fArgErr || fOptErr) return false;
  if (fNDone < fObjc) {
    AppendResult("-E: superfluous arguments, first one '",
                 Tcl_GetString(fObjv[fNDone]), "'", nullptr);
    return false;
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const char* RtclArgs::PeekArgString(int rind) const
{
  int ind = fNDone + rind;
  if (ind < 0 || ind >= (int)fObjc) return "";
  return Tcl_GetString(fObjv[ind]);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclArgs::AppendResult(const char* str, ...)
{
  Tcl_AppendResult(fpInterp, str, nullptr);
  va_list ap;
  va_start (ap, str);
  Tcl_AppendResultVA(fpInterp, ap);
  va_end (ap);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclArgs::AppendResultLines(const std::string& str)
{
  Rtcl::AppendResultNewLines(fpInterp);

  if (str.length()>0 && str[str.length()-1]=='\n') {
    Tcl_AppendResult(fpInterp, str.substr(0,str.length()-1).c_str(), nullptr);
  } else {
    Tcl_AppendResult(fpInterp, str.c_str(), nullptr);
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::NextArg(const char* name, Tcl_Obj*& pobj)
{
  pobj = nullptr;
  
  bool isopt    = name[0] == '?';
  bool isoptopt = isopt && (name[1] == '?');

  if (!isopt) fNOptMiss = 0;

  if (fNDone == fObjc) {
    if (!isopt) {
      AppendResult("-E: required argument '", name, "' missing", nullptr);
      fArgErr = true;
      return false;
    }
    fNOptMiss += 1;
    return true;
  }

  // if %% arg peek in next arg and check that it's not an option
  if (isoptopt) {
    const char* nval = Tcl_GetString(fObjv[fNDone]);
    if (nval[0]=='-' && nval[1] && isalpha(nval[1])) {
      fNOptMiss += 1;
      return true;
    }
  }
  
  pobj = fObjv[fNDone++];

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::NextArgList(const char* name, int& objc, Tcl_Obj**& objv,
                           size_t lmin, size_t lmax)
{
  objc = 0;
  objv = nullptr;
  Tcl_Obj* pobj = nullptr;
  if (!NextArg(name, pobj)) return false;
  if (pobj==0) return true;

  if (Tcl_ListObjGetElements(fpInterp, pobj, &objc, &objv) != TCL_OK) {
    return false;
  }

  if ((size_t)objc < lmin || (size_t)objc > lmax) {
    ostringstream sos;
    sos << "-E: list length '" << objc << "' for '" << name << "' out of range "
        << lmin << "..." << lmax;
    AppendResult(sos);
    return false;
  }
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclArgs::ConfigNameCheck(const char* name)
{
  if (name==0 || name[0]!='?' || name[1]!='?')
    throw Rexception("RtclArgs::Config()","Bad args: name must start with ??");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclArgs::ConfigReadCheck()
{
  if (fNConfigRead != 0) {
    SetResult(Tcl_NewObj());
    AppendResult("-E: only one config read allowed per command, '", 
                 PeekArgString(-1), "' is second", nullptr);
    return false;
  }
  fNConfigRead += 1;
  return true;
}

} // end namespace Retro
