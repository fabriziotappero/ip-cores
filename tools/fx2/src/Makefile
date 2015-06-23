# $Id: Makefile 638 2015-01-25 22:01:38Z mueller $
#
# Copyright 2011-2015 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
# Code was forked from ixo-jtag.svn.sourceforge.net on 2011-07-17
#
# - original copyright and licence disclaimer --------------------------------
# - Copyright 2007 Kolja Waschk, ixo.de
# - This code is part of usbjtag. usbjtag is free software;
#-----------------------------------------------------------------------------
# 
# This program is free software; you may redistribute and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 2, or at your option any later version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# for complete details.
#-----------------------------------------------------------------------------
#
# Makefile for FX2 Firmware on Digilent Nexys2, Nexys3, and Atlys boards
#
#  Revision History: 
# Date         Rev Version  Comment
# 2015-01-25   638   2.1    retire _as versions (old async interface)
# 2014-11-16   604   2.0    add sdcc 3.x migration
# 2012-04-09   461   1.5.1  fixed nexys3_jtag_3fifo_ic.ihx rule,used _2fifo code
# 2012-02-11   457   1.5    re-organize VID/PID and descriptor handling
# 2012-01-02   448   1.4    add support for sync fifo w/ int. clock (_ic)
# 2011-12-29   446   1.3    add nexys3 support
# 2011-07-23   397   1.2    add usb_fifo_init.c
# 2011-07-17   395   1.1    reorganized to support multiple target/fifo configs
# 2011-07-17   394   1.0    Initial version (from ixo-jtag/usb_jtag Rev 204)
#-----------------------------------------------------------------------------
#
# handle USB VID/PID
# - normaly given via the environment variables (as 4 digit hex number)
#     RETRO_FX2_VID
#     RETRO_FX2_PID
#
# - in the retro11 project the default is:
#     VID: 16c0  (VOTI)
#     PID: 03ef  (VOTI free for internal lab use 1007)
#
#   !! Important Note on Usage of this USB VID/PID !!
#   This VID/PID is owned by VOTI, a small dutch company. Usage is granted 
#   for 'internal lab use only' by VOTI under the conditions:
#     - the gadgets in which you use those PIDs do not leave your desk
#     - you won't complain to VOTI if you get in trouble with duplicate PIDs 
#       (for instance because someone else did not follow the previous rule).
#   See also http://www.voti.nl/pids/pidfaq.html
#
# Define default VID/PID -----------------------------------------------
#
ifndef RETRO_FX2_VID
RETRO_FX2_VID = 16c0
endif
ifndef RETRO_FX2_PID
RETRO_FX2_PID = 03ef
endif
#
DEFVIDPID=-DUSE_VID=0x${RETRO_FX2_VID} -DUSE_PID=0x${RETRO_FX2_PID}
#
# defs for sdcc 2.9 to 3.x transition handling -------------------------
#
include sdccdefs.mk
#
# compiler and assembler flags -----------------------------------------
#
LIBDIR=lib
LIB=libfx2.lib

CFLAGS+=-mmcs51 --no-xinit-opt -I${LIBDIR}
CFLAGS+=${CC29COMPOPT}

ASFLAGS+=-plosgff

LDFLAGS=--code-loc 0x0000 --code-size 0x1800
LDFLAGS+=--xram-loc 0x1800 --xram-size 0x0800
LDFLAGS+=-Wl '-b USBDESCSEG = 0xE100'
LDFLAGS+=-L ${LIBDIR}
#
# compile rules
#
%.rel : %.a51
	$(AS) $(ASFLAGS) $<

%.rel : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
#
# link rule
#
%.ihx :
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+
#
# primary target rules
#
ALLIHX  =nexys2_jtag.ihx
ALLIHX +=nexys2_jtag_2fifo_ic.ihx 
ALLIHX +=nexys2_jtag_3fifo_ic.ihx
ALLIHX +=nexys3_jtag.ihx
ALLIHX +=nexys3_jtag_2fifo_ic.ihx 
ALLIHX +=nexys3_jtag_3fifo_ic.ihx

.PHONY: all install

all: $(ALLIHX)

install: $(ALLIHX)
	cp -p $(ALLIHX) ../bin
#
# rules to create USB descriptor sources
#
CPPA51=cpp -P -x assembler-with-cpp

