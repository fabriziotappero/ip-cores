
### native
#CC      = gcc
#CFLAGS  = -c -Wall
#LDFLAGS = 

### cygwin
CC      = gcc
CFLAGS  = -c -Wall -DWIN32 -mno-cygwin
LDFLAGS = -mno-cygwin

OBJS1	= bmp2c_rgb565.c bmp.o
OBJS2	= bmp2bmp_white_black.c bmp.o

TARGET1	= bmp2c_rgb565
TARGET2 = bmp2bmp_white_black

all: $(TARGET1) $(TARGET2)
	#
	# Input BMP file is ONLY 24bit-format!!!
	#
	cat oc_bnr1.bmp			| ./bmp2c_rgb565 image_oc_bnr1			>image_oc_bnr1.c
	cat oc_bnr1_half.bmp		| ./bmp2c_rgb565 image_oc_bnr1_half		>image_oc_bnr1_half.c
	cat tessera_logo.bmp		| ./bmp2c_rgb565 image_tessera_logo		>image_tessera_logo.c
	cat tessera_logo_half.bmp	| ./bmp2c_rgb565 image_tessera_logo_half	>image_tessera_logo_half.c
	cat red.bmp			| ./bmp2c_rgb565 image_red			>image_red.c
	cat green.bmp			| ./bmp2c_rgb565 image_green			>image_green.c
	cat blue.bmp			| ./bmp2c_rgb565 image_blue			>image_blue.c
	cat rose.bmp			| ./bmp2c_rgb565 image_rose			>image_rose.c

$(TARGET1): $(OBJS1)
	$(CC) $(LDFLAGS) -o $(TARGET1) $(OBJS1)
$(TARGET2): $(OBJS2)
	$(CC) $(LDFLAGS) -o $(TARGET2) $(OBJS2)
.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) $<
clean:
	rm -f *.o $(TARGET1) $(TARGET2) *~ *.stackdump *.exe *.BAK

