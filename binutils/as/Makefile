#
# Makefile for ECO32 assembler
#

BUILD = ../../build

CC = gcc
CFLAGS = -g -Wall
LDFLAGS = -g
LDLIBS = -lm

SRCS = as.c
OBJS = $(patsubst %.c,%.o,$(SRCS))
BIN = as

.PHONY:		all install clean

all:		$(BIN)

install:	$(BIN)
		mkdir -p $(BUILD)/bin
		cp $(BIN) $(BUILD)/bin

$(BIN):		$(OBJS)
		$(CC) $(LDFLAGS) -o $(BIN) $(OBJS) $(LDLIBS)

%.o:		%.c
		$(CC) $(CFLAGS) -o $@ -c $<

depend.mak:
		$(CC) -MM -MG $(CFLAGS) $(SRCS) >depend.mak

-include depend.mak

clean:
		rm -f *~ $(OBJS) $(BIN) depend.mak
