// $Id: RosFill.cpp 488 2013-02-16 18:49:47Z mueller $
//
// Copyright 2000-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-02-25   364   1.1    Support << also to string
// 2011-01-30   357   1.0    Adopted from RosFill
// 2000-02-29     -   -      Last change on RosFill
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RosFill.cpp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation of RosFill .
*/

#include "RosFill.hpp"

using namespace std;

/*! 
  \class Retro::RosFill 
  \brief I/O appicator to generate fill characters.

  An \c RosFill object will add a given number of fill characters to an output
  stream each time the object is inserted into the stream. The fill character
  and the repeat count are specified when the object is constructed.

  A typical usage of \c RosFill is to implement indention, especially when the
  amount of indention is only known at runtime. The a Dump() function of a 
  class may use use \c RosFill following the pattern:
  \code
void xyz::Dump(ostream& os, int indent) const
{
  RosFill bl(indent);
  
  os << bl << "-- xyz " << " @ " << this << endl;
  os << bl << "  fMember1:    " << fMember1 << endl;
  os << bl << "  fMember2:    " << fMember2 << endl;
  fEmbeddedClass.Dump(os, indent+2);
  return;
}
  \endcode

  The indention is passed with \c indent. The object \c bl is setup to
  create \c indent blanks and thrown into the outstream \c os at the
  start of each output line. The \c Dump() function of member variables of
  class type is called with a increamented indention (here \c indent+2).
  This finally produces a nicely structured output.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
/*! 
  \relates RosFill
  \brief ostream insertion operator.
*/

std::ostream& operator<<(std::ostream& os, const RosFill& obj)
{
  for (int i=0; i<obj.Count(); i++) os.put(obj.Fill());
  return os;
}

//------------------------------------------+-----------------------------------
/*! 
  \relates RosFill
  \brief string insertion operator.
*/

std::string& operator<<(std::string& os, const RosFill& obj)
{
  for (int i=0; i<obj.Count(); i++) os.push_back(obj.Fill());
  return os;
}

} // end namespace Retro
