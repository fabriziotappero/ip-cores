# $Id: README_USB-VID-PID.txt 467 2013-01-02 19:49:05Z mueller $

!! Read this disclaimer carefully. You'll be responsible for any  !!
!! misuse of the defaults provided with the project sources.      !!

USB drivers identify hardware by means of two 16 bit identifiers

  VID - Vendor ID
  PID - Product ID

In a 'softcoded' USB Controler like the Cypress FX2 each firmware with a
specific functionality should have a unique VID/PID so that drivers can
automatically detect and configure.

The assignment of USB VID/PID is done by usb.org. Unfortunately there is no 
VID range reserved for 'development' or 'internal use', the only official way
to obtain a VID is to buy one from usb.org, see
  http://www.usb.org/developers/vendor/

The 'usb_jtag' project bought many years ago a small PID range from a re-seller
and used 
   VID=16C0
   PID=06AD
for a project which implemented an Altera UsbBlaster compatible JTAG interface.

The firmware provided with this project provides
  - a JTAG interface (via EP1 and EP2)
  - data channels (via EP4, EP6 and optionally EP8)
The JTAG part is compatible with the 'usb_jtag' implementation and by extension
compatible with the 'usbblaster' cable driver provided by 'UrJtag', and can
therefore be operated with the 'jtag' command.

However, because the firmware offers additional functionality it should have a
separate VID/PID. Unfortunately it is not longer possible to buy at very modest
cost a PID sub-range, as was done by the 'usb_jtag' project bought many years 
ago. 

VOTI, a small dutch company, has bought a VID for it's own developments and
made a small range of PID publicly available as "free for internal lab use".
Usage is granted for 'internal lab use only' by VOTI under the conditions:
   - the gadgets in which you use those PIDs do not leave your desk
   - you won't complain to VOTI if you get in trouble with duplicate PIDs
     (for instance because someone else did not follow the previous rule).
   - See http://www.voti.nl/pids/pidfaq.html for further details.

The retro11 project uses one of these 'free for internal lab use' PIDs

   VID=16C0
   PID=03EF

from VOTI as default VID/PID.

==> This is is perfectly fine for plain hobbyist usage
==> But respect the ownership of VOTI of this VID/PID and do not
    use this VID/PID for other purposes
