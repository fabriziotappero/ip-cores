// $Id: RosPrintfBase.hpp 486 2013-02-10 22:34:43Z mueller $
//
// Copyright 2006-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-01-30   357   1.0    Adopted from CTBprintfBase
// 2006-04-16     -   -      Last change on CTBprintfBase
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RosPrintfBase.hpp 486 2013-02-10 22:34:43Z mueller $
  \brief   Declaration of RosPrintfBase class .
*/

#ifndef included_Retro_RosPrintfBase
#define included_Retro_RosPrintfBase 1

#include <ostream>
#include <string>

namespace Retro {

  class RosPrintfBase {
    public:
                    RosPrintfBase(const char* form, int width, int prec);
      virtual       ~RosPrintfBase();

      virtual void  ToStream(std::ostream& os) const = 0;

    protected:
      const char*   fForm;		    //!< format string
      int	    fWidth;		    //!< field width
      int	    fPrec;                  //!< field precision
  };

  std::ostream& operator<<(std::ostream& os, const RosPrintfBase& obj);
  std::string&  operator<<(std::string& os,  const RosPrintfBase& obj);

} // end namespace Retro

#include "RosPrintfBase.ipp"

#endif
