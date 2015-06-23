// $Id: RtclSet.hpp 487 2013-02-12 19:14:38Z mueller $
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
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclSet.hpp 487 2013-02-12 19:14:38Z mueller $
  \brief   Declaration of class \c RtclSet.
*/

#ifndef included_Retro_RtclSet
#define included_Retro_RtclSet 1

#include "tcl.h"

#include <cstdint>
#include <string>

#include "boost/function.hpp"

#include "librtools/Rexception.hpp"
#include "RtclSetBase.hpp"

namespace Retro {

  template <class TP>
  class RtclSet : public RtclSetBase {
    public:
      explicit      RtclSet(const boost::function<void(TP)>& set);
                   ~RtclSet();

      virtual void  operator()(RtclArgs& args) const;

    protected: 
      boost::function<void(TP)> fSet;
  };
  
  
} // end namespace Retro

#include "RtclSet.ipp"

#endif
