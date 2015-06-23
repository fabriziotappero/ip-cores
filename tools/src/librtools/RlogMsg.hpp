// $Id: RlogMsg.hpp 490 2013-02-22 18:43:26Z mueller $
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
  \version $Id: RlogMsg.hpp 490 2013-02-22 18:43:26Z mueller $
  \brief   Declaration of class RlogMsg.
*/

#ifndef included_Retro_RlogMsg
#define included_Retro_RlogMsg 1

#include <sstream>

#include "boost/utility.hpp"

namespace Retro {

  class RlogFile;                           // forw decl to avoid circular incl

  class RlogMsg : private boost::noncopyable {
    public:
      explicit      RlogMsg(char tag = 0);
                    RlogMsg(RlogFile& lfile, char tag = 0);
                   ~RlogMsg();

      void          SetTag(char tag);
      void          SetString(const std::string& str);

      char          Tag() const;
      std::string   String() const;

      std::ostream& operator()();

    protected:
      std::stringstream  fStream;                //!< string stream
      RlogFile*     fLfile;
      char          fTag;
  };

  template <class T>
  std::ostream&     operator<<(RlogMsg& lmsg, const T& val);
  
} // end namespace Retro

#include "RlogMsg.ipp"

#endif
