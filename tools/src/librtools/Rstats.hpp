// $Id: Rstats.hpp 495 2013-03-06 17:13:48Z mueller $
//
// Copyright 2011- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2011-02-06   359   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rstats.hpp 495 2013-03-06 17:13:48Z mueller $
  \brief   Declaration of class Rstats .
*/

#ifndef included_Retro_Rstats
#define included_Retro_Rstats 1

#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>
#include <ostream>

namespace Retro {
  
  class Rstats {
    public: 
		    Rstats();
                    Rstats(const Rstats& rhs);
                    ~Rstats();

      void          Define(size_t ind, const std::string& name, 
                           const std::string& text);

      void          Set(size_t ind, double val);
      void          Inc(size_t ind, double val=1.);

      void          SetFormat(const char* format, int width=0, int prec=0);
    
      size_t        Size() const;
      double        Value(size_t ind) const;
      const std::string&  Name(size_t ind) const;
      const std::string&  Text(size_t ind) const;

      void          Print(std::ostream& os, const char* format=0, 
                          int width=0, int prec=0) const;
      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

      double        operator[](size_t ind) const;

      Rstats&       operator=(const Rstats& rhs);
      Rstats&       operator-(const Rstats& rhs);
      Rstats&       operator*(double rhs);

  private:
      std::vector<double> fValue;           //!< counter value
      std::vector<std::string> fName;       //!< counter name
      std::vector<std::string> fText;       //!< counter text
      std::uint32_t fHash;                  //!< hash value for name+text
      std::string   fFormat;                //!< default format for Print
      int           fWidth;                 //!< default width for Print
      int           fPrec;                  //!< default precision for Print
  };

  std::ostream&	    operator<<(std::ostream& os, const Rstats& obj);

} // end namespace Retro

#include "Rstats.ipp"

#endif
