// $Id: RlinkContext.hpp 661 2015-04-03 18:28:41Z mueller $
//
// Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-03-28   660   1.1    add SetStatus(Value|Mask)()
// 2013-02-23   492   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkContext.hpp 661 2015-04-03 18:28:41Z mueller $
  \brief   Declaration of class RlinkContext.
*/

#ifndef included_Retro_RlinkContext
#define included_Retro_RlinkContext 1

#include <cstdint>

namespace Retro {

  class RlinkContext {
    public:
                    RlinkContext();
                   ~RlinkContext();

      void          SetStatus(uint8_t stat, uint8_t statmsk=0xff);

      void          SetStatusValue(uint8_t stat);
      void          SetStatusMask(uint8_t statmsk);

      uint8_t       StatusValue() const;
      uint8_t       StatusMask() const;

      bool          StatusIsChecked() const;
      bool          StatusCheck(uint8_t val) const;

      void          IncErrorCount(size_t inc = 1);
      void          ClearErrorCount();
      size_t        ErrorCount() const;

      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;
    
    protected: 
      uint8_t       fStatusVal;             //!< status value
      uint8_t       fStatusMsk;             //!< status mask
      size_t        fErrCnt;                //!< error count
  };
  
} // end namespace Retro

#include "RlinkContext.ipp"

#endif
