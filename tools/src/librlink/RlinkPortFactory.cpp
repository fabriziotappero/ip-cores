// $Id: RlinkPortFactory.cpp 632 2015-01-11 12:30:03Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-02-23   492   1.2    use RparseUrl
// 2012-12-26   465   1.1    add cuff: support
// 2011-03-27   374   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPortFactory.cpp 632 2015-01-11 12:30:03Z mueller $
  \brief   Implemenation of RlinkPortFactory.
*/

#include "librtools/RparseUrl.hpp"

#include "RlinkPortFifo.hpp"
#include "RlinkPortTerm.hpp"
#include "RlinkPortCuff.hpp"

#include "RlinkPortFactory.hpp"

using namespace std;

/*!
  \class Retro::RlinkPortFactory
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkPort* Retro::RlinkPortFactory::New(const std::string& url, RerrMsg& emsg)
{
  string scheme = RparseUrl::FindScheme(url);
  
  if (scheme.length() == 0) { 
    emsg.Init("RlinkPortFactory::New()", 
              string("no scheme specified in url '" + url + "'"));
    return 0;
  }

  if        (scheme == "fifo") {
    return new RlinkPortFifo();
  } else if (scheme == "term") {
    return new RlinkPortTerm();
  } else if (scheme == "cuff") {
    return new RlinkPortCuff();
  }
  
  emsg.Init("RlinkPortFactory::New()", string("unknown scheme: ") + scheme);
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

RlinkPort* RlinkPortFactory::Open(const std::string& url, RerrMsg& emsg)
{
  RlinkPort* pport = New(url, emsg);
  if (pport == nullptr) return 0;

  if (pport->Open(url, emsg)) return pport;
  delete pport;
  return 0;
}

} // end namespace Retro