dscr_nexys2_jtag.a51 : dscr_gen.A51
	$(CPPA51) $(DEFVIDPID) -DUSE_NEXYS2 $< > $@
dscr_nexys2_jtag_2fifo_ic.a51 : dscr_gen.A51
	$(CPPA51) $(DEFVIDPID) -DUSE_NEXYS2 -DUSE_2FIFO -DUSE_IC $< > $@
dscr_nexys2_jtag_3fifo_ic.a51 : dscr_gen.A51
	$(CPPA51) $(DEFVIDPID) -DUSE_NEXYS2 -DUSE_3FIFO -DUSE_IC $< > $@

dscr_nexys3_jtag.a51 : dscr_gen.A51
	$(CPPA51) $(DEFVIDPID) -DUSE_NEXYS3 $< > $@
dscr_nexys3_jtag_2fifo_ic.a51 : dscr_gen.A51
	$(CPPA51) $(DEFVIDPID) -DUSE_NEXYS3 -DUSE_2FIFO -DUSE_IC $< > $@
dscr_nexys3_jtag_3fifo_ic.a51 : dscr_gen.A51
	$(CPPA51) $(DEFVIDPID) -DUSE_NEXYS3 -DUSE_3FIFO -DUSE_IC $< > $@
#
# rules to create usb_fifo_init variants
#
usb_fifo_init_jtag.rel : usb_fifo_init.c
	$(CC) -c $(CFLAGS)  $< -o $@
#
usb_fifo_init_jtag_2fifo_ic.rel : usb_fifo_init.c
	$(CC) -c $(CFLAGS) -DUSE_2FIFO -DUSE_IC30 $< -o $@
usb_fifo_init_jtag_3fifo_ic.rel : usb_fifo_init.c
	$(CC) -c $(CFLAGS) -DUSE_3FIFO -DUSE_IC30 $< -o $@
#
COM_REL=vectors.rel main.rel eeprom.rel startup.rel
#
I0_REL=usb_fifo_init_jtag.rel
#
IIC2_REL=usb_fifo_init_jtag_2fifo_ic.rel
IIC3_REL=usb_fifo_init_jtag_3fifo_ic.rel
#
N2_REL=hw_nexys2.rel
N3_REL=hw_nexys3.rel
#
LIB_REL=$(LIBDIR)/$(LIB)
#
# rules to compile all code
#
$(LIBDIR)/$(LIB) :
	make -C $(LIBDIR) $(MAKELIBOPT)

eeprom.rel : eeprom.c eeprom.h
main.rel : main.c hardware.h eeprom.h

$(N2_REL) : hw_nexys2.c hardware.h
$(N3_REL) : hw_nexys3.c hardware.h

#
# rules to build Nexys2 firmware images
#
nexys2_jtag.ihx :          $(COM_REL) dscr_nexys2_jtag.rel \
				$(N2_REL) $(I0_REL)   $(LIB_REL)
#
nexys2_jtag_2fifo_ic.ihx : $(COM_REL) dscr_nexys2_jtag_2fifo_ic.rel \
				$(N2_REL) $(IIC2_REL) $(LIB_REL)
nexys2_jtag_3fifo_ic.ihx : $(COM_REL) dscr_nexys2_jtag_3fifo_ic.rel \
				$(N2_REL) $(IIC3_REL) $(LIB_REL)
#
# rules to build Nexys3 firmware images
#
nexys3_jtag.ihx :          $(COM_REL) dscr_nexys3_jtag.rel \
				$(N3_REL) $(I0_REL)   $(LIB_REL)
#
nexys3_jtag_2fifo_ic.ihx : $(COM_REL) dscr_nexys3_jtag_2fifo_ic.rel \
				$(N3_REL) $(IIC2_REL) $(LIB_REL)
nexys3_jtag_3fifo_ic.ihx : $(COM_REL) dscr_nexys3_jtag_3fifo_ic.rel \
				$(N3_REL) $(IIC3_REL) $(LIB_REL)
#
# cleanup phony's
#
.PHONY : clean distclean

clean :
	make -C ${LIBDIR} clean
	rm -f *.lst *.asm *.lib *.sym *.rel *.mem *.map *.rst *.lnk *.lk
	rm -f dscr_*.a51

distclean : clean
	rm -f *.ihx


