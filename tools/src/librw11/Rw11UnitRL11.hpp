// $Id: Rw11UnitRL11.hpp 653 2015-03-01 12:53:01Z mueller $
//
// Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-06-08   561   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11UnitRL11.hpp 653 2015-03-01 12:53:01Z mueller $
  \brief   Declaration of class Rw11UnitRL11.
*/

#ifndef included_Retro_Rw11UnitRL11
#define included_Retro_Rw11UnitRL11 1

#include "Rw11UnitDiskBase.hpp"

namespace Retro {

  class Rw11CntlRL11;                       // forw decl to avoid circular incl

  class Rw11UnitRL11 : public Rw11UnitDiskBase<Rw11CntlRL11> {
    public:
                    Rw11UnitRL11(Rw11CntlRL11* pcntl, size_t index);
                   ~Rw11UnitRL11();

      virtual void  SetType(const std::string& type);

      void          SetRlsta(uint16_t rlsta);
      void          SetRlpos(uint16_t rlpos);
      uint16_t      Rlsta() const;
      uint16_t      Rlpos() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      uint16_t      fRlsta;
      uint16_t      fRlpos;
  };
  
} // end namespace Retro

#include "Rw11UnitRL11.ipp"

#endif
