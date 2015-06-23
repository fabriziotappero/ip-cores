// $Id: RtclRw11UnitStream.cpp 515 2013-05-04 17:28:59Z mueller $
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
// 2013-05-01   513   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitStream.cpp 515 2013-05-04 17:28:59Z mueller $
  \brief   Implemenation of RtclRw11UnitStream.
*/

using namespace std;

#include "RtclRw11UnitStream.hpp"

/*!
  \class Retro::RtclRw11UnitStream
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitStream::RtclRw11UnitStream(RtclRw11Unit* ptcl, Rw11UnitStream* pobj)
  : fpTcl(ptcl),
    fpObj(pobj)
{
  RtclGetList& gets = ptcl->GetList();
  RtclSetList& sets = ptcl->SetList();
  gets.Add<int>           ("pos",  
                            boost::bind(&Rw11UnitStream::Pos,  pobj));

  sets.Add<int>           ("pos",  
                            boost::bind(&Rw11UnitStream::SetPos,pobj, _1));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclRw11UnitStream::~RtclRw11UnitStream()
{}


} // end namespace Retro
