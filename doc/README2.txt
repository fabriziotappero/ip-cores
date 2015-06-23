-----------------------------------------
 USB 1.1 / 2.0 serial data transfer core
-----------------------------------------

Version:   2009-10-06
Author:    Joris van Rantwijk
Language:  VHDL
License:   GPL - GNU General Public License
Website:   http://www.xs4all.nl/~rjoris/fpga/usb.html


usb_serial is a synthesizable VHDL core, implementing serial data
transfer over USB.  Combined with a UTMI-compatible USB transceiver
chip, this core acts as a USB device that transfers a byte stream
in both directions over the bus.

This package is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.


-----------------------------------------
See MANUAL.pdf for detailed information.
-----------------------------------------


Files in this package
---------------------

 COPYING               Text of the GNU General Public License.
 MANUAL.pdf            Manual for usb_serial core.
 Makefile              Script to synthesizes the VHDL code for Xilinx devices.
 usb_serial.vhdl       Main core.
 usb_control.vhdl      Sub-entity handling control requests.
 usb_init.vhdl         Sub-entity handling device initialization.
 usb_packet.vhdl       Sub-entity for sending and receiving packets.
 usb_transact.vhdl     Sub-entity for transaction handling.
 usbtest.vhdl          Sample top-level design for testing.
 te0146.ucf            Constraints file for a TE0146 FPGA module.
 testdev.py            Python program running a torture test on usbtest.bit.
 perftest.c            C program measuring data transfer performance on Linux.
 crcformula.py         Python program for computing CRC update formulas.

----

The rest of this file contains some unorganized notitions.


Changes from version 2007-04-19 to 2009-10-06
---------------------------------------------

* usb_init:
  + Add generic HSSUPPORT
  + Rename USBRST to I_USBRST
  + Add output signal I_HIGHSPEED, active iff attached in high speed mode
  + Add output signal I_SUSPEND, active iff suspended by host
  + Add output P_CHIRPK
  + Add output PHY_XCVRSELECT
  + Add output PHY_TERMSELECT
  + Implement HS handshake / FS fallback protocol.
  + Implement suspend detection.

* usb_packet:
  + Add input P_CHIRPK.
  + Send continuous chirp-K when P_CHIRPK asserted.
  + Use signal s_dataout instead of variable v_dataout as register.
  + Recognize PING as a valid token packet.
  + Clear PHY_TXVALID and PHY_DATAOUT in response to RESET.
  + Pay attention to PHY_RXERROR while receiving handshake packet.
  + Eliminate ST_RFIN state and release P_RXACT one cycle earlier,
    i.e. at the same time as raising P_RXFIN. (Necessary because PHY_RXACTIVE
    may be low for just a single cycle between packets).

* usb_transact:
  + Verified that releasing P_RXACT while asserting P_RXFIN is handled fine.
  + Add generic HSSUPPORT.
  + Add output signal T_PING.
  + Add input signal T_NYET; must be valid when SEND goes down.
  + Eliminate ST_FIN so that we will always be in time to catch the rising
    edge of P_RXACT even in the cycle immediately following P_RXFIN.
  + Implement PING transaction (same application timing as IN transaction).
  + Implement NYET handshake.
  + Reduce guaranteed decision time for application from 10 to 2 cycles.
  + Separate inter-packet delay and response timeout values for FS and HS;
    increase FS inter-packet delay from 10 to 14 cycles.
  + Ignore our own transmitted packet while waiting for ACK.
  + Fail transaction if empty packet received while waiting for ACK or DATA.
  + Again rejected (after extensive consideration) the idea of using
    PHY_LINESTATE for inter-packet delay, even though this is actually
    required according to the UTMI standard. It is difficult to reliably
    relate PHY_LINESTATE to logical send/receive activity. The best I can come
    up with is to have an inter-packet timer which counts down iff the line
    is idle as indicated by PHY_LINESTATE. But detecting line idle in FS mode
    depends on the SE0-to-J transition, which makes the scheme vulnerable in
    case the SE0 state is missed somehow.
    So we stay with the concept of inter-packet timing based on PHY_RXACTIVE
    plus a much relaxed timeout for host responses.
    Note to self: please don't waste more time on this.

* usb_control:
  + Add generic HSSUPPORT.
  + Rename upstream interface signals to C_xxx.
  + Add input signal T_PING (ignored, therefore always ACK-ed).
  + Add output signal T_NYET (always driven to zero).
  + Redesigned descriptor ROM interface.
  + Implement ENDPOINT_HALT feature.
  + Implement self-powered bit in status word.

