# $Id: README_211bsd_rkset.txt 680 2015-05-14 13:29:46Z mueller $

Notes on oskit: 2.11BSD system on RK05 volumes

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
       http://www.retro11.de/data/oc_w11/oskits/211bsd_rkset.tgz
     Download, unpack and copy the disk images (*.dsk), e.g.

       cd $RETROBASE/tools/oskit/211bsd_rk/
       wget http://www.retro11.de/data/oc_w11/oskits/211bsd_rkset.tgz
       tar -xzf 211bsd_rkset.tgz

3. Usage -------------------------------------------------------------

   - Start backend server and boot system (see section 3 in w11a_os_guide.txt)
       boot script:  211bsd_rk_boot.tcl
       example:      ti_w11 <opt> @211bsd_rk_boot.tcl
                     where <opt> is the proper option set for the board.

   - Hit <ENTER> in the xterm window to connnect to backend server.
     The boot dialog in the console xterm window will look like
     (required input is in {..}, with {<CR>} denoting a carriage return:

       70Boot from rk(0,0,0) at 0177404
       : {<CR>}
       : rk(0,0,0)unix
       Boot: bootdev=03000 bootcsr=0177404
       
       2.11 BSD UNIX #26: Thu Jan 1 19:49:13 PST 2009
           root@curly.2bsd.com:/usr/src/sys/RETRONFPRK
       
       phys mem  = 3932160
       avail mem = 3577856
       user mem  = 307200
       
       January  4 16:45:33 init: configure system
       
       dz ? csr 160100 vector 310 skipped:  No CSR.
       lp 0 csr 177514 vector 200 attached
       rk 0 csr 177400 vector 220 attached
       rl 0 csr 174400 vector 160 attached
       tm 0 csr 172520 vector 224 attached
       xp 0 csr 176700 vector 254 attached
       cn 1 csr 176500 vector 300 attached
       erase, kill ^U, intr ^C

     In first '#' prompt the system is in single-user mode. Just enter a ^D 
     to continue the system startup to multi-user mode:

       #^D
       checking quotas: done.
       Assuming non-networking system ...
       checking for core dump... 
       preserving editor files
       clearing /tmp
       standard daemons: update cron accounting.
       starting lpd
       starting local daemons:Sun Jan  4 16:46:37 PST 2009
       January  4 16:46:37 init: kernel security level changed from 0 to 1
       January  4 16:46:40 getty: /dev/tty01: Device not configured
       ...
       
       2.11 BSD UNIX (curly.2bsd.com) (console)
       
       login: 

     The login prompt is sometimes mangled with the 'Device not configured'
     system messages, if its not visible just hit <ENTER> to get a fresh one.

       login: {root}
       erase, kill ^U, intr ^C

     Now the system is in multi-user mode, daemons runnng. You can explore
     the system, e.g. with a 'pstat -T' or a 'mount' command. The second
     xterm can be activated too, it will connect to a second emulated DL11.
     At the end is important to shutdown properly with a 'halt':

       # {pstat -T}
         7/186 files
        39/208 inodes
        11/150 processes
         6/ 46 texts active,  28 used
         2/135 swapmap entries,  366 kB used, 2069 kB free, 2063 kB max
        33/150 coremap entries, 2960 kB free, 2867 kB max
         1/ 10  ub_map entries,   10    free,   10    max
       # {mount}
       /dev/rk0h on /
       /dev/rk2h on /tmp
       /dev/rk3h on /bin
       /dev/rk4h on /usr
       # {halt}
       syncing disks... done
       halting

     While the system was running the server process display the
       cpumon> 
     prompt. When the w11 has halted after 211bsd shutdown a message like

       CPU down attention
       Processor registers and status:
         PS: 030350 cm,pm=k,u s,p,t=0,7,0 NZVC=1000  rust: 01 HALTed
           R0: 177560  R1: 161322  R2: 053436  R3: 000010
           R4: 003000  R5: 147510  SP: 147466  PC: 000014
 
     will be visible. Now the server process can be stopped with ^D.
