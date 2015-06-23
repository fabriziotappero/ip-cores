# $Id: README.txt 604 2014-11-16 22:33:09Z mueller $
#

The FX2 software is based on the Sourceforge project ixo-jtag

  http://sourceforge.net/projects/ixo-jtag/

The usb_jtag sub project was checked out on 2011-07-17 (Rev 204) from 
Sourceforge and take as the basis for the further developement.
The original README.txt is preserved under README_iso_jtag.txt.
Only the hw_nexys.c branch is kept on the import.

Change log:

2014-11-16 (Rev 604)
  - ported to sdcc 3.3
    - all prior development was done with sdcc 2.x, latest sdcc 2.9 was bundled
      with Ubuntu 12.04 LTS.
    - now switching to sdcc 3.3 as bundled with Ubuntu 14.04 LTS.
    - mayor changes:
      1. assembler now named sdas8051 (was asx8051)
      2. all special reserved keywords start now with a double underscore
           at        --> __at
           bit       --> __bit
           interrupt --> __interrupt
           sbit      --> __sbit
           sfr       --> __sfr
           xdata     --> __xdata
           _asm      --> __asm
           _endasm   --> __endasm
           _naked    --> __naked
    - in general sources stayed untouched in the sdcc 2.9 form, all keyword
      mappings are done with the preprocessor and defs like "-Dat=__at"

    - make usage now
      - default is now sdcc 3.x, in this case simply use

           make clean && make

      - on systems with sdcc 2.x use

           make clean && make SDCC29=1

  - detected and fixed BUG inherted from ixo-jtag and GNU Radio in SYNCDELAY
    The macro SYNCDELAY (defined in lib/syncdelay.h) inserts 'nop' needed
    to resolve some timing issues in the FX2. The old implementation was

      #define SYNCDELAY _asm nop; nop; nop; _endasm
      #define NOP       _asm nop; _endasm

    This inserts into the assembler output a single line
       nop; nop; nop;
    Since ';' is the comment delimiter for the assember the 2nd and 3rd nop
    are simply ignored.

    This wrong implementation was changed to
      #define SYNCDELAY   NOP; NOP; NOP
    That created three lines in the assembler output
       nop;
       nop;
       nop;
    and generated the three desired nops in the binary.

    !! This was definitively broken from the very beginning.         !!
    !! The code ran alway. Reason is mosu likely that the SYNCDELAY  !!
    !! macros were only used in the setup phase and never is a       !!
    !! really time critical context.                                 !!

2011-07-17 (Rev 395)
  - Makefile: reorganized to support multiple target/fifo configs
  - renames: 
      dscr.a51->dscr_jtag.a51
      hw_nexys.c->hw_nexys2.c
      usbjtag.c->main.c
  - dscr_jtag.a51
    - Use USB 2.0; New string values
    - use 512 byte for all high speed endpoints
  - dscr_jtag_2fifo.a51
    - dscr with EP4 as HOST->FPGA and EP6 as FPGA->HOST hardware fifo
