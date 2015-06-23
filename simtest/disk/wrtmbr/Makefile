#
# Makefile for a program which writes the master boot record to the disk
#

BUILD = ../../../build

CC = gcc
CFLAGS = -g -Wall
LDFLAGS = -g
LDLIBS = -lm

SRCS = wrtmbr.c
OBJS = $(patsubst %.c,%.o,$(SRCS))
BIN = wrtmbr

.PHONY:		all install clean

all:		$(BIN)

install:	$(BIN)
		mkdir -p $(BUILD)/simtest
		cp $(BIN) $(BUILD)/simtest

$(BIN):		$(OBJS)
		$(CC) $(LDFLAGS) -o $(BIN) $(OBJS) $(LDLIBS)

%.o:		%.c
		$(CC) $(CFLAGS) -o $@ -c $<

depend.mak:
		$(CC) -MM -MG $(CFLAGS) $(SRCS) >depend.mak

-include depend.mak

clean:
		rm -f *~ $(OBJS) $(BIN) depend.mak
