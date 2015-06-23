# File to be included in all makefiles

ROOTDIR = ..

BACKEND_DIR := $(ROOTDIR)/../backend
SUPPORT_DIR := $(ROOTDIR)/support
DRIVERS_DIR := $(ROOTDIR)/drivers
UTILS_DIR := $(ROOTDIR)/utils

SUPPORT := $(SUPPORT_DIR)/libsupport.a
DRIVERS := $(DRIVERS_DIR)/libdrivers.a

LINKER_SCRIPT := $(BACKEND_DIR)/orp.ld

OR32_TOOL_PREFIX=or32-elf

BIN2HEX = $(UTILS_DIR)/bin2hex

ifdef UART_PRINTF
GCC_OPT += -DUART_PRINTF
endif
