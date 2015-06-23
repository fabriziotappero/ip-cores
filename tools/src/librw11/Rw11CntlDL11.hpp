// $Id: Rw11CntlDL11.hpp 665 2015-04-07 07:13:49Z mueller $
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
// 2013-05-04   516   1.0.1  add RxRlim support (receive interrupt rate limit)
// 2013-03-06   495   1.0    Initial version
// 2013-02-05   483   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11CntlDL11.hpp 665 2015-04-07 07:13:49Z mueller $
  \brief   Declaration of class Rw11CntlDL11.
*/

#ifndef included_Retro_Rw11CntlDL11
#define included_Retro_Rw11CntlDL11 1

#include "Rw11CntlBase.hpp"
#include "Rw11UnitDL11.hpp"

namespace Retro {

  class Rw11CntlDL11 : public Rw11CntlBase<Rw11UnitDL11,1> {
    public:

                    Rw11CntlDL11();
                   ~Rw11CntlDL11();

      void          Config(const std::string& name, uint16_t base, int lam);

      virtual void  Start();

      virtual void  UnitSetup(size_t ind);
      void          Wakeup();

      void          SetRxRlim(uint16_t rlim);
      uint16_t      RxRlim() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants (also defined in cpp)
      static const uint16_t kIbaddr = 0177560; //!< DL11 default address
      static const int      kLam    = 1;       //!< DL11 default lam 

      static const uint16_t kRCSR = 000; //!< RCSR reg offset
      static const uint16_t kRBUF = 002; //!< RBUF reg offset
      static const uint16_t kXCSR = 004; //!< XCSR reg offset
      static const uint16_t kXBUF = 006; //!< XBUF reg offset

      static const uint16_t kProbeOff = kRCSR; //!< probe address offset (rcsr)
      static const bool     kProbeInt = true;  //!< probe int active
      static const bool     kProbeRem = true;  //!< probr rem active

      static const uint16_t kRCSR_M_RXRLIM = 0070000;
      static const uint16_t kRCSR_V_RXRLIM = 12;
      static const uint16_t kRCSR_B_RXRLIM = 007;
      static const uint16_t kRCSR_M_RDONE  = kWBit07;
      static const uint16_t kXCSR_M_XRDY   = kWBit07;
      static const uint16_t kXBUF_M_RRDY   = kWBit09;
      static const uint16_t kXBUF_M_XVAL   = kWBit08;
      static const uint16_t kXBUF_M_XBUF   = 0xff;

    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
    
    protected:
      size_t        fPC_xbuf;               //!< PrimClist: xbuf index
      uint16_t      fRxRlim;                //!< rx interrupt rate limit
  };
  
} // end namespace Retro

//#include "Rw11CntlDL11.ipp"

#endif
