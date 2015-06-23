// $Id: RlinkPacketBufRcv.hpp 621 2014-12-26 21:20:05Z mueller $
//
// Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-12-25   621   1.0.1  Reorganize packet send/revd stats
// 2014-11-30   607   1.0    Initial version 
// 2014-11-02   600   0.1    First draft (re-organize PacketBuf for rlink v4)
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkPacketBufRcv.hpp 621 2014-12-26 21:20:05Z mueller $
  \brief   Declaration of class RlinkPacketBuf.
*/

#ifndef included_Retro_RlinkPacketBufRcv
#define included_Retro_RlinkPacketBufRcv 1

#include "RlinkPacketBuf.hpp"
#include "RlinkPort.hpp"

namespace Retro {

  class RlinkPacketBufRcv: public RlinkPacketBuf  {
    public:

                    RlinkPacketBufRcv();
                   ~RlinkPacketBufRcv();

      int           ReadData(RlinkPort* port, double timeout, RerrMsg& emsg);
      bool          ProcessData();
      void          AcceptPacket();
      void          FlushRaw();

      enum pkt_state {
        kPktPend=0,                         //<! pending, still being filled
        kPktResp,                           //<! response packet (SOP+EOP)
        kPktAttn,                           //<! attn notify packet (ATTN+EOP)
        kPktError                           //<! errorous packet
      };
      pkt_state     PacketState();

      bool          CheckSize(size_t nbyte) const;
      void          GetWithCrc(uint8_t& data);
      void          GetWithCrc(uint16_t& data);
      void          GetWithCrc(uint16_t* pdata, size_t count);
      bool          CheckCrc();
 
      int           NakIndex() const;
 
      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

   // statistics counter indices
      enum stats {
        kStatNRxPktByt=0,                   //!< Rx packet bytes rcvd
        kStatNRxDrop,                       //!< Rx bytes dropped
        kStatNRxSop,                        //!< Rx SOP commas seen
        kStatNRxEop,                        //!< Rx EOP commas seen
        kStatNRxNak,                        //!< Rx NAK commas seen
        kStatNRxAttn,                       //!< Rx ATTN commas seen
        kStatNRxEsc,                        //!< Rx data escapes
        kStatNRxClobber                     //!< Rx clobbered escapes
      };

    protected:
      void          ProcessDataIdle();
      void          ProcessDataFill();
      uint8_t       GetEcode();

      enum rcv_state {
        kRcvIdle=0,                         //!< wait for SOP or ATTN
        kRcvFill,                           //!< fill packet till EOP seen
        kRcvDone,                           //!< packet ok, EOP seen
        kRcvError                           //!< packet framing error
      };
    
    protected: 
      uint8_t       fRawBuf[4096];          //!< raw data buffer
      size_t        fRawBufSize;            //!< # of valid bytes in RawBuf
      size_t        fRawBufDone;            //!< # of processed bytes in RawBuf
      enum rcv_state       fRcvState;       //!< receive FSM state
      size_t        fNDone;                 //!< number of pkt bytes processed
      bool          fEscSeen;               //!< last char was Escape
      int           fNakIndex;              //!< index of active nak (-1 if no)
      std::vector<uint8_t> fDropData;       //!< dropped data buffer    
  };
  
} // end namespace Retro

#include "RlinkPacketBufRcv.ipp"

#endif
