#
# Makefile for "twotasks-1", a tiny OS which runs two tasks
# (with fixed TLB entries and no page tables)
#

BUILD = ../../build

.PHONY:		all install run clean

all:		dump/dump task1/task1 task2/task2 os/twotasks-1.bin

install:	dump/dump task1/task1 task2/task2 os/twotasks-1.bin
		mkdir -p $(BUILD)/stdalone
		cp os/twotasks-1.bin $(BUILD)/stdalone
		cp os/twotasks-1.map $(BUILD)/stdalone
		cp os/twotasks-1.exo $(BUILD)/stdalone

run:		dump/dump task1/task1 task2/task2 os/twotasks-1.bin
		$(MAKE) -C os run

dump/dump:
		$(MAKE) -C dump

task1/task1:
		$(MAKE) -C task1

task2/task2:
		$(MAKE) -C task2

os/twotasks-1.bin:
		$(MAKE) -C os

clean:
		$(MAKE) -C dump clean
		$(MAKE) -C task1 clean
		$(MAKE) -C task2 clean
		$(MAKE) -C os clean
		rm -f *~
