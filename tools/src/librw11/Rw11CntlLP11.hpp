// $Id: Rw11CntlLP11.hpp 665 2015-04-07 07:13:49Z mueller $
//
// Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-12-29   623   1.1    adopt to Rlink V4 attn logic
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11CntlLP11.hpp 665 2015-04-07 07:13:49Z mueller $
  \brief   Declaration of class Rw11CntlLP11.
*/

#ifndef included_Retro_Rw11CntlLP11
#define included_Retro_Rw11CntlLP11 1

#include "Rw11CntlBase.hpp"
#include "Rw11UnitLP11.hpp"

namespace Retro {

  class Rw11CntlLP11 : public Rw11CntlBase<Rw11UnitLP11,1> {
    public:

                    Rw11CntlLP11();
                   ~Rw11CntlLP11();

      void          Config(const std::string& name, uint16_t base, int lam);

      virtual void  Start();

      virtual void  UnitSetup(size_t ind);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants (also defined in cpp)
      static const uint16_t kIbaddr = 0177514; //!< LP11 default address
      static const int      kLam    = 8;       //!< LP11 default lam 

      static const uint16_t kCSR = 000;  //!< CSR reg offset
      static const uint16_t kBUF = 002;  //!< BUF reg offset

      static const uint16_t kProbeOff = kCSR;  //!< probe address offset (rcsr)
      static const bool     kProbeInt = true;  //!< probe int active
      static const bool     kProbeRem = true;  //!< probr rem active

      static const uint16_t kCSR_M_ERROR = kWBit15;
      static const uint16_t kBUF_M_VAL   = kWBit08;
      static const uint16_t kBUF_M_BUF   = 0177;

    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
      void          SetOnline(bool online);
    
    protected:
      size_t        fPC_buf;               //!< PrimClist: buf index
  };
  
} // end namespace Retro

//#include "Rw11CntlLP11.ipp"

#endif
