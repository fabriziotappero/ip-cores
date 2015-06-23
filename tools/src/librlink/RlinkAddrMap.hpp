// $Id: RlinkAddrMap.hpp 486 2013-02-10 22:34:43Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-03-05   366   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkAddrMap.hpp 486 2013-02-10 22:34:43Z mueller $
  \brief   Declaration of class \c RlinkAddrMap.
*/

#ifndef included_Retro_RlinkAddrMap
#define included_Retro_RlinkAddrMap 1

#include <cstdint>
#include <string>
#include <map>
#include <ostream>

namespace Retro {

  class RlinkAddrMap {
    public:
      typedef std::map<std::string, uint16_t> nmap_t;
      typedef nmap_t::iterator         nmap_it_t;
      typedef nmap_t::const_iterator   nmap_cit_t;
      typedef nmap_t::value_type       nmap_val_t;
      typedef std::map<uint16_t, std::string> amap_t;
      typedef amap_t::iterator         amap_it_t;
      typedef amap_t::const_iterator   amap_cit_t;
      typedef amap_t::value_type       amap_val_t;

                    RlinkAddrMap();
                   ~RlinkAddrMap();

      void          Clear();

      bool          Insert(const std::string& name, uint16_t addr);
      bool          Erase(const std::string& name);
      bool          Erase(uint16_t addr);

      bool          Find(const std::string& name, uint16_t& addr) const;
      bool          Find(uint16_t addr, std::string& name) const;

      const nmap_t& Nmap() const;
      const amap_t& Amap() const;

      size_t        MaxNameLength() const;

      void          Print(std::ostream& os, int ind=0) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      nmap_t        fNameMap;               //!< name->addr map
      amap_t        fAddrMap;               //!< addr->name map
      mutable size_t  fMaxLength;           //!< max name length
    
  };
  
} // end namespace Retro

#include "RlinkAddrMap.ipp"

#endif
