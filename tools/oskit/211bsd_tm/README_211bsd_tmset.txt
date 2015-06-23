# $Id: README_211bsd_rpset.txt 680 2015-05-14 13:29:46Z mueller $

Notes on oskit: 2.11BSD system on a TM11 tape distribution kit

  Table of content:

    1.  General remarks
    2.  Installation
    3.  Usage
    4.  Install 211bsd from tape on a RP06 disk

1. General remarks ---------------------------------------------------

   See notes on

     1.  I/O emulation setup
     2.  FPGA Board setup
     3.  Rlink and Backend Server setup
     4.  Legal terms

   in $RETROBASE/doc/w11a_os_guide.txt

2. Installation ------------------------------------------------------

   - A tape set is available from
       http://www.retro11.de/data/oc_w11/oskits/211bsd_tmset.tgz
     Download, unpack and copy the tape images (*.tap), e.g.

       cd $RETROBASE/tools/oskit/211bsd_tm/
       wget http://www.retro11.de/data/oc_w11/oskits/211bsd_tmset.tgz
       tar -xzf 211bsd_tmset.tgz

3. Usage -------------------------------------------------------------

   - This is a tape distribution kit and tailoed to be installed on RP06 disks.
     So first step is to create a disk image which will hold the system

       create_disk --typ=rp06 --bad 211bsd_rp06.dsk

   - Start backend server and boot system (see section 3 in w11a_os_guide.txt)
       boot script:  211bsd_tm_boot.tcl
       example:      ti_w11 <opt> @211bsd_tm_boot.tcl
                     where <opt> is the proper option set for the board.

   - Hit <ENTER> in the xterm window to connnect to backend server.
     The boot dialog in the console xterm window will look like
     (required input is in {..}, with {<CR>} denoting a carriage return:

       70Boot from tm(0,0,0) at 0172522
       : 

     This prompt of the 'mtboot' monitor, from which the different steps of
     the installation procedure can be started.

4. Install 211bsd from tape on a RP06 disk ---------------------------

   The tape distribution contains 8 files

     file  #records  length  Contents
        0        73     512  tape boot (twice) and boot handler
        1        38    1024  standalone disklabel
        2        34    1024  standalone mkfs
        3        36    1024  standalone restor
        4        33    1024  standalone icheck
        5       501   10240  dump of root file system
        6      3516   10240  tar of adm bin crash ...
        7       903   10240  tar of sys include
        8      4168   10240  tar of remaining directories

   The installation will
   - partition the disk with disklabel
   - create the root file system with mkfs
   - re-store the root file system with restor
   - than boot 211bsd from disk into single user mode
   - write the boot block
   - create the /usr file system
   - load the /usr file with tar from tape (three steps)

4.1 Install 211bsd, tape phase ---------------------------------------
  
  The following shows the full dialogue, the input is after a '##' separator

70Boot from tm(0,0,0) at 0172522
:                                                                ## tm(0,1)
Boot: bootdev=0401 bootcsr=0172522
disklabel
Disk?                                                            ## xp(0,0)
'xp(0,0)' is unlabeled or the label is corrupt.
Proceed? [y/n]                                                   ## y
d(isplay) D(efault) m(odify) w(rite) q(uit)?                     ## m
modify
d(isplay) g(eometry) m(isc) p(artitions) q(uit)?                 ## p
modify partitions
d(isplay) n(umber) s(elect) q(uit)?                              ## n
Number of partitions (8 max) [1]?                                ## 3
modify partitions
d(isplay) n(umber) s(elect) q(uit)?                              ## s
a b c d e f g h q(uit)?                                          ## a
sizes and offsets may be given as sectors, cylinders
or cylinders plus sectors:  6200, 32c, 19c10s respectively
modify partition 'a'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## t
'a' fstype [2.11BSD]:                                            ## 2.11BSD
modify partition 'a'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## o
'a' offset [0]:                                                  ## 
modify partition 'a'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## s
'a' size [340670]:                                               ## 50c
modify partition 'a'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## q
modify partitions
d(isplay) n(umber) s(elect) q(uit)?                              ## s
a b c d e f g h q(uit)?                                          ## b
sizes and offsets may be given as sectors, cylinders
or cylinders plus sectors:  6200, 32c, 19c10s respectively
modify partition 'b'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## t
'b' fstype [unused]:                                             ## swap
modify partition 'b'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## o
'b' offset [0]:                                                  ## 50c
modify partition 'b'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## s
'b' size [0]:                                                    ## 15c
modify partition 'b'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## q
modify partitions
d(isplay) n(umber) s(elect) q(uit)?                              ## s
a b c d e f g h q(uit)?                                          ## c
sizes and offsets may be given as sectors, cylinders
or cylinders plus sectors:  6200, 32c, 19c10s respectively
modify partition 'c'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## t
'c' fstype [unused]:                                             ## 2.11BSD
modify partition 'c'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## o
'c' offset [0]:                                                  ## 65c
modify partition 'c'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## s
'c' size [0]:                                                    ## 749c
modify partition 'c'
d(isplay) z(ero) t(ype) o(ffset) s(ize) f(rag) F(size) q(uit)?   ## q
modify partitions
d(isplay) n(umber) s(elect) q(uit)?                              ## d

type: SMD
disk: SMD
label: DEFAULT
flags:
bytes/sector: 512
sectors/track: 22
tracks/cylinder: 19
sectors/cylinder: 418
cylinders: 815
rpm: 3600
drivedata: 1 0 0 0 0

3 partitions:
#        size   offset    fstype   [fsize bsize]
  a:    20900        0   2.11BSD     1024 1024      # (Cyl. 0 - 49)
  b:     6270    20900      swap                    # (Cyl. 50 - 64)
  c:   313082    27170   2.11BSD     1024 1024      # (Cyl. 65 - 813)

modify partitions
d(isplay) n(umber) s(elect) q(uit)?               ## q
modify
d(isplay) g(eometry) m(isc) p(artitions) q(uit)?  ## q
d(isplay) D(efault) m(odify) w(rite) q(uit)?      ## w
d(isplay) D(efault) m(odify) w(rite) q(uit)?      ## q

70Boot from tm(0,0,1) at 0172522
:                                       ## tm(0,2)
Boot: bootdev=0402 bootcsr=0172522
Mkfs
file system:                            ## xp(0,0)
file sys size [10450]:                  ##
bytes per inode [4096]:                 ##
interleaving factor (m; 2 default):     ##
interleaving modulus (n; 209 default):  ##
isize = 2608
m/n = 2 209
Exit called

70Boot from tm(0,0,2) at 0172522
:                                       ## tm(0,3)
Boot: bootdev=0403 bootcsr=0172522
Restor
Tape?                                   ## tm(0,5)
Disk?                                   ## xp(0,0)
Last chance before scribbling on disk.  ## <cr>
End of tape

70Boot from tm(0,0,3) at 0172522
:                                       ## xp(0,0)unix

4.2 Install 211bsd, disk phase ---------------------------------------

  The last command boots 211bsd form the just setup disk, which has now
  a root file system, but not yet a hardward boot block.
  '#' is now the shell prompt
  '!!' indicates comments
  indented lines show output

  Boot: bootdev=05000 bootcsr=0176700
  
  2.11 BSD UNIX #9: Wed Dec 10 06:24:37 PST 2008
      root@curly.2bsd.com:/usr/src/sys/RETRONFPNW
  
  attaching lo0
  
  phys mem  = 3932160
  avail mem = 3461952
  user mem  = 307200
  
  June  8 21:21:24 init: configure system
  
  dz ? csr 160100 vector 310 skipped:  No CSR.
  lp 0 csr 177514 vector 200 attached
  rk 0 csr 177400 vector 220 attached
  rl 0 csr 174400 vector 160 attached
  tm 0 csr 172520 vector 224 attached
  xp 0 csr 176700 vector 254 attached
  cn 1 csr 176500 vector 300 attached
  
  erase, kill ^U, intr ^C

!! make system bootable
# dd if=/mdec/hpuboot of=/dev/rxp0a count=1
  1+0 records in
  1+0 records out

!! create file system on partition c
# mkfs -s 156541 -i 4096 -m 2 -n 209 /dev/rxp0c
  isize = 39120
  m/n = 2 209

!! now load the /usr files

# mount /dev/xp0c /usr

# cd /usr
# mt rew
# mt fsf 6
# tar xpbf 20 /dev/rmt12
# sync

!! now load the /usr/src files
# mkdir /usr/src
# cd /usr/src
# mt -f /dev/rmt12 fsf
# tar xpbf 20 /dev/rmt12			
# sync
# mt -f /dev/rmt12 fsf
# tar xpbf 20 /dev/rmt12			
# cd /
# chmod 755 / /usr /usr/src /usr/src/sys
# sync
# df
  Filesystem  1K-blocks     Used    Avail Capacity  Mounted on
  root            10285     4503     5782    44%    /
  /dev/xp0c      154094    87043    67051    56%    /usr

4.3 test boot created sysyem -----------------------------------------

# halt

on ti_w11 prompt
  cpu0 boot rpa0

70Boot from xp(0,0,0) at 0176700
: ## <cr>

from now on like for README_211bsd_rpset.txt
