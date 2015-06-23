// $Id: Rw11CntlBase.ipp 495 2013-03-06 17:13:48Z mueller $
//
// Copyright 2013- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-03-06   495   1.0    Initial version
// 2013-02-14   488   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11CntlBase.ipp 495 2013-03-06 17:13:48Z mueller $
  \brief   Implemenation (inline) of Rw11CntlBase.
*/

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"

#include "Rw11CntlBase.hpp"

/*!
  \class Retro::Rw11CntlBase
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TU, size_t NU>
inline Rw11CntlBase<TU,NU>::Rw11CntlBase(const std::string& type)
  : Rw11Cntl(type)
{}

//------------------------------------------+-----------------------------------
//! Destructor

template <class TU, size_t NU>
inline Rw11CntlBase<TU,NU>::~Rw11CntlBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TU, size_t NU>
inline size_t Rw11CntlBase<TU,NU>::NUnit() const
{
  return NU;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TU, size_t NU>
inline TU& Rw11CntlBase<TU,NU>::Unit(size_t index) const
{
  return *fspUnit[index];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TU, size_t NU>
inline const boost::shared_ptr<TU>& 
  Rw11CntlBase<TU,NU>::UnitSPtr(size_t index) const
{
  return fspUnit[index];
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TU, size_t NU>
void Rw11CntlBase<TU,NU>::Dump(std::ostream& os, int ind, 
                               const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11CntlBase @ " << this << std::endl;
  os << bl << "  fspUnit:         " << std::endl;
  for (size_t i=0; i<NU; i++) {
    os << bl << "    " << RosPrintf(i,"d",2) << "       : " 
       << fspUnit[i].get() << std::endl;
  }
  Rw11Cntl::Dump(os, ind, " ^");
  return;
}
  
} // end namespace Retro
