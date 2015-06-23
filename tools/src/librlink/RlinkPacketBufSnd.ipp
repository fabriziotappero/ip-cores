// $Id: RlinkPacketBufSnd.ipp 666 2015-04-12 21:17:54Z mueller $
//
// Copyright 2014-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-04-11   666   1.1    handle xon/xoff escaping, add (Set)XonEscape()
// 2014-11-08   602   1.0    Initial version
// 2014-11-02   600   0.1    First draft (re-organize PacketBuf for rlink v4)
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPacketBufSnd.ipp 666 2015-04-12 21:17:54Z mueller $
  \brief   Implemenation (inline) of class RlinkPacketBuf.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBufSnd::PutWithCrc(uint8_t data)
{
  fPktBuf.push_back(data);
  fCrc.AddData(data);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBufSnd::SetXonEscape(bool xon)
{
  fXonEscape = xon;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkPacketBufSnd::XonEscape() const
{
  return fXonEscape;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBufSnd::PutWithCrc(uint16_t data)
{
  uint8_t  datl =  data     & 0xff;
  uint8_t  dath = (data>>8) & 0xff;
  fPktBuf.push_back(datl);
  fPktBuf.push_back(dath);
  fCrc.AddData(datl);
  fCrc.AddData(dath);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBufSnd::PutCrc()
{
  uint16_t data = fCrc.Crc();
  uint8_t  datl =  data     & 0xff;
  uint8_t  dath = (data>>8) & 0xff;
  fPktBuf.push_back(datl);
  fPktBuf.push_back(dath);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkPacketBufSnd::PutRawEsc(uint8_t ec)
{
  fRawBuf.push_back(kSymEsc);
  uint8_t ed = kSymEdPref | ((~ec)&0x7)<<3 | ec;
  fRawBuf.push_back(ed);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t RlinkPacketBufSnd::RawSize() const
{
  return fRawBuf.size();
}

} // end namespace Retro
