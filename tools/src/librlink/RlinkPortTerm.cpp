// $Id: RlinkPortTerm.cpp 666 2015-04-12 21:17:54Z mueller $
//
// Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
// 2015-04-12   666   1.3    drop xon/xoff excaping; add noinit attribute
// 2015-02-01   641   1.2    support custom baud rates (5M,6M,10M,12M)
// 2013-02-23   492   1.1    use RparseUrl
// 2011-12-18   440   1.0.4  add kStatNPort stats; Open(): autoadd /dev/tty,
//                           BUGFIX: Open(): set VSTART, VSTOP
// 2011-12-11   438   1.0.3  Read(),Write(): added for xon handling, tcdrain();
//                           Open(): add more baud rates, support xon attribute
// 2011-12-04   435   1.0.2  Open(): add cts attr, hw flow control now optional
// 2011-07-04   388   1.0.1  add termios readback and verification
// 2011-03-27   374   1.0    Initial version
// ---------------------------------------------------------------------------

/*!
  \file
  \version $Id: RlinkPortTerm.cpp 666 2015-04-12 21:17:54Z mueller $
  \brief   Implemenation of RlinkPortTerm.
*/

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <termios.h>
#include <sys/ioctl.h>
#include <linux/serial.h>

#include "RlinkPortTerm.hpp"

#include "librtools/RosFill.hpp"
#include "librtools/RosPrintf.hpp"

using namespace std;

/*!
  \class Retro::RlinkPortTerm
  \brief FIXME_docs
*/

