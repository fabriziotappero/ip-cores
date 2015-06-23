include ../support/Makefile.inc
include $(BACKEND_DIR)/gcc-opt.mk

#USER INPUT
SRCS = eth.c
OR32_TARGET = eth.hex
TARGET = 
TARGETLIB = 
MODEL = static  	#dynamic|static
VERSION = 0.1
MODE = debug		#release|debug

INCLUDEDIRS = $(SUPPORT_DIR) $(DRIVERS_DIR)
#libsystemc or systemc (system ignores lib at the beginning)
LIBNAMES = 
LIBDIRS = 
DEPENDDIR = ./depend


#CONFIGURATION
DEBUGPARAM = 
RELEASEPARAM = 

DEBUGFLAGS = -g -O0
RELEASEFLAGS = -O2 -fomit-frame-pointer

CFLAGS = -Wall
CC = or32-elf-gcc
AR = or32-elf-ar
RANLIB = or32-elf-ranlib

CFLAGS += $(GCC_OPT)


#MECHANICS
INCLUDESPATH = $(addprefix -I, $(INCLUDEDIRS))
LIBSPATH = $(addprefix -L, $(LIBDIRS))
LIBSLINKAGE = $(addprefix -l, $(subst lib, , $(LIBNAMES)) )
COMMA = ,
RPATH = $(addprefix -Wl$(COMMA)-R, $(LIBDIRS))

OBJS = $(addsuffix .o, $(basename $(SRCS)))
DEPS = $(addprefix $(DEPENDDIR)/, $(addsuffix .d, $(basename $(SRCS) ) ) )

STATICLIB = $(addprefix lib, $(addsuffix .a, $(TARGETLIB) ) )
DYNAMICLIB = $(addprefix lib, $(addsuffix .so, $(TARGETLIB) ) )
SONAME = $(addsuffix .$(VERSION), $(DYNAMICLIB))

ifeq (debug,$(findstring debug, $(MODE)))
CFLAGS += $(DEBUGFLAGS) $(addprefix -D, $(DEBUGPARAM))
else
CFLAGS += $(RELEASEFLAGS) $(addprefix -D, $(RELEASEPARAM))
endif

ifdef TARGETLIB
ifeq (dynamic,$(findstring dynamic, $(MODEL)))
TARGET = $(DYNAMICLIB)
CFLAGS += -fPIC
else
TARGET = $(STATICLIB)
endif
endif


#MAKEFILE RULES
all: $(TARGET) $(OR32_TARGET)

depend: $(DEPS)

docs: Doxyfile
	doxygen

distclean:
	make clean
	rm -rf $(DEPENDDIR) Doxygen


-include $(DEPS)


ifndef TARGETLIB
$(TARGET): $(OBJS)
	$(CC) $(LIBSPATH) $(RPATH) -o $@ $^ $(LIBSLINKAGE)
endif


$(STATICLIB): $(OBJS)
	$(AR) cru $@ $^
	$(RANLIB) $@

$(DYNAMICLIB): $(OBJS)
	$(CC) -shared -Wl,-soname,$(SONAME) -o $@ $^
	ln -fs $@ $(SONAME)


%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDESPATH) -c $< -o $@


$(DEPENDDIR)/%.d: %.c
	mkdir -p $(DEPENDDIR)
	$(CC) $(INCLUDESPATH) -MM -MF $@ $<


# DO NOT DELETE

STEM = $(subst .hex, , $(OR32_TARGET))
BINARY = $(addsuffix .bin, $(STEM) )
EXECUTABLE = $(addsuffix .or32, $(STEM) )

$(OR32_TARGET): $(BINARY)
	$(BIN2HEX) $? 1 -size_word > $@

$(BINARY): $(EXECUTABLE)
	$(OR32_TOOL_PREFIX)-objcopy -O binary $? $@

#except.o and reset.o should be already inside of $(SUPPORT) (libsupport.a) but for some reason the compiler ignores that fact
#(e.g. or32-elf-objdump -t libsupport.a shows it)
$(EXECUTABLE): $(OBJS) ../support/except.o ../support/reset.o $(SUPPORT) $(DRIVERS)
	$(CC) $(CFLAGS) $(GCC_LIB_OPTS) -T $(LINKER_SCRIPT) $^ -o $@

clean:
	rm -f *.o *~ $(TARGET) $(STATICLIB) $(DYNAMICLIB) $(SONAME) $(OR32_TARGET) $(BINARY) $(EXECUTABLE)

#EOF
