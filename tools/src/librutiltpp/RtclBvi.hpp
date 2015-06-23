// $Id: RtclBvi.hpp 486 2013-02-10 22:34:43Z mueller $
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
// 2011-03-27   374   1.0    Initial version
// 2011-02-18   362   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclBvi.hpp 486 2013-02-10 22:34:43Z mueller $
  \brief   Declaration of class RtclBvi.
*/

#ifndef included_Retro_RtclBvi
#define included_Retro_RtclBvi 1

#include "tcl.h"

namespace Retro {

  class RtclBvi {
    public:
      static void   CreateCmds(Tcl_Interp* interp);

    protected:
      enum ConvMode {kStr2Int = 0,
                     kInt2Str};
    
      static int    DoCmd(ClientData cdata, Tcl_Interp* interp, 
                           int objc, Tcl_Obj* const objv[]);
      static Tcl_Obj* DoConv(Tcl_Interp* interp, ConvMode mode, Tcl_Obj* val, 
                             char form, int nbit);
      static bool   CheckFormat(Tcl_Interp* interp, int objc,
                                Tcl_Obj* const objv[], bool& list, 
                                char& form, int& nbit);
  };
  
} // end namespace Retro

//#include "RtclBvi.ipp"

#endif
