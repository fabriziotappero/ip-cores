PACKAGE = libfx2.lib

#DEBUG = --debug -DDEBUG_LEVEL_ERROR
DEBUG =

FEATURES = -DUSB_DFU_SUPPORT 
#FEATURES =

BUILD_DIR = build
INCLUDE_DIR = ../include
CC = sdcc

SRCS_C = \
	 i2c.c 		\
         delay.c 	\
         fx2utils.c 	\
         isr.c 		\
         timer.c 	\
         usb_common.c 	\
	 usb_dfu.c	\
	 ser.c
SRCS_ASM = \

ASFLGS = -plosgff

CFLAGS = --opt-code-size --no-xinit-opt -mmcs51 --model-small $(FEATURES) $(DEBUG)

INCLUDE_DIR = ../include
LIB_DIR = ../lib
LIB = libfx2
BUILD_DIR = build
CC = sdcc


OBJS = $(SRCS_C:.c=.rel) $(SRCS_ASM:.asm=.rel)

all : $(BUILD_DIR) $(PACKAGE)

$(BUILD_DIR) :
	mkdir $@

$(BUILD_DIR)/%.rel : %.c
	$(CC) -c $(CFLAGS) -I$(INCLUDE_DIR) -o $@ $<

$(BUILD_DIR)/%.rel : %.asm
	cp $< $(BUILD_DIR)/; \
	cd $(BUILD_DIR); \
	asx8051 $(ASFLGS) $(BUILD_DIR)/$<

$(PACKAGE) : $(patsubst %,$(BUILD_DIR)/%,$(OBJS))
	for obj in $^; do sdcclib $@ $$obj; done


clean :
	rm -f $(PACKAGE) $(BUILD_DIR)/*

run : all

.PHONY : clean all
