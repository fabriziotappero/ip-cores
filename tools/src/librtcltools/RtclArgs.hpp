// $Id: RtclArgs.hpp 521 2013-05-20 22:16:45Z mueller $
//
// Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-05-19   521   1.0.9  add NextSubOpt() method, pass optset's as const
// 2013-03-05   495   1.0.8  add SetResult(bool)
// 2013-03-02   494   1.0.7  add Quit() method
// 2013-02-12   487   1.0.6  add CurrentArg() method
// 2013-02-01   479   1.0.5  add Objv() method
// 2011-03-26   373   1.0.4  add GetArg(flt/dbl), SetResult(str,sos,int,dbl)
// 2011-03-13   369   1.0.3  add GetArg(vector<unit8_t>)
// 2011-03-06   367   1.0.2  add min to GetArg(unsigned); add Config() methods;
// 2011-03-05   366   1.0.1  fObjc,fNDone now size_t; add NDone(), NOptMiss();
//                           add SetResult(), GetArg(Tcl_Obj), PeekArgString();
// 2011-02-26   364   1.0    Initial version
// 2011-02-06   359   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RtclArgs.hpp 521 2013-05-20 22:16:45Z mueller $
  \brief   Declaration of class RtclArgs.
*/

#ifndef included_Retro_RtclArgs
#define included_Retro_RtclArgs 1

#include "tcl.h"

#include <cstddef>
#include <vector>
#include <limits>
#include <sstream>

#include "RtclNameSet.hpp"

namespace Retro {

  class RtclArgs {
    public:

    const static int8_t   int8_min   = 0xff;
    const static int8_t   int8_max   = 0x7f;
    const static uint8_t  uint8_max  = 0xff;
    const static int16_t  int16_min  = 0xffff;
    const static int16_t  int16_max  = 0x7fff;
    const static uint16_t uint16_max = 0xffff;
    const static int32_t  int32_min  = 0xffffffff;
    const static int32_t  int32_max  = 0x7fffffff;
    const static uint32_t uint32_max = 0xffffffff;

                        RtclArgs();
                        RtclArgs(Tcl_Interp* interp, int objc, 
                                 Tcl_Obj* const objv[], size_t nskip=1);
                        RtclArgs(const RtclArgs& rhs);
                        ~RtclArgs();

      Tcl_Interp*       Interp() const;
      int               Objc() const;
      Tcl_Obj* const *  Objv() const;
      Tcl_Obj*          Objv(size_t ind) const;

      bool              GetArg(const char* name, Tcl_Obj*& pval);

      bool              GetArg(const char* name, const char*& val);
      bool              GetArg(const char* name, std::string& val);

      bool              GetArg(const char* name, int8_t& val,
                               int8_t min=int8_min, int8_t max=int8_max);
      bool              GetArg(const char* name, uint8_t& val,
                               uint8_t max=uint8_max, uint8_t min=0);
      bool              GetArg(const char* name, int16_t& val,
                               int16_t min=int16_min, int16_t max=int16_max);
      bool              GetArg(const char* name, uint16_t& val,
                               uint16_t max=uint16_max, uint16_t min=0);
      bool              GetArg(const char* name, int32_t& val,
                               int32_t min=int32_min, int32_t max=int32_max);
      bool              GetArg(const char* name, uint32_t& val,
                               uint32_t max=uint32_max, uint32_t min=0);

      bool              GetArg(const char* name, float& val,
                               float min=-1.e30, float max=+1.e30);
      bool              GetArg(const char* name, double& val,
                               double min=-1.e30, double max=+1.e30);

      bool              GetArg(const char* name, std::vector<uint8_t>& val,
                               size_t lmin=0, size_t lmax=uint32_max);
      bool              GetArg(const char* name, std::vector<uint16_t>& val,
                               size_t lmin=0, size_t lmax=uint32_max);

      bool              Config(const char* name, std::string& val);
      bool              Config(const char* name, uint32_t& val,
                               uint32_t max=uint32_max, uint32_t min=0);
    
      bool              NextOpt(std::string& val);
      bool              NextOpt(std::string& val, const RtclNameSet& optset);
      int               NextSubOpt(std::string& val, const RtclNameSet& optset);
      bool              OptValid() const;

      Tcl_Obj*          CurrentArg() const;

      bool              AllDone();
      size_t            NDone() const;
      size_t            NOptMiss() const;

      const char*       PeekArgString(int rind) const;

      void              SetResult(const std::string& str);
      void              SetResult(std::ostringstream& sos);
      void              SetResult(bool val);
      void              SetResult(int val);
      void              SetResult(double val);
      void              SetResult(Tcl_Obj* pobj);

      void              AppendResult(const char* str, ...);
      void              AppendResult(const std::string& str);
      void              AppendResult(std::ostringstream& sos);
      void              AppendResultLines(const std::string& str);
      void              AppendResultLines(std::ostringstream& sos);

      int               Quit(const std::string& str);

      Tcl_Obj*          operator[](size_t ind) const;

    protected:
      bool              NextArg(const char* name, Tcl_Obj*& pobj);
      bool              NextArgList(const char* name, int& objc, 
                                    Tcl_Obj**& objv, size_t lmin=0, 
                                    size_t lmax=uint32_max);
      void              ConfigNameCheck(const char* name);
      bool              ConfigReadCheck();

    protected:
      Tcl_Interp*       fpInterp;           //!< pointer to tcl interpreter
      size_t            fObjc;              //!< original args count
      Tcl_Obj* const *  fObjv;              //!< original args vector
      size_t            fNDone;             //!< number of processed args
      size_t            fNOptMiss;          //!< number of missed optional args
      size_t            fNConfigRead;       //!< number of read mode config's
      bool              fOptErr;            //!< option processing error flag
      bool              fArgErr;            //!< argument processing error flag
    
  };

} // end namespace Retro

#include "RtclArgs.ipp"

#endif
