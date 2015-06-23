

CFLAGS+=  -g -ggdb -Wall
CXXFLAGS+=-g -ggdb -Wall
LDFLAGS=-lusb -lX11 -lstdc++

TARGET=csa_test

run:$(TARGET)
	if [[ ! -z "$(shell /sbin/lsmod | grep usbtest)" ]] ; then \
                /sbin/rmmod usbtest ;                        \
        fi
	if [[ -z "$(shell cat /proc/mounts | grep debugfs)" ]];  then                   \
               mount -t debugfs none_debugs /sys/kernel/debug;      \
        fi                                                          
	./$(TARGET)



clean:
	rm -fr *.o
	rm -fr $(TARGET)

SRCS=   csa.c      \
        imgdev.c   \
        simcsa.c   \
        test.c

OBJS=$(SRCS:.c=.o)

.depend:
	rm -fr .depend
	for f in $(SRCS);        \
        do                       \
                gcc -MM -M $$f>>.depend;       \
        done


csa_test:csa_test.o imgdev.o

include .depend


