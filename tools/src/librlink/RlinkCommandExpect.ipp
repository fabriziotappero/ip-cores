// $Id: RlinkCommandExpect.ipp 661 2015-04-03 18:28:41Z mueller $
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
// 2015-04-02   661   1.2    expect logic: remove stat from Expect, invert mask
// 2014-12-20   616   1.1    add Done count methods (for rblk/wblk)
// 2011-03-12   368   1.0    Initial version
// 2011-01-15   355   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkCommandExpect.ipp 661 2015-04-03 18:28:41Z mueller $
  \brief   Implemenation (inline) of class RlinkCommandExpect.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommandExpect::SetData(uint16_t data, uint16_t datamsk)
{
  fDataVal = data;
  fDataMsk = datamsk;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommandExpect::SetDone(uint16_t done, bool check)
{
  fDataVal = done;
  fDataMsk = check ? 0xffff : 0x0;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommandExpect::SetBlock(const std::vector<uint16_t>& block)
{
  fBlockVal = block;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void RlinkCommandExpect::SetBlock(
                   const std::vector<uint16_t>& block,
                   const std::vector<uint16_t>& blockmsk)
{
  fBlockVal = block;
  fBlockMsk = blockmsk;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t RlinkCommandExpect::DataValue() const
{
  return fDataVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t RlinkCommandExpect::DataMask() const
{
  return fDataMsk;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint16_t RlinkCommandExpect::DoneValue() const
{
  return fDataVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::vector<uint16_t>& RlinkCommandExpect::BlockValue() const
{
  return fBlockVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::vector<uint16_t>& RlinkCommandExpect::BlockMask() const
{
  return fBlockMsk;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkCommandExpect::DataCheck(uint16_t val) const
{
  return (val & fDataMsk) == fDataVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkCommandExpect::DoneCheck(uint16_t val) const
{
  return !DoneIsChecked() || val == fDataVal;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkCommandExpect::DataIsChecked() const
{
  return fDataMsk != 0x0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool RlinkCommandExpect::DoneIsChecked() const
{
  return fDataMsk != 0x0;
}

} // end namespace Retro
