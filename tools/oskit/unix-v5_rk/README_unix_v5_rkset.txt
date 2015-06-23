# $Id: README_unix_v5_rkset.txt 680 2015-05-14 13:29:46Z mueller $

Notes on oskit: Unix V5 system on RK05 volumes

  Table of content:

    1.  General remarks
    2.  Installation
    3.  Usage

1. General remarks ---------------------------------------------------

   See notes on

     1.  I/O emulation setup
     2.  FPGA Board setup
     3.  Rlink and Backend Server setup
     4.  Legal terms

   in $RETROBASE/doc/w11a_os_guide.txt

2. Installation ------------------------------------------------------

   - A disk set is available from
       http://www.retro11.de/data/oc_w11/oskits/unix_v5_rkset.tgz
     Download, unpack and copy the disk images (*.dsk), e.g.

       cd $RETROBASE/tools/oskit/unix-v5_rk
       wget http://www.retro11.de/data/oc_w11/oskits/unix_v5_rkset.tgz
       tar -xzf unix_v5_rkset.tgz

3. Usage -------------------------------------------------------------

   - Start backend server and boot system (see section 3 in w11a_os_guide.txt)
       boot script:  uv5_rk_boot.tcl
       example:      ti_w11 <opt> @uv5_rk_boot.tcl
                     where <opt> is the proper option set for the board.

   - Hit <ENTER> in the xterm window to connect to backend server.
     The boot dialog in the console xterm window will look like
     (required input is in {..}, with {<CR>} denoting a carriage return:

       @{unix}
       
       login: {root}

     Now you are at the shell prompt and can exercise the system, e.g.

       # {ls -al}
       total 62
       drwxr-xr-x  9 bin       160 Jan 29 16:14 .
       drwxr-xr-x  9 bin       160 Jan 29 16:14 ..
       drwxr-xr-x  2 bin       944 Nov 26 18:13 bin
       drwxr-xr-x  2 bin        80 Nov 26 18:13 dev
       drwxr-xr-x  2 bin       240 Mar 21 12:07 etc
       drwxr-xr-x  2 bin       224 Nov 26 18:13 lib
       drwxr-xr-x  2 bin        32 Nov 26 18:13 mnt
       drwxrwxrwx  2 bin        32 Nov 26 18:13 tmp
       -rwxrwxrwx  1 bin     25802 Mar 21 12:07 unix
       drwxr-xr-x 14 bin       224 Nov 26 18:13 usr

     There is no 'halt' or 'shutdown' command, just terminate the server
     session with a 
       tirri_exit
     command. The disks aren't cached, so no need to sync either.
