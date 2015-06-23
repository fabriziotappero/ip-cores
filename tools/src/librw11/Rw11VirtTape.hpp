// $Id: Rw11VirtTape.hpp 686 2015-06-04 21:08:08Z mueller $
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
  \version $Id: Rw11VirtTape.hpp 686 2015-06-04 21:08:08Z mueller $
  \brief   Declaration of class Rw11VirtTape.
*/

#ifndef included_Retro_Rw11VirtTape
#define included_Retro_Rw11VirtTape 1

#include "Rw11Virt.hpp"

namespace Retro {

  class Rw11VirtTape : public Rw11Virt {
    public:
      explicit      Rw11VirtTape(Rw11Unit* punit);
                   ~Rw11VirtTape();

      void          SetWProt(bool wprot);
      void          SetCapacity(size_t nbyte);
      bool          WProt() const;
      size_t        Capacity() const;

      virtual bool  ReadRecord(size_t nbyte, uint8_t* data, size_t& ndone, 
                               int& opcode, RerrMsg& emsg) = 0;
      virtual bool  WriteRecord(size_t nbyte, const uint8_t* data, 
                                int& opcode, RerrMsg& emsg) = 0;
      virtual bool  WriteEof(RerrMsg& emsg) = 0;
      virtual bool  SpaceForw(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg) = 0;
      virtual bool  SpaceBack(size_t nrec, size_t& ndone, 
                              int& opcode, RerrMsg& emsg) = 0;
      virtual bool  Rewind(int& opcode, RerrMsg& emsg) = 0;

      void          SetPosFile(int posfile);
      void          SetPosRecord(int posrec);

      bool          Bot() const;
      bool          Eot() const;
      bool          Eom() const;

      int           PosFile() const;
      int           PosRecord() const;

      virtual void  Dump(std::ostream& os, int ind=0, const char* text=0) const;

      static Rw11VirtTape* New(const std::string& url, Rw11Unit* punit,
                               RerrMsg& emsg);

    // statistics counter indices
      enum stats {
        kStatNVTReadRec = Rw11Virt::kDimStat,
        kStatNVTReadByt,
        kStatNVTReadEof,
        kStatNVTReadEom,
        kStatNVTReadPErr,
        kStatNVTReadLErr,
        kStatNVTWriteRec,
        kStatNVTWriteByt,
        kStatNVTWriteEof,
        kStatNVTSpaForw,
        kStatNVTSpaBack,
        kStatNVTRewind,
        kDimStat
      };    

    // operation code
      enum OpCode {
        kOpCodeOK = 0,                      //<! operation OK
        kOpCodeBot,                         //<! ended at BOT
        kOpCodeEof,                         //<! ended at EOF
        kOpCodeEom,                         //<! ended at EOM
        kOpCodeRecLenErr,                   //<! record length error
        kOpCodeBadParity,                   //<! record with parity error
        kOpCodeBadFormat                    //<! file format error
      };

    protected:
      bool          fWProt;                 //<! write protected
      size_t        fCapacity;              //<! capacity in byte (0=unlimited)
      bool          fBot;                   //<! tape at bot
      bool          fEot;                   //<! tape beyond eot
      bool          fEom;                   //<! tape beyond medium
      int           fPosFile;               //<! tape pos: #files  (-1=unknown)
      int           fPosRecord;             //<! tape pos: #record (-1=unknown)
  };
  
} // end namespace Retro

#include "Rw11VirtTape.ipp"

#endif
