// $Id: RtclSet.ipp 488 2013-02-16 18:49:47Z mueller $
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
// 2013-02-12   487   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RtclSet.ipp 488 2013-02-16 18:49:47Z mueller $
  \brief   Implemenation (inline) of class RtclSet.
*/

/*!
  \class Retro::RtclSet
  \brief FIXME_docs
*/

#include <climits>
#include <cfloat>

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline RtclSet<TP>::RtclSet(const boost::function<void(TP)>& set)
  : fSet(set)
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <class TP>
inline RtclSet<TP>::~RtclSet()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<bool>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetBooleanFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet((bool)val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<char>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if (val < CHAR_MIN || val > CHAR_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'char'");

  fSet((char)val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<signed char>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if (val < SCHAR_MIN || val > SCHAR_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'signed char'");

  fSet((signed char)val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<unsigned char>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if ((unsigned int)val > UCHAR_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'unsigned char'");

  fSet((unsigned char)val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<short>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if (val < SHRT_MIN || val > SHRT_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'short'");

  fSet((short)val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<unsigned short>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if ((unsigned int)val > USHRT_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'unsigned short'");

  fSet((unsigned short)val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<int>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet(val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<unsigned int>::operator()(RtclArgs& args) const 
{
  int val;
  if(Tcl_GetIntFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet((unsigned int) val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<long>::operator()(RtclArgs& args) const 
{
  long val;
  if(Tcl_GetLongFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet(val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<unsigned long>::operator()(RtclArgs& args) const 
{
  long val;
  if(Tcl_GetLongFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet((unsigned long) val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<float>::operator()(RtclArgs& args) const 
{
  double val;
  if(Tcl_GetDoubleFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");
  if (val < -FLT_MAX || val > FLT_MAX)
    throw Rexception("RtclSet<>::oper()", 
                     "out of range for type 'float'");

  fSet((float)val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<double>::operator()(RtclArgs& args) const 
{
  double val;
  if(Tcl_GetDoubleFromObj(args.Interp(), args.CurrentArg(), &val) != TCL_OK)
    throw Rexception("RtclSet<>::oper()", "conversion error");

  fSet(val);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

template <>
inline void RtclSet<const std::string&>::operator()(RtclArgs& args) const 
{
  char* val = Tcl_GetString(args.CurrentArg());
  fSet(std::string(val));
  return;
}


} // end namespace Retro

