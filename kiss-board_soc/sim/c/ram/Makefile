#
CC	 = gcc
CFLAGS	 = -c -Wall -O3
LDFLAGS	 = -O3
#
INCLUDES = `gtk-config --cflags`
LIBS	 = `gtk-config --libs`
#
OBJS	 = ram.o
#
TARGET  = ram

all: clean $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) $(LIBS) -o $(TARGET)
.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) $<
clean:
	rm -f *.o $(TARGET) *~ *.stackdump *.BAK

