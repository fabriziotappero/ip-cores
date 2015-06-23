#
#change this makefile for your target...
#

BASENAME = libpex_board.so
SONAME   = $(BASENAME).0
LIBNAME  = $(BASENAME).0.0

ROOT_DIR := $(shell pwd)
LIBDIR  := ../../lib

CC := $(CROSS_COMPILE)g++
LD := $(CROSS_COMPILE)g++

INCDIR := . \
 ../../driver/pexdrv \
 ../board \
 ../utils \
 ../dma

INCLUDE := $(addprefix -I, $(INCDIR))

CFLAGS := -D__LINUX__ -O2 -Wall $(INCLUDE)
LFLAGS := -ldl -lrt -lpthread -lm

SRCFILE := $(wildcard *.cpp)
SRCFILE += $(wildcard ../board/*.cpp)
#SRCFILE += $(wildcard ../dma/*.cpp)
OBJFILE := $(patsubst %.cpp,%.o, $(SRCFILE))

all: $(LIBNAME)

$(LIBNAME): $(OBJFILE)
	$(LD) -shared -rdynamic -Wl,-soname,$(SONAME) \
	-o $(LIBNAME) $(notdir $(OBJFILE)) $(LFLAGS)
	chmod 666 $(LIBNAME)
	ln -sf $(LIBNAME) $(SONAME)
	ln -sf $(SONAME) $(BASENAME)
	cp -fa $(BASENAME) $(SONAME) $(LIBNAME) $(LIBDIR)
	rm *.o *.d

include ../Mk.Rules

src:
	echo $(SRCFILE)
