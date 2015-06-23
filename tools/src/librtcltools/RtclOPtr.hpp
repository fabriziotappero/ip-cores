// $Id: RtclOPtr.hpp 521 2013-05-20 22:16:45Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-05-20   521   1.0.1  declare ctor(Tcl_Obj*) as explicit
// 2011-02-20   363   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclOPtr.hpp 521 2013-05-20 22:16:45Z mueller $
  \brief   Declaration of class RtclOPtr.
*/

#ifndef included_Retro_RtclOPtr
#define included_Retro_RtclOPtr 1

#include "tcl.h"

namespace Retro {

  class RtclOPtr {
    public:
                        RtclOPtr();
      explicit          RtclOPtr(Tcl_Obj* pobj);
                        RtclOPtr(const RtclOPtr& rhs);
                       ~RtclOPtr();

                        operator Tcl_Obj*() const;
      bool              operator !() const;
      RtclOPtr&         operator=(const RtclOPtr& rhs);
      RtclOPtr&         operator=(Tcl_Obj* pobj);

    protected:
      Tcl_Obj*          fpObj;              //!< pointer to tcl object
  };

} // end namespace Retro

// implementation all inline
#include "RtclOPtr.ipp"

#endif
