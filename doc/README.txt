$Id: README.txt 687 2015-06-05 09:03:34Z mueller $

Release notes for w11a

  Table of content:
  
  1. Documentation
  2. Change Log

1. Documentation -------------------------------------------------------------

  More detailed information on installation, build and test can be found 
  in the doc directory, specifically

    * README.txt: release notes
    * README_known_issues.txt: known issues
    * INSTALL.txt: installation and building test benches and systems
    * FILES.txt: short description of the directory layout, what is where ?
    * w11a_tb_guide.txt: running test benches
    * w11a_os_guide.txt: booting operating systems 
    * w11a_known_issues.txt: known differences, limitations and issues

2. Change Log ----------------------------------------------------------------

- trunk (2015-06-05: svn rev 31(oc) 687(wfjm); untagged w11a_V0.66)  +++++++++
  - Preface
    
    - Since the previous release a full set of small, medium and large sized 
      disks (RK,RL,RP/RM) is available, covering all use cases. Still missing
      was a tape system, which allows to install systems from distribution tapes
      but is also very handy for data exchange. This release adds a TM11/TU10
      tape controller emulation. This is much simpler to implement than a 
      massbus based TU16 or TU78 controller. Because storage is emulated there
      is neither a speed nor a capacity advantage of 1600 or 6250 bpi drives,
      so for all practical purposes the simple 800 bpi TU10 drive emulation is
      fully adequate.
      The TM11/TU10 was tested under 211bsd with creating a tape distribution
      kit and building a RP06 based system from such a tape. A 211bsd_tm
      oskit is provided with a recipe to restore a RP06 from tape.

    - bug fixes
      - the ti_rri event loop aborted under heavy load with three devices, seen
        when RP disk, TM tape and DL11 run simultaneously. Was caused by a race
        condition in attention handling and dispatching.
      - the boot command failed when cpu was running and the unit not decoded
        properly, so boots from units other then 0 failed.

  - Summary
    - added TM11/TU10 tape support

  - New features
    - new modules
      - rtl/ibus/ibdr_rm11        - ibus controller for RM11
      - tools/bin
        - file2tap                  - create a tap container from disk files
        - tap2file                  - split a tap container into disk files
      - tools/src/librw11
        - Rw11(Cntl|Unit)TM11     - Controller/Unit for TM11
        - Rw11UnitTape(|Base)     - support for tape units
        - Rw11VirtTape(|Tap)      - virtual tapes (generic and tap containers)
      - tools/tcl/rw11
        - tbench.tcl                - support sub directories and return in tests
    - new oskits
      - tools/oskit/211bsd_tm     - 2.11BSD tape distribution kit (for RP06)

  - Changes
    - renames
      - tools/tbench              - the text benches were re-organized and 
                                    grouped now in sub directories:
                                      cp    for w11a control port
                                      w11a  for w11a CPU tests
                                      rhrp  for RHRP device tests
                                      tm11  for TM11 device tests
    - functional changes
      - tools/bin/create_disk       - add RM80 support

  - Bug fixes
    - tools/src/librlink
      - RlinkServer                  - fix race condition in attention handling
    - tools/src/librw11
      - Rw11Cpu                      - stop cpu before load, proper unit handling

  - Known issues
    - all issues: see README_known_issues.txt
    - resolved issues: -- none --
    - new issues:
      - V0.66-1: the TM11 controller transfers data byte wise (all disk do it
          16bit word wise) and allows for odd byte length transfers. Odd length
          transfers are currently not supported and rejected as invalid command.
          Odd byte length records aren't used by OS, if at all, so in practice
          this limitation isn't relevant.
      - V0.66-2: using two RP06 drives in parallel under 211bsd leads to a 
          hangup of the system after a short time. Currently only operation
          of a single drive works reliably.

