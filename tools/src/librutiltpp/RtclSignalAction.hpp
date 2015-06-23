// $Id: RtclSignalAction.hpp 521 2013-05-20 22:16:45Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-05-17   521   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclSignalAction.hpp 521 2013-05-20 22:16:45Z mueller $
  \brief   Declaration of class RtclSignalAction.
*/

#ifndef included_Retro_RtclSignalAction
#define included_Retro_RtclSignalAction 1

// Note: on cpp environment _POSIX_C_SOURCE is already defined !!
#include <signal.h>

#include "tcl.h"

#include "librtools/RerrMsg.hpp"
#include "librtools/Rexception.hpp"
#include "librtcltools/RtclOPtr.hpp"

namespace Retro {

  class RtclSignalAction {
    public:

      static bool              Init(Tcl_Interp* interp, RerrMsg& emsg);
      static RtclSignalAction* Obj();
    
      bool          SetAction(int signum, Tcl_Obj* pobj, RerrMsg& emsg);
      bool          GetAction(int signum, Tcl_Obj*& pobj, RerrMsg& emsg);
      bool          ClearAction(int signum, RerrMsg& emsg);

    protected:
      bool          ValidSignal(int signum, RerrMsg& emsg);
      void          TclChannelHandler(int mask);
      static void   SignalHandler(int signum);
      static void   ThunkTclChannelHandler(ClientData cdata, int mask);
      static void   ThunkTclExitProc(ClientData cdata);

    private:
                    RtclSignalAction(Tcl_Interp* interp);
                   ~RtclSignalAction();

    protected:
      Tcl_Interp*   fpInterp;               //!< Tcl interpreter used
      int           fFdPipeRead;            //!< attn pipe read fd
      int           fFdPipeWrite;           //!< attn pipe write fd
      Tcl_Channel   fShuttleChn;            //!< Tcl channel
      bool          fActionSet[32];         //!< true if SetAction() done
      RtclOPtr      fpScript[32];           //!< action scripts
      struct sigaction fOldAction[32];      //!< original sigaction

    private:
      static RtclSignalAction* fpObj;       //!< pointer to singleton
  };
  
} // end namespace Retro

//#include "RtclSignalAction.ipp"

#endif
