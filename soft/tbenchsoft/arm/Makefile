#Konrad Eisele<eiselekd@web.de>,2004

-include build/Makefile.misc

CROSS = $(CROSSARM)

targets		= rom ram

rom_target 	= rom.exe 
rom_files	= romlocore.o test.o
rom_subdirs	= 
rom_predeps     = check-install $(obj)/linkrom.lds 
rom_postdeps    = armrom 
rom_tmpfiles    = $(obj)/../armrom.dis $(obj)/../armrom.dat $(obj)/linkrom.lds 

ram_target 	= ram.exe 
ram_files	= ramlocore.o test.o
ram_subdirs	= 
ram_predeps     = check-install $(obj)/linkram.lds 
ram_postdeps    = armram 
ram_tmpfiles    = $(obj)/../armram.dis $(obj)/../armram.dat $(obj)/linkram.lds $(obj)/../sdram.dat

LOCAL_CFLAGS = -mcpu=arm7tdmi

LDFLAGS_rom.exe = -g -N $(NOSTDLIB_FLAGS) -T $(obj)/linkrom.lds -e _hardreset 
LDFLAGS_ram.exe = -g -N $(NOSTDLIB_FLAGS) -T $(obj)/linkram.lds -e _hardreset 

cmd_link_lds = $(CURCPP) $(a_flags) -P -C -o $@ $<
$(obj)/linkrom.lds: $(obj)/linkrom.lds.S
	$(call if_changed_dep,link_lds)
$(obj)/linkram.lds: $(obj)/linkram.lds.S
	$(call if_changed_dep,link_lds)

armrom: $(obj)/../armrom.dat
$(obj)/../armrom.dat: $(obj)/rom.exe
	cp $(obj)/rom.exe $(obj)/.tmp.rom.exe
	$(CROSS)$(OBJCOPY) --remove-section=.comment $(obj)/.tmp.rom.exe
	$(CROSS)$(OBJDUMP) -s $(obj)/.tmp.rom.exe > $(obj)/../armrom.dat
	$(CROSS)$(OBJDUMP) -d $(obj)/.tmp.rom.exe > $(obj)/../armrom.dis
	$(CROSS)$(OBJSIZE) $(obj)/.tmp.rom.exe
	rm -f $(obj)/.tmp.rom.exe
	touch $(obj)/../sdram.dat

armram: $(obj)/../armram.dat
$(obj)/../armram.dat: $(obj)/ram.exe
	cp $(obj)/ram.exe $(obj)/.tmp.ram.exe
	$(CROSS)$(OBJCOPY) --remove-section=.comment $(obj)/.tmp.ram.exe
	$(CROSS)$(OBJDUMP) -s $(obj)/.tmp.ram.exe > $(obj)/../armram.dat
	$(CROSS)$(OBJDUMP) -d $(obj)/.tmp.ram.exe > $(obj)/../armram.dis
	$(CROSS)$(OBJSIZE) $(obj)/.tmp.ram.exe
	rm -f $(obj)/.tmp.ram.exe
	touch $(obj)/../sdram.dat

EXE_FIX = $(if $(strip $(shell uname -o | sed -e 's/cygwin//gi')), ,.exe)


check-install: 
	@echo Checking weather $(CROSS)$(GCC)$(EXE_FIX) is installed: 
	$(if $(strip $(call pathsearch-return,$(CROSS)$(GCC)$(EXE_FIX))),,cat $(obj)/install.txt;exit 1)


