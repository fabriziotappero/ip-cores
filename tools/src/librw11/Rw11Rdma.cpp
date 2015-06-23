// $Id: Rw11Rdma.cpp 648 2015-02-20 20:16:21Z mueller $
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
// 2015-02-17   647   1.1    PreExecCB with nwdone and nwnext
// 2015-01-04   627   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: Rw11Rdma.cpp 648 2015-02-20 20:16:21Z mueller $
  \brief   Implemenation of Rw11Rdma.
*/

#include <algorithm>

#include "boost/bind.hpp"

#include "librtools/Rexception.hpp"
#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"
#include "librtools/RosPrintBvi.hpp"

#include "Rw11Rdma.hpp"

using namespace std;

/*!
  \class Retro::Rw11Rdma
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
//! Constructor

Rw11Rdma::Rw11Rdma(Rw11Cntl* pcntl, const precb_t& precb, 
                   const postcb_t& postcb)
  : fpCntlBase(pcntl),
    fPreExecCB(precb),
    fPostExecCB(postcb),
    fChunksize(0),
    fStatus(kStatusDone),
    fIsWMem(false),
    fAddr(0),
    fMode(0),
    fNWordMax(0),
    fNWordRest(0),
    fNWordDone(0),
    fpBlock(nullptr),
    fStats()
{
  fStats.Define(kStatNQueRMem,     "NQueRMem"     , "RMem chains queued");
  fStats.Define(kStatNQueWMem,     "NQueWMem"     , "WMem chains queued");
  fStats.Define(kStatNRdmaRMem,    "NRdmaRMem"    , "RMem chunks done");
  fStats.Define(kStatNRdmaWMem,    "NRdmaWMem"    , "WMem chunks done");
  fStats.Define(kStatNExtClist,    "NExtClist"    , "clist extended");
  fStats.Define(kStatNFailRdma,    "NFailRdma"    , "Rdma failures");
}

//------------------------------------------+-----------------------------------
//! Destructor

Rw11Rdma::~Rw11Rdma()
{}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Rdma::SetChunkSize(size_t chunk)
{
  size_t cmax = CntlBase().IsStarted() ? Connect().BlockSizePrudent() : 0;
  if (chunk==0 || chunk>cmax) chunk = cmax;
  fChunksize = chunk;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Rdma::QueueRMem(uint32_t addr, uint16_t* block, size_t size,
                         uint16_t mode)
{
  fStats.Inc(kStatNQueRMem);
  SetupRdma(false, addr, block, size, mode);
  Server().QueueAction(boost::bind(&Rw11Rdma::RdmaHandler, this));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Rdma::QueueWMem(uint32_t addr, const uint16_t* block, size_t size,
                         uint16_t mode)
{
  fStats.Inc(kStatNQueWMem);
  SetupRdma(true, addr, const_cast<uint16_t*>(block), size, mode);
  Server().QueueAction(boost::bind(&Rw11Rdma::RdmaHandler, this));
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Rdma::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "Rw11Rdma @ " << this << endl;

  os << bl << "  fChunkSize:      " << RosPrintf(fChunksize,"d",4) << endl;
  os << bl << "  fStatus:         " << fStatus << endl;
  os << bl << "  fIsWMem:         " << fIsWMem << endl;
  os << bl << "  fAddr:           " << RosPrintBvi(fAddr,8,22) << endl;
  os << bl << "  fMode:           " << RosPrintBvi(fAddr,16,16) << endl;
  os << bl << "  fNWordMax:       " << RosPrintf(fNWordMax,"d",4) << endl;
  os << bl << "  fNWordRest:      " << RosPrintf(fNWordRest,"d",4) << endl;
  os << bl << "  fNWordDone:      " << RosPrintf(fNWordDone,"d",4) << endl;
  os << bl << "  fpBlock:         " << fpBlock << endl;
  fStats.Dump(os, ind+2, "fStats: ");
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Rdma::SetupRdma(bool iswmem, uint32_t addr, uint16_t* block, 
                         size_t size, uint16_t mode)
{
  if (IsActive())
    throw Rexception("Rw11Rdma::SetupRdma", "Bad state: Rdma already active");
  
  // if chunk size not yet defined use 'maximal prudent size from Connect
  // Note: can't be done in ctor because linkage to Connect is set much
  //       later in Cntl::Start
  if (fChunksize == 0) fChunksize = Connect().BlockSizePrudent();

  fStatus    = kStatusBusy;
  fIsWMem    = iswmem;
  fAddr      = addr;
  fMode      = mode;
  fNWordMax  = fChunksize;
  fNWordRest = size;
  fNWordDone = 0;  
  fpBlock    = block;
  return;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

int Rw11Rdma::RdmaHandler()
{
  RlinkCommandList clist;

  if (fNWordDone == 0) {                    // first chunk ?
    PreRdmaHook();
  }

  size_t nwnext = min(fNWordRest, fNWordMax);
  if (fIsWMem) {
    fStats.Inc(kStatNRdmaWMem);
    Cpu().AddWMem(clist, fAddr, fpBlock, nwnext, fMode, true);
  } else {
    fStats.Inc(kStatNRdmaRMem);
    Cpu().AddRMem(clist, fAddr, fpBlock, nwnext, fMode, true);
  }
  size_t ncmd = clist.Size();
  
  if (nwnext == fNWordRest) fStatus = kStatusBusyLast;
  
  fPreExecCB(fStatus, fNWordDone, nwnext, clist);
  if (clist.Size() != ncmd) fStats.Inc(kStatNExtClist);

  Server().Exec(clist);

  size_t nwdone = clist[ncmd-1].BlockDone();
  
  fAddr      += 2*nwdone;
  fNWordRest -= nwdone;
  fNWordDone += nwdone;
  fpBlock    += nwdone;

  bool islast = false;
  if (nwnext != nwdone) {
    fStats.Inc(kStatNFailRdma);
    fStatus = kStatusFailRdma;
    islast  = true;
  } else if (fNWordRest == 0) {
    fStatus = kStatusDone;
    islast  = true;
  }

  if (islast) {
    PostRdmaHook(fNWordDone);
  }

  fPostExecCB(fStatus, fNWordDone, clist, ncmd);

  if (fStatus == kStatusBusy) {
    return 1;
  }
  fStatus = kStatusDone;
  return 0;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Rdma::PreRdmaHook()
{
  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void Rw11Rdma::PostRdmaHook(size_t nwdone)
{
  return;
}
  

} // end namespace Retro
