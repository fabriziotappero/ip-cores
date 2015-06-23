
CC		= gcc
CFLAGS		= -c -Wall -O3
LDFLAGS		= -O3

###INCLUDES	= `gtk-config --cflags`
###LIBS		= `gtk-config --libs`
INCLUDES	=
LIBS		=

OBJS1		= ram_write.o
OBJS2		= ram_read.o
OBJS3		= ram_boot.o
OBJS4		= ram_test.o

TARGET1		= ram_write
TARGET2		= ram_read
TARGET3		= ram_boot
TARGET4		= ram_test

#
# /dev/ttyS0(com1) is pc-rs232c-port
# /dev/ttyS1(com2)
# /dev/ttyS2(com3) is ftdi_usb_serial
#

#DEV_FILE	= /dev/ttyS0
#DEV_FILE	= /dev/ttyS1
DEV_FILE	= /dev/ttyS2

#COM_PORT	= com1
#COM_PORT	= com2
COM_PORT	= com3

COM_BAUD	= 9600
#COM_BAUD	= 19200
#COM_BAUD	= 38400

#cat ./0xff.bin | ./ram_write $(DEV_FILE) 0x03400000 0x00000100
#cat ./boot_uart.or32.bin | ./ram_write $(DEV_FILE) 0x02000000 0x01000000
#cat ./0x0000ffff.bin | od -A x -t x1 -v 

#./ram_read $(DEV_FILE) 0x00000000 0x00000100 | od -A x -t x1 -v 
#./ram_read $(DEV_FILE) 0x01000000 0x00000100 | od -A x -t x1 -v 
#./ram_read $(DEV_FILE) 0x02000000 0x00000080 | od -A x -t x1 -v 

all: clean $(TARGET1) $(TARGET2) $(TARGET3) $(TARGET4)

test: config $(TARGET4)
	./ram_test $(DEV_FILE) 0x02000000 0x00000010 | od -A x -t x1 -v 

write: config $(TARGET1)
	cat ./0xff.bin       | ./ram_write $(DEV_FILE) 0x03000000 0x00000004
	cat ./0x00.bin       | ./ram_write $(DEV_FILE) 0x03000010 0x00000004
	#cat ./0xff.bin       | ./ram_write $(DEV_FILE) 0x02810000 0x00000004
	#cat ./0xff.bin       | ./ram_write $(DEV_FILE) 0x02820000 0x00000004
	#cat ./0x00.bin       | ./ram_write $(DEV_FILE) 0x03800000 0x00000004
	#cat ./0x00.bin       | ./ram_write $(DEV_FILE) 0x03810000 0x00000004
	#cat ./0x00.bin       | ./ram_write $(DEV_FILE) 0x03820000 0x00000004
	#cat ./0xff.bin       | ./ram_write $(DEV_FILE) 0x03800001 0x00000001
	#cat ./0x00.bin       | ./ram_write $(DEV_FILE) 0x03810000 0x00000001
	#cat ./0x00.bin       | ./ram_write $(DEV_FILE) 0x03820000 0x00000001
	
read: config $(TARGET2)
	./ram_read $(DEV_FILE) 0x02000000 0x00000020 | od -A x -t x1 -v 

boot: config $(TARGET3)
	./ram_boot 0x02000000

config:
	mode.com $(COM_PORT): BAUD=$(COM_BAUD) PARITY=e DATA=8 STOP=1

$(TARGET1): $(OBJS1)
	$(CC) $(LDFLAGS) $(OBJS1) $(LIBS) -o $(TARGET1)
$(TARGET2): $(OBJS2)
	$(CC) $(LDFLAGS) $(OBJS2) $(LIBS) -o $(TARGET2)
$(TARGET3): $(OBJS3)
	$(CC) $(LDFLAGS) $(OBJS3) $(LIBS) -o $(TARGET3)
$(TARGET4): $(OBJS4)
	$(CC) $(LDFLAGS) $(OBJS4) $(LIBS) -o $(TARGET4)

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) $<
clean:
	rm -f *.o *.exe $(TARGET1) $(TARGET2) $(TARGET3) $(TARGET4) *~ *.stackdump *.BAK
