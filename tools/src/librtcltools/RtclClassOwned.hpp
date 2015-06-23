// $Id: RtclClassOwned.hpp 482 2013-02-05 15:53:09Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-02-20   363   1.0    Initial version
// 2011-02-11   360   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclClassOwned.hpp 482 2013-02-05 15:53:09Z mueller $
  \brief   Declaration of class RtclClassOwned.
*/

#ifndef included_Retro_RtclClassOwned
#define included_Retro_RtclClassOwned 1

#include "tcl.h"

#include <string>

#include "RtclClassBase.hpp"

namespace Retro {

  template <class TP>
    class RtclClassOwned : public RtclClassBase {
    public:

      explicit      RtclClassOwned(const std::string& type = std::string());
                   ~RtclClassOwned();

      int           ClassCmdCreate(Tcl_Interp* interp, int objc, 
                                   Tcl_Obj* const objv[]);    

      static void   CreateClass(Tcl_Interp* interp, const char* name,
                                const std::string& type);
  };
  
} // end namespace Retro

// implementation all inline
#include "RtclClassOwned.ipp"

#endif
