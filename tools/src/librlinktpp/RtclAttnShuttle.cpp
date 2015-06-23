// $Id: RtclAttnShuttle.cpp 631 2015-01-09 21:36:51Z mueller $
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
// 2014-12-30   625   1.1    adopt to Rlink V4 attn logic
// 2014-11-08   602   1.0.3  cast int first to ptrdiff_t, than to ClientData
// 2014-08-22   584   1.0.2  use nullptr
// 2013-05-20   521   1.0.1  Setup proper Tcl channel options
// 2013-03-01   493   1.0    Initial version
// 2013-01-12   475   0.5    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclAttnShuttle.cpp 631 2015-01-09 21:36:51Z mueller $
  \brief   Implemenation of class RtclAttnShuttle.
 */

#include <errno.h>

#include "boost/bind.hpp"

#include "librtools/Rexception.hpp"

#include "RtclAttnShuttle.hpp"

using namespace std;

/*!
  \class Retro::RtclAttnShuttle
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! constructor

RtclAttnShuttle::RtclAttnShuttle(uint16_t mask, Tcl_Obj* pobj)
  : fpServ(nullptr),
    fpInterp(nullptr),
    fFdPipeRead(-1),
    fFdPipeWrite(-1),
    fShuttleChn(0),
    fMask(mask),
    fpScript(pobj)
{
  int pipefd[2];
  int irc = ::pipe(pipefd);
  if (irc < 0) 
    throw Rexception("RtclAttnShuttle::<ctor>", "pipe() failed: ", errno);
  fFdPipeRead  = pipefd[0];
  fFdPipeWrite = pipefd[1];
}

//------------------------------------------+-----------------------------------
//! Destructor

RtclAttnShuttle::~RtclAttnShuttle()
{
  Remove();
  ::close(fFdPipeWrite);
  ::close(fFdPipeRead);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclAttnShuttle::Add(RlinkServer* pserv, Tcl_Interp* interp)
{
  // connect to RlinkServer
  pserv->AddAttnHandler(boost::bind(&RtclAttnShuttle::AttnHandler, this, _1),
                        fMask, (void*)this);
  fpServ = pserv;

  // connect to Tcl
  // cast first to ptrdiff_t to promote to proper int size
  fShuttleChn = Tcl_MakeFileChannel((ClientData)(ptrdiff_t)fFdPipeRead, 
                                    TCL_READABLE);

  Tcl_SetChannelOption(nullptr, fShuttleChn, "-buffersize", "64");
  Tcl_SetChannelOption(nullptr, fShuttleChn, "-encoding", "binary");
  Tcl_SetChannelOption(nullptr, fShuttleChn, "-translation", "binary");

  Tcl_CreateChannelHandler(fShuttleChn, TCL_READABLE, 
                           (Tcl_FileProc*) ThunkTclChannelHandler,
                           (ClientData) this);

  fpInterp = interp;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclAttnShuttle::Remove()
{
  // disconnect from RlinkServer
  if (fpServ) {
    fpServ->RemoveAttnHandler(fMask, (void*)this);
    fpServ = nullptr;
  }
  // disconnect from Tcl
  if (fpInterp) {
    Tcl_DeleteChannelHandler(fShuttleChn, 
                             (Tcl_FileProc*) ThunkTclChannelHandler,
                             (ClientData) this);
    Tcl_Close(fpInterp, fShuttleChn);
    fpInterp = nullptr;
  }
  
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclAttnShuttle::AttnHandler(RlinkServer::AttnArgs& args)
{
  fpServ->GetAttnInfo(args);

  uint16_t apat = args.fAttnPatt & args.fAttnMask;
  int irc = ::write(fFdPipeWrite, (void*) &apat, sizeof(apat));
  if (irc < 0) 
    throw Rexception("RtclAttnShuttle::AttnHandler()",
                     "write() failed: ", errno);
  
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclAttnShuttle::TclChannelHandler(int mask)
{
  uint16_t apat;
  Tcl_ReadRaw(fShuttleChn, (char*) &apat, sizeof(apat));
  // FIXME_code: handle return code

  Tcl_SetVar2Ex(fpInterp, "Rlink_attnbits", nullptr, 
                Tcl_NewIntObj((int)apat), 0);
  // FIXME_code: handle return code

  Tcl_EvalObjEx(fpInterp, fpScript, TCL_EVAL_GLOBAL);
  // FIXME_code: handle return code
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclAttnShuttle::ThunkTclChannelHandler(ClientData cdata, int mask)
{
  ((RtclAttnShuttle*) cdata)->TclChannelHandler(mask);
  return;
}

} // end namespace Retro
