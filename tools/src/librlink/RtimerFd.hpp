// $Id: RtimerFd.hpp 486 2013-02-10 22:34:43Z mueller $
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
// 2013-01-11   473   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtimerFd.hpp 486 2013-02-10 22:34:43Z mueller $
  \brief   Declaration of class \c RtimerFd.
*/

#ifndef included_Retro_RtimerFd
#define included_Retro_RtimerFd 1

#include "boost/utility.hpp"
#include "boost/date_time/posix_time/posix_time_types.hpp"

namespace Retro {

  class RtimerFd : private boost::noncopyable {
    public:
                    RtimerFd();
      virtual      ~RtimerFd();

      int           Fd() const;
      void          SetRelTimer(boost::posix_time::time_duration interval,
                                boost::posix_time::time_duration initial);

      operator      int() const;

    protected:

      int           fFd;
};
  
} // end namespace Retro

#include "RtimerFd.ipp"

#endif
