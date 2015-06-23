// $Id: Rw11UnitTermBase.hpp 504 2013-04-13 15:37:24Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-03-03   494   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11UnitTermBase.hpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Declaration of class Rw11UnitTermBase.
*/

#ifndef included_Retro_Rw11UnitTermBase
#define included_Retro_Rw11UnitTermBase 1

#include "Rw11UnitTerm.hpp"

namespace Retro {

  template <class TC>
  class Rw11UnitTermBase : public Rw11UnitTerm {
    public:

                    Rw11UnitTermBase(TC* pcntl, size_t index);
                   ~Rw11UnitTermBase();

      TC&           Cntl() const;

      virtual void  WakeupCntl();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      TC*           fpCntl;
  };
  
} // end namespace Retro

#include "Rw11UnitTermBase.ipp"

#endif
