# Makefile for AVR code.
AS= avr-as
CC= avr-gcc
LD= avr-ld
OBJC= avr-objcopy
SIZE= avr-size
CFLAGS= -g -Wall -mmcu=avr6 -mmcu=atmega2560 -O0 -I. -Idev
LDFLAGS= -mavr6
OBJCFLAGS= -O ihex -R .eeprom
LIBS=
TARGET=devhandler
TESTTARGET=testbus
PROGTARGET=$(TARGET).hex

//UIP= uip/telnetd.c uip/uip.c uip/memb.c uip/shell.c uip/uip_arp.c uip/timer.c uip/clock-arch.c dev/enc28j60.c

# Device dependent modules
SRCS_DEV= bus.c dev/7seg.c dev/usart.c dev/mmc.c dev/kvga.c dev/boot.c dev/spi.c $(UIP)

# Avr program modules
SRCS= dispatch.c req.c buf.c encdec.c

DEVOBJS= $(SRCS_DEV:.c=.o)
OBJS= $(SRCS:.c=.o)

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
	
clean:
	rm -f $(OBJS) $(TARGET) $(TESTTARGET) $(PROGTARGET) $(DEVOBJS) $(TESTOBJS) 
