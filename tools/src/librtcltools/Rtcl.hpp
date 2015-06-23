// $Id: Rtcl.hpp 486 2013-02-10 22:34:43Z mueller $
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
// 2013-01-06   473   1.0.4  add NewListIntObj(const uint(8|16)_t, ...)
// 2011-03-13   369   1.0.3  add NewListIntObj(vector<uint8_t>)
// 2011-03-12   368   1.0.2  use namespace Rtcl
// 2011-03-05   366   1.0.1  add AppendResultNewLines()
// 2011-02-26   364   1.0    Initial version
// 2011-02-18   362   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rtcl.hpp 486 2013-02-10 22:34:43Z mueller $
  \brief   Declaration of class Rtcl.
*/

#ifndef included_Retro_Rtcl
#define included_Retro_Rtcl 1

#include "tcl.h"

#include <cstddef>
#include <string>
#include <sstream>
#include <vector>

namespace Retro {

  namespace Rtcl {
    Tcl_Obj*        NewLinesObj(const std::string& str);
    Tcl_Obj*        NewLinesObj(std::ostringstream& sos);

    Tcl_Obj*        NewListIntObj(const uint8_t* data, size_t size);
    Tcl_Obj*        NewListIntObj(const uint16_t* data, size_t size);
    Tcl_Obj*        NewListIntObj(const std::vector<uint8_t>& vec);
    Tcl_Obj*        NewListIntObj(const std::vector<uint16_t>& vec);

    bool            SetVar(Tcl_Interp* interp, 
                           const std::string& varname, Tcl_Obj* pobj);
    bool            SetVarOrResult(Tcl_Interp* interp, 
                                   const std::string& varname, Tcl_Obj* pobj);

    void            AppendResultNewLines(Tcl_Interp* interp);

    void            SetResult(Tcl_Interp* interp, const std::string& str);
    void            SetResult(Tcl_Interp* interp, std::ostringstream& sos);
  };
  
} // end namespace Retro

#include "Rtcl.ipp"

#endif
