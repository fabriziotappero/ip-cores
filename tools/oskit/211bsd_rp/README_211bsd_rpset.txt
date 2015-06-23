# $Id: README_211bsd_rpset.txt 680 2015-05-14 13:29:46Z mueller $

Notes on oskit: 2.11BSD system on a RP06 volume

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
       http://www.retro11.de/data/oc_w11/oskits/211bsd_rpset.tgz
     Download, unpack and copy the disk images (*.dsk), e.g.

       cd $RETROBASE/tools/oskit/211bsd_rp/
       wget http://www.retro11.de/data/oc_w11/oskits/211bsd_rpset.tgz
       tar -xzf 211bsd_rpset.tgz

3. Usage -------------------------------------------------------------

   - Start backend server and boot system (see section 3 in w11a_os_guide.txt)
       boot script:  211bsd_rp_boot.tcl
       example:      ti_w11 <opt> @211bsd_rp_boot.tcl
                     where <opt> is the proper option set for the board.

   - Hit <ENTER> in the xterm window to connnect to backend server.
     The boot dialog in the console xterm window will look like
     (required input is in {..}, with {<CR>} denoting a carriage return:

       70Boot from xp(0,0,0) at 0176700
       : {<CR>}
       : xp(0,0,0)unix
       Boot: bootdev=05000 bootcsr=0176700

       2.11 BSD UNIX #9: Wed Dec 10 06:24:37 PST 2008
           root@curly.2bsd.com:/usr/src/sys/RETRONFPNW

       attaching lo0

       phys mem  = 3932160
       avail mem = 3461952
       user mem  = 307200

       January  3 23:00:35 init: configure system
       
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
       Fast boot ... skipping disk checks
       checking quotas: done.
       Assuming NETWORKING system ...
       ifconfig: ioctl (SIOCGIFFLAGS): no such interface
       add host curly.2bsd.com: gateway localhost.2bsd.com
       add net default: gateway 206.139.202.1: Network is unreachable
       starting system logger
       checking for core dump... 
       preserving editor files
       clearing /tmp
       standard daemons: update cron accounting.
       starting network daemons: inetd  printer.
       January  3 23:00:47 lpd[76]: /dev/ttyS5: No such file or directory
       starting local daemons:Sat Jan  3 23:00:47 PST 2009
       January  3 23:00:47 init: kernel security level changed from 0 to 1
       January  3 23:00:49 getty: /dev/tty04: Device not configured
       January  3 23:00:49 getty: /dev/tty03: Device not configured
       January  3 23:00:49 getty: /dev/tty00: Device not configured
       January  3 23:00:49 getty: /dev/tty01: Device not configured
       January  3 23:00:49 getty: /dev/tty02: Device not config

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
        40/208 inodes
        11/150 processes
         6/ 46 texts active,  31 used
         2/135 swapmap entries,  420 kB used, 2139 kB free, 2133 kB max
        34/150 coremap entries, 2906 kB free, 2818 kB max
         1/ 10  ub_map entries,   10    free,   10    max
       # {mount}
       /dev/xp0a on /
       /dev/xp0c on /usr
       # {halt}
       syncing disks... done
       halting

     While the system was running the server process display the
       cpumon> 
     prompt. When the w11 has halted after 211bsd shutdown a message like

       CPU down attention
       Processor registers and status:
       Processor registers and status:
         PS: 030350 cm,pm=k,u s,p,t=0,7,0 NZVC=1000  rust: 01 HALTed
         R0: 177560  R1: 010330  R2: 056172  R3: 000010
         R4: 005000  R5: 147510  SP: 147466  PC: 000014
 
     will be visible. Now the server process can be stopped with ^D.
