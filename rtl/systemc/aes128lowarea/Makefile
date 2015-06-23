TARGET_ARCH = linux

CC     = g++
OPT    = -O3
DEBUG  = -g
OTHER  = -Wall -Wno-deprecated
EXTRA_CFLAGS = $(OPT) $(OTHER)
# EXTRA_CFLAGS = $(DEBUG) $(OTHER)

MODULE = aes
SRCS = byte_mixcolum.cpp word_mixcolum.cpp keysched.cpp sbox.cpp mixcolum.cpp subbytes.cpp aes.cpp stimulus.cpp main.cpp
OBJS = $(SRCS:.cpp=.o)

include Makefile.defs
