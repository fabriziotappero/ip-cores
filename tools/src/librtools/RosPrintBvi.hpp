// $Id: RosPrintBvi.hpp 486 2013-02-10 22:34:43Z mueller $
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
  \version $Id: RosPrintBvi.hpp 486 2013-02-10 22:34:43Z mueller $
  \brief   Declaration of class RosPrintBvi .
*/

#ifndef included_Retro_RosPrintBvi
#define included_Retro_RosPrintBvi 1

#include <cstdint>
#include <ostream>
#include <string>

namespace Retro {
  
  class RosPrintBvi {
    public:
      explicit      RosPrintBvi(uint8_t val, size_t base=2, size_t nbit=8);
      explicit      RosPrintBvi(uint16_t val, size_t base=2, size_t nbit=16);
      explicit      RosPrintBvi(uint32_t val, size_t base=2, size_t nbit=32);

      void          Print(std::ostream& os) const;
      void          Print(std::string& os) const;

  protected:
      void          Convert(char* pbuf) const;

  protected:
      uint32_t      fVal;		    //!< value to be printed
      size_t        fBase;		    //!< base: 2,8, or 16
      size_t        fNbit;		    //!< number of bits to print

  };

  std::ostream&	    operator<<(std::ostream& os, const RosPrintBvi& obj);
  std::string& 	    operator<<(std::string&  os, const RosPrintBvi& obj);

} // end namespace Retro

#include "RosPrintBvi.ipp"

#endif
