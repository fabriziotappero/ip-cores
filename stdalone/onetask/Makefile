#
# Makefile for "onetask", a tiny OS which runs a single task
#

BUILD = ../../build

.PHONY:		all install run clean

all:		dump/dump task/task os/onetask.bin

install:	dump/dump task/task os/onetask.bin
		mkdir -p $(BUILD)/stdalone
		cp os/onetask.bin $(BUILD)/stdalone
		cp os/onetask.map $(BUILD)/stdalone
		cp os/onetask.exo $(BUILD)/stdalone

run:		dump/dump task/task os/onetask.bin
		$(MAKE) -C os run

dump/dump:
		$(MAKE) -C dump

task/task:
		$(MAKE) -C task

os/onetask.bin:
		$(MAKE) -C os

clean:
		$(MAKE) -C dump clean
		$(MAKE) -C task clean
		$(MAKE) -C os clean
		rm -f *~
