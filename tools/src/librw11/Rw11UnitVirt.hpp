// $Id: Rw11UnitVirt.hpp 504 2013-04-13 15:37:24Z mueller $
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
  \version $Id: Rw11UnitVirt.hpp 504 2013-04-13 15:37:24Z mueller $
  \brief   Declaration of class Rw11UnitVirt.
*/

#ifndef included_Retro_Rw11UnitVirt
#define included_Retro_Rw11UnitVirt 1

#include "boost/scoped_ptr.hpp"

#include "Rw11Unit.hpp"

namespace Retro {

  template <class TV>
  class Rw11UnitVirt : public Rw11Unit {
    public:

                    Rw11UnitVirt(Rw11Cntl* pcntl, size_t index);
                   ~Rw11UnitVirt();

      TV*           Virt() const;

      virtual bool  Attach(const std::string& url, RerrMsg& emsg);
      virtual void  Detach();

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      boost::scoped_ptr<TV> fpVirt;

  };
  
} // end namespace Retro

#include "Rw11UnitVirt.ipp"

#endif
