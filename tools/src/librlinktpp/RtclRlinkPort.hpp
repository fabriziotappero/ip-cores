// $Id: RtclRlinkPort.hpp 632 2015-01-11 12:30:03Z mueller $
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
// 2015-01-09   632   1.0.2  add M_get, M_set, remove M_config
// 2013-02-23   492   1.0.1  use RlogFile.Name();
// 2013-01-27   478   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRlinkPort.hpp 632 2015-01-11 12:30:03Z mueller $
  \brief   Declaration of class RtclRlinkPort.
*/

#ifndef included_Retro_RtclRlinkPort
#define included_Retro_RtclRlinkPort 1

#include <cstddef>
#include <string>

#include "boost/shared_ptr.hpp"

#include "librtools/RlogFile.hpp"
#include "librtcltools/RtclProxyBase.hpp"
#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"

#include "librlink/RlinkPort.hpp"

namespace Retro {

  class RtclRlinkPort : public RtclProxyBase {
    public:
                    RtclRlinkPort(Tcl_Interp* interp, const char* name);
                   ~RtclRlinkPort();

      friend class RtclRlinkConnect;

    protected:
      int           M_open(RtclArgs& args);
      int           M_close(RtclArgs& args);
      int           M_errcnt(RtclArgs& args);
      int           M_rawio(RtclArgs& args);
      int           M_stats(RtclArgs& args);
      int           M_log(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_default(RtclArgs& args);

      void          SetupGetSet();
      bool          TestOpen(RtclArgs& args);
      void          SetLogFileName(const std::string& name);
      std::string   LogFileName() const;

      static int    DoRawio(RtclArgs& args, RlinkPort* pport, size_t& errcnt);

    protected:
      RlinkPort*    fpObj;                  //!< ptr to managed object
      boost::shared_ptr<RlogFile> fspLog;   //!< port log file
      uint32_t      fTraceLevel;            //!< 0=off,1=buf,2=char
      size_t        fErrCnt;                //!< error count
      RtclGetList   fGets;
      RtclSetList   fSets;
  };
  
} // end namespace Retro

//#include "RtclRlinkPort.ipp"

#endif
