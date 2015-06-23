// $Id: RlinkPacketBuf.hpp 606 2014-11-24 07:08:51Z mueller $
//
// Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-11-23   606   2.0    re-organize for rlink v4
// 2013-04-21   509   1.0.2  add SndAttn() method
// 2013-01-13   474   1.0.1  add PollAttn() method
// 2011-04-02   375   1.0    Initial version
// 2011-03-05   366   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkPacketBuf.hpp 606 2014-11-24 07:08:51Z mueller $
  \brief   Declaration of class RlinkPacketBuf.
*/

#ifndef included_Retro_RlinkPacketBuf
#define included_Retro_RlinkPacketBuf 1

#include <cstdint>
#include <ostream>
#include <vector>

#include "boost/utility.hpp"

#include "librtools/Rstats.hpp"

#include "RlinkCrc16.hpp"

namespace Retro {

  class RlinkPacketBuf : private boost::noncopyable {
    public:

                    RlinkPacketBuf();
                   ~RlinkPacketBuf();
    
      size_t        PktSize() const;

      uint32_t      Flags() const;
      bool          TestFlag(uint32_t mask) const;

      const Rstats& Stats() const;

      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // flag bits (also defined in cpp)
      static const uint32_t kFlagSopSeen    = 1<<0;  //!< sop was seen
      static const uint32_t kFlagEopSeen    = 1<<1;  //!< eop was seen
      static const uint32_t kFlagNakSeen    = 1<<2;  //!< nak was seen
      static const uint32_t kFlagAttnSeen   = 1<<3;  //!< attn was seen
      static const uint32_t kFlagErrTout    = 1<<16; //!< err: timeout on read
      static const uint32_t kFlagErrIO      = 1<<17; //!< err: IO error on read
      static const uint32_t kFlagErrFrame   = 1<<18; //!< err: frame error
      static const uint32_t kFlagErrClobber = 1<<19; //!< err: clobbered esc

    // some constants (also defined in cpp)
      static const uint8_t kSymEsc    = 0xCA;   //!< VHDL def escape  1100 1010
      static const uint8_t kSymFill   = 0xD5;   //!< VHDL def fill    1101 0101
      static const uint8_t kSymXon    = 0x11;   //!< VHDL def xon     0001 0001
      static const uint8_t kSymXoff   = 0x13;   //!< VHDL def xoff    0001 0011
      static const uint8_t kSymEdPref = 0x40;   //!< VHDL def ed_pref 0100 0000
      static const uint8_t kEcSop     = 0x00;   //!< VHDL def ec_sop        000
      static const uint8_t kEcEop     = 0x01;   //!< VHDL def ec_eop        001
      static const uint8_t kEcNak     = 0x02;   //!< VHDL def ec_nak        010
      static const uint8_t kEcAttn    = 0x03;   //!< VHDL def ec_attn       011
      static const uint8_t kEcXon     = 0x04;   //!< VHDL def ec_xon        100
      static const uint8_t kEcXoff    = 0x05;   //!< VHDL def ec_xoff       101
      static const uint8_t kEcFill    = 0x06;   //!< VHDL def ec_fill       110
      static const uint8_t kEcEsc     = 0x07;   //!< VHDL def ec_esc        111
      static const uint8_t kEcClobber = 0xff;   //!< invalid Ecode             

    protected:
      void          SetFlagBit(uint32_t mask);
      void          ClearFlagBit(uint32_t mask);

    protected: 
      std::vector<uint8_t> fPktBuf;         //!< packet buffer
      RlinkCrc16    fCrc;                   //!< crc accumulator
      uint32_t      fFlags;                 //!< request/response flags
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "RlinkPacketBuf.ipp"

#endif
