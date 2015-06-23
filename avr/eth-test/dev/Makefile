# Makefile for AVR Network devices.
AS= avr-as
CC= avr-gcc
LD= avr-ld

CFLAGS= -g -Wall -ffreestanding -mmcu=avr6 -mmcu=atmega2560 -O0 -I..
LDFLAGS=
LIBS=

SRCS= enc28j60.c

OBJS= $(SRCS:.c=.o)


.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

all: $(OBJS)
	
clean:
	rm -f $(OBJS)