* usb_serial:
  + Changed interface to sub-entities.
  + Redesigned descriptor ROM interface.
  + Implement device_qualifier and other_speed_configuration descriptors.
  + Split single block RAM into three separate RAMs for RX buffer,
    TX buffer and descriptor ROM.
  + Streamline state machine.
  + Implement PING / NYET handshake.
  + Add RXLEN / TXROOM status signals.
  + Add TXCORK control signal.
  + Add HIGHSPEED and SUSPEND signals to application interface.
  + Prepare for separate clock domains.
  + Support halting of endpoints.

* usb_serial_wb:
  + Removed. Wishbone is not intended for this kind of thing.

* usbtest:
  + Add testing of TXCORK flag.
  + Add blast mode for test of fast streaming transmission.

* Makefile:
  + Fix command line options for newer versions of Xilinx tools.

* testdev.py:
  + Testing of TXCORK feature.
  + Adapt test parameters for bigger TX/RX buffers in the device.
  + Test partial read of incoming data.

* perftest.c
  + Performance measurements.


Performance measurements
------------------------

Version 20090929:

Performance full speed, RX 128, TX 128, libusb-1.0 async:
  RX 67108864 bytes in 61.673 s =  1088137 bytes/s
  TX 64000000 bytes in 58.816 s =  1088146 bytes/s

Performance high speed, RX 2k, TX 1k, libusb-1.0 async:
  RX 67108864 bytes in  1.490 s = 45049302 bytes/s
  TX 64000000 bytes in  1.953 s = 32766457 bytes/s


Intermediate version 20090917:
( Comparing performance of normal code against error injection. )

Performance FS, normal:
  RX 67108864 bytes in 61.674 s =  1088118 bytes/s
  TX 64000000 bytes in 58.820 s =  1088073 bytes/s

Performance HS, normal:
  RX 67108864 bytes in  1.535 s = 43727704 bytes/s
  TX 64000000 bytes in  1.961 s = 32635212 bytes/s

Performance FS, error injection:
  RX 67108864 bytes in 82.163 s =   816777 bytes/s
  TX 64000000 bytes in 78.420 s =   816113 bytes/s

Performance HS, error injection:
  RX 67108864 bytes in  1.965 s = 34144882 bytes/s
  TX 64000000 bytes in  3.110 s = 20576099 bytes/s


Tested
------

  + Suspend/resume with SUSPEND signal used as clock gate.
  + Verified that none of the following events occur during functional test:
    aborted transaction; duplicate OUT packet; OUT-NAK in high speed mode.
  + Deliberate error injection: works ok, but reduced performance as expected.
  + Tested SetFeature(ENDPOINT_HALT)
  + Functional test and performance test:
    + full speed, konijn, linux, RX 128, TX 128
    + full speed, konijn, linux, RX 128, TX 128, no_fullpacket
    + full speed, konijn, linux, RX 1k, TX 128
    + full speed, konijn, linux, RX 128, TX 1k (one time hang in perftest)
    + full speed, konijn, linux, RX 2k, TX 1k
    + high speed, konijn, linux, RX 1k, TX 1k  (problems with usbserial, fixed)
    + high speed, konijn, linux, RX 2k, TX 1k
    + high speed, konijn, linux, RX 2k, TX 1k, no_fullpacket
    + high speed, konijn, linux, RX 1k, TX 2k
    + high speed, konijn, linux, RX 4k, TX 2k
    + full speed, schildpad, linux, RX 128, TX 128
    + fallback to full speed, schildpad, linux, RX 2k, TX 1k
    + full speed, sron, linux
    + high speed, sron, linux
  + Limited functional test:
    + full speed, schildpad, Win2k, RX 128, TX 128 (fails due to zero length packet)
    + full speed, schildpad, Win2k, RX 128, TX 128, no_fullpacket
    + fallback to full speed, schildpad, Win2k, RX 2k, TX 1k, no_fullpacket (failed)
    + full speed, iBook, RX 128, TX 128
    + high speed, iBook, RX 2k, TX 1k
    + full speed, sron, Windows XP
    + high speed, sron, Windows XP
  + Performance:
    + full speed, konijn, linux, RX 128, TX 128
    + high speed, konijn, linux, RX 2k, TX 1k
  + Verify descriptors, device, config, qualifier, other_speed_config, status:
    + full speed, konijn, linux
    + high speed, konijn, linux
  + Test suspend/resume:
    + full speed, konijn
    + full speed, iBook
    + high speed, konijn
    + high speed, iBook
  + Plug-in handling:
    + high speed, konijn, linux
    + fallback to full speed, schildpad, linux
    + high speed, sron, Windows XP
    + high speed, iBook


