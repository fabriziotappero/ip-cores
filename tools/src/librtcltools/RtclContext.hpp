// $Id: RtclContext.hpp 490 2013-02-22 18:43:26Z mueller $
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
// 2013-01-12   474   1.0.3  add FindProxy() method
// 2011-04-24   380   1.0.2  use boost::noncopyable (instead of private dcl's)
// 2011-03-12   368   1.0.1  drop fExitSeen, get exit handling right
// 2011-02-18   362   1.0    Initial version
// 2011-02-18   362   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclContext.hpp 490 2013-02-22 18:43:26Z mueller $
  \brief   Declaration of class RtclContext.
*/

#ifndef included_Retro_RtclContext
#define included_Retro_RtclContext 1

#include "tcl.h"

#include <string>
#include <set>
#include <map>

#include "boost/utility.hpp"

#include "RtclClassBase.hpp"
#include "RtclProxyBase.hpp"

namespace Retro {

  class RtclContext : private boost::noncopyable {
    public:
      typedef std::set<RtclClassBase*> cset_t;
      typedef cset_t::iterator         cset_it_t;
      typedef std::set<RtclProxyBase*> pset_t;
      typedef pset_t::iterator         pset_it_t;
      typedef std::map<Tcl_Interp*, RtclContext*>  xmap_t;
      typedef xmap_t::iterator                     xmap_it_t;
      typedef xmap_t::value_type                   xmap_val_t;

      explicit      RtclContext(Tcl_Interp* interp);
      virtual      ~RtclContext();

      void          RegisterClass(RtclClassBase* pobj);
      void          UnRegisterClass(RtclClassBase* pobj);

      void          RegisterProxy(RtclProxyBase* pobj);
      void          UnRegisterProxy(RtclProxyBase* pobj);
      bool          CheckProxy(RtclProxyBase* pobj);
      bool          CheckProxy(RtclProxyBase* pobj, const std::string& type);

      void          ListProxy(std::vector<RtclProxyBase*>& list,
                              const std::string& type);
      RtclProxyBase* FindProxy(const std::string& type,
                               const std::string& name);

      static RtclContext&  Find(Tcl_Interp* interp);

      static void   ThunkTclExitProc(ClientData cdata);

    protected:

      Tcl_Interp*   fInterp;                //!< associated tcl interpreter
      cset_t        fSetClass;              //!< set for Class objects
      pset_t        fSetProxy;              //!< set for Proxy objects

      static xmap_t fMapContext;            //!< map of contexts
  };
  
} // end namespace Retro

//#include "RtclContext.ipp"

#endif
