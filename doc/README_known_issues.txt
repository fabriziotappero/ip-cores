$Id: README_known_issues.txt 687 2015-06-05 09:03:34Z mueller $

Known issues for this release.
The case id indicates the release when the issue was first recognized.

- V0.66-1: the TM11 controller transfers data byte wise (all disk do it 16bit 
    word wise) and allows for odd byte length transfers. Odd length transfers
    are currently not supported and rejected as invalid command. Odd byte 
    length records aren't used by OS, if at all, so in practice this limitation 
    isn't relevant.
- V0.66-2: using two RP06 drives in parallel under 211bsd leads to a hangup of 
    the system after a short time. Currently only operation of a single drive
    works reliably.

- V0.65-1: ti_rri sometimes crashes in normal rundown (exit or ^D) when
    a cuff: type rlink is active. One gets
      terminate called after throwing an instance of 'Retro::Rexception'
        what():  RlinkPortCuff::Cleanup(): driver thread failed to stop
    doesn't affect normal operation, will be fixed in upcoming release.
- V0.65-2: some exotic RH70/RP/RM features and conditions not implemented yet
    - last block transfered flag (in DS)
    - CS2.BAI currently ignored and not handled
    - read or write 'with header' gives currently ILF
    All this isn't used by any OS, so in practice not relevant.

- V0.64-7: ghdl simulated OS boots via ti_w11 (-n4 ect options) fail due to a 
    flow control issue (likely since V0.63).
- V0.64-6: IO delays still unconstraint in vivado. All critical IOs use
    explicitly IOB flops, thus timing well defined.
- V0.64-5: w11a_tb_guide.txt covers only ISE based tests (see also V0.64-4).
- V0.64-4: No support for the Vivado simulator (xsim) yet. With ghdl only
    functional simulations, post synthesis (_ssim) fails to compile.
- V0.64-3: Highest baud rate with basys3 and nexys4 is 10 MBaud. 10 MBaud is
    not supported according to FTDI, but works. 12 MBaud in an upcoming release.
- V0.64-2: rlink throughput on basys3/nexys4 limited by serial port stack 
    round trip times. Will be overcome by libusb based custom driver.
- V0.64-1: The large default transfer size for disk accesses leads to bad
    throughput in the DL11 emulation for low speed links, like the
    460kBaud the S3board is limited too. Will be overcome by a DL11
    controller with more buffering.

- V0.62-2: rlink v4 error recovery not yet implemented, will crash on error
- V0.62-1: Command lists aren't split to fit in retransmit buffer size
    {last two issues not relevant for w11 backend over USB usage because 
    the backend produces proper command lists and the USB channel is 
    usually error free}
