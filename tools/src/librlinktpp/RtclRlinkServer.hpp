// $Id: RtclRlinkServer.hpp 662 2015-04-05 08:02:54Z mueller $
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
// 2015-04-04   662   1.1    add M_get, M_set; remove 'server -trace'
// 2013-02-05   482   1.0.1  add shared_ptr to RlinkConnect object
// 2013-01-12   474   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRlinkServer.hpp 662 2015-04-05 08:02:54Z mueller $
  \brief   Declaration of class RtclRlinkServer.
*/

#ifndef included_Retro_RtclRlinkServer
#define included_Retro_RtclRlinkServer 1

#include <cstddef>
#include <list>

#include "boost/shared_ptr.hpp"

#include "librtcltools/RtclOPtr.hpp"
#include "librtcltools/RtclProxyOwned.hpp"
#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"
#include "RtclAttnShuttle.hpp"

#include "librlink/RlinkServer.hpp"

namespace Retro {

  class RlinkConnect;

  class RtclRlinkServer : public RtclProxyOwned<RlinkServer> {
    public:
                    RtclRlinkServer(Tcl_Interp* interp, const char* name);
                   ~RtclRlinkServer();

      virtual int   ClassCmdConfig(RtclArgs& args);

    protected:
      int           M_server(RtclArgs& args);
      int           M_attn(RtclArgs& args);
      int           M_stats(RtclArgs& args);
      int           M_print(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_default(RtclArgs& args);

    protected:
      typedef std::list<RtclAttnShuttle*> alist_t;
      typedef alist_t::iterator           alist_it_t;

      boost::shared_ptr<RlinkConnect> fspConn;
      alist_t       fAttnHdl; //<! list of attn handlers
      RtclGetList   fGets;
      RtclSetList   fSets;
  };
  
} // end namespace Retro

//#include "RtclRlinkServer.ipp"

#endif
