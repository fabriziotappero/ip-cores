# $Id: README_rsx11mp-30_rpset.txt 680 2015-05-14 13:29:46Z mueller $

Notes on oskit: RSX-11Mplus V3.0 system on RP06 volumes

  Table of content:

    1.  General remarks
    2.  Installation
    3.  Usage

1. General remarks ---------------------------------------------------

   See notes, especially on legal terms, in $RETROBASE/doc/w11a_os_guide.txt

   Also read README_license.txt which is included in the oskit !!

2. Installation ------------------------------------------------------

   - A disk set is available from
       http://www.retro11.de/data/oc_w11/oskits/rsx11mp-30_rpset.tgz
     Download, unpack and copy the disk images (*.dsk), e.g.

       cd $RETROBASE/tools/oskit/rsx11mp-30_rp
       wget http://www.retro11.de/data/oc_w11/oskits/rsx11mp-30_rpset.tgz
       tar -xzf rsx11mp-30_rpset.tgz

3. Usage -------------------------------------------------------------

   - Start them in simulator
       pdp11 rsx11mp-30_rp_boot.scmd
     or ONLY IF YOU HAVE A VALID LICENSE on w11a
       ti_w11 <opt> @rsx11mp-30_rp_boot.tcl
     where <opt> is the proper option set for the board.

   - Hit <ENTER> in the xterm window to connect to simh or backend server.
     The boot dialog in the console xterm window will look like
     (required input is in {..}, with {<CR>} denoting a carriage return:

       RSX-11M-PLUS V3.0  BL24   1920.KW  System:"RSXMPL"
       >RED DB:=SY:
       >RED DB:=LB:
       >RED DB:=SP:
       >MOU DB:"RSX11MPBL24"
       >@DB:[1,2]STARTUP
       >; ... some comments ...

     This os version was released in July 1985, so it's no suprise
     that it is not y2k ready. So enter a date before prior to 2000.

       >* Please enter time and date (HH:MM DD-MMM-YY) [S]: {<.. see above ..>}

       >TIME 12:42 14-MAY-95
       >ACS SY:/BLKS=1024.
       >CON ONLINE ALL
       >ELI /LOG/LIM
       >CLI /INIT=DCL/CTRLC
       >INS LB:[1,1]RMSRESAB.TSK/RON=YES/PAR=GEN
       >INS LB:[1,1]RMSLBL.TSK/RON=YES/PAR=GEN
       >INS LB:[1,1]RMSLBM.TSK/RON=YES/PAR=GEN
       >INS $QMGCLI
       >INS $QMGCLI/TASK=...PRI
       >INS $QMGCLI/TASK=...SUB
       >QUE /START:QMG
       >INS $QMGPRT/TASK=PRT.../SLV=NO
       >QUE LP0:/CR/NM
       >START/ACCOUNTING
       >CON ESTAT LP0:
       >QUE LP0:/SP/FL:2/LOWER/FO:0
       >QUE BAP0:/BATCH
       >QUE LP0:/AS:PRINT
       >QUE BAP0:/AS:BATCH
       >@ <EOF>
       >

     Now you are at the MCR prompt and can exercise the system.

     At the end it is important to shutdown properly with a 'run $shutup'.
     The simululaor (or the rlink backend) can be stopped when the
     CPU has halted.
