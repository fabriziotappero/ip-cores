# Makefile for AVR code.
MCU= atmega2560
AS= avr-as
CC= avr-gcc
LD= avr-ld
OBJC= avr-objcopy
SIZE= avr-size
CFLAGS= -g -Wall -mmcu=avr6 -mmcu=$(MCU) -Os -mcall-prologues -I. -Idev
LDFLAGS= -mavr6
OBJCFLAGS= -O ihex -R .eeprom
LIBS=
TARGET=devhandler
TESTTARGET=testbus
PROGTARGET=$(TARGET).hex
AVRDUDE_PORT= /dev/ttyUSB0
AVRDUDE_PROGRAMMER= stk500v2

UIP= uip/telnetd.c uip/uip.c uip/memb.c uip/shell.c uip/uip_arp.c uip/timer.c uip/clock-arch.c

# Device dependent modules
SRCS_DEV= bus.c dev/7seg.c dev/usart.c dev/spi.c dev/mmc.c dev/enc28j60.c $(UIP)

# Avr program modules
SRCS= dispatch.c req.c buf.c encdec.c

# Test modules 
SRCS_TEST=testbus.c

DEVOBJS= $(SRCS_DEV:.c=.o)
TESTOBJS= $(SRCS_TEST:.c=.o)
OBJS= $(SRCS:.c=.o)

APPS= telnetd

all: $(TARGET)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $@ $(SRCS) $(SRCS_DEV) $(LIBS) 
	$(SIZE) $(TARGET)
	$(OBJC) $(OBJCFLAGS) $(TARGET) $(PROGTARGET)
#$(TARGET): $(OBJS) $(DEVOBJS)
#	$(LD) $(LDFLAGS) $(OBJS) $(DEVOBJS) -o $@ $(LIBS)

#$(PROGTARGET): $(TARGET)
#	$(SIZE) $(TARGET)
#	$(OBJC) $(OBJCFLAGS) $< $@

program: $(TARGET).hex
	avrdude -p $(MCU) -P $(AVRDUDE_PORT) -c $(AVRDUDE_PROGRAMMER) -U flash:w:$(PROGTARGET)
	
clean:
	rm -f $(OBJS) $(TARGET) $(TESTTARGET) $(PROGTARGET) $(DEVOBJS) $(TESTOBJS) 
