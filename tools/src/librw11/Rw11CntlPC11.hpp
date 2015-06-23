// $Id: Rw11CntlPC11.hpp 665 2015-04-07 07:13:49Z mueller $
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
// 2013-05-03   515   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11CntlPC11.hpp 665 2015-04-07 07:13:49Z mueller $
  \brief   Declaration of class Rw11CntlPC11.
*/

#ifndef included_Retro_Rw11CntlPC11
#define included_Retro_Rw11CntlPC11 1

#include "Rw11CntlBase.hpp"
#include "Rw11UnitPC11.hpp"

namespace Retro {

  class Rw11CntlPC11 : public Rw11CntlBase<Rw11UnitPC11,2> {
    public:

                    Rw11CntlPC11();
                   ~Rw11CntlPC11();

      void          Config(const std::string& name, uint16_t base, int lam);

      virtual void  Start();

      virtual bool  BootCode(size_t unit, std::vector<uint16_t>& code, 
                             uint16_t& aload, uint16_t& astart);

      virtual void  UnitSetup(size_t ind);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants (also defined in cpp)
      static const uint16_t kIbaddr = 0177550; //!< PC11 default address
      static const int      kLam    = 10;      //!< PC11 default lam 

      static const uint16_t kRCSR = 000;  //!< RCSR reg offset
      static const uint16_t kRBUF = 002;  //!< RBUF reg offset
      static const uint16_t kPCSR = 004;  //!< PCSR reg offset
      static const uint16_t kPBUF = 006;  //!< PBUF reg offset

      static const uint16_t kUnit_PR   = 0;   //<! unit number of paper reader 
      static const uint16_t kUnit_PP   = 1;   //<! unit number of paper puncher 

      static const uint16_t kProbeOff = kRCSR; //!< probe address offset (rcsr)
      static const bool     kProbeInt = true;  //!< probe int active
      static const bool     kProbeRem = true;  //!< probr rem active

      static const uint16_t kRCSR_M_ERROR = kWBit15;
      static const uint16_t kPCSR_M_ERROR = kWBit15;
      static const uint16_t kPBUF_M_RBUSY = kWBit09;
      static const uint16_t kPBUF_M_PVAL  = kWBit08;
      static const uint16_t kPBUF_M_BUF   = 0377;

    protected:
      int           AttnHandler(RlinkServer::AttnArgs& args);
      void          SetOnline(size_t ind, bool online);
    
    protected:
      size_t        fPC_pbuf;               //!< PrimClist: pbuf index
  };
  
} // end namespace Retro

//#include "Rw11CntlPC11.ipp"

#endif
