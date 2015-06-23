// $Id: RtclSignalAction.cpp 631 2015-01-09 21:36:51Z mueller $
//
// Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-11-08   602   1.0.3  cast int first to ptrdiff_t, than to ClientData
// 2014-08-22   584   1.0.2  use nullptr
// 2014-08-02   577   1.0.1  add include unistd.h  (write+pipe dcl)
// 2013-05-17   521   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclSignalAction.cpp 631 2015-01-09 21:36:51Z mueller $
  \brief   Implemenation of class RtclSignalAction.
 */

#include <errno.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

#include <iostream>

#include "librtools/Rexception.hpp"

#include "RtclSignalAction.hpp"

using namespace std;

/*!
  \class Retro::RtclSignalAction
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

RtclSignalAction* RtclSignalAction::fpObj = nullptr;

//------------------------------------------+-----------------------------------
//! FIXME_docs
bool RtclSignalAction::Init(Tcl_Interp* interp, RerrMsg& emsg)
{
  if (fpObj) {
    emsg.Init("RtclSignalAction::Init", "already initialized");
    return false;
  }
  
  try {
    fpObj = new RtclSignalAction(interp);
  } catch (exception& e) {
    emsg.Init("RtclSignalAction::Init", string("exception: ")+e.what());
    return false;
  }

  Tcl_CreateExitHandler((Tcl_ExitProc*) ThunkTclExitProc, (ClientData) fpObj);

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclSignalAction* RtclSignalAction::Obj()
{
  return fpObj;
}
  

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclSignalAction::SetAction(int signum, Tcl_Obj* pobj, RerrMsg& emsg)
{
  if (!ValidSignal(signum, emsg)) return false;
  if (fActionSet[signum] && !ClearAction(signum, emsg)) return false;

  struct sigaction sigact;
  ::memset(&sigact, 0, sizeof(sigact));
  sigact.sa_handler = SignalHandler;

  if (::sigaction(signum, &sigact, &fOldAction[signum]) != 0) {
    emsg.InitErrno("RtclSignalAction::SetAction",
                   "sigaction() failed: ", errno);
    return false;
  }

  fpScript[signum] = pobj;
  fActionSet[signum] = true;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclSignalAction::GetAction(int signum, Tcl_Obj*& pobj, RerrMsg& emsg)
{
  if (!ValidSignal(signum, emsg)) return false;
  if (!fActionSet[signum]) {
    emsg.Init("RtclSignalAction::GetAction", "no action for signal");
    return false;
  }

  pobj = fpScript[signum];
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclSignalAction::ClearAction(int signum, RerrMsg& emsg)
{
  if (!ValidSignal(signum, emsg)) return false;
  if (!fActionSet[signum]) {
    emsg.Init("RtclSignalAction::ClearAction", "no action for signal");
    return false;
  }

  if (::sigaction(signum, &fOldAction[signum], nullptr) != 0) {
    emsg.InitErrno("RtclSignalAction::ClearAction",
                   "sigaction() failed: ", errno);
    return false;
  }  
  fpScript[signum] = nullptr;
  fActionSet[signum] = false;
  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RtclSignalAction::ValidSignal(int signum, RerrMsg& emsg)
{
  if (signum > 0 && signum < 32) {
    switch (signum) {
    case SIGHUP:
    case SIGINT:
    case SIGTERM:
    case SIGUSR1:
    case SIGUSR2:
      return true;
    default:
      break;
    }
  }
  emsg.Init("RtclSignalAction::ValidSignal", "unsupported signal");
  return false;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclSignalAction::TclChannelHandler(int mask)
{
  char signum;
  Tcl_Read(fShuttleChn, (char*) &signum, sizeof(signum));
  // FIXME_code: handle return code

  Tcl_SetVar2Ex(fpInterp, "Rutil_signum", nullptr, 
                Tcl_NewIntObj((int)signum), 0);
  // FIXME_code: handle return code

  if ((Tcl_Obj*)fpScript[(int)signum]) {
    Tcl_EvalObjEx(fpInterp, fpScript[(int)signum], TCL_EVAL_GLOBAL);
    // FIXME_code: handle return code 
  }

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclSignalAction::SignalHandler(int signum)
{
  if (fpObj && fpObj->fFdPipeWrite>0) {
    char signum_c = signum;
    int irc = ::write(fpObj->fFdPipeWrite, (void*) &signum_c, sizeof(signum_c));
    if (irc < 0) 
      cerr << "RtclSignalAction::SignalHandler-E: write() failed, errno="
           << errno << endl;
  } else {
    cerr << "RtclSignalAction::SignalHandler-E: spurious call" << endl;
  }
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclSignalAction::ThunkTclChannelHandler(ClientData cdata, int mask)
{
  if (fpObj) fpObj->TclChannelHandler(mask);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclSignalAction::ThunkTclExitProc(ClientData cdata)
{
  delete fpObj;
  fpObj = nullptr;
  return;
}

//------------------------------------------+-----------------------------------
//! constructor

RtclSignalAction::RtclSignalAction(Tcl_Interp* interp)
  : fpInterp(interp),
    fFdPipeRead(-1),
    fFdPipeWrite(-1),
    fShuttleChn(),
    fActionSet(),
    fpScript(),
    fOldAction()
{
  for (size_t i=0; i<32; i++) {
    fActionSet[i] = false;
    ::memset(&fOldAction[i], 0, sizeof(fOldAction[0]));
  }

  int pipefd[2];
  if (::pipe(pipefd) < 0) 
    throw Rexception("RtclSignalAction::<ctor>", "pipe() failed: ", errno);

  fFdPipeRead  = pipefd[0];
  fFdPipeWrite = pipefd[1];

  // cast first to ptrdiff_t to promote to proper int size
  fShuttleChn = Tcl_MakeFileChannel((ClientData)(ptrdiff_t)fFdPipeRead, 
                                    TCL_READABLE);

  Tcl_SetChannelOption(nullptr, fShuttleChn, "-buffersize", "64");
  Tcl_SetChannelOption(nullptr, fShuttleChn, "-encoding", "binary");
  Tcl_SetChannelOption(nullptr, fShuttleChn, "-translation", "binary");

  Tcl_CreateChannelHandler(fShuttleChn, TCL_READABLE, 
                           (Tcl_FileProc*) ThunkTclChannelHandler,
                           (ClientData) this);
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclSignalAction::~RtclSignalAction()
{
  for (size_t i=0; i<32; i++) {
    RerrMsg emsg;
    if (fActionSet[i]) ClearAction(i, emsg);
  }
}
  

} // end namespace Retro