- trunk (2015-05-14: svn rev 30(oc) 681(wfjm); untagged w11a_V0.65)  +++++++++
  - Preface

    - With small RK05 or RL02 sized disks only quite reduced OS setups could
      be booted, full featured systems were beyond reach. Now finally large
      disks are available, with a RH70 + RP/RM disk controller emulation. It
      supports up to four disks and allows now to run full featured 211bsd
      or rsx-11mplus systems.

    - to track down issues with ibus devices a 'ibus monitor' was added, it can
      record in the default setup up to 511 ibus transactions. An address filter
      allows to select accesses of one device. The ibd_ibmon tcl package
      contains the appropriate support scripts.

    - several cleanups
      - factor out common blocks on sys_w11a_* systems: the core+rbus+cache
        logic of single cpu systems now contained in pdp11_sys70, and the
        human I/O for digilent boards now in pdp11_hio70.
      - cpu start/stop logic cleanup: new command set with simple commands.
        Add also a new suspend/resume mechanism, which allows to hold the cpu 
        without leaving the 'run state'. While suspended all timers are frozen.
        Very helpful when debugging, will be the basis for a hardware break
        point logic in a later release.
      - xon/xoff consolidation: escaping now done in cdata2byte/byte2cdata in
        FPGA and in RlinkPacketBufSnd/RlinkPacketBufRcv in backend. The extra
        escaping level in serport_xonrx/serport_xontx isn't used anymore, the 
        special code in RlinkPortTerm has been removed. This allows to use 
        xon/xoff flow control also in simulation links via RlinkPortFifo.
      - status check cleanup: it is very helpful to have a default status check
        and an easy way to modify it cases where some error flags are expected
        (e.g. on device polls). In the old logic status and data checks were
        done via RlinkCommandExpect. The new logic reflects that status checks
        are the normal case, and store the status check pattern in RlinkCommand.
        The meaning of expect masks for status and data is inverted, now a '1'
        means that the bit is checked (before it meant the bit is ignored).
        The default status check pattern is still in RlinkContext, but will be
        copied to RlinkCommand when the list is processed. RlinkCommandExpect
        handles now only data checks.

    - and bug fixes
      - rk11 cleanup: since the first days 211bsd autoconfig printed
           rk ? csr 177400 vector 220 didn't interrupt
        for boots from a RK11 it didn't have consequences, but when booted from
        a RL,RP, or RM disk this prevents that the RK11 disks are configured.
        Was caused by a missing interrupt after device reset. Now fixed.

  - Summary
    - added RH70/RP/RM big disk support
    - many cleanups

  - New features
    - new directory trees for
      - tools/asm-11/lib          - definitions and macros for asm-11
    - new modules
      - rtl/vlib/serport
        - serport_master          - serial port module, master side
      - rtl/ibus/ibd_ibmon        - ibus monitor
      - rtl/ibus/ibdr_rhrp        - ibus controller for RH70 plus RP/RM drives
      - rtl/w11a/pdp11_sys70      - 11/70 system - single core +rbus,debug,cache
      - rtl/w11a/pdp11_hio70      - hio led and dsp for sys70
      - tools/src/librw11
        - Rw11(Cntl|Unit)RHRP       - Controller/Unit for RHRP
      - tools/tbench
        - test_rhrp_*               - test tbench for RHRP
    - new oskits
      - tools/oskit/211bsd_rp     - new oskit for 2.11BSD on RP06
      - tools/oskit/rsx11mp-30_rp - new oskit for RSX-11Mplus V3.0 on RP06

  - Changes
    - renames
      - rtl/w11a/pdp11_sys70 -> pdp11_reg70 (_sys70 now different function)
    - functional changes
      - rtl/bplib/*/tb/tb_*       - use serport_master instead of 
                                      serport_uart_rxtx, allow xon/xoff
      - rtl/bplib/fx2rlink
        - rlink_sp1c_fx2          - add rbd_rbmon (optional via generics)
      - rtl/vlib/rlink/rlink_sp1c - add rbd_rbmon (optional via generics)
      - rtl/ibus/ibd_kw11l        - freeze timer when cpu suspended
      - tools/bin/tbrun_tbwrri    - add --fusp,--xon
      - tools/bin/ti_w11          - rename -fu->-fc, add -f2,-fx; setup defaults
      - tools/bin/librlink
        - RlinkCommandList          - add SetLastExpect() methods
        - RlinkPort                 - add XonEnable()
        - RlinkPortCuff             - add noinit attribute
        - RlinkPort(Fifo|Term)      - add xon,noinit attributes
     - tools/src/librw11
       - Rw11Cpu                    - add AddRbibr(), AddWbibr(), RAddrMap()
     - tools/bin/librlinktpp
        - RtclRlinkConnect          - errcnt: add -increment
                                      log: add -bare,-info..
                                      wtlam: allow tout=0 for attn cleanup
                                      init: new command
                                      exec: drop -estatdef
        - RtclRlinkServer           - get/set interface added
     - tools/src/librwxxtpp
       - RtclRw11Cntl               - start: new command
       - RtclRw11Cpu                - cp: add -rbibr, wbibr, -rreg,...,-init
                                    - cp: add -estat(err|nak|tout), drop estatdef
                                    - rename amap->imap; add rmap

  - Bug fixes
    - rtl/ibus
      - ibdr_rk11                 - interrupt after dreset and seek command start
    - tools/src/librlink
      - RlinkConnect                - WaitAttn(): return 0. (not -1.) if poll
      - RlinkServer                 - Stop(): fix race in (could hang)

  - Known issues
    - all issues: see README_known_issues.txt
    - resolved issues: -- none --
    - new issues:
      - V0.65-1: ti_rri sometimes crashes in normal rundown (exit or ^D) when
          a cuff: type rlink is active. One gets
            terminate called after throwing an instance of 'Retro::Rexception'
              what():  RlinkPortCuff::Cleanup(): driver thread failed to stop
          doesn't affect normal operation, will be fixed in upcoming release.
      - V0.65-2: some exotic RH70/RP/RM features and conditions not implemented
         - last block transfered flag (in DS)
         - CS2.BAI currently ignored and not handled
         - read or write 'with header' gives currently ILF
         All this isn't used by any OS, so in practice not relevant.

- trunk (2015-03-01: svn rev 29(oc) 655(wfjm); untagged w11a_V0.64)  +++++++++

  - Preface
    - The w11 project started on a Spartan-3 based Digilent S3board, and soon 
      moved on to a Nexys2 with much better connectivity. Next step was the
      Spartan-6 based Nexys3. Now is time to continue with 7-Series FPGAs.
    - When Vivado started in 2013 it was immediately clear that the architecture
      is far superior to ISE. But tests with the first versions were sobering,
      the w11a design either didn't compile at all, or produced faulty synthesis
      results. In 2014 Vivado matured, and the current version 2014.4 works
      fine with the w11a code base.
    - The original Nexys4 board allowed to quickly port Nexys3 version because 
      both have the same memory chip. The newer Nexys4 DDR will be addressed 
      later.
    - The BRAM capacity of FPGAs increased significantly over time. The low
      cost Basys3 board with the second smallest Artix-7 (XC7A35T) has 200 KB 
      BRAM. That allows to implement a purely BRAM based w11a system with
      176 kB memory. Not enough for 2.11BSD, but for many other less demanding
      OS available for a PDP11.
    - The Nexyx4 and Basys3 have 16 LEDs. Not quite the 'blinking lights'
      console of the classic 11/45 and 11/70, but enough to display the
      well known OS typical light patterns the veterans remember so well.
    - With a new design tool, a new FPGA generation, two new boards, and a
      new interface for the rlink connection that some of the code and tools
      base had to be re-organized.
    - Last but not least: finally access to a bit bigger disks: RL11 support
    - Many changes, some known issues, some rough edges may still lurke around

  - Summary
    - added support for Vivado
    - added support for Nexys4 and Basys3 boards
    - added RL11 disk support
    - lots of documentation updated

  - New features
    - new directory trees for
      - rtl/bplib/basys3            - support for Digilent Basys3 board
      - rtl/bplib/nexys4            - support for Digilent Nexys4 board
      - rtl/make_viv                - make includes for Vivado
    - new files
      - tools/bin/xviv_ghdl_unisim  - ghdl compile Vivado UNISIM & UNIMACRO libs
    - new modules
      - rtl/ibus/ibdr_rl11          - ibus controller for RL11
      - rtl/vlib/rlink/ioleds_sp1c  - io activity leds for rlink+serport_1clk
      - rtl/vlib/xlib
        - s7_cmt_sfs_gsim             - Series-7 CMT: simple vhdl model
        - s7_cmt_sfs_unisim           - Series-7 CMT: wrapper for UNISIM
      - rtl/w11a
        - pdp11_bram_memctl           - simple BRAM based memctl
        - pdp11_dspmux                - mux for hio display
        - pdp11_ledmux                - mux for hio leds
        - pdp11_statleds              - status led generator
      - tools/src/librw11/
        - Rw11*RL11                   - classes for RL11 disk handling
      - tools/src/librwxxtpp
        - RtclRw11*RL11               - tcl iface for RL11 disk handling
    - new systems
      - rtl/sys_gen/tst_rlink       - rlink tester
        - basys3/sys_tst_rlink_b3     - for Basys3
        - nexys4/sys_tst_rlink_n4     - for Nexys4
      - rtl/sys_gen/tst_serloop     - serport loop tester
        - nexys4/sys_tst_serloop_n4   - for Nexys4
      - rtl/sys_gen/tst_snhumanio   - human I/O tester
        - basys3/sys_tst_snhumanio_b3 - for Basys3
        - nexys4/sys_tst_snhumanio_n4 - for Nexys4
      - rtl/sys_gen/w11a            - w11a
        - basys3/sys_w11a_b3          - small BRAM only (176 kB memory)
        - nexys4/sys_w11a_n4          - with full 4 MB memory using cram
    - new oskits
      - tools/oskit/211bsd_rl       - new oskit for 2.11BSD on RL02
      - tools/oskit/rt11-53_rl      - new oskit for RT11 V5.3 on RL02
      - tools/oskit/xxdp_rl         - new oskit for XXDP 22 and 25 on RL02
 
  - Changes
    - renames
      - ensure that old ISE and new Vivado co-exists, ensure telling names
        - rtl/make                        -> make_ise
        - rtl/bplib/bpgen/sn_4x7segctl    -> sn_7segctl
        - tools/bin/isemsg_filter         -> xise_msg_filter
        - tools/bin/xilinx_ghdl_unisim    -> xise_ghdl_unisim
        - tools/bin/xilinx_ghdl_simprim   -> xise_ghdl_simprim

    - retired files
      - rtl/bplib/fx2lib
        - fx2_2fifoctl_as    - obsolete, wasn't actively used since long
      - tools/bin
        - set_ftdi_lat       - obsolete, since kernel 2.6.32 the default is 1 ms
        - xilinx_vhdl_chop   - obsolete, since ISE 11 sources come chopped

    - functional changes
      - $RETROBASE/Makefile           - re-structured, many new targets
      - rtl/bplib/bpgen
        - sn_7segctl                  - handle also 8 digit displays
        - sn_humanio                  - configurable SWI and DSP width
        - sn_humanio_rbus             - configurable SWI and DSP width
      - rtl/vlib/serport
        - serport_1clock              - export fractional part of divider
      - rtl/ibus
        - ibdr_maxisys                - add RL11 (ibdr_rl11)
      - rtl/sys_gen/w11a/*
        - sys_w11a_*                  - use new led and dsp control modules
      - tools/src/librlink
        - RlinkConnect                - drop LogOpts, indivitual getter/setter
        - RlinkPortTerm               - support custom baud rates (5M,6M,10M,12M)
      - tools/src/librtcltools
        - RtclGetList                 - add '?' (key list) and '*' (kv list)
        - RtclSetList                 - add '?' (key list) 
        - RlogFile                    - Open(): now with cout/cerr support
      - tools/src/librlinktpp
        - RtclRlinkConnect            - drop config cmd, use get/set cmd
        - RtclRlinkPort               - drop config cmd, use get/set cmd
      - tools/src/librw11
        - Rw11Rdma                    - PreExecCB() with nwdone and nwnext
        - Rw11UnitDisk                - add Nwrd2Nblk()
      - tools/src/librwxxtpp
        - RtclRw11CntlFactory         - add RL11 support
      - tools/bin
        - xise_ghdl_unisim            - handle also UNIMACRO lib
        - vbomconv                    - handle Vivado flows too

  - Bug fixes
    - tools/src/librw11
      - Rw11CntlRK11                  - revise RdmaPostExecCB() logic

  - Known issues
    - V0.64-7: ghdl simulated OS boots via ti_w11 (-n4 ect options) fail due to
        a flow control issue (likely since V0.63).
    - V0.64-6: IO delays still unconstraint in vivado. All critical IOs use
        explicitly IOB flops, thus timing well defined.
    - V0.64-5: w11a_tb_guide.txt covers only ISE based tests (see also V0.64-4).
    - V0.64-4: No support for the Vivado simulator (xsim) yet. With ghdl only
        functional simulations, post synthesis (_ssim) fails to compile.
    - V0.64-3: Highest baud rate with basys3 and nexys4 is 10 MBaud. 10 MBaud 
        is not supported according to FTDI, but works. 12 MBaud in next release.
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

- trunk (2015-01-04: svn rev 28(oc) 629(wfjm); untagged w11a_V0.63)  +++++++++

  - Summary
    - the w11a rbus interface used so far a narrow dynamically adjusted 
      rbus->ibus window. Replaces with a 4k word window for whole IO page.
    - utilize rlink protocol version 4 features in w11a backend
      - use attn notifies to dispatch attn handlers
      - use larger blocks (7*512 rather 1*512 bytes) for rdma transfers
      - use labo and merge csr updates with last block transfer
      - this combined reduces the number of round trips by a factor 2 to 3, 
        and in some cases the throughput accordingly.

  - Remarks on reference system
    - still using tcl 8.5 (even though 8.6 is now default in Ub 14.04)
    - don't use doxygen 1.8.8 and 1.8.9, it fails to generate vhdl docs

  - New features
    - new modules
      - tools/bin
        - ghdl_assert_filter      - filter to suppress startup warnings
        - tbrun_tbw               - wrapper for tbw based test benches
        - tbrun_tbwrri            - wrapper for ti_rri + tbw based test benches
      - tools/src/librw11
        - Rw11Rdma                - Rdma engine base class
        - Rw11RdmaDisk            - Rdma engine for disk emulation

  - Changes
    - rtl/vlib/rlink
      - rlink_core                - use 4th stat bit to signal rbus timeout
    - rtl/vlib/rbus
      - rbd_rbmon                 - reorganized, supports now 16 bit addresses
    - rtl/w11a
      - pdp11_core_rbus           - use full size 4k word ibus window
    - tools/bin/tbw               - add -fifo and -verbose options
    - tools/src/librtools
      - Rexception                - add ctor from RerrMsg
    - tools/src/librlink
      - RlinkCommandExpect        - rblk/wblk done counts now expectable
      - RlinkConnect              - cleanups and minor enhancements
      - RlinkServer               - use attn notifies to dispatch handlers
    - tools/src/librw11
      - Rw11CntlRK11              - re-organize, use now Rw11RdmaDisk
      - Rw11Cpu                   - add ibus address map
    - tools/src/librwxxtpp
      - RtclRw11CntlRK11          - add get/set for ChunkSize
      - RtclRw11Cpu               - add amap sub-command for ibus map access

  - Resolved known issues from V0.62
    - the rbus monitor (rbd_rbmon) has been updated to handle 16 bit addresses

  - Known issues
    - (V0.62): rlink v4 error recovery not yet implemented, will crash on error
    - (V0.62): command lists aren't split to fit in retransmit buffer size
      {both issues not relevant for w11 backend over USB usage because the
       backend produces proper command lists and the USB channel is error free}

- trunk (2014-12-20: svn rev 27(oc) 614(wfjm); untagged w11a_V0.62)  +++++++++

  - Summary
    - migrate to rlink protocol version 4
      - Goals for rlink v4
        - 16 bit addresses (instead of 8 bit)
        - more robust encoding, support for error recovery at transport level
        - add features to reduce round trips
          - improved attention handling
          - new 'list abort' command
      - For further details see README_Rlink_V4.txt
    - use own C++ based tcl shell tclshcpp instead of tclsh

    Notes:
      1. rlink protocol, core, and backend are updated in this release
      2. error recovery in backend not yet implemented
      3. the designs using rlink are still essentially unchanged
      4. the new rlink v4 features will be exploited in upcoming releases

  - New reference system
    The development and test system was upgraded from Kubuntu 12.04 to 14.04.
    The version of several key tools and libraries changed:
       linux kernel    3.13.0   (was  3.2.0) 
       gcc/g++         4.8.2    (was  4.6.3)
       boost           1.54     (was  1.46.1)
       libusb          1.0.17   (was  1.0.9)
       perl            5.18.2   (was  5.14.2)
       tcl             8.5.15   (was  8.5.11)
       sdcc            3.3.0    (was  2.9.0)
       doxygen         1.8.7    {installed from sources; Ub 14.04 has 1.8.6}

    Notes:
      1. still using tcl 8.5 (even though 8.6 is now default in Ub 14.04)
      2. sdcc 3.x is not source compatible with sdcc 2.9. The Makefile
         allows to use both, see tools/fx2/src/README.txt .
      3. don't use doxygen 1.8.8, it fails to generate vhdl docs

  - New features
    - new environment variables TCLLIB and TCLLIBNAME. TCLLIBNAME must be
      defined, and hold the library name matching the Tcl version already
      specified with TCLINC.
    - new modules
      - rtl/vlib/comlib/crc16     - 16 bit crc generator (replaces crc8)
      - tools/src/tclshcpp/*      - new tclshcpp shell

  - Changes
    - rtl/vlib/comlib
      - byte2cdata,cdata2byte     - re-write, commas now 2 byte sequences
    - rtl/vlib/rlink
      - rlink_core                - re-write for rlink v4
    - rtl/*/*                     - use new rlink v4 iface and 4 bit STAT
    - rtl/vlib/rbus/rbd*          - new addresses in 16 bit rlink space
    - rtl/vlib/simlib/simlib      - add simfifo_*, wait_*, writetrace
    - tools/bin/
      - fx2load_wrapper           - use _ic instead of _as as default firmware
      - ti_rri                    - use tclshcpp (C++ based) rather tclsh
    - tools/fx2/bin/*.ihx         - recompiled with sdcc 3.3.0 + bugfixes
    - tools/fx2/src/Makefile      - support sdcc 3.3.0
    - tools/src/
      - */*.cpp                   - adopt for rlink v4; use nullptr 
      - librlink/RlinkCrc16       - 16 crc, replaces RlinkCrc8
      - librlink/RlinkConnect     - many changes for rlink v4
      - librlink/RlinkPacketBuf*  - re-write for for rlink v4
    - tools/tcl/*/*.tcl           - adopt for rlink v4
    - renames:
      - tools/bin/telnet_starter  -> tools/bin/console_starter

  - Bug fixes
    - tools/fx2/src
      - dscr_gen.A51              - correct string 0 descriptor
      - lib/syncdelay.h           - handle triple nop now properly

  - Known issues
    - rlink v4 error recovery not yet implemented, will crash on error
    - command lists aren't split to fit in retransmit buffer size
      {both issues not relevant for w11 backend over USB usage because the
       backend produces proper command lists and the USB channel is error free}
    - the rbus monitor (rbd_rbmon) not yet handling 16 bit addresses and
      therefore of limited use

- trunk (2014-08-08: svn rev 25(oc) 579(wfjm); tagged w11a_V0.61)  +++++++++++

  - Summary
    - The div instruction gave wrong results in some corner cases when either
      divisor or quotient were the largest negative integer (100000 or -32768).
      This is corrected now, for details see ECO-026-div.txt
    - some minor updates and fixes to support scripts
    - xtwi usage and XTWI_PATH setup explained in INSTALL.txt

  - New features
    - the Makefile's for in all rtl building block directories allow now to
      configure the target board for a test synthesis via the XTW_BOARD
      environment variable or XTW_BOARD=<board name> make option.

  - Changes
    - tools/bin/asm-11            - add call and return opcodes
    - tools/bin/create_disk       - add RM02,RM05,RP04,RP07 support
    - tools/bin/tbw               - use xtwi to start ISim models
    - tools/bin/ticonv_pdpcp      - add --tout and --cmax; support .sdef
    - tools/dox/*.Doxyfile        - use now doxygen 1.8.7
    - tools/src/librw11
      - Rw11CntlRK11              - add statistics

  - Bug fixes
    - rtl/w11a                    - div bug ECO-026
      - pdp11_munit                 - port changes; fix divide logic
      - pdp11_sequencer             - s_opg_div_sr: check for late div_quit
      - pdp11_dpath                 - port changes for pdp11_munit
    - tools/bin/create_disk       - repair --boot option (was inaccessible)
    - tools/bin/ti_w11            - split args now into ti_w11 opts and cmds
    - tools/src/librwxxtpp
      - RtclRw11Cpu                 - redo estatdef logic; avoid LastExpect()
    - tools/dox/make_doxy         - create directories, fix 'to view use' text

- w11a_V0.6 (2014-06-06) +++++++++++++++++++++++++++++++++++++++++++++++++++++

  cummulative summary of key changes from w11a_V0.5 to w11a_V0.60
  - revised ibus protocol V2  (in w11a_V0.51)
  - revised rbus protocol V3  (in w11a_V0.52)
  - backend server rewritten in C++ and Tcl (in w11a_V0.53 and w11a_V0.562)
  - add Nexys3 port of w11a (in w11a_V0.54)
  - add Cypress FX2 support (in w11a_V0.56 and w11a_V0.57)
  - added LP11,PC11 support (in w11a_V0.58)
  - reference system now ISE 14.7 and Ubuntu 12.04 64 bit, ghdl 0.31
  - many code cleanups; use numeric_std
  - many documentation improvements
  - development status upgraded to beta (from alpha)

  for details see README-w11a_V.50-w11a_V0.60.txt

- w11a_V0.5 (2010-07-23) +++++++++++++++++++++++++++++++++++++++++++++++++++++

  Initial release with 
  - w11a CPU core
  - basic set of peripherals: kw11l, dl11, lp11, pc11, rk11/rk05
  - just for fun: iist (not fully implemented and tested yet)
  - two complete system configurations with 
    - for a Digilent S3board    rtl/sys_gen/w11a/s3board/sys_w11a_s3
    - for a Digilent Nexys2     rtl/sys_gen/w11a/nexys2/sys_w11a_n2
