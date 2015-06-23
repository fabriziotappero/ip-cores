// $Id: RtclSystem.cpp 632 2015-01-11 12:30:03Z mueller $
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
// 2014-08-22   584   1.0.1  use nullptr
// 2013-05-17   521   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclSystem.cpp 632 2015-01-11 12:30:03Z mueller $
  \brief   Implemenation of RtclSystem.
*/

#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <iostream>
#include <string>
#include <algorithm>

#include "librtools/RerrMsg.hpp"
#include "librtcltools/RtclArgs.hpp"

#include "RtclSignalAction.hpp"

#include "RtclSystem.hpp"

using namespace std;

/*!
  \class Retro::RtclSystem
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

static const int kOK  = TCL_OK;
static const int kERR = TCL_ERROR;

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RtclSystem::CreateCmds(Tcl_Interp* interp)
{
  Tcl_CreateObjCommand(interp, "rutil::isatty", Isatty, 
                       (ClientData) 0, nullptr);
  Tcl_CreateObjCommand(interp, "rutil::sigaction", SignalAction, 
                       (ClientData) 0, nullptr);
  Tcl_CreateObjCommand(interp, "rutil::waitpid", WaitPid, 
                       (ClientData) 0, nullptr);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclSystem::Isatty(ClientData cdata, Tcl_Interp* interp, 
                       int objc, Tcl_Obj* const objv[])
{
  RtclArgs args(interp, objc, objv);
  string file = "stdin";
  if (!args.GetArg("?file", file)) return kERR;
  if (!args.AllDone()) return kERR;

  transform(file.begin(), file.end(), file.begin(), ::tolower);
  int fileno = -1;
  if (file == "stdin")  fileno = STDIN_FILENO;
  if (file == "stdout") fileno = STDOUT_FILENO;
  if (file == "stderr") fileno = STDERR_FILENO;
  if (fileno == -1) return args.Quit("file must be stdin, stdout, or stderr");

  args.SetResult(bool(::isatty(fileno)));

  return kOK;
}

//------------------------------------------+-----------------------------------

static int signam2num(const std::string& signam)
{
  string sn = signam;
  transform(sn.begin(), sn.end(), sn.begin(), ::toupper);
  if (sn == "SIGHUP")  return SIGHUP;
  if (sn == "SIGINT")  return SIGINT;
  if (sn == "SIGTERM") return SIGTERM;
  if (sn == "SIGUSR1") return SIGUSR1;
  if (sn == "SIGUSR2") return SIGUSR2;
  return -1;
}

static const char* signum2nam(int signum)
{
  if (signum == SIGHUP)  return "SIGHUP";
  if (signum == SIGINT)  return "SIGINT";
  if (signum == SIGTERM) return "SIGTERM";
  if (signum == SIGUSR1) return "SIGUSR1";
  if (signum == SIGUSR2) return "SIGUSR2";
  return "???";
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclSystem::SignalAction(ClientData cdata, Tcl_Interp* interp, 
                             int objc, Tcl_Obj* const objv[])
{
  RtclArgs args(interp, objc, objv);
  RerrMsg emsg;

  // check if initialized, if not, do it
  if (!RtclSignalAction::Obj()) {
    RerrMsg emsg;
    if (!RtclSignalAction::Init(interp, emsg)) return args.Quit(emsg);
  }
  RtclSignalAction* pact = RtclSignalAction::Obj();
  
  // blank 'sigaction' is a noop (initialize as side effect)
  if (objc == 1) return kOK;  

  // handle cases with only options (no signal name first)

  if (args.PeekArgString(0)[0] == '-') {
    static RtclNameSet optset("-init|-info");
    string opt;
    if (args.NextOpt(opt, optset)) {

      if        (opt == "-init") {          // -init
        if (!args.AllDone()) return kERR;
        return kOK;

      } else if (opt == "-info") {          // -info
        RtclOPtr pres(Tcl_NewListObj(0,nullptr));
        int siglist[] = {SIGHUP,SIGINT,SIGTERM,SIGUSR1,SIGUSR2};
        for (size_t i=0; i<sizeof(siglist)/sizeof(int); i++) {
          Tcl_Obj* pobj;
          if (pact->GetAction(siglist[i], pobj, emsg)) {
            RtclOPtr pele(Tcl_NewListObj(0,0));
            Tcl_ListObjAppendElement(nullptr, pele, 
                     Tcl_NewStringObj(signum2nam(siglist[i]),-1));
            if (pobj) {
              Tcl_ListObjAppendElement(nullptr, pele, pobj);
            } else {
              Tcl_ListObjAppendElement(nullptr, pele, 
                                       Tcl_NewStringObj("{}",-1));
            }
            Tcl_ListObjAppendElement(nullptr, pres, pele);
          }
        }
        args.SetResult(pres);
        return kOK;
      }
    }
    if (!args.OptValid()) return kERR;
    if (!args.AllDone()) return kERR;
    return kERR;
  }

  // handle cases which start with a signal name

  string signam;
  if (!args.GetArg("signam", signam)) return kERR;
  int signum = signam2num(signam);
  if (signum < 0) return args.Quit("invalid signal name");

  static RtclNameSet optset("-action|-revert");
  string opt;
  if (args.NextOpt(opt, optset)) {
    if        (opt == "-action") {          // signam -action script
      string script;
      if (!args.GetArg("script", script)) return kERR;
      if (!args.AllDone()) return kERR;
      RtclOPtr pobj(Tcl_NewStringObj(script.c_str(), -1));
      if (!pact->SetAction(signum, pobj, emsg)) 
        return args.Quit(emsg);
      
    } else if (opt == "-revert") {          // signam -revert
      if (!args.AllDone()) return kERR;
      if (!pact->ClearAction(signum, emsg)) 
        return args.Quit(emsg);
    }

  } else {                                  // signam
    if (!args.OptValid()) return kERR;
    if (!args.AllDone()) return kERR;
    Tcl_Obj* pobj;
    if (!pact->GetAction(signum, pobj, emsg))
      return args.Quit("no handler defined");
    if (pobj == nullptr) pobj = Tcl_NewStringObj("{}",-1);
    args.SetResult(pobj);
  }

  return kOK;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int RtclSystem::WaitPid(ClientData cdata, Tcl_Interp* interp, 
                        int objc, Tcl_Obj* const objv[])
{
  RtclArgs args(interp, objc, objv);
  int pid;
  if (!args.GetArg("pid", pid)) return kERR;
  if (!args.AllDone()) return kERR;

  int status;
  int irc = ::waitpid(pid, &status, WNOHANG);
  if (irc < 0) {
    RerrMsg emsg("RtclSystem::WaitPid", "waitpid() failed: ", errno);
    return args.Quit(emsg);  
  }
  args.SetResult(status);
  return kOK;
}


} // end namespace Retro
