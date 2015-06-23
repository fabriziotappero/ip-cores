# $Id: README_rsx11m-40_rkset.txt 680 2015-05-14 13:29:46Z mueller $

Notes on oskit: RSX-11M V4.0 system on RK05 volumes

  Table of content:

    1.  General remarks
    2.  Installation
    3.  Usage

1. General remarks ---------------------------------------------------

   See notes, especially on legal terms, in $RETROBASE/doc/w11a_os_guide.txt

   Also read README_license.txt which is included in the oskit !!

2. Installation ------------------------------------------------------

   - A disk set is available from
       http://www.retro11.de/data/oc_w11/oskits/rsx11m-40_rkset.tgz
     Download, unpack and copy the disk images (*.dsk), e.g.

       cd $RETROBASE/tools/oskit/rsx11m-40_rk
       wget http://www.retro11.de/data/oc_w11/oskits/rsx11m-40_rkset.tgz
       tar -xzf rsx11m-40_rkset.tgz

3. Usage -------------------------------------------------------------

   - Start them in simulator
       pdp11 rsx11m-40_rk_boot.scmd
     or ONLY IF YOU HAVE A VALID LICENSE on w11a
       ti_w11 <opt> @rsx11m-40_rk_boot.tcl
     where <opt> is the proper option set for the board.

   - Hit <ENTER> in the xterm window to connect to simh or backend server.
     The boot dialog in the console xterm window will look like
     (required input is in {..}, with {<CR>} denoting a carriage return:

         RSX-11M V4.0 BL32   1920.K MAPPED
       >RED DK:=SY:
       >RED DK:=LB:
       >MOU DK:SYSM40RKV0
       >@DK:[1,2]STARTUP

     This os version was released in November 1981, so it's no suprise
     that it is not y2k ready. So enter a date before prior to 2000.

       >* PLEASE ENTER TIME AND DATE (HR:MN DD-MMM-YY) [S]: {<.. see above ..>}
       >TIM 18:17 12-may-83
       >* ENTER LINE WIDTH OF THIS TERMINAL [D D:132.]: {<CR>}
       >SET /BUF=TI:132.
       >ACS SY:/BLKS=512.
       >CLI /INIT=DCL/TASK=...DCL
       >;
       >; mount 2nd system disk
       >;
       >mou dk1:SYSM40RKV1/pub
       >;
       >; installing tasks from 2nd system disk
       >;
       >INS DK1:$BRU
       >INS DK1:$DMP
       >INS DK1:$DSC
       >INS DK1:$EDT
       >INS DK1:$FLX
       >INS DK1:$K11RSX/TASK=...KER
       >INS DK1:$LBR
       >INS DK1:$MAC
       >INS DK1:$RMD
       >INS DK1:$SLP
       >INS DK1:$SRD
       >INS DK1:$TEC
       >INS DK1:$TEC/TASK=...MAK
       >INS DK1:$TKB
       >INS DK1:$VFY
       >INS DK1:$VTEC
       >@ <EOF>
       >

     Now you are at the MCR prompt and can exercise the system.

     You can also login on the 2nd DL11, possible accounts are
       >hel 1,1             ; password root
       >hel 200,201         ; password test

     At the end it is important to shutdown properly with a 'run $shutup'.
     The simululaor (or the rlink backend) can be stopped when the
     CPU has halted.