// all method definitions in namespace Retro
namespace Retro {

//------------------------------------------+-----------------------------------
// constants definitions
const uint8_t RlinkPortTerm::kc_xon;
const uint8_t RlinkPortTerm::kc_xoff;

//------------------------------------------+-----------------------------------
//! Default constructor

RlinkPortTerm::RlinkPortTerm()
  : RlinkPort()
{}

//------------------------------------------+-----------------------------------
//! Destructor

RlinkPortTerm::~RlinkPortTerm()
{
  RlinkPortTerm::Close();
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

bool RlinkPortTerm::Open(const std::string& url, RerrMsg& emsg)
{
  Close();

  if (!fUrl.Set(url, "|baud=|break|cts|xon|noinit|", emsg)) return false;

  // if path doesn't start with a '/' prepend a '/dev/tty'
  if (fUrl.Path().substr(0,1) != "/") {
    fUrl.SetPath(string("/dev/tty" + fUrl.Path()));
  }

  speed_t speed = B115200;
  unsigned long nsbaud = 0;
  string baud;
  if (fUrl.FindOpt("baud", baud)) {
    speed = B0;
    if (baud=="2400")                     speed = B2400;
    if (baud=="4800")                     speed = B4800;
    if (baud=="9600")                     speed = B9600;
    if (baud=="19200"   || baud=="19k")   speed = B19200;
    if (baud=="38400"   || baud=="38k")   speed = B38400;
    if (baud=="57600"   || baud=="57k")   speed = B57600;
    if (baud=="115200"  || baud=="115k")  speed = B115200;
    if (baud=="230400"  || baud=="230k")  speed = B230400;
    if (baud=="460800"  || baud=="460k")  speed = B460800;
    if (baud=="500000"  || baud=="500k")  speed = B500000;
    if (baud=="921600"  || baud=="921k")  speed = B921600;
    if (baud=="1000000" || baud=="1000k" || baud=="1M") speed = B1000000;
    if (baud=="1152000" || baud=="1152k")               speed = B1152000;
    if (baud=="1500000" || baud=="1500k")               speed = B1500000;
    if (baud=="2000000" || baud=="2000k" || baud=="2M") speed = B2000000;
    if (baud=="2500000" || baud=="2500k")               speed = B2500000;
    if (baud=="3000000" || baud=="3000k" || baud=="3M") speed = B3000000;
    if (baud=="3500000" || baud=="3500k")               speed = B3500000;
    if (baud=="4000000" || baud=="4000k" || baud=="4M") speed = B4000000;

    // now handle non-standart baud rates
    if (speed == B0) {
      if (baud== "5000000" || baud== "5000k" || baud== "5M") nsbaud =  5000000;
      if (baud== "6000000" || baud== "6000k" || baud== "6M") nsbaud =  6000000;
      if (baud== "6666666" || baud== "6666k")                nsbaud =  6666666;
      if (baud=="10000000" || baud=="10000k" || baud=="10M") nsbaud = 10000000;
      if (baud=="12000000" || baud=="12000k" || baud=="12M") nsbaud = 12000000;
      if (nsbaud == 0) {
        emsg.Init("RlinkPortTerm::Open()", 
                  string("invalid baud rate '") + baud + "' specified");
        return false;
      }
    }
  }

  int fd;

  fd = open(fUrl.Path().c_str(), O_RDWR|O_NOCTTY);
  if (fd < 0) {
    emsg.InitErrno("RlinkPortTerm::Open()", 
                   string("open() for '") + fUrl.Path() + "' failed: ",
                   errno);
    return false;
  }

  if (!isatty(fd)) {
    emsg.Init("RlinkPortTerm::Open()", 
              string("isatty() check for '") + fUrl.Path() +
              "' failed: not a TTY");
    close(fd);
    return false;
  }

  if (::tcgetattr(fd, &fTiosOld) != 0) {
    emsg.InitErrno("RlinkPortTerm::Open()", 
                   string("tcgetattr() for '") + fUrl.Path() + "' failed: ",
                   errno);
    ::close(fd);
    return false;
  }

  struct serial_struct sioctl;
  int cdivisor = 0;
  
  if (nsbaud != 0) {
    if (::ioctl(fd, TIOCGSERIAL, &sioctl) < 0) {
      emsg.InitErrno("RlinkPortTerm::Open()", 
                     string("ioctl(TIOCGSERIAL) for '")+fUrl.Path()+"' failed: ",
                     errno);
      ::close(fd);
      return false;
    }
    double fcdivisor = double(sioctl.baud_base) / double(nsbaud);
    cdivisor = fcdivisor + 0.5;
    speed    = B38400;
  }

  bool use_cts = fUrl.FindOpt("cts");
  bool use_xon = fUrl.FindOpt("xon");
  fXon = use_xon;

  fTiosNew = fTiosOld;

  fTiosNew.c_iflag = IGNBRK |               // ignore breaks on input
                     IGNPAR;                // ignore parity errors
  if (use_xon) {
    fTiosNew.c_iflag |= IXON|               // XON/XOFF flow control output
                        IXOFF;              // XON/XOFF flow control input
  }

  fTiosNew.c_oflag = 0;

  fTiosNew.c_cflag = CS8 |                  // 8 bit chars
                     CSTOPB |               // 2 stop bits
                     CREAD |                // enable receiver
                     CLOCAL;                // ignore modem control
  if (use_cts) {
    fTiosNew.c_cflag |= CRTSCTS;            // enable hardware flow control
  }

  fTiosNew.c_lflag = 0;

  if (::cfsetspeed(&fTiosNew, speed) != 0) {
    emsg.InitErrno("RlinkPortTerm::Open()", 
                   string("cfsetspeed() for '") + baud + "' failed: ",
                   errno);
    close(fd);
    return false;
  }

  if (cdivisor != 0) {
    sioctl.flags          |= ASYNC_SPD_CUST;
    sioctl.custom_divisor  = cdivisor;
    if (::ioctl(fd, TIOCSSERIAL, &sioctl) < 0) {
      emsg.InitErrno("RlinkPortTerm::Open()", 
                     string("ioctl(TIOCSSERIAL) for '")+fUrl.Path()+"' failed: ",
                     errno);
      ::close(fd);
      return false;
    }
  }

  fTiosNew.c_cc[VEOF]   = 0;                // undef
  fTiosNew.c_cc[VEOL]   = 0;                // undef
  fTiosNew.c_cc[VERASE] = 0;                // undef
  fTiosNew.c_cc[VINTR]  = 0;                // undef
  fTiosNew.c_cc[VKILL]  = 0;                // undef
  fTiosNew.c_cc[VQUIT]  = 0;                // undef
  fTiosNew.c_cc[VSUSP]  = 0;                // undef
  fTiosNew.c_cc[VSTART] = 0;                // undef
  fTiosNew.c_cc[VSTOP]  = 0;                // undef
  fTiosNew.c_cc[VMIN]   = 1;                // wait for 1 char
  fTiosNew.c_cc[VTIME]  = 0;                // 
  if (use_xon) {
    fTiosNew.c_cc[VSTART] = kc_xon;         // setup XON  -> ^Q
    fTiosNew.c_cc[VSTOP]  = kc_xoff;        // setup XOFF -> ^S   
  }

  if (::tcsetattr(fd, TCSANOW, &fTiosNew) != 0) {
    emsg.InitErrno("RlinkPortTerm::Open()", 
                   string("tcsetattr() for '") + fUrl.Path() + "' failed: ",
                   errno);
    ::close(fd);
    return false;
  }

  // tcsetattr() returns success if any of the requested changes could be
  // successfully carried out. Therefore the termios structure is read back
  // and verified.

  struct termios tios;
  if (::tcgetattr(fd, &tios) != 0) {
    emsg.InitErrno("RlinkPortTerm::Open()", 
                   string("2nd tcgetattr() for '") + fUrl.Path() +
                   "' failed: ", errno);
    ::close(fd);
    return false;
  }

  const char* pmsg = 0;
  if (tios.c_iflag != fTiosNew.c_iflag) pmsg = "c_iflag";
  if (tios.c_oflag != fTiosNew.c_oflag) pmsg = "c_oflag";
  if (tios.c_cflag != fTiosNew.c_cflag) pmsg = "c_cflag";
  if (tios.c_lflag != fTiosNew.c_lflag) pmsg = "c_lflag";
  if (::cfgetispeed(&tios) != speed)      pmsg = "ispeed";
  if (::cfgetospeed(&tios) != speed)      pmsg = "ospeed";
  for (int i=0; i<NCCS; i++) {
    if (tios.c_cc[i] != fTiosNew.c_cc[i]) pmsg = "c_cc char";
  }

  // FIXME_code: why does readback fail for 38400 ?
  if (speed != B38400 && pmsg) {
    emsg.Init("RlinkPortTerm::Open()",
              string("tcsetattr() failed to set") + string(pmsg));
    ::close(fd);
    return false;
  }

  fFdWrite = fd;
  fFdRead  = fd;
  fIsOpen  = true;

  if (fUrl.FindOpt("break")) {
    if (tcsendbreak(fd, 0) != 0) {
      emsg.InitErrno("RlinkPortTerm::Open()", 
                     string("tcsendbreak() for '") + fUrl.Path() + 
                     "' failed: ", errno);
      Close();
      return false;
    }
    uint8_t buf[1];
    buf[0] = 0x80;
    if (Write(buf, 1, emsg) != 1) {
      Close();
      return false;      
    }
  }

  return true;
}

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPortTerm::Close()
{
  if (!IsOpen()) return;

  if (fFdWrite >= 0) {
    ::tcflush(fFdWrite, TCIOFLUSH);
    ::tcsetattr(fFdWrite, TCSANOW, &fTiosOld);
  }
  RlinkPort::Close();

  return;
}
  
//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPortTerm::Dump(std::ostream& os, int ind, const char* text) const
{
  RosFill bl(ind);
  os << bl << (text?text:"--") << "RlinkPortTerm @ " << this << endl;
  DumpTios(os, ind, "fTiosOld", fTiosOld);
  DumpTios(os, ind, "fTiosNew", fTiosNew);
  RlinkPort::Dump(os, ind, " ^");
  return;
} 

//------------------------------------------+-----------------------------------
//! FIXME_docs

void RlinkPortTerm::DumpTios(std::ostream& os, int ind, const std::string& name,
                             const struct termios& tios) const
{
  RosFill bl(ind+2);
  os << bl << name << ":" << endl;
  os << bl << "  c_iflag : " << RosPrintf(tios.c_iflag,"x0",8);
  if (tios.c_iflag & BRKINT) os << " BRKINT";
  if (tios.c_iflag & ICRNL)  os << " ICRNL ";
  if (tios.c_iflag & IGNBRK) os << " IGNBRK";
  if (tios.c_iflag & IGNCR)  os << " IGNCR ";
  if (tios.c_iflag & IGNPAR) os << " IGNPAR";
  if (tios.c_iflag & INLCR)  os << " INLCR ";
  if (tios.c_iflag & INPCK)  os << " INPCK ";
  if (tios.c_iflag & ISTRIP) os << " ISTRIP";
  if (tios.c_iflag & IXOFF)  os << " IXOFF ";
  if (tios.c_iflag & IXON)   os << " IXON  ";
  if (tios.c_iflag & PARMRK) os << " PARMRK";
  os << endl;

  os << bl << "  c_oflag : " << RosPrintf(tios.c_oflag,"x0",8);
  if (tios.c_oflag & OPOST)  os << " OPOST ";
  os << endl;

  os << bl << "  c_cflag : " << RosPrintf(tios.c_cflag,"x0",8);
  if (tios.c_cflag & CLOCAL) os << " CLOCAL";
  if (tios.c_cflag & CREAD)  os << " CREAD ";
  if ((tios.c_cflag & CSIZE) == CS5)  os << " CS5   ";
  if ((tios.c_cflag & CSIZE) == CS6)  os << " CS6   ";
  if ((tios.c_cflag & CSIZE) == CS7)  os << " CS7   ";
  if ((tios.c_cflag & CSIZE) == CS8)  os << " CS8   ";
  if (tios.c_cflag & CSTOPB) os << " CSTOPB";
  if (tios.c_cflag & HUPCL)  os << " HUPCL ";
  if (tios.c_cflag & PARENB) os << " PARENB";
  if (tios.c_cflag & PARODD) os << " PARODD";
  speed_t speed = cfgetispeed(&tios);
  int baud = 0;
  if (speed == B2400)    baud =    2400;
  if (speed == B4800)    baud =    4800;
  if (speed == B9600)    baud =    9600;
  if (speed == B19200)   baud =   19200;
  if (speed == B38400)   baud =   38400;
  if (speed == B57600)   baud =   57600;
  if (speed == B115200)  baud =  115200;
  if (speed == B230400)  baud =  230400;
  if (speed == B460800)  baud =  460800;
  if (speed == B500000)  baud =  500000;
  if (speed == B921600)  baud =  921600;
  if (speed == B1000000) baud = 1000000;
  if (speed == B1152000) baud = 1152000;
  if (speed == B1500000) baud = 1500000;
  if (speed == B2000000) baud = 2000000;
  if (speed == B2500000) baud = 2500000;
  if (speed == B3000000) baud = 3000000;
  if (speed == B3500000) baud = 3500000;
  if (speed == B4000000) baud = 4000000;
  os << " speed: " << RosPrintf(baud, "d", 7);
  os << endl;

  os << bl << "  c_lflag : " << RosPrintf(tios.c_lflag,"x0",8);
  if (tios.c_lflag & ECHO)   os << " ECHO  ";
  if (tios.c_lflag & ECHOE)  os << " ECHOE ";
  if (tios.c_lflag & ECHOK)  os << " ECHOK ";
  if (tios.c_lflag & ECHONL) os << " ECHONL";
  if (tios.c_lflag & ICANON) os << " ICANON";
  if (tios.c_lflag & IEXTEN) os << " IEXTEN";
  if (tios.c_lflag & ISIG)   os << " ISIG  ";
  if (tios.c_lflag & NOFLSH) os << " NOFLSH";
  if (tios.c_lflag & TOSTOP) os << " TOSTOP";
  os << endl;

  os << bl << "  c_cc    : " << endl;
  os << bl << "    [VEOF]  : " << RosPrintf(tios.c_cc[VEOF],"o",3);
  os       << "    [VEOL]  : " << RosPrintf(tios.c_cc[VEOL],"o",3);
  os       << "    [VERASE]: " << RosPrintf(tios.c_cc[VERASE],"o",3);
  os       << "    [VINTR] : " << RosPrintf(tios.c_cc[VINTR],"o",3)  << endl;
  os << bl << "    [VKILL] : " << RosPrintf(tios.c_cc[VKILL],"o",3);
  os       << "    [VQUIT] : " << RosPrintf(tios.c_cc[VQUIT],"o",3);
  os       << "    [VSUSP] : " << RosPrintf(tios.c_cc[VSUSP],"o",3);
  os       << "    [VSTART]: " << RosPrintf(tios.c_cc[VSTART],"o",3) << endl;
  os << bl << "    [VSTOP] : " << RosPrintf(tios.c_cc[VSTOP],"o",3);
  os       << "    [VMIN]  : " << RosPrintf(tios.c_cc[VMIN],"o",3);
  os       << "    [VTIME] : " << RosPrintf(tios.c_cc[VTIME],"o",3)  << endl;

  return;
}

} // end namespace Retro
