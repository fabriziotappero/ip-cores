// $Id: RlogFile.hpp 631 2015-01-09 21:36:51Z mueller $
//
// Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-01-08   631   2.2    Open(): now with RerrMsg and cout/cerr support
// 2013-02-23   492   2.1    add Name(), keep log file name; add Dump()
// 2013-02-22   491   2.0    add Write(),IsNew(), RlogMsg iface; use lockable
// 2011-04-24   380   1.0.1  use boost::noncopyable (instead of private dcl's)
// 2011-01-30   357   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlogFile.hpp 631 2015-01-09 21:36:51Z mueller $
  \brief   Declaration of class RlogFile.
*/

#ifndef included_Retro_RlogFile
#define included_Retro_RlogFile 1

#include <string>
#include <ostream>
#include <fstream>

#include "boost/utility.hpp"
#include "boost/thread/mutex.hpp"

#include "RerrMsg.hpp"

namespace Retro {

  class RlogMsg;                            // forw decl to avoid circular incl

  class RlogFile : private boost::noncopyable {
    public:
                    RlogFile();
      explicit      RlogFile(std::ostream* os, const std::string& name = "");
                   ~RlogFile();

      bool          IsNew() const;
      bool          Open(std::string name, RerrMsg& emsg);
      void          Close();
      void          UseStream(std::ostream* os, const std::string& name = "");
      const std::string&  Name() const;

      void          Write(const std::string& str, char tag = 0);

      void          Dump(std::ostream& os, int ind=0, const char* text=0) const;

      // provide boost Lockable interface
      void          lock();
      void          unlock();

      RlogFile&     operator<<(const RlogMsg& lmsg);

    protected:
      std::ostream& Stream();
      void          ClearTime();
      std::string   BuildinStreamName(std::ostream* os, const std::string& str);

    protected:
      std::ostream* fpExtStream;            //!< pointer to external stream
      std::ofstream fIntStream;             //!< internal stream
      bool          fNew;                   //!< true if never opened or used
      std::string   fName;                  //!< log file name
      int           fTagYear;               //!< year of last time tag
      int           fTagMonth;              //!< month of last time tag
      int           fTagDay;                //!< day of last time tag
      boost::mutex  fMutex;                 //!< mutex to lock file
  };
  
} // end namespace Retro

#include "RlogFile.ipp"

#endif
