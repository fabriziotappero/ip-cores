#-- common.mk - Makefile include common to all test and demo programs ----------
#
# This make include file should be included in a project makefile *after* the 
# project configuration variables have been defined. See the Dhrystone makefile 
# for an usage example.

#-- Toolchain executables ------------------------------------------------------

# FIXME only tested in Win32/Cygwin host. This may not work in a vanilla Win32.

AS = 
CC = SDCC
LD = SDCC
RM = rm
CP = cp

#-- Give default values to the compiler, linker and assembler flags ------------

ifndef LFLAGS
LFLAGS = -o $(OBJDIR)/
endif
ifndef CFLAGS 
CFLAGS = -o $(OBJDIR)/
endif
ifndef AFLAGS
AFLAGS = -c
endif


#-- A bit of 'make magic' to simplify the rules --------------------------------

# Add all the source directories to the VPATH... 
VPATH := $(dir $(SRC))
# ...and build the OBJS list from the list of sources
OBJS := $(patsubst %.c, $(OBJDIR)/%.rel, $(notdir $(SRC)))


#-- Targets & rules ------------------------------------------------------------

# Compile C sources into relocatable object files
$(OBJDIR)/%.rel : %.c
	@echo Compiling $< ...
	$(CC) $(CFLAGS) -c $<

# Build executable file and move it to the bin directory
$(BINDIR)/$(BIN): $(OBJS)
	@echo Building executable file $@ ...
	$(LD) $(OBJS) $(LFLAGS)
	$(CP) $(OBJDIR)/*.ihx $(BINDIR)/$(BIN)

# Root target
all: $(BINDIR)/$(BIN) package
	@echo Done


#-- Targets that build the synthesizable vhdl ----------------------------------

#-- Create VHDL package with object code and synthesis parameters
package: $(BINDIR)/$(BIN)
	@echo Building object code VHDL package...
	@python $(BRPATH)/src/build_rom.py \
		-f $(BINDIR)/$(BIN)  \
		-v $(BRPATH)/templates/obj_code_pkg_template.vhdl \
		--xcode $(XCODE_SIZE) --xdata $(XDATA_SIZE) -n $(PROJ_NAME) \
		-o $(VHDL_TB_PATH)/obj_code_pkg.vhdl

#-- And now the usual housekeeping stuff ---------------------------------------

.PHONY: clean

clean:
	-$(RM) $(OBJDIR)/*.* $(BINDIR)/*.* $(VHDL_TB_PATH)/obj_code_pkg.vhdl
