// $Id: RosFill.ipp 488 2013-02-16 18:49:47Z mueller $
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
// 2011-01-30   359   1.0    Adopted from CTBosFill
// 2000-02-06     -   -      Last change on CTBosFill
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RosFill.ipp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation (inline) of RosFill.
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor.
/*!
  The fill character is specified with \a fill, the repeat count is
  specified with \a count. Note, that RosFill does not have a default
  constructor and that this constructor is the only means to set this object up.
  Note also, that the \a fill argument can be omitted, the default fill
  character is a blank.
*/
inline RosFill::RosFill(int count, char fill)
  : fCount(count),
    fFill(fill)
{}

//------------------------------------------+-----------------------------------
//! Get repeat count.

inline int RosFill::Count() const
{
  return fCount;
}

//------------------------------------------+-----------------------------------
//! Get fill character.

inline char RosFill::Fill() const
{
  return fFill;
}

} // end namespace Retro
