// $Id: Rw11Unit.hpp 680 2015-05-14 13:29:46Z mueller $
//
// Copyright 2013-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-05-13   680   1.1.1  add Enabled()
// 2013-05-03   515   1.1    use AttachDone(),DetachCleanup(),DetachDone()
// 2013-05-01   513   1.0.1  add fAttachOpts, (Set)AttachOpts()
// 2013-03-06   495   1.0    Initial version
// 2013-02-13   488   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11Unit.hpp 680 2015-05-14 13:29:46Z mueller $
  \brief   Declaration of class Rw11Unit.
*/

#ifndef included_Retro_Rw11Unit
#define included_Retro_Rw11Unit 1

#include <string>

#include "boost/utility.hpp"

#include "librtools/Rstats.hpp"
#include "librtools/RerrMsg.hpp"
#include "librlink/RlinkServer.hpp"

#include "librtools/Rbits.hpp"
#include "Rw11Cntl.hpp"

namespace Retro {

  class Rw11Unit : public Rbits, private boost::noncopyable {
    public:

                    Rw11Unit(Rw11Cntl* pcntl, size_t index);
      virtual      ~Rw11Unit();

      size_t        Index() const;
      std::string   Name() const;

      void          SetAttachOpts(const std::string& opts);
      const std::string& AttachOpts() const;

      Rw11Cntl&     CntlBase() const;
      Rw11Cpu&      Cpu() const;
      Rw11&         W11() const;
      RlinkServer&  Server() const;
      RlinkConnect& Connect() const;
      RlogFile&     LogFile() const;

      virtual bool  Enabled() const;

      virtual bool  Attach(const std::string& url, RerrMsg& emsg);
      virtual void  Detach();

      const Rstats& Stats() const;
      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    // statistics counter indices
      enum stats {
        kDimStat = 0
      };    

    protected:
      virtual void  AttachDone();
      virtual void  DetachCleanup();
      virtual void  DetachDone();

    private:
                    Rw11Unit() {}           //!< default ctor blocker

    protected:
      Rw11Cntl*     fpCntlBase;             //!< plain Rw11Cntl ptr
      size_t        fIndex;                 //!< unit number
      std::string   fAttachOpts;            //!< unit context options for attach
      Rstats        fStats;                 //!< statistics
  };
  
} // end namespace Retro

#include "Rw11Unit.ipp"

#endif
