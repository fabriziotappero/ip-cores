// $Id: Rw11CntlBase.hpp 682 2015-05-15 18:35:29Z mueller $
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
// 2013-03-06   495   1.0    Initial version
// 2013-02-14   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11CntlBase.hpp 682 2015-05-15 18:35:29Z mueller $
  \brief   Declaration of class Rw11CntlBase.
*/

#ifndef included_Retro_Rw11CntlBase
#define included_Retro_Rw11CntlBase 1

#include "boost/shared_ptr.hpp"

#include "Rw11Cntl.hpp"

namespace Retro {

  template <class TU, size_t NU>
  class Rw11CntlBase : public Rw11Cntl {
    public:

      explicit      Rw11CntlBase(const std::string& type);
                   ~Rw11CntlBase();

      virtual size_t NUnit() const;
      TU&           Unit(size_t index) const;
      const boost::shared_ptr<TU>& UnitSPtr(size_t index) const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      boost::shared_ptr<TU> fspUnit[NU];
  };
  
} // end namespace Retro

#include "Rw11CntlBase.ipp"

#endif
