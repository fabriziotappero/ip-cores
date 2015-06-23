// $Id: RlogMsg.cpp 490 2013-02-22 18:43:26Z mueller $
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
// 2013-02-22   490   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlogMsg.cpp 490 2013-02-22 18:43:26Z mueller $
  \brief   Implemenation of RlogMsg.
*/

#include "boost/thread/locks.hpp"

#include "RlogFile.hpp"

#include "RlogMsg.hpp"

using namespace std;

/*!
  \class Retro::RlogMsg
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

RlogMsg::RlogMsg(char tag)
  : fStream(),
    fLfile(0),
    fTag(tag)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlogMsg::RlogMsg(RlogFile& lfile, char tag)
  : fStream(),
    fLfile(&lfile),
    fTag(tag)
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlogMsg::~RlogMsg()
{
  if (fLfile) *fLfile << *this;
}

} // end namespace Retro
