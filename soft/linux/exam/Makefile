#
#change this makefile for your target...
#

PHONY = clean
TARGET_NAME = pex_test

all: $(TARGET_NAME)

ROOT_DIR = $(shell pwd)

CC = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)g++

CFLAGS := -D__LINUX__ -g -Wall -I../driver/pexdrv -I../common/board -I../common/utils
LFLAGS = -Wl

$(TARGET_NAME): $(patsubst %.cpp,%.o, $(wildcard *.cpp))
	$(LD) -o $(TARGET_NAME) $(notdir $^) $(LFLAGS)
	rm -f *.o *~ core

%.o: %.cpp
	$(CC) $(CFLAGS) -c -MD $<
	
include $(wildcard *.d)


clean:
	rm -f *.o *~ core
	rm -f *.d *~ core
	rm -f $(TARGET_NAME)
	
distclean:
	rm -f *.o *~ core
	rm -f *.d *~ core
	rm -f $(TARGET_NAME)
