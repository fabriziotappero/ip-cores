// $Id: Rw11UnitDisk.ipp 659 2015-03-22 23:15:51Z mueller $
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
// 2015-03-21   659   1.0.2  add fEnabled, Enabled()
// 2015-02-18   647   1.0.1  add Nwrd2Nblk()
// 2013-04-19   507   1.0    Initial version
// 2013-02-19   490   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11UnitDisk.ipp 659 2015-03-22 23:15:51Z mueller $
  \brief   Implemenation (inline) of Rw11UnitDisk.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline const std::string& Rw11UnitDisk::Type() const
{
  return fType;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitDisk::Enabled() const
{
  return fEnabled;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11UnitDisk::NCylinder() const
{
  return fNCyl;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11UnitDisk::NHead() const
{
  return fNHead;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11UnitDisk::NSector() const
{
  return fNSect;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11UnitDisk::BlockSize() const
{
  return fBlksize;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline size_t Rw11UnitDisk::NBlock() const
{
  return fNBlock;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t Rw11UnitDisk::Chs2Lba(uint16_t cy, uint16_t hd, uint16_t se)
{
  return se + fNSect * (hd + fNHead*cy);
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitDisk::Lba2Chs(uint32_t lba, uint16_t& cy, uint16_t& hd, 
                                  uint16_t& se)
{
  se = lba % fNSect;
  hd = (lba/fNSect) % fNHead;
  cy = lba / (fNSect*fNHead);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline uint32_t Rw11UnitDisk::Nwrd2Nblk(uint32_t nwrd)
{
  return (2*nwrd+BlockSize()-1) / BlockSize();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline void Rw11UnitDisk::SetWProt(bool wprot)
{
  fWProt = wprot;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

inline bool Rw11UnitDisk::WProt() const
{
  return fWProt;
}


} // end namespace Retro
