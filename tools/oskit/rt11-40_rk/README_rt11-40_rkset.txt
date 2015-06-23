# $Id: README_rt11-40_rkset.txt 680 2015-05-14 13:29:46Z mueller $

Notes on oskit: RT-11 V4.0 system on RK05 volumes

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

       cd $RETROBASE/tools/oskit/rt11-40_rk
       wget http://www.retro11.de/data/oc_w11/oskits/rt11-40_rkset.tgz
       tar -xzf rt11-40_rkset.tgz

3. Usage -------------------------------------------------------------

   - Start them in simulator
       pdp11 rt11-40_rk_boot.scmd
     or ONLY IF YOU HAVE A VALID LICENSE on w11a
       ti_w11 <opt> @rt11-40_rk_boot.tcl
     where <opt> is the proper option set for the board.

   - Hit <ENTER> in the xterm window to connect to simh or backend server.
     The boot dialog in the console xterm window will look like
     (required input is in {..}, with {<CR>} denoting a carriage return:

       RT-11SJ  V04.00C 
       
       .D 56=5015
       
       .TYPE V4USER.TXT
       Welcome to RT-11 Version 4. RT-11 V04 provides new hardware support
       and some major enhancements over Version 3B.
       
       Please use the HELP command;  it describes the new options in many
       of the utilities.
       
       If you are using a terminal that requires fill characters,
       modify location 56 with a Deposit command before proceeding with
       system installation. LA36 DECwriter II and VT52 DECscope terminals
       do NOT require such modification.
       
       .D 56=0
       
       .

     Now you are at the RT-11 prompt and can exercise the system.

     There is no 'halt' or 'shutdown' command, just terminate the 
     simulator or backend server session.
