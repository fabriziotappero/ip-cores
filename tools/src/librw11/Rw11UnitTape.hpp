// $Id: Rw11UnitTape.hpp 686 2015-06-04 21:08:08Z mueller $
//
// Copyright 2015- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-06-04   686   1.0    Initial version
// 2015-05-17   683   0.1    First draft
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: Rw11UnitTape.hpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Declaration of class Rw11UnitTape.
*/

#ifndef included_Retro_Rw11UnitTape
#define included_Retro_Rw11UnitTape 1

#include "Rw11VirtTape.hpp"

#include "Rw11UnitVirt.hpp"

namespace Retro {

  class Rw11UnitTape : public Rw11UnitVirt<Rw11VirtTape> {
    public:
                    Rw11UnitTape(Rw11Cntl* pcntl, size_t index);
                   ~Rw11UnitTape();

      virtual void  SetType(const std::string& type);

      const std::string& Type() const;
      virtual bool  Enabled() const;

      void          SetWProt(bool wprot);
      void          SetCapacity(size_t nbyte);
      bool          WProt() const;
      size_t        Capacity() const;

      void          SetPosFile(int posfile);
      void          SetPosRecord(int posrec);

      bool          Bot() const;
      bool          Eot() const;
      bool          Eom() const;

      int           PosFile() const;
      int           PosRecord() const;

      bool          VirtReadRecord(size_t nbyte, uint8_t* data, size_t& ndone, 
                               int& opcode, RerrMsg& emsg);
      bool          VirtWriteRecord(size_t nbyte, const uint8_t* data, 
                                int& opcode, RerrMsg& emsg);
      bool          VirtWriteEof(RerrMsg& emsg);
      bool          VirtSpaceForw(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg);
      bool          VirtSpaceBack(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg);
      bool          VirtRewind(int& opcode, RerrMsg& emsg);

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

    protected:
      std::string   fType;                  //!< drive type
      bool          fEnabled;               //!< unit enabled
      bool          fWProt;                 //!< unit write protected
      size_t        fCapacity;              //<! capacity in byte (0=unlimited)
  };
  
} // end namespace Retro

#include "Rw11UnitTape.ipp"

#endif
