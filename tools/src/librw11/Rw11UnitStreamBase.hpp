// $Id: Rw11UnitStreamBase.hpp 515 2013-05-04 17:28:59Z mueller $
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
// 2013-05-04   515   1.0    Initial version
// 2013-05-01   513   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11UnitStreamBase.hpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Declaration of class Rw11UnitStreamBase.
*/

#ifndef included_Retro_Rw11UnitStreamBase
#define included_Retro_Rw11UnitStreamBase 1

#include "Rw11UnitStream.hpp"

namespace Retro {

  template <class TC>
  class Rw11UnitStreamBase : public Rw11UnitStream {
    public:

                    Rw11UnitStreamBase(TC* pcntl, size_t index);
                   ~Rw11UnitStreamBase();

      TC&           Cntl() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      virtual void  AttachDone();
      virtual void  DetachDone();

    protected:
      TC*           fpCntl;
  };
  
} // end namespace Retro

#include "Rw11UnitStreamBase.ipp"

#endif
