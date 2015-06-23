#
# Makefile for "twotasks-2", a tiny OS which runs two tasks
# (with randomly written TLB entries and real page tables)
#

BUILD = ../../build

.PHONY:		all install run clean

all:		dump/dump task1/task1 task2/task2 os/twotasks-2.bin

install:	dump/dump task1/task1 task2/task2 os/twotasks-2.bin
		mkdir -p $(BUILD)/stdalone
		cp os/twotasks-2.bin $(BUILD)/stdalone
		cp os/twotasks-2.map $(BUILD)/stdalone
		cp os/twotasks-2.exo $(BUILD)/stdalone

run:		dump/dump task1/task1 task2/task2 os/twotasks-2.bin
		$(MAKE) -C os run

dump/dump:
		$(MAKE) -C dump

task1/task1:
		$(MAKE) -C task1

task2/task2:
		$(MAKE) -C task2

os/twotasks-2.bin:
		$(MAKE) -C os

clean:
		$(MAKE) -C dump clean
		$(MAKE) -C task1 clean
		$(MAKE) -C task2 clean
		$(MAKE) -C os clean
		rm -f *~
