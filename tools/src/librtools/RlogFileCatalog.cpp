// $Id: RlogFileCatalog.cpp 631 2015-01-09 21:36:51Z mueller $
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
// 2013-02-22   491   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlogFileCatalog.cpp 631 2015-01-09 21:36:51Z mueller $
  \brief   Implemenation of RlogFileCatalog.
*/

#include <iostream> 

#include "RlogFileCatalog.hpp"

using namespace std;

/*!
  \class Retro::RlogFileCatalog
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlogFileCatalog& RlogFileCatalog::Obj()
{
  static RlogFileCatalog obj;               // lazy creation singleton
  return obj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const boost::shared_ptr<RlogFile>& 
  RlogFileCatalog::FindOrCreate(const std::string& name)
{
  map_cit_t it = fMap.find(name);
  if (it != fMap.end()) return it->second;

  boost::shared_ptr<RlogFile> sptr(new RlogFile());
  it = fMap.insert(fMap.begin(), map_val_t(name, sptr));

  return it->second;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlogFileCatalog::Delete(const std::string& name)
{
  fMap.erase(name);
  return;
}

//------------------------------------------+-----------------------------------
//! Default constructor

RlogFileCatalog::RlogFileCatalog()
{
  FindOrCreate("cout")->UseStream(&cout);
  FindOrCreate("cerr")->UseStream(&cerr);
}

//------------------------------------------+-----------------------------------
//! Destructor

RlogFileCatalog::~RlogFileCatalog()
{}

} // end namespace Retro
