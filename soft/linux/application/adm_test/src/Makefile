#
#change this makefile for your target...
#

PHONY = clean
TARGET_NAME = adm_test

all: $(TARGET_NAME)

ROOT_DIR = $(shell pwd)

CC = $(CROSS_COMPILE)g++
LD = $(CROSS_COMPILE)g++

INCDIR := . \
 ../../../driver/pexdrv \
 ../../../common/board \
 ../../../common/pex \
 ../../../common/utils \
 ../../../common/dac \
 ../../../common/adc \
 ../../../common/dma \
 ../../../common/console
 
INCLUDE := $(addprefix -I, $(INCDIR))

CFLAGS := -D__LINUX__ -O2 -Wall $(INCLUDE)
LFLAGS := -Wl -ldl -lrt -lpthread -lm -lncurses

SRCFILE := $(wildcard *.cpp)
SRCFILE += $(wildcard ../../../common/board/*.cpp)
SRCFILE += $(wildcard ../../../common/pex/*.cpp)
SRCFILE += $(wildcard ../../../common/utils/*.cpp)
SRCFILE += $(wildcard ../../../common/console/*.cpp)
#SRCFILE += $(wildcard ../../../common/dma/*.cpp)
#SRCFILE += $(wildcard ../../../common/adc/*.cpp)
#SRCFILE += $(wildcard ../../../common/dac/*.cpp)
SRCFILE += $(wildcard ./work/*.cpp)
OBJFILE := $(patsubst %.cpp,%.o, $(SRCFILE))

$(TARGET_NAME): $(OBJFILE)
	$(LD) -o $(TARGET_NAME) $(notdir $^) $(LFLAGS)

#	rm -f *.o *.d *~ core
	mv $(TARGET_NAME) ../bin
	@echo DONE...

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

src:
	@echo $(SRCFILE)
	@echo $(OBJFILE)
