KERNELDIR ?= /lib/modules/`uname -r`/build

PWD = $(shell pwd)
KBUILD_FLAGS = -C $(KERNELDIR) M=$(PWD) INSTALL_MOD_PATH=$(INSTALL_MOD_PATH)

%:
	$(MAKE) $(KBUILD_FLAGS) $@

.DEFAULT_GOAL = modules
