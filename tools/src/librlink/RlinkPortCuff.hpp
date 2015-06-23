// $Id: RlinkPortCuff.hpp 502 2013-04-02 19:29:30Z mueller $
//
// Copyright 2012-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2013-01-02   467   1.0.1  get cleanup code right; add USBErrorName()
// 2012-12-26   465   1.0    Initial version
// ---------------------------------------------------------------------------


/*!
  \file
  \version $Id: RlinkPortCuff.hpp 502 2013-04-02 19:29:30Z mueller $
  \brief   Declaration of class RlinkPortCuff.
*/

#ifndef included_Retro_RlinkPortCuff
#define included_Retro_RlinkPortCuff 1

#include "RlinkPort.hpp"

#include <poll.h>
#include <libusb-1.0/libusb.h>

#include <vector>
#include <deque>

#include "boost/thread/thread.hpp"

namespace Retro {

  class RlinkPortCuff : public RlinkPort {
    public:

                    RlinkPortCuff();
      virtual       ~RlinkPortCuff();

      virtual bool  Open(const std::string& url, RerrMsg& emsg);
      virtual void  Close();

    // some constants (also defined in cpp)
      static const size_t kUSBBufferSize  = 4096;  //!< USB buffer size
      static const int    kUSBWriteEP     = 4   ;  //!< USB write endpoint
      static const int    kUSBReadEP      = 6   ;  //!< USB read endpoint
      static const size_t kUSBReadQueue   = 2   ;  //!< USB read queue length

    // statistics counter indices
      enum stats {
        kStatNPollAddCB = RlinkPort::kDimStat,
        kStatNPollRemoveCB,
        kStatNUSBWrite,
        kStatNUSBRead,
        kDimStat
      };

    // event loop states
      enum loopState {
        kLoopStateStopped,
        kLoopStateRunning,
        kLoopStateStopping
      };

    protected:
      int           fFdReadDriver;          //!< fd for read (driver end)
      int           fFdWriteDriver;         //!< fd for write (driver end)
      boost::thread fDriverThread;          //!< driver thread
      libusb_context*  fpUsbContext;
      libusb_device**  fpUsbDevList;
      ssize_t          fUsbDevCount;
      libusb_device_handle* fpUsbDevHdl;
      loopState        fLoopState;
      std::vector<pollfd>   fPollFds;
      std::deque<libusb_transfer*>  fWriteQueueFree;
      std::deque<libusb_transfer*>  fWriteQueuePending;
      std::deque<libusb_transfer*>  fReadQueuePending;

    private:
      void          Cleanup();
      bool          OpenPipe(int& fdread, int& fdwrite, RerrMsg& emsg);
      void          Driver();
      void          DriverEventWritePipe();
      void          DriverEventUSB();
      libusb_transfer* NewWriteTransfer();
      bool          TraceOn();
      void          BadSysCall(const char* meth, const char* text, int rc);
      void          BadUSBCall(const char* meth, const char* text, int rc);
      void          CheckUSBTransfer(const char* meth, libusb_transfer *t);
      const char*   USBErrorName(int rc);

      void          PollfdAdd(int fd, short events);
      void          PollfdRemove(int fd);
      void          USBWriteDone(libusb_transfer* t);
      void          USBReadDone(libusb_transfer* t);

      static void   ThunkPollfdAdd(int fd, short events, void* udata);
      static void   ThunkPollfdRemove(int fd, void* udata);
      static void   ThunkUSBWriteDone(libusb_transfer* t);
      static void   ThunkUSBReadDone(libusb_transfer* t);

  };
  
} // end namespace Retro

//#include "RlinkPortCuff.ipp"

#endif
