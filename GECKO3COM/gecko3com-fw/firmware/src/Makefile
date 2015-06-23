# GECKO3COM
#
# Copyright (C) 2008 by
#   ___    ____  _   _
#  (  _`\ (  __)( ) ( )   
#  | (_) )| (_  | |_| |   Berne University of Applied Sciences
#  |  _ <'|  _) |  _  |   School of Engineering and
#  | (_) )| |   | | | |   Information Technology
#  (____/'(_)   (_) (_)
#
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

PACKAGE = gecko3com.hex

BOARD = GECKO3MAIN #currently the only supported board 

#DEBUG = --debug -DDEBUG_LEVEL_INFO
DEBUG =  

MEMOPTS = --code-loc 0x0000 --code-size 0x3A00 --xram-loc 0x3A00 --xram-size 0x0600 -Wl '-b USBDESCSEG = 0xE000'

ASFLAGS = -plosgff

CFLAGS = --opt-code-size --no-xinit-opt -mmcs51 --model-small $(MEMOPTS) $(DEBUG) -D$(BOARD)

LDFLAGS = --model-small $(MEMOPTS) $(DEBUG)

INCLUDE_DIR = ../include
LIB_DIR = ../lib
LIB = libfx2
GPIF_DIR = ../gpif-design
GPIF_DATA = gpif_data
BUILD_DIR = build
CC = sdcc

# the Hex2bix utility is included in the development software package 
# provided by Cypress. you can download it for free. 
# feel free to enhance the hex2bix.py python script from the GNUradio project
# to replace this wine & proprietary software hack. 
HEX2BIX = wine Hex2bix.exe -I -F 0xC2 -C 0×41 -R -M 0xe200 -V 0×0547 -P 0×0002 

SRCS_C =  eeprom_io.c		\
	  usb_tmc.c             \
	  scpi_parser.c		\
	  fpga_load.c		\
          spi_flash.c           \
	  $(GPIF_DATA).c	\
	  gecko3com_gpif.c	\
	  gecko3com_common.c	\
	  gecko3com_main.c	

SRCS_ASM = \
	vectors.a51		\
	_startup.a51		\
	usb_descriptors.a51

#SRCS_RE = \
#	scpi_parser.re



OBJS = $(SRCS_ASM:.a51=.rel) $(SRCS_C:.c=.rel) #$(SRCS_RE:.re=.rel)

all : $(LIB) $(GPIF_DIR) $(BUILD_DIR) $(PACKAGE)

iic : $(LIB) $(GPIF_DIR) $(BUILD_DIR) $(PACKAGE) $(PACKAGE:.hex=.iic)


$(BUILD_DIR) :
	mkdir $@

$(BUILD_DIR)/%.rel : %.c
	$(CC) -c $(CFLAGS) -I$(INCLUDE_DIR) -o $@ $<

$(BUILD_DIR)/%.rel : %.a51
	cp $< $(BUILD_DIR)/
	cd $(BUILD_DIR)
	asx8051 $(ASFLAGS) $(BUILD_DIR)/$<

$(LIB) : 
	cd $(LIB_DIR) && $(MAKE)


$(GPIF_DATA).c :
	$(MAKE) -C $(GPIF_DIR) $(BOARD) /
	cp $(GPIF_DIR)/gpif_data.* .


ls $(PACKAGE) : $(patsubst %,$(BUILD_DIR)/%,$(OBJS))
	$(CC) $(LDFLAGS) -o $@ -L$(LIB_DIR) -l $(LIB) $^

%.hex : %.ihx
	cp $< $@

%.iic : %.hex
	$(HEX2BIX) -o $@ $<
	cp $@ ../../

%.c   : %.re
	re2c -s -o $@ $<

clean :
	rm -f $(PACKAGE) $(BUILD_DIR)/* *.iic *.mem *.cdb *.map *.lnk gpif_data.*
	cd $(LIB_DIR) && $(MAKE) clean
	cd $(GPIF_DIR) && $(MAKE) clean


.PHONY : clean all





