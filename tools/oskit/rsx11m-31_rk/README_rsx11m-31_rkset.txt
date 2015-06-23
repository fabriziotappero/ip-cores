# $Id: README_rsx11m-31_rkset.txt 680 2015-05-14 13:29:46Z mueller $

Notes on oskit: RSX-11M V3.1 system on RK05 volumes

  Table of content:

    1.  General remarks
    2.  Installation
    3.  Usage

1. General remarks ---------------------------------------------------

   See notes, especially on legal terms, in $RETROBASE/doc/w11a_os_guide.txt

   Also read README_license.txt which is included in the oskit !!

2. Installation ------------------------------------------------------

   - A disk set is available from
       http://www.retro11.de/data/oc_w11/oskits/rsx11m-31_rkset.tgz
     Download, unpack and copy the disk images (*.dsk), e.g.

       cd $RETROBASE/tools/oskit/rsx11m-31_rk
       wget http://www.retro11.de/data/oc_w11/oskits/rsx11m-31_rkset.tgz
       tar -xzf rsx11m-31_rkset.tgz

3. Usage -------------------------------------------------------------

   - Start them in simulator
       pdp11 rsx11m-31_rk_boot.scmd
     or ONLY IF YOU HAVE A VALID LICENSE on w11a
       ti_w11 <opt> @rsx11m-31_rk_boot.tcl
     where <opt> is the proper option set for the board.

   - Hit <ENTER> in the xterm window to connect to simh or backend server.
     The boot dialog in the console xterm window will look like
     (required input is in {..}, with {<CR>} denoting a carriage return:

         RSX-11M V3.1 BL22   65408K MAPPED
       >RED DK0:=SY0:
       >RED DK0:=LB0:
       >MOU DK0:SYSTEM0
       >@[1,2]STARTUP

     That RSX shows '65408K' is a bug in V3.1. It should be 1920K' the
     size of accessible memory in words. For configurations with 1 MByte
     and below the correct value is displayed, above a wrong one.

     This os version was released in December 1977, so it's no suprise
     that it is not y2k ready. So enter a date before prior to 2000.

       >* PLEASE ENTER TIME AND DATE (HR:MN DD-MMM-YY) [S]: {<.. see above ..>}
       >TIM 17:18 12-may-83
       >;
       >RUN ERRLOG
       >
       ;ERL -- ERROR LOG INITIALIZED
       >MOU DK1:SYSTEM1
       >;
       >INS DK1:[1,54]BIGMAC/PAR=GEN
       >INS DK1:[1,54]BIGTKB/PAR=GEN
       >INS DK1:[1,54]CDA
       >INS DK1:[1,54]DSC/PAR=GEN
       >INS DK1:[1,54]EDT/PAR=GEN
       >INS DK1:[1,54]FLX
       >INS DK1:[1,54]FOR
       >INS DK1:[1,54]FTB
       >INS DK1:[1,54]LBR
       >INS DK1:[1,54]PSE
       >INS DK1:[1,54]RNO
       >INS DK1:[1,54]SRD
       >INS DK1:[1,54]SYE
       >;
       >INS DK1:[1,54]TEC
       >INS DK1:[1,54]TEC/TASK=...MAK
       >INS DK1:[1,54]TEC/TASK=...MUN
       >;
       >INS DK1:[1,54]VTEC
       >;
       >;
       >SET /UIC=[1,6]
       >PSE =
       >SET /UIC=[200,200]
       >;
       >ACS DK1:/BLKS=512.
       >;
       >@ <EOF>
       >

     Now you are at the MCR prompt and can exercise the system.

     At the end is important to shutdown properly with a 'run $shutup'.
     The simululaor (or the rlink backend) can be stopped when the
     CPU has halted.
