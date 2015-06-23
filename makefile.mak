#
#	Module:			makefile
#
#					Copyright (C) Altera Corporation 1997-1999
#
#	Description:	Makefile for JAM Interpreter
#
#
#	Actel version 1.1             May 2003
#

OBJS = \
	jamstub.obj \
	jamexec.obj \
	jamnote.obj \
	jamcrc.obj \
	jamsym.obj \
	jamstack.obj \
	jamheap.obj \
	jamarray.obj \
	jamcomp.obj \
	jamjtag.obj \
	jamutil.obj \
	jamexp.obj

.c.obj :
	cl /W4 /c /ML /DWINNT $<

# LINK: add appropriate linker command here

jam.exe : $(OBJS)
	link $(OBJS) advapi32.lib /out:jam.exe

# Dependencies:

jamstub.obj : \
	jamstub.c \
	jamport.h \
	jamexprt.h

jamexec.obj : \
	jamexec.c \
	jamport.h \
	jamexprt.h \
	jamdefs.h \
	jamexec.h \
	jamutil.h \
	jamexp.h \
	jamsym.h \
	jamstack.h \
	jamheap.h \
	jamarray.h \
	jamjtag.h

jamnote.obj : \
	jamnote.c \
	jamexprt.h \
	jamdefs.h \
	jamexec.h \
	jamutil.h

jamcrc.obj : \
	jamcrc.c \
	jamexprt.h \
	jamdefs.h \
	jamexec.h \
	jamutil.h

jamsym.obj : \
	jamsym.c \
	jamexprt.h \
	jamdefs.h \
	jamsym.h \
	jamheap.h \
	jamutil.h

jamstack.obj : \
	jamstack.c \
	jamexprt.h \
	jamdefs.h \
	jamutil.h \
	jamsym.h \
	jamstack.h

jamheap.obj : \
	jamheap.c \
	jamport.h \
	jamexprt.h \
	jamdefs.h \
	jamsym.h \
	jamstack.h \
	jamheap.h \
	jamutil.h

jamarray.obj : \
	jamarray.c \
	jamexprt.h \
	jamdefs.h \
	jamexec.h \
	jamexp.h \
	jamsym.h \
	jamstack.h \
	jamheap.h \
	jamutil.h \
	jamcomp.h \
	jamarray.h

jamcomp.obj : \
	jamcomp.c \
	jamdefs.h \
	jamcomp.h

jamjtag.obj : \
	jamjtag.c \
	jamexprt.h \
	jamdefs.h \
	jamsym.h \
	jamutil.h \
	jamjtag.h

jamutil.obj : \
	jamutil.c \
	jamutil.h

jamexp.obj : \
	jamexp.c \
	jamexprt.h \
	jamdefs.h \
	jamexp.h \
	jamsym.h \
	jamheap.h \
	jamarray.h \
	jamutil.h \
	jamytab.h
