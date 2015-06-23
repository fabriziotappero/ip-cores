// $Id: Rw11RdmaDisk.cpp 648 2015-02-20 20:16:21Z mueller $
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
// 2015-01-04   628   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11RdmaDisk.cpp 648 2015-02-20 20:16:21Z mueller $
  \brief   Implemenation of Rw11RdmaDisk.
*/

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/Rexception.hpp"

#include "Rw11RdmaDisk.hpp"

using namespace std;

/*!
  \class Retro::Rw11RdmaDisk
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11RdmaDisk::Rw11RdmaDisk(Rw11Cntl* pcntl, const precb_t& precb, 
                           const postcb_t& postcb)
  : Rw11Rdma(pcntl, precb, postcb),
    fBuf(),
    fpUnit(nullptr),
    fNWord(0),
    fNBlock(0),
    fLba()
{
  fStats.Define(kStatNWritePadded, "NWritePadded" , "padded disk write");
  fStats.Define(kStatNWChkFail,    "NWChkFail"    , "write check failed");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11RdmaDisk::~Rw11RdmaDisk()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11RdmaDisk::QueueDiskRead(uint32_t addr, size_t size, uint16_t mode, 
                                 uint32_t lba, Rw11UnitDisk* punit)
{
  SetupDisk(size, lba, punit, kFuncRead);
  QueueWMem(addr, fBuf.data(), size, mode);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11RdmaDisk::QueueDiskWrite(uint32_t addr,size_t size, uint16_t mode,
                                  uint32_t lba, Rw11UnitDisk* punit)
{
  SetupDisk(size, lba, punit, kFuncWrite);
  QueueRMem(addr, fBuf.data(), size, mode);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11RdmaDisk::QueueDiskWriteCheck(uint32_t addr, size_t size, 
                                       uint16_t mode, uint32_t lba, 
                                       Rw11UnitDisk* punit)
{
  SetupDisk(size, lba, punit, kFuncWriteCheck);
  QueueRMem(addr, fBuf.data(), size, mode);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

size_t Rw11RdmaDisk::WriteCheck(size_t nwdone)
{
  if (nwdone == 0) return 0;

  size_t bszwrd = fpUnit->BlockSize()/2;    // block size in words
  size_t nblk   = (nwdone+bszwrd-1)/bszwrd;
  size_t dsize  = nblk*bszwrd;
  
  std::vector<uint16_t>  dbuf(dsize);
  RerrMsg emsg;
  bool rc = fpUnit->VirtRead(fLba, nblk,
                             reinterpret_cast<uint8_t*>(dbuf.data()), emsg);
  if (!rc) throw Rexception("Rw11RdmaDisk::WriteCheck()", 
                            "VirtRead() failed: ", emsg);
  
  uint16_t* pdsk = dbuf.data();
  uint16_t* pmem = fBuf.data();
  for (size_t i=0; i<nwdone; i++) {
    if (*pdsk++ != *pmem++) {
      fStats.Inc(kStatNWChkFail);
      return i;
    }
  }

  return nwdone;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11RdmaDisk::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11RdmaDisk @ " << this << endl;
  os << bl << "  fBuf.size()      " << RosPrintf(fBuf.size(),"d",5) << endl;
  os << bl << "  fpUnit:          " << fpUnit << endl;
  os << bl << "  fNWord:          " << RosPrintf(fNWord,"d",5) << endl;
  os << bl << "  fNBlock:         " << RosPrintf(fNBlock,"d",5) << endl;
  os << bl << "  fLba:            " << RosPrintf(fLba,"d",8) << endl;
  os << bl << "  fFunc:           " << fFunc << endl;

  Rw11Rdma::Dump(os, ind, " ^");
  return;
} 

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11RdmaDisk::SetupDisk(size_t size, uint32_t lba, Rw11UnitDisk* punit, 
                             Rw11RdmaDisk::func func)
{
  fpUnit = punit;
  size_t bszwrd = fpUnit->BlockSize()/2;    // block size in words

  fNWord  = size;
  fNBlock = (fNWord+bszwrd-1)/bszwrd;
  fLba    = lba;
  fFunc   = func;

  size_t tsize = fNBlock*bszwrd;
  if (fBuf.size() < tsize) fBuf.resize(tsize);

  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11RdmaDisk::PreRdmaHook()
{
  if (fFunc != kFuncRead) return;          // quit unless read request

  RerrMsg emsg;
  bool rc = fpUnit->VirtRead(fLba, fNBlock,
                             reinterpret_cast<uint8_t*>(fBuf.data()), emsg);
  if (!rc) throw Rexception("Rw11RdmaDisk::PreRdmaHook()", 
                            "VirtRead() failed: ", emsg);
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11RdmaDisk::PostRdmaHook(size_t nwdone)
{
  if (nwdone == 0) return;                  // quit if rdma failed early
  if (fFunc != kFuncWrite) return;          // quit unless write request

  size_t bszwrd = fpUnit->BlockSize()/2;    // block size in words
  size_t nblock = (nwdone+bszwrd-1)/bszwrd;
  size_t npad   = nblock*bszwrd - nwdone;

  // if an incomplete block was read, pad it with hex dead
  if (npad) {
    fStats.Inc(kStatNWritePadded);
    uint16_t* p = fBuf.data()+nwdone;
    for (size_t i=0; i<npad; i++) *p++ = 0xdead;
  }

  RerrMsg emsg;
  bool rc = fpUnit->VirtWrite(fLba, nblock, 
                              reinterpret_cast<uint8_t*>(fBuf.data()), emsg);
  if (!rc) throw Rexception("Rw11RdmaDisk::PostRdmaHook()", 
                            "VirtWrite() failed: ", emsg);
  return;
}


} // end namespace Retro
