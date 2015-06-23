// $Id: RlogFileCatalog.hpp 491 2013-02-23 12:41:18Z mueller $
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
// 2013-02-22   491   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlogFileCatalog.hpp 491 2013-02-23 12:41:18Z mueller $
  \brief   Declaration of class RlogFileCatalog.
*/

#ifndef included_Retro_RlogFileCatalog
#define included_Retro_RlogFileCatalog 1

#include <map>

#include "boost/utility.hpp"
#include "boost/shared_ptr.hpp"

#include "RlogFile.hpp"

namespace Retro {

  class RlogFileCatalog : private boost::noncopyable {
    public:

      static RlogFileCatalog&  Obj();    

      const boost::shared_ptr<RlogFile>& FindOrCreate(const std::string& name);
      void          Delete(const std::string& name);

    private:
                    RlogFileCatalog();
                   ~RlogFileCatalog();

    protected:
      typedef std::map<std::string, boost::shared_ptr<RlogFile>> map_t;
      typedef map_t::iterator         map_it_t;
      typedef map_t::const_iterator   map_cit_t;
      typedef map_t::value_type       map_val_t;

      map_t         fMap;                   //!< name->rlogfile map
  };
  
} // end namespace Retro

//#include "RlogFileCatalog.ipp"

#endif
