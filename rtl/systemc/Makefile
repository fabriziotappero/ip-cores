TARGET_ARCH = linux

CC     = g++
OPT    = -O3
DEBUG  = -g
OTHER  = -Wall -Wno-deprecated
EXTRA_CFLAGS = $(OPT) $(OTHER)
# EXTRA_CFLAGS = $(DEBUG) $(OTHER)

MODULE = des
SRCS = s1.cpp s2.cpp s3.cpp s4.cpp s5.cpp s6.cpp s7.cpp s8.cpp key_gen.cpp round.cpp des.cpp stimulus.cpp main.cpp
OBJS = $(SRCS:.cpp=.o)

include Makefile.defs
