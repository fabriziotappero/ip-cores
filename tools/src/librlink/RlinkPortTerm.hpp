// $Id: RlinkPortTerm.hpp 666 2015-04-12 21:17:54Z mueller $
//
// Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-04-11   666   1.1    drop xon/xoff excaping, now done in RlinkPacketBuf
// 2011-12-18   440   1.0.2  add kStatNPort stats
// 2011-12-11   438   1.0.1  Read(),Write(): added for xon handling, tcdrain();
// 2011-03-27   374   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkPortTerm.hpp 666 2015-04-12 21:17:54Z mueller $
  \brief   Declaration of class RlinkPortTerm.
*/

#ifndef included_Retro_RlinkPortTerm
#define included_Retro_RlinkPortTerm 1

#include <vector>
#include <termios.h>

#include "RlinkPort.hpp"

namespace Retro {

  class RlinkPortTerm : public RlinkPort {
    public:

                    RlinkPortTerm();
      virtual       ~RlinkPortTerm();

      virtual bool  Open(const std::string& url, RerrMsg& emsg);
      virtual void  Close();
 
      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants (also defined in cpp)
      static const uint8_t kc_xon  = 0x11;  // XON  char -> ^Q = hex 11
      static const uint8_t kc_xoff = 0x13;  // XOFF char -> ^S = hex 13

    protected:
      void          DumpTios(std::ostream& os, int ind, const std::string& name,
                             const struct termios& tios) const;

    protected:
      struct termios fTiosOld;
      struct termios fTiosNew;
  };
  
} // end namespace Retro

//#include "RlinkPortTerm.ipp"

#endif
