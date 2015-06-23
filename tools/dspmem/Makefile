#
# Makefile for generating initialization statements
# for the display's screen memory
#

BUILD = ../../build

.PHONY:		all install clean

all:		dspatthi.init dspattlo.init dspchrhi.init dspchrlo.init

install:	dspatthi.init dspattlo.init dspchrhi.init dspchrlo.init
		mkdir -p $(BUILD)/hw-dsp
		cp dspatthi.init $(BUILD)/hw-dsp
		cp dspattlo.init $(BUILD)/hw-dsp
		cp dspchrhi.init $(BUILD)/hw-dsp
		cp dspchrlo.init $(BUILD)/hw-dsp

dspatthi.init:	mkinit
		./mkinit

dspattlo.init:	mkinit
		./mkinit

dspchrhi.init:	mkinit
		./mkinit

dspchrlo.init:	mkinit
		./mkinit

mkinit:		mkinit.c screen
		gcc -g -Wall -o mkinit mkinit.c

clean:
		rm -f *~ mkinit
		rm -f dspatthi.init dspattlo.init
		rm -f dspchrhi.init dspchrlo.init
