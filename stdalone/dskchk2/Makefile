#
# Makefile for "dskchk2", a program to check the hard disk
#

BUILD = ../../build

DISK_IMG = disk.img
NUM_CHECKS = 5000

.PHONY:		all install run chk clean

all:		genimg chkimg
		$(MAKE) -C dskchk2 all

install:	genimg chkimg
		$(MAKE) -C dskchk2 install

run:		$(DISK_IMG)
		$(MAKE) -C dskchk2 run

chk:		chkimg $(DISK_IMG)
		./chkimg $(DISK_IMG) $(NUM_CHECKS)

chkimg:		chkimg.c
		gcc -Wall -o chkimg chkimg.c

$(DISK_IMG):	genimg
		./genimg $(DISK_IMG)

genimg:		genimg.c
		gcc -Wall -o genimg genimg.c

clean:
		$(MAKE) -C dskchk2 clean
		rm -f *~ genimg chkimg $(DISK_IMG)
