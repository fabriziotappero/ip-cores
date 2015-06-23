// $Id: RtclRw11UnitTerm.hpp 511 2013-04-27 13:51:46Z mueller $
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
// 2013-04-26   511   1.0.1  add M_type
// 2013-03-03   494   1.0    Initial version
// 2013-03-01   493   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11UnitTerm.hpp 511 2013-04-27 13:51:46Z mueller $
  \brief   Declaration of class RtclRw11UnitTerm.
*/

#ifndef included_Retro_RtclRw11UnitTerm
#define included_Retro_RtclRw11UnitTerm 1

#include "librw11/Rw11UnitTerm.hpp"

#include "RtclRw11Unit.hpp"

namespace Retro {

  class RtclRw11UnitTerm {
    public:
                    RtclRw11UnitTerm(RtclRw11Unit* ptcl, Rw11UnitTerm* pobj);
                   ~RtclRw11UnitTerm();

    protected:
      int           M_type(RtclArgs& args);

    protected:
      RtclRw11Unit* fpTcl;
      Rw11UnitTerm* fpObj;
  };
  
} // end namespace Retro

//#include "RtclRw11UnitTerm.ipp"

#endif
