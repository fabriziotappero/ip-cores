// $Id: Rw11UnitRHRP.hpp 680 2015-05-14 13:29:46Z mueller $
//
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-05-14   680   1.0    Initial version
// 2015-03-21   659   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11UnitRHRP.hpp 680 2015-05-14 13:29:46Z mueller $
  \brief   Declaration of class Rw11UnitRHRP.
*/

#ifndef included_Retro_Rw11UnitRHRP
#define included_Retro_Rw11UnitRHRP 1

#include "Rw11UnitDiskBase.hpp"

namespace Retro {

  class Rw11CntlRHRP;                       // forw decl to avoid circular incl

  class Rw11UnitRHRP : public Rw11UnitDiskBase<Rw11CntlRHRP> {
    public:
                    Rw11UnitRHRP(Rw11CntlRHRP* pcntl, size_t index);
                   ~Rw11UnitRHRP();

      virtual void  SetType(const std::string& type);
      uint16_t      Rpdt() const;
      bool          IsRmType() const;

      void          SetRpds(uint16_t rpds);
      uint16_t      Rpds() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants (also defined in cpp)
      static const uint16_t kDTE_M_RM = kWBit02; //!< rm type flag
      static const uint16_t kDTE_RP04 = 00; //!< drive type of RP04  rm=0
      static const uint16_t kDTE_RP06 = 01; //!< drive type of RP06  rm=0
      static const uint16_t kDTE_RM03 = 04; //!< drive type of RM03  rm=1
      static const uint16_t kDTE_RM80 = 05; //!< drive type of RM80  rm=1
      static const uint16_t kDTE_RM05 = 06; //!< drive type of RM05  rm=1
      static const uint16_t kDTE_RP07 = 07; //!< drive type of RP07  rm=1

    protected:
      uint16_t      fRpdt;                  //!< drive type (encoded)
      uint16_t      fRpds;                  //!< drive status
  };
  
} // end namespace Retro

#include "Rw11UnitRHRP.ipp"

#endif
