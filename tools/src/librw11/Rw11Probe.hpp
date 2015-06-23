// $Id: Rw11Probe.hpp 495 2013-03-06 17:13:48Z mueller $
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
// 2013-03-05   495   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11Probe.hpp 495 2013-03-06 17:13:48Z mueller $
  \brief   Declaration of class Rw11Probe.
*/

#ifndef included_Retro_Rw11Probe
#define included_Retro_Rw11Probe 1

namespace Retro {

  struct Rw11Probe {
      uint16_t      fAddr;
      bool          fProbeInt;
      bool          fProbeRem;
      bool          fProbeDone;
      bool          fFoundInt;
      bool          fFoundRem;

      explicit      Rw11Probe(uint16_t addr = 0, bool probeint = false, 
                              bool proberem = false);

      bool          Found() const;

      char          IndicatorInt() const;
      char          IndicatorRem() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;
  };
  
} // end namespace Retro

//#include "Rw11Probe.ipp"

#endif
