// $Id: RlinkPacketBufRcv.ipp 606 2014-11-24 07:08:51Z mueller $
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
// 2014-11-23   606   1.0    Initial version
// 2014-11-02   600   0.1    First draft (re-organize PacketBuf for rlink v4)
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPacketBufRcv.ipp 606 2014-11-24 07:08:51Z mueller $
  \brief   Implemenation (inline) of class RlinkPacketBuf.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPacketBufRcv::CheckSize(size_t nbyte) const
{
  return fPktBuf.size()-fNDone >= nbyte;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBufRcv::GetWithCrc(uint8_t& data)
{
  data = fPktBuf[fNDone++];
  fCrc.AddData(data);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBufRcv::GetWithCrc(uint16_t& data)
{
  uint8_t datl = fPktBuf[fNDone++];
  uint8_t dath = fPktBuf[fNDone++];
  fCrc.AddData(datl);
  fCrc.AddData(dath);
  data = uint16_t(datl) | (uint16_t(dath) << 8);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPacketBufRcv::CheckCrc()
{
  uint8_t  datl = fPktBuf[fNDone++];
  uint8_t  dath = fPktBuf[fNDone++];
  uint16_t data = uint16_t(datl) | (uint16_t(dath) << 8);
  return data == fCrc.Crc();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline int RlinkPacketBufRcv::NakIndex() const
{
  return fNakIndex;
}

} // end namespace Retro
