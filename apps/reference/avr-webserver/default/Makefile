###############################################################################
# Makefile for the project avrnet
###############################################################################

## General Flags
PROJECT = avrnet
MCU = atmega32
TARGET = avrnet.elf
CC = avr-gcc.exe

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -gdwarf-2     -DF_CPU=16000000UL -Os -fsigned-char
CFLAGS += -MD -MP -MT $(*F).o -MF dep/$(@F).d 

## Assembly specific flags
ASMFLAGS = $(COMMON)
ASMFLAGS += $(CFLAGS)
ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS +=  -Wl,-Map=avrnet.map


## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0 --no-change-warnings


## Objects that must be built in order to link
OBJECTS = enc28j60.o main.o http.o arp.o tcp.o ip.o ethernet.o icmp.o menu.o lcd.o adc.o udp.o 

## Objects explicitly added by the user
LINKONLYOBJECTS = 

## Build
all: $(TARGET) avrnet.hex avrnet.eep avrnet.lss size

## Compile
enc28j60.o: ../enc28j60.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

main.o: ../main.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

http.o: ../http.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

arp.o: ../arp.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

tcp.o: ../tcp.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

ip.o: ../ip.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

ethernet.o: ../ethernet.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

icmp.o: ../icmp.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

menu.o: ../menu.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

lcd.o: ../lcd.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

adc.o: ../adc.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

udp.o: ../udp.c
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

##Link
$(TARGET): $(OBJECTS)
	 $(CC) $(LDFLAGS) $(OBJECTS) $(LINKONLYOBJECTS) $(LIBDIRS) $(LIBS) -o $(TARGET)

%.hex: $(TARGET)
	avr-objcopy -O ihex $(HEX_FLASH_FLAGS)  $< $@

%.eep: $(TARGET)
	-avr-objcopy $(HEX_EEPROM_FLAGS) -O ihex $< $@ || exit 0

%.lss: $(TARGET)
	avr-objdump -h -S $< > $@

size: ${TARGET}
	@echo
	@avr-size -C --mcu=${MCU} ${TARGET}

## Clean target
.PHONY: clean
clean:
	-rm -rf $(OBJECTS) avrnet.elf dep/* avrnet.hex avrnet.eep avrnet.lss avrnet.map


## Other dependencies
-include $(shell mkdir dep 2>/dev/null) $(wildcard dep/*)

