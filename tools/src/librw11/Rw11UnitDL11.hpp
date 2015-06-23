// $Id: Rw11UnitDL11.hpp 504 2013-04-13 15:37:24Z mueller $
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
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11UnitDL11.hpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Declaration of class Rw11UnitDL11.
*/

#ifndef included_Retro_Rw11UnitDL11
#define included_Retro_Rw11UnitDL11 1

#include "Rw11VirtTerm.hpp"

#include "Rw11UnitTermBase.hpp"

namespace Retro {

  class Rw11CntlDL11;                       // forw decl to avoid circular incl

  class Rw11UnitDL11 : public Rw11UnitTermBase<Rw11CntlDL11> {
    public:

                    Rw11UnitDL11(Rw11CntlDL11* pcntl, size_t index);
                   ~Rw11UnitDL11();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:

  };
  
} // end namespace Retro

//#include "Rw11UnitDL11.ipp"

#endif
