#
# Makefile for arch/m68knommu/platform/ao68000.
#

head-y			= head-$(MODEL).o

obj-y			+= entry.o ints.o
#timers.o
obj-$(CONFIG_AO68000)	+= config.o

extra-y			:= head.o

$(obj)/head.o: $(obj)/$(head-y)
	ln -sf $(head-y) $(obj)/head.o

clean-files := $(obj)/head.o $(head-y)
