#
# Makefile for generating initialization statements
# for the display's character generator
#

BUILD = ../../build

.PHONY:		all install clean

all:		chrgenlo.init chrgenhi.init

install:	chrgenlo.init chrgenhi.init
		mkdir -p $(BUILD)/hw-dsp
		cp chrgenlo.init $(BUILD)/hw-dsp
		cp chrgenhi.init $(BUILD)/hw-dsp

chrgenlo.init:	mkinit
		./mkinit

chrgenhi.init:	mkinit
		./mkinit

mkinit:		mkinit.c font-8x16
		gcc -g -Wall -o mkinit mkinit.c

clean:
		rm -f *~ mkinit
		rm -f chrgenlo.init chrgenhi.init
