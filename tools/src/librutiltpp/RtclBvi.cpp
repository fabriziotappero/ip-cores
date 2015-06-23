// $Id: RtclBvi.cpp 632 2015-01-11 12:30:03Z mueller $
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
// 2014-08-22   584   1.0.2  use nullptr
// 2011-11-28   434   1.0.1  DoCmd(): use intptr_t cast for lp64 compatibility
// 2011-03-27   374   1.0    Initial version
// 2011-02-13   361   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclBvi.cpp 632 2015-01-11 12:30:03Z mueller $
  \brief   Implemenation of RtclBvi.
*/

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include <iostream>

#include "RtclBvi.hpp"
#include "librtcltools/RtclOPtr.hpp"

using namespace std;

/*!
  \class Retro::RtclBvi
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

static const int kOK  = TCL_OK;
static const int kERR = TCL_ERROR;

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclBvi::CreateCmds(Tcl_Interp* interp)
{
  Tcl_CreateObjCommand(interp,  "bvi", DoCmd, (ClientData) kStr2Int, nullptr);
  Tcl_CreateObjCommand(interp, "pbvi", DoCmd, (ClientData) kInt2Str, nullptr);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclBvi::DoCmd(ClientData cdata, Tcl_Interp* interp, int objc, 
                   Tcl_Obj* const objv[])
{
  bool list = false;
  char form = 0;
  int nbit  = 0;
  if (!CheckFormat(interp, objc, objv, list, form, nbit)) return kERR;
  
  //ConvMode mode = (ConvMode)((int) cdata);
  ConvMode mode = (ConvMode)((intptr_t) cdata);

  if (list) {
    int lobjc = 0;
    Tcl_Obj** lobjv = nullptr;
    if (Tcl_ListObjGetElements(interp, objv[2], &lobjc, &lobjv) != kOK) {
      return kERR;
    }
    
    RtclOPtr rlist(Tcl_NewListObj(0, nullptr));

    for (int i=0; i<lobjc; i++) {
      RtclOPtr rval(DoConv(interp, mode, lobjv[i], form, nbit));
      if (!rval) return kERR;
      if (Tcl_ListObjAppendElement(interp, rlist, rval) != kOK) return kERR;
    }

    Tcl_SetObjResult(interp, rlist);

  } else {
    Tcl_Obj* rval = DoConv(interp, mode, objv[2], form, nbit);
    if (rval==0) return kERR;
    Tcl_SetObjResult(interp, rval);
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Tcl_Obj* RtclBvi::DoConv(Tcl_Interp* interp, ConvMode mode, Tcl_Obj* val, 
                         char form, int nbit)
{
  if (mode == kStr2Int) {
    const char* pval = Tcl_GetString(val);
    int lval = strlen(pval);

    // strip leading blanks
    while (pval[0]!=0 && ::isblank(pval[0])) {
      pval++;
      lval--;
    }
    // strip trailing blanks
    while (lval>0 && ::isblank(pval[lval-1])) {
      lval--;
    }

    // check for c"ddd" format
    if (lval>3 && pval[1]=='"' && pval[lval-1]=='"') {
      if (strchr("bBoOdDxX", pval[0]) == 0) {
        Tcl_AppendResult(interp, "-E: bad prefix in c'dddd' format string", 
                         nullptr);
        return 0;
      }
      form = pval[0];
      pval += 2;
      lval -= 3;
    // check for 0xddd format
    } else if (lval>2 && pval[0]=='0' && (pval[1]=='x' || pval[1]=='X')) {
      form = 'x';
      pval += 2;
      lval -= 2;
    }

    int base = 0;
    switch (form) {
      case 'b': case 'B':  base =  2; break;
      case 'o': case 'O':  base =  8; break;
      case 'd': case 'D':  base = 10; break;
      case 'x': case 'X':  base = 16; break;
    }

    unsigned long lres=0;
    char* eptr=0;

    if (base==10 && pval[0]=='-') {
      lres = (unsigned long) ::strtol(pval, &eptr, base);
      if (nbit<32) lres &= (1ul<<nbit)-1;
    } else {
      lres = ::strtoul(pval, &eptr, base);
    }

    if (eptr != pval+lval) {
      Tcl_AppendResult(interp, "-E: conversion error in '", 
                       Tcl_GetString(val), "'", nullptr);
      return 0;
    }

    if (lres > (1ul<<nbit)-1) {
      Tcl_AppendResult(interp, "-E: too many bits defined in '", 
                       Tcl_GetString(val), "'", nullptr);
      return 0;
    }

    return Tcl_NewIntObj((int)lres);

  } else if (mode == kInt2Str) {
    int val_int;
    if (Tcl_GetIntFromObj(interp, val, &val_int)  != kOK) return 0;
    int val_uint = (unsigned int) val_int;

    int nwidth = 1;
    if (form=='o' || form=='O') nwidth = 3;
    if (form=='x' || form=='X') nwidth = 4;
    unsigned int nmask = (1<<nwidth)-1;

    char buf[64];
    char* pbuf = buf;
    if (form=='B' || form=='O' || form=='X') {
      *pbuf++ = tolower(form);
      *pbuf++ = '"';
    }

    int ndig = (nbit+nwidth-1)/nwidth;
    for (int i=ndig-1; i>=0; i--) {
      unsigned int nibble = ((val_uint)>>(i*nwidth)) & nmask;
      nibble += (nibble <= 9) ? '0' : ('a'-10);
      *pbuf++ = (char) nibble;
    }

    if (form=='B' || form=='O' || form=='X') {
      *pbuf++ = '"';
    }
    
    return Tcl_NewStringObj(buf, pbuf-buf);

  } else {
    Tcl_AppendResult(interp, "-E: BUG! bad cdata in RtclBvi::DoConv() call", 
                     nullptr);
  }
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclBvi::CheckFormat(Tcl_Interp* interp, int objc, Tcl_Obj* const objv[], 
                          bool& list, char& form, int& nbit)
{
  list = false;
  form = 'b';
  nbit = 0;
  
  if (objc != 3) {
    Tcl_WrongNumArgs(interp, 1, objv, "form arg");
    return false;
  }

  const char* opt = Tcl_GetString(objv[1]);

  while(*opt != 0) {
    switch (*opt) {
    case 'b':
    case 'B':
    case 'o':
    case 'O':
    case 'x':
    case 'X':
      form = *opt;
      break;
      
    case 'l':
      list = true;
      break;

    default:
      if (*opt>='0' && *opt<='9') {
        nbit = 10*nbit + ((*opt) - '0');
        if (nbit > 32) {
          Tcl_AppendResult(interp, "-E: invalid bvi format '", opt, "'", 
                           " bit count > 32", nullptr);
          return false;
        }
      } else {
        Tcl_AppendResult(interp, "-E: invalid bvi format '", opt, "'", 
                         " allowed: [bBoOxXl][0-9]*", nullptr);
        return false;
      }
      break;
    }
    opt++;
  }  

  if (nbit==0) nbit=8;

  return true;
}

} // end namespace Retro
