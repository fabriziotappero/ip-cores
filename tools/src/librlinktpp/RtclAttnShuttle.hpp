// $Id: RtclAttnShuttle.hpp 625 2014-12-30 16:17:45Z mueller $
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
// 2013-03-01   493   1.0    Initial version
// 2013-01-14   475   0.5    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclAttnShuttle.hpp 625 2014-12-30 16:17:45Z mueller $
  \brief   Declaration of class RtclAttnShuttle.
*/

#ifndef included_Retro_RtclAttnShuttle
#define included_Retro_RtclAttnShuttle 1

#include "tcl.h"

#include <cstdint>

#include "librtcltools/RtclOPtr.hpp"
#include "librlink/RlinkServer.hpp"

namespace Retro {

  class RtclAttnShuttle {
    public:
                    RtclAttnShuttle(uint16_t mask, Tcl_Obj* pobj);
                   ~RtclAttnShuttle();

      uint16_t      Mask() const;
      Tcl_Obj*      Script() const;

      void          Add(RlinkServer* pserv, Tcl_Interp* interp);
      void          Remove();

    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
      void          TclChannelHandler(int mask);
      static void   ThunkTclChannelHandler(ClientData cdata, int mask);

    protected:
      RlinkServer*  fpServ;                 //!< RlinkServer used
      Tcl_Interp*   fpInterp;               //!< Tcl interpreter used
      int           fFdPipeRead;            //!< attn pipe read fd
      int           fFdPipeWrite;           //!< attn pipe write fd
      Tcl_Channel   fShuttleChn;            //!< Tcl channel
      uint16_t      fMask;                  //!< attn mask
      RtclOPtr      fpScript;               //!< Tcl handler script (as Tcl_Obj)
  };
  
} // end namespace Retro

#include "RtclAttnShuttle.ipp"

#endif