Misc issues
-----------

* USB 2.0 high speed requires support of SET_FEATURE(TEST_MODE).
  We will not implement this.
  Reason: overkill, no way to test it properly.

* Suspend detection is implemented.
  The output signal SUSPEND from usb_serial can be used to combinatorially
  drive the suspend pin on the UTMI interface. Reset of the SUSPEND signal
  is asynchronous and can therefore work even when the FPGA has no clock.

* We will not implement detection of SOF packets.
  Reason: usefulness is questionable.

* No separate clock domains.
  Reason: difficult to implement, very hard to validate.

* There is a problem with empty packets under Windows 2000.
  The Windows 2000 version of usbser.dll chokes on unexpected empty packets,
  such as send by the device after a final full-length packet.
  This has been solved in Windows XP.

* A babble error occurs when a device sends more bytes than expected
  by the host, even if this is less than the maximum packet size.
  This may happen if software submits an IN request which is not
  a multiple of the maximum packet size. It may also happen if the host
  sends an invalid standard device request, for example GET_STATUS with
  wLength=0.
  To avoid this, always submit IN requests with the transfer size set to
  a multiple of the maximum packet size.
  Note that babble errors can freeze the host controller; this is a known
  bug of VIA UHCI controllers:
  http://www.mail-archive.com/linux-usb-devel@lists.sourceforge.net/msg17019.html

* After plugging in, the Linux kernel log shows
  "device descriptor read/64, error -62" and
  "Cannot enable port 2.  Maybe the USB cable is bad?".
  After the errors, the kernel retries and the second attempt is successful.
  It seems pretty reproducible; occurs in FS and HS mode after plugin,
  but not after soft-reattach of the device.
  It is worse under Win2k; the USB subsystem seems to crash after plugging in.
  Theory: Initialization of the FPGA initialization takes longer than 100 ms,
  causing us to miss the initial port handshake.

* Even 8k TX buffer is not sufficient for loss-free transmission @ 25 MB/s.
  Loss rate becomes much higher under CPU load.


FPGA Resources
--------------

( From mapper log file; target = XC3S1000 )

Design:     usbtest-20070419
Tools:      Xilinx Webpack 7.1i

Number of errors:      0
Number of warnings:    2
Logic Utilization:
  Number of Slice Flip Flops:         301 out of  15,360    1%
  Number of 4 input LUTs:             969 out of  15,360    6%
Logic Distribution:
  Number of occupied Slices:                          573 out of   7,680    7%
    Number of Slices containing only related logic:     573 out of     573  100%
    Number of Slices containing unrelated logic:          0 out of     573    0%
      *See NOTES below for an explanation of the effects of unrelated logic
Total Number 4 input LUTs:          1,034 out of  15,360    6%
  Number used as logic:                969
  Number used as a route-thru:          65
  Number of bonded IOBs:               31 out of     173   17%
    IOB Flip Flops:                    27
  Number of Block RAMs:                2 out of      24    8%
  Number of GCLKs:                     1 out of       8   12%

Total equivalent gate count for design:  140,539

----

Design:     usbtest-20090927, full speed, RX 128, TX 128
Tools:      Xilinx Webpack 7.1i

Number of errors:      0
Number of warnings:    2
Logic Utilization:
  Number of Slice Flip Flops:         337 out of  15,360    2%
  Number of 4 input LUTs:           1,151 out of  15,360    7%
Logic Distribution:
  Number of occupied Slices:                          671 out of   7,680    8%
    Number of Slices containing only related logic:     671 out of     671  100%
    Number of Slices containing unrelated logic:          0 out of     671    0%
      *See NOTES below for an explanation of the effects of unrelated logic
Total Number 4 input LUTs:          1,249 out of  15,360    8%
  Number used as logic:              1,151
  Number used as a route-thru:          98
  Number of bonded IOBs:               31 out of     173   17%
    IOB Flip Flops:                    31
  Number of Block RAMs:                4 out of      24   16%
  Number of GCLKs:                     1 out of       8   12%

Total equivalent gate count for design:  273,110

----

Design:     usbtest-20090929, high speed, RX 2k, TX 1k
Tools:      Xilinx Webpack 7.1i

Number of errors:      0
Number of warnings:    2
Logic Utilization:
  Number of Slice Flip Flops:         380 out of  15,360    2%
  Number of 4 input LUTs:           1,349 out of  15,360    8%
Logic Distribution:
  Number of occupied Slices:                          787 out of   7,680   10%
    Number of Slices containing only related logic:     787 out of     787  100%
    Number of Slices containing unrelated logic:          0 out of     787    0%
      *See NOTES below for an explanation of the effects of unrelated logic
