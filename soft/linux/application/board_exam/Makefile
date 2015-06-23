
PHONY = clean
TARGET_NAME = pex_board_test

all: $(TARGET_NAME)

BINPATH  := ../..
BINDIR  := $(BINPATH)/bin
LIBPATH  := ../..
LIBDIR := $(LIBPATH)/lib

CC := $(CROSS_COMPILE)g++
LD := $(CROSS_COMPILE)g++

INCDIR := . \
 ../../driver/pexdrv \
 ../../common/board \
 ../../common/utils

INCLUDE := $(addprefix -I, $(INCDIR))

#CFLAGS := -D__linux__ -D__VERBOSE__ -g -Wall $(INCLUDE)
CFLAGS := -D__linux__ -O2 -Wall $(INCLUDE)
LFLAGS := -Wl,-rpath $(LIBDIR) -L"$(LIBDIR)" -lboard -ldl -lpthread

#EXTFILES := ../common/net/net_board.cpp
#EXTFILES := ../common/net/netcmn.cpp

$(TARGET_NAME): $(patsubst %.cpp,%.o, $(wildcard *.cpp)) $(EXTFILES)
	$(LD) -o $(TARGET_NAME) $(notdir $^) $(LFLAGS)
	cp $(TARGET_NAME) $(BINDIR)
	rm -f *.o *~ core

%.o: %.cpp
	$(CC) $(CFLAGS) -c -MD $<
	
include $(wildcard *.d)


test:
	@echo $(SRC)

clean:
	rm -f *.o *~ core
	rm -f *.d *~ core
	rm -f $(TARGET_NAME)
	
distclean:
	rm -f *.o *~ core
	rm -f *.d *~ core
	rm -f $(TARGET_NAME)
