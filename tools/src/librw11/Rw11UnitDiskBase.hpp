// $Id: Rw11UnitDiskBase.hpp 515 2013-05-04 17:28:59Z mueller $
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
// 2013-05-03   515   1.1    use AttachDone(),DetachCleanup(),DetachDone()
// 2013-04-14   506   1.0    Initial version
// 2013-02-22   490   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11UnitDiskBase.hpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Declaration of class Rw11UnitDiskBase.
*/

#ifndef included_Retro_Rw11UnitDiskBase
#define included_Retro_Rw11UnitDiskBase 1

#include "Rw11UnitDisk.hpp"

namespace Retro {

  template <class TC>
  class Rw11UnitDiskBase : public Rw11UnitDisk {
    public:

                    Rw11UnitDiskBase(TC* pcntl, size_t index);
                   ~Rw11UnitDiskBase();

      TC&           Cntl() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      virtual void  AttachDone();
      virtual void  DetachDone();

    protected:
      TC*           fpCntl;
  };
  
} // end namespace Retro

#include "Rw11UnitDiskBase.ipp"

#endif
