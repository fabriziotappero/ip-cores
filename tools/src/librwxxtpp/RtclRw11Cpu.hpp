// $Id: RtclRw11Cpu.hpp 661 2015-04-03 18:28:41Z mueller $
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
// 2015-04-03   661   1.0.4  add ClistNonEmpty()
// 2015-03-21   659   1.0.3  rename M_amap->M_imap; add M_rmap; add GetRAddr()
// 2014-12-25   621   1.0.2  add M_amap
// 2013-04-26   511   1.0.1  add M_show
// 2013-04-02   502   1.0    Initial version
// 2013-02-02   480   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclRw11Cpu.hpp 661 2015-04-03 18:28:41Z mueller $
  \brief   Declaration of class RtclRw11Cpu.
*/

#ifndef included_Retro_RtclRw11Cpu
#define included_Retro_RtclRw11Cpu 1

#include <cstddef>
#include <string>

#include "librlink/RlinkConnect.hpp"

#include "librtcltools/RtclProxyBase.hpp"
#include "librtcltools/RtclGetList.hpp"
#include "librtcltools/RtclSetList.hpp"

#include "librw11/Rw11Cpu.hpp"

namespace Retro {

  class RtclRw11Cpu : public RtclProxyBase {
    public:

      explicit      RtclRw11Cpu(const std::string& type);
      virtual      ~RtclRw11Cpu();

      virtual Rw11Cpu&  Obj() = 0;

    protected:
      int           M_add(RtclArgs& args);
      int           M_imap(RtclArgs& args);
      int           M_rmap(RtclArgs& args);
      int           M_cp(RtclArgs& args);
      int           M_wtcpu(RtclArgs& args);
      int           M_deposit(RtclArgs& args);
      int           M_examine(RtclArgs& args);
      int           M_lsmem(RtclArgs& args);
      int           M_ldabs(RtclArgs& args);
      int           M_ldasm(RtclArgs& args);
      int           M_boot(RtclArgs& args);
      int           M_get(RtclArgs& args);
      int           M_set(RtclArgs& args);
      int           M_show(RtclArgs& args);
      int           M_stats(RtclArgs& args);
      int           M_dump(RtclArgs& args);
      int           M_default(RtclArgs& args);

      void          SetupGetSet();

      RlinkServer&  Server();
      RlinkConnect& Connect();

      bool          GetIAddr(RtclArgs& args, uint16_t& ibaddr);
      bool          GetRAddr(RtclArgs& args, uint16_t& rbaddr);
      bool          GetVarName(RtclArgs& args, const char* argname, 
                               size_t nind, std::vector<std::string>& varname);
      bool          ClistNonEmpty(RtclArgs& args, 
                                  const RlinkCommandList& clist);

    protected:
      RtclGetList   fGets;
      RtclSetList   fSets;
  };
  
} // end namespace Retro

#include "RtclRw11Cpu.ipp"

#endif