Total Number 4 input LUTs:          1,465 out of  15,360    9%
  Number used as logic:              1,349
  Number used as a route-thru:         116
  Number of bonded IOBs:               31 out of     173   17%
    IOB Flip Flops:                    34
  Number of Block RAMs:                4 out of      24   16%
  Number of GCLKs:                     1 out of       8   12%

Total equivalent gate count for design:  274,894

----

Design:     usb_serial only, 20090929, full speex RX 128, TX 128
Tools:      Xilinx Webpack 7.1i

Number of errors:      0
Number of warnings:    2
Logic Utilization:
  Number of Slice Flip Flops:         235 out of  15,360    1%
  Number of 4 input LUTs:             841 out of  15,360    5%
Logic Distribution:
  Number of occupied Slices:                          479 out of   7,680    6%
    Number of Slices containing only related logic:     479 out of     479  100%
    Number of Slices containing unrelated logic:          0 out of     479    0%
      *See NOTES below for an explanation of the effects of unrelated logic
Total Number 4 input LUTs:            899 out of  15,360    5%
  Number used as logic:                841
  Number used as a route-thru:          58
  Number of bonded IOBs:               69 out of     173   39%
    IOB Flip Flops:                    33
  Number of Block RAMs:                3 out of      24   12%
  Number of GCLKs:                     1 out of       8   12%

Total equivalent gate count for design:  204,527

----

Design:     usb_serial only, 20090929, high speed, RX 2k, TX 1k
Tools:      Xilinx Webpack 7.1i

Number of errors:      0
Number of warnings:    2
Logic Utilization:
  Number of Slice Flip Flops:         285 out of  15,360    1%
  Number of 4 input LUTs:           1,062 out of  15,360    6%
Logic Distribution:
  Number of occupied Slices:                          610 out of   7,680    7%
    Number of Slices containing only related logic:     610 out of     610  100%
    Number of Slices containing unrelated logic:          0 out of     610    0%
      *See NOTES below for an explanation of the effects of unrelated logic
Total Number 4 input LUTs:          1,139 out of  15,360    7%
  Number used as logic:              1,062
  Number used as a route-thru:          77
  Number of bonded IOBs:               76 out of     173   43%
    IOB Flip Flops:                    36
  Number of Block RAMs:                3 out of      24   12%
  Number of GCLKs:                     1 out of       8   12%

Total equivalent gate count for design:  206,559

----

Design:     usb_serial only, 20090929, full speed, RX 128, TX 128
Tools:      Xilinx ISE 11.2

Number of errors:      0
Number of warnings:    1
Logic Utilization:
  Number of Slice Flip Flops:           227 out of  15,360    1%
  Number of 4 input LUTs:               808 out of  15,360    5%
Logic Distribution:
  Number of occupied Slices:            459 out of   7,680    5%
    Number of Slices containing only related logic:     459 out of     459 100%
    Number of Slices containing unrelated logic:          0 out of     459   0%
      *See NOTES below for an explanation of the effects of unrelated logic.
  Total Number of 4 input LUTs:         835 out of  15,360    5%
    Number used as logic:               808
    Number used as a route-thru:         27
  The Slice Logic Distribution report is not meaningful if the design is
  over-mapped for a non-slice resource or if Placement fails.
  Number of bonded IOBs:                 69 out of     173   39%
    IOB Flip Flops:                      27
  Number of RAMB16s:                      3 out of      24   12%
  Number of BUFGMUXs:                     1 out of       8   12%

----

Design:     usb_serial only, 20090929, high speed, RX 2k, TX 1k
Tools:      Xilinx ISE 11.2

Number of errors:      0
Number of warnings:    2
Logic Utilization:
  Number of Slice Flip Flops:           265 out of  15,360    1%
  Number of 4 input LUTs:               955 out of  15,360    6%
Logic Distribution:
  Number of occupied Slices:            555 out of   7,680    7%
    Number of Slices containing only related logic:     555 out of     555 100%
    Number of Slices containing unrelated logic:          0 out of     555   0%
      *See NOTES below for an explanation of the effects of unrelated logic.
  Total Number of 4 input LUTs:       1,010 out of  15,360    6%
    Number used as logic:               955
    Number used as a route-thru:         55
  The Slice Logic Distribution report is not meaningful if the design is
  over-mapped for a non-slice resource or if Placement fails.
  Number of bonded IOBs:                 76 out of     173   43%
    IOB Flip Flops:                      32
  Number of RAMB16s:                      3 out of      24   12%
  Number of BUFGMUXs:                     1 out of       8   12%

----
