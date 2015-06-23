// $Id: RtclRw11UnitTape.cpp 686 2015-06-04 21:08:08Z mueller $
//
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11UnitTape.cpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Implemenation of RtclRw11UnitTape.
*/

using namespace std;

#include "RtclRw11UnitTape.hpp"

/*!
  \class Retro::RtclRw11UnitTape
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

RtclRw11UnitTape::RtclRw11UnitTape(RtclRw11Unit* ptcl, Rw11UnitTape* pobj)
  : fpTcl(ptcl),
    fpObj(pobj)
{
  RtclGetList& gets = ptcl->GetList();
  RtclSetList& sets = ptcl->SetList();
  gets.Add<const string&> ("type",  
                            boost::bind(&Rw11UnitTape::Type,  pobj));
  gets.Add<bool>          ("wprot",  
                            boost::bind(&Rw11UnitTape::WProt, pobj));
  gets.Add<size_t>        ("capacity",  
                            boost::bind(&Rw11UnitTape::Capacity, pobj));
  gets.Add<bool>          ("bot",  
                            boost::bind(&Rw11UnitTape::Bot, pobj));
  gets.Add<bool>          ("eot",  
                            boost::bind(&Rw11UnitTape::Eot, pobj));
  gets.Add<bool>          ("eom",  
                            boost::bind(&Rw11UnitTape::Eom, pobj));
  gets.Add<int>           ("posfile",  
                            boost::bind(&Rw11UnitTape::PosFile, pobj));
  gets.Add<int>           ("posrecord",  
                            boost::bind(&Rw11UnitTape::PosRecord, pobj));

  sets.Add<const string&> ("type",  
                            boost::bind(&Rw11UnitTape::SetType,pobj, _1));
  sets.Add<bool>          ("wprot",  
                            boost::bind(&Rw11UnitTape::SetWProt,pobj, _1));
  sets.Add<size_t>        ("capacity",  
                            boost::bind(&Rw11UnitTape::SetCapacity,pobj, _1));
  sets.Add<int>           ("posfile",  
                            boost::bind(&Rw11UnitTape::SetPosFile,pobj, _1));
  sets.Add<int>           ("posrecord",  
                            boost::bind(&Rw11UnitTape::SetPosRecord,pobj, _1));
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RtclRw11UnitTape::~RtclRw11UnitTape()
{}


} // end namespace Retro
