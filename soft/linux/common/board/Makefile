#
#change this makefile for your target...
#

BASENAME = libboard.so
SONAME   = $(BASENAME).0
LIBNAME  = $(BASENAME).0.0

ROOT_DIR := $(shell pwd)
LIBDIR  := ../../lib

SRC := $(wildcard *.cpp)
SOURCE := $(SRC)
OBJ_FILES := $(SOURCE:.cpp=.o)

all: $(LIBNAME)

CFLAGS += -I. -I../utils

$(LIBNAME): $(OBJ_FILES)
	$(LD) -g -shared -rdynamic -Wl,-soname,$(SONAME) \
	-o $(LIBNAME) $(notdir $(OBJ_FILES)) -ldl -lrt -lc -lpthread
	chmod 666 $(LIBNAME)
	ln -sf $(LIBNAME) $(SONAME)
	ln -sf $(SONAME) $(BASENAME)
	cp -vfa $(BASENAME) $(SONAME) $(LIBNAME) $(LIBDIR)
	rm *.o *.d

include ../Mk.Rules
