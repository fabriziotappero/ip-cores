// $Id: Rw11UnitTapeBase.hpp 686 2015-06-04 21:08:08Z mueller $
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
// 2015-05-17   683   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11UnitTapeBase.hpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Declaration of class Rw11UnitTapeBase.
*/

#ifndef included_Retro_Rw11UnitTapeBase
#define included_Retro_Rw11UnitTapeBase 1

#include "Rw11UnitTape.hpp"

namespace Retro {

  template <class TC>
  class Rw11UnitTapeBase : public Rw11UnitTape {
    public:

                    Rw11UnitTapeBase(TC* pcntl, size_t index);
                   ~Rw11UnitTapeBase();

      TC&           Cntl() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      virtual void  AttachDone();
      virtual void  DetachDone();

    protected:
      TC*           fpCntl;
  };
  
} // end namespace Retro

#include "Rw11UnitTapeBase.ipp"

#endif
