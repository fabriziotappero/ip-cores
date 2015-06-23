// $Id: RtclRw11UnitBase.ipp 680 2015-05-14 13:29:46Z mueller $
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
// 2015-05-14   680   1.1    fGets: add enabled (moved from RtclRw11UnitDisk)
// 2013-03-06   495   1.0    Initial version
// 2013-02-16   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitBase.ipp 680 2015-05-14 13:29:46Z mueller $
  \brief   Implemenation (all inline) of RtclRw11UnitBase.
*/

#include "librtcltools/RtclStats.hpp"

/*!
  \class Retro::RtclRw11UnitBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TO>
inline RtclRw11UnitBase<TO>::RtclRw11UnitBase(const std::string& type,
                                     const boost::shared_ptr<TO>& spunit)
  : RtclRw11Unit(type, &(spunit->Cntl().Cpu())),
    fspObj(spunit)
{
  AddMeth("stats",    boost::bind(&RtclRw11UnitBase<TO>::M_stats,   this, _1));
  TO* pobj = fspObj.get();
  fGets.Add<size_t>            ("index",  boost::bind(&TO::Index, pobj));
  fGets.Add<std::string>       ("name",   boost::bind(&TO::Name,  pobj));
  fGets.Add<bool>              ("enabled", boost::bind(&TO::Enabled, pobj));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclRw11UnitBase<TO>::~RtclRw11UnitBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline TO& RtclRw11UnitBase<TO>::Obj()
{
  return *fspObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline const boost::shared_ptr<TO>& RtclRw11UnitBase<TO>::ObjSPtr()
{
  return fspObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
int RtclRw11UnitBase<TO>::M_stats(RtclArgs& args)
{
  RtclStats::Context cntx;
  if (!RtclStats::GetArgs(args, cntx)) return kERR;
  if (!RtclStats::Collect(args, cntx, Obj().Stats())) return kERR;
  if (Obj().Virt()) {
    if (!RtclStats::Collect(args, cntx, Obj().Virt()->Stats())) return kERR;
  }
  return kOK;
}

} // end namespace Retro
