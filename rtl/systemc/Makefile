TARGET_ARCH = linux

CC     = g++
OPT    = -O3
DEBUG  = -g
OTHER  = -Wall -Wno-deprecated
EXTRA_CFLAGS = $(OPT) $(OTHER)
# EXTRA_CFLAGS = $(DEBUG) $(OTHER)

MODULE = md5
SRCS = md5.cpp stimulus.cpp main.cpp
OBJS = $(SRCS:.cpp=.o)

include Makefile.defs
