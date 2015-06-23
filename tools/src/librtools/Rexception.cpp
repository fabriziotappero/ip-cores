// $Id: Rexception.cpp 625 2014-12-30 16:17:45Z mueller $
//
// Copyright 2013-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2014-12-30   625   1.1    add ctor(meth,text,emsg)
// 2013-01-12   474   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rexception.cpp 625 2014-12-30 16:17:45Z mueller $
  \brief   Implemenation of Rexception.
*/

#include "Rexception.hpp"

using namespace std;

/*!
  \class Retro::Rexception
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Default constructor

Rexception::Rexception()
  : fErrmsg()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rexception::Rexception(const RerrMsg& errmsg)
  : fErrmsg(errmsg)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rexception::Rexception(const std::string& meth, const std::string& text)
  : fErrmsg(meth,text)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rexception::Rexception(const std::string& meth, const std::string& text, 
                       int errnum)
  : fErrmsg(meth,text,errnum)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

Rexception::Rexception(const std::string& meth, const std::string& text, 
                       const RerrMsg& errmsg)
  : fErrmsg(meth,text+errmsg.Message())
{}

//------------------------------------------+-----------------------------------
//! Destructor

Rexception::~Rexception() throw()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

const char* Rexception::what() const throw()
{
  return fErrmsg.Message().c_str();
}

} // end namespace Retro
