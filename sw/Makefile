CC = gcc
OBJS = hight.o hight_unit_test.o hight_test.o main.o
TARGET = hight

.SUFFIXES : .c .o

all : $(TARGET)

$(TARGET) : $(OBJS)
	$(CC) -o $@ $(OBJS)

clean :
	rm -f $(OBJS) $(TARGET)

run :
	./$(TARGET) |tee run.log

rclean : 
	rm -f run.log


