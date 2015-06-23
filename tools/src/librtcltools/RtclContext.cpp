// $Id: RtclContext.cpp 492 2013-02-24 22:14:47Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-03   481   1.0.3  use Rexception
// 2013-01-12   474   1.0.2  add FindProxy() method
// 2011-03-12   368   1.0.1  drop fExitSeen, get exit handling right
// 2011-02-18   362   1.0    Initial version
// 2011-02-13   361   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclContext.cpp 492 2013-02-24 22:14:47Z mueller $
  \brief   Implemenation of RtclContext.
*/

#include <iostream>

#include "RtclContext.hpp"

#include "librtools/Rexception.hpp"

using namespace std;

/*!
  \class Retro::RtclContext
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

typedef std::pair<RtclContext::cset_it_t, bool>  cset_ins_t;
typedef std::pair<RtclContext::pset_it_t, bool>  pset_ins_t;

RtclContext::xmap_t RtclContext::fMapContext;

//------------------------------------------+-----------------------------------
//! Default constructor

RtclContext::RtclContext(Tcl_Interp* interp)
  : fInterp(interp),
    fSetClass(),
    fSetProxy()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RtclContext::~RtclContext()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclContext::RegisterClass(RtclClassBase* pobj)
{
  cset_ins_t ret = fSetClass.insert(pobj);
  if (ret.second == false)                  // or use !(ret.second)
    throw Rexception("RtclContext::RegisterClass()",
                     "Bad args: duplicate pointer");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclContext::UnRegisterClass(RtclClassBase* pobj)
{
  fSetClass.erase(pobj);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclContext::RegisterProxy(RtclProxyBase* pobj)
{
  pset_ins_t ret = fSetProxy.insert(pobj);
  if (ret.second == false)                  // or use !(ret.second)
    throw Rexception("RtclContext::RegisterProxy()",
                     "Bad args: duplicate pointer");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclContext::UnRegisterProxy(RtclProxyBase* pobj)
{
  fSetProxy.erase(pobj);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclContext::CheckProxy(RtclProxyBase* pobj)
{
  pset_it_t it = fSetProxy.find(pobj);
  return it != fSetProxy.end();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclContext::CheckProxy(RtclProxyBase* pobj, const string& type)
{
  pset_it_t it = fSetProxy.find(pobj);
  if (it == fSetProxy.end()) return false;
  return (*it)->Type() == type;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclContext::ListProxy(std::vector<RtclProxyBase*>& list,
                            const std::string& type)
{
  list.clear();
  for (pset_it_t it = fSetProxy.begin(); it != fSetProxy.end(); it++) {
    if (type.length() == 0 || (*it)->Type()==type) {
      list.push_back(*it);
    }
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclProxyBase* RtclContext::FindProxy(const std::string& type, 
                                      const std::string& name)
{
  for (pset_it_t it = fSetProxy.begin(); it != fSetProxy.end(); it++) {
    if (type.length() == 0 || (*it)->Type()==type) {
      const char* cmdname = Tcl_GetCommandName(fInterp, (*it)->Token());
      if (name == cmdname) return *it;
    }
  }
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclContext& RtclContext::Find(Tcl_Interp* interp)
{
  RtclContext* pcntx = 0;
  xmap_it_t it = fMapContext.find(interp);
  if (it != fMapContext.end()) {
    pcntx = it->second;
  } else {
    pcntx = new RtclContext(interp);
    fMapContext.insert(xmap_val_t(interp, pcntx));
    Tcl_CreateExitHandler((Tcl_ExitProc*) ThunkTclExitProc, (ClientData) pcntx);

  }
  return *pcntx;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

// Note: tcl exit handlers are executed in inverse order of creation.
//       If Find() is called before any Class or Proxy cleanup handlers
//       are created the exit handler created in Find() will be called
//       last, when all map entries have been erased.

void RtclContext::ThunkTclExitProc(ClientData cdata)
{
  RtclContext* pcntx = (RtclContext*) cdata;
  if (pcntx->fSetClass.empty() && pcntx->fSetProxy.empty()) {
    delete pcntx;
  } else {
    cerr << "RtclContext::ThunkTclExitProc called when maps non-empty" << endl;
  }
  return;
}

} // end namespace Retro
