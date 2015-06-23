include Makefile.inc

all: libsupport.a reset-nocache.o reset-ic.o reset-dc.o reset-icdc.o

libsupport.a: support.o int.o except.o uart.o vfnprintf.o
	$(OR32_TOOL_PREFIX)-ar cru libsupport.a support.o except.o int.o uart.o vfnprintf.o
	$(OR32_TOOL_PREFIX)-ranlib libsupport.a

support.o: support.c
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) -c -o $@ $?

reset-nocache.o: reset.S
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) -c -DIC=0 -DDC=0 -o $@ $?

reset-dc.o: reset.S
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) -c -DIC=0 -DDC=1 -o $@ $?

reset-ic.o: reset.S
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) -c -DIC=1 -DDC=0 -o $@ $?

reset-icdc.o: reset.S
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) -c -DIC=1 -DDC=1 -o $@ $?

except.o: except.S
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) -c -o $@ $?

uart.o: uart.c
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) -c -o $@ $?

#snprintf.o: snprintf.c
#	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) -O2 -c -o $@ $?

vfnprintf.o: vfnprintf.c
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) -c -o $@ $?

int.o: int.c
	$(OR32_TOOL_PREFIX)-gcc $(GCC_OPT) -c -o $@ $?
