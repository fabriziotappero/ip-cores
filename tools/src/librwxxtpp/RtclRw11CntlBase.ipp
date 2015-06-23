// $Id: RtclRw11CntlBase.ipp 521 2013-05-20 22:16:45Z mueller $
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
// 2013-03-06   495   1.0    Initial version
// 2013-02-08   484   0.1    First draft
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclRw11CntlBase.ipp 521 2013-05-20 22:16:45Z mueller $
  \brief   Implemenation (all inline) of RtclRw11CntlBase.
*/

/*!
  \class Retro::RtclRw11CntlBase
  \brief FIXME_docs
*/

#include "librtcltools/Rtcl.hpp"
#include "librtcltools/RtclOPtr.hpp"

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

template <class TO>
inline RtclRw11CntlBase<TO>::RtclRw11CntlBase(const std::string& type)
  : RtclRw11Cntl(type),
    fspObj(new TO())
{
  AddMeth("bootcode", boost::bind(&RtclRw11CntlBase<TO>::M_bootcode,this, _1));

  TO* pobj = fspObj.get();
  fGets.Add<const std::string&>("type",  boost::bind(&TO::Type, pobj));
  fGets.Add<const std::string&>("name",  boost::bind(&TO::Name, pobj));
  fGets.Add<uint16_t>          ("base",  boost::bind(&TO::Base, pobj));
  fGets.Add<int>               ("lam",   boost::bind(&TO::Lam,  pobj));  
  fGets.Add<bool>              ("enable",boost::bind(&TO::Enable, pobj));  
  fGets.Add<bool>              ("started",boost::bind(&TO::IsStarted, pobj));  
  fGets.Add<uint32_t>    ("trace", boost::bind(&TO::TraceLevel,pobj));  

  fSets.Add<bool>        ("enable", boost::bind(&TO::SetEnable,pobj,_1));  
  fSets.Add<uint32_t>    ("trace", boost::bind(&TO::SetTraceLevel,pobj,_1));  
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline RtclRw11CntlBase<TO>::~RtclRw11CntlBase()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline TO& RtclRw11CntlBase<TO>::Obj()
{
  return *fspObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
inline const boost::shared_ptr<TO>& RtclRw11CntlBase<TO>::ObjSPtr()
{
  return fspObj;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TO>
int RtclRw11CntlBase<TO>::M_bootcode(RtclArgs& args)
{
  int unit = 0;
  if (!args.GetArg("?unit", unit, 0, Obj().NUnit()-1)) return kERR;
  if (!args.AllDone()) return kERR;

  std::vector<uint16_t> code;
  uint16_t aload;
  uint16_t astart;
  if (Obj().BootCode(unit, code, aload, astart)) {
    RtclOPtr pres(Tcl_NewListObj(0, NULL));
    Tcl_ListObjAppendElement(NULL, pres, Tcl_NewIntObj((int)aload));
    Tcl_ListObjAppendElement(NULL, pres, Tcl_NewIntObj((int)astart));
    Tcl_ListObjAppendElement(NULL, pres, Rtcl::NewListIntObj(code));
    args.SetResult(pres);
  }

  return kOK;
}  

} // end namespace Retro
