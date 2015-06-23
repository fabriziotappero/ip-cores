// $Id: RtclGetList.hpp 631 2015-01-09 21:36:51Z mueller $
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
// 2015-01-08   631   1.1    add Clear()
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclGetList.hpp 631 2015-01-09 21:36:51Z mueller $
  \brief   Declaration of class \c RtclGetList.
*/

#ifndef included_Retro_RtclGetList
#define included_Retro_RtclGetList 1

#include "tcl.h"

#include <cstdint>
#include <string>
#include <map>

#include "boost/utility.hpp"
#include "boost/function.hpp"

#include "RtclGet.hpp"
#include "librtcltools/RtclArgs.hpp"

namespace Retro {

  class RtclGetList : private boost::noncopyable {
    public:
                    RtclGetList();
      virtual      ~RtclGetList();

      void          Add(const std::string& name, RtclGetBase* pget);

      template <class TP>
      void          Add(const std::string& name, 
                        const boost::function<TP()>& get);

      void          Clear();
      int           M_get(RtclArgs& args);

    protected: 
      typedef std::map<std::string, RtclGetBase*> map_t;
      typedef map_t::iterator         map_it_t;
      typedef map_t::const_iterator   map_cit_t;
      typedef map_t::value_type       map_val_t;

      map_t         fMap;
  };
  
} // end namespace Retro

#include "RtclGetList.ipp"

#endif
