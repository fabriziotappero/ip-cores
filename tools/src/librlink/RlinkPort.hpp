// $Id: RlinkPort.hpp 666 2015-04-12 21:17:54Z mueller $
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
// 2015-04-11   666   1.3    add fXon, XonEnable()
// 2014-12-10   611   1.2.2  add time stamps for Read/Write for logs
// 2013-05-01   513   1.2.1  fTraceLevel now uint32_t
// 2013-02-23   492   1.2    use RparseUrl
// 2013-02-22   491   1.1    use new RlogFile/RlogMsg interfaces
// 2013-01-27   477   1.0.3  add RawRead(),RawWrite() methods
// 2012-12-26   465   1.0.2  add CloseFd() method
// 2011-04-24   380   1.0.1  use boost::noncopyable (instead of private dcl's)
// 2011-03-27   375   1.0    Initial version
// 2011-01-15   356   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkPort.hpp 666 2015-04-12 21:17:54Z mueller $
  \brief   Declaration of class RlinkPort.
*/

#ifndef included_Retro_RlinkPort
#define included_Retro_RlinkPort 1

#include <string>
#include <map>

#include "boost/utility.hpp"

#include "librtools/RerrMsg.hpp"
#include "librtools/RlogFile.hpp"
#include "librtools/Rstats.hpp"
#include "librtools/RparseUrl.hpp"

namespace Retro {

  class RlinkPort : private boost::noncopyable {
    public:
                    RlinkPort();
      virtual      ~RlinkPort();

      virtual bool  Open(const std::string& url, RerrMsg& emsg) = 0;
      virtual void  Close();

      virtual int   Read(uint8_t* buf, size_t size, double timeout, 
                         RerrMsg& emsg);
      virtual int   Write(const uint8_t* buf, size_t size, RerrMsg& emsg);
      virtual bool  PollRead(double timeout);

      int           RawRead(uint8_t* buf, size_t size, bool exactsize,
                            double timeout, double& tused, RerrMsg& emsg);
      int           RawWrite(const uint8_t* buf, size_t size, RerrMsg& emsg);

      bool          IsOpen() const;

      const RparseUrl&  Url() const;
      bool          XonEnable() const;

      int           FdRead() const;
      int           FdWrite() const;

      void          SetLogFile(const boost::shared_ptr<RlogFile>& splog);
      void          SetTraceLevel(uint32_t level);

      uint32_t      TraceLevel() const;

      const Rstats& Stats() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // some constants (also defined in cpp)
      static const int  kEof  =  0;         //<! return code: end-of-file 
      static const int  kTout = -1;         //<! return code: time out
      static const int  kErr  = -2;         //<! return code: IO error

    // statistics counter indices
      enum stats {
        kStatNPortWrite = 0,
        kStatNPortRead,
        kStatNPortTxByt,
        kStatNPortRxByt,
        kStatNPortRawWrite,
        kStatNPortRawRead,
        kDimStat
      };    

    protected:
      void          CloseFd(int& fd);

    protected:
      bool          fIsOpen;                //!< is open flag
      RparseUrl     fUrl;                   //!< parsed url
      bool          fXon;                   //!< xon attribute set 
      int           fFdRead;                //!< fd for read
      int           fFdWrite;               //!< fd for write
      boost::shared_ptr<RlogFile>  fspLog;  //!< log file ptr
      uint32_t      fTraceLevel;            //!< trace level
      double        fTsLastRead;            //!< time stamp last write
      double        fTsLastWrite;           //!< time stamp last write
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "RlinkPort.ipp"

#endif
