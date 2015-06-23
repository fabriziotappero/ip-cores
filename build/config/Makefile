-include build/Makefile.misc

targets		= mconf conf tkparse

conf_target 	 = conf.exe 
conf_files	 = conf.o zconf.tab.o
conf_hostcompile = y
conf_subdirs	 = 

tkparse_target 	    = tkparse.exe 
tkparse_files	    = tkcond.o tkgen.o tkparse.o
tkparse_tmpfiles    = $(CFGP)/Configs/xconfig.tk $(CFGP)/Configs/xconfig.tk.mid
tkparse_hostcompile = y
tkparse_subdirs	    = 

mconf_target 	  = mconf.exe 
mconf_files	  = mconf.o checklist.o menubox.o textbox.o yesno.o inputbox.o util.o msgbox.o zconf.tab.o 
mconf_hostcompile = y
mconf_subdirs	  = 

LIBS = -lncurses
ifeq (/usr/include/ncurses/ncurses.h, $(wildcard /usr/include/ncurses/ncurses.h))
	HOSTNCURSES += -I/usr/include/ncurses -DCURSES_LOC="<ncurses.h>"
else
ifeq (/usr/include/ncurses/curses.h, $(wildcard /usr/include/ncurses/curses.h))
	HOSTNCURSES += -I/usr/include/ncurses -DCURSES_LOC="<ncurses/curses.h>"
else
ifeq (/usr/local/include/ncurses/ncurses.h, $(wildcard /usr/local/include/ncurses/ncurses.h))
	HOSTCFLAGS += -I/usr/local/include/ncurses -DCURSES_LOC="<ncurses.h>"
else
ifeq (/usr/local/include/ncurses/curses.h, $(wildcard /usr/local/include/ncurses/curses.h))
	HOSTCFLAGS += -I/usr/local/include/ncurses -DCURSES_LOC="<ncurses/curses.h>"
else
ifeq (/usr/include/ncurses.h, $(wildcard /usr/include/ncurses.h))
	HOSTNCURSES += -DCURSES_LOC="<ncurses.h>"
else
	HOSTNCURSES += -DCURSES_LOC="<curses.h>"
endif
endif
endif
endif
endif

LOCAL_CFLAGS		+=  $(HOSTNCURSES)
LDFLAGS_mconf.exe	 =  -lncurses


###
# The following requires flex/bison
# By default we use the _shipped versions, uncomment the 
# following line if you are modifying the flex/bison src.

#LKC_GENPARSER := 1


ifdef LKC_GENPARSER

%.tab.c %.tab.h: %.y
	bison -t -d -v -b $* -p $(notdir $*) $<

lex.%.c: %.l
	flex -P$(notdir $*) -o$@ $<
else

lex.zconf.o: lex.zconf.c $(SHARED_DEPS)
	$(HOSTCC) $(HOSTCFLAGS) -I. -c $< -o $@

lex.zconf.c: lex.zconf.c_shipped
	cp lex.zconf.c_shipped lex.zconf.c

zconf.tab.o: zconf.tab.c lex.zconf.c confdata.c expr.c symbol.c menu.c $(SHARED_DEPS)
	$(HOSTCC) $(HOSTCFLAGS) -I. -c $< -o $@

zconf.tab.c: zconf.tab.c_shipped
	cp zconf.tab.c_shipped zconf.tab.c

zconf.tab.h: zconf.tab.h_shipped
	cp zconf.tab.h_shipped zconf.tab.h

endif


.PHONY: ncurses

ncurses:
	@echo "main() {}" > lxtemp.c
	@if $(HOSTCC) lxtemp.c $(LIBS) ; then \
		$(RM) lxtemp.c a.out; \
	else \
		$(RM) lxtemp.c; \
		echo -e "\007" ;\
		echo ">> Unable to find the Ncurses libraries." ;\
		echo ">>" ;\
		echo ">> You must have Ncurses installed in order" ;\
		echo ">> to use 'make menuconfig'" ;\
		echo ">>" ;\
		echo ">> Maybe you want to try 'make config', which" ;\
		echo ">> doesn't depend on the Ncurses libraries." ;\
		echo ;\
		exit 1 ;\
	fi







include build/Makefile.conf
include build/Makefile.defs

CFGP = build/config
EXE_FIX = $(if $(strip $(shell uname -o | sed -e 's/cygwin//gi')), ,.exe)
WISH_EXE_PATH = $(call pathsearch-return,wish$(EXE_FIX))
WISH_NOEXEPATH = $(call pathsearch-return,wish)
WISH_PATH =  $(if $(WISH_NOEXE_PATH), $(WISH_NOEXE_PATH), $(WISH_EXE_PATH))

config:
	@echo --------------------------------------------------------
	@echo Trying to build and run xconfig, menuconfig or oldconfig
	@echo If neather one will start. Then use:
	@echo \"make xconfig\" to try to build and run the tcl/tk graphical configurator. This requires tcl/tk to be installed
	@echo \"make menuconfig\" to try to build and run the ncurses configurator. This requires ncurses to be installed
	@echo \"make oldconfig\" to try to build and run the shell configurator
	@echo --------------------------------------------------------
	-$(MAKE) -f build/Makefile.c obj=build/config target=tkparse cmd=dobuild >/dev/null 2>&1
	-$(MAKE) -f build/Makefile.c obj=build/config target=mconf cmd=dobuild >/dev/null 2>&1
	-$(MAKE) -f build/Makefile.c obj=build/config target=conf cmd=dobuild >/dev/null 2>&1
	$(if $(strip $(wildcard $(WISH_PATH))), \
  $(CFGP)/tkparse.exe < $(CFGP)/Configs/xconfig.in > $(CFGP)/Configs/xconfig.tk.mid; \
  cat $(CFGP)/header.tk $(CFGP)/Configs/xconfig.tk.mid $(CFGP)/tail.tk >$(CFGP)/Configs/xconfig.tk; \
  $(WISH_PATH) $(CFGP)/Configs/xconfig.tk \
,$(if $(strip $(wildcard $(CFGP)/mconf.exe)), \
  @echo Could not start xconfig. \
  Switching to menuconfig instead;$(CFGP)/mconf.exe $(CFGP)/Configs/Config.in \
,$(if $(strip $(wildcard $(CFGP)/conf.exe)), \
  @echo Could not start xconfig nor menuconfig. \
  Switching to oldconfig instead;$(CFGP)/conf.exe $(CFGP)/Configs/Config.in \
,echo Neather tkconfig, menuconfig or oldconfig could be build;exit 1)))
	$(MAKE) -f build/Makefile.switch obj=$(CFGP) .config.vhd

xconfig:
	$(MAKE) -f build/Makefile.c obj=$(CFGP) target=tkparse cmd=dobuild
	$(CFGP)/tkparse.exe < $(CFGP)/Configs/xconfig.in > $(CFGP)/Configs/xconfig.tk.mid; 
	cat $(CFGP)/header.tk $(CFGP)/Configs/xconfig.tk.mid $(CFGP)/tail.tk >$(CFGP)/Configs/xconfig.tk; 
	$(WISH_PATH) $(CFGP)/Configs/xconfig.tk 
	$(MAKE) -f build/Makefile.switch obj=$(CFGP) .config.vhd

menuconfig:
	$(MAKE) -f build/Makefile.c obj=$(CFGP) target=mconf cmd=dobuild
	$(CFGP)/mconf.exe $(CFGP)/Configs/Config.in
	$(MAKE) -f build/Makefile.switch obj=$(CFGP) .config.vhd

oldconfig:
	$(MAKE) -f build/Makefile.c obj=$(CFGP) target=conf cmd=dobuild
	$(CFGP)/conf.exe $(CFGP)/Configs/Config.in
	$(MAKE) -f build/Makefile.switch obj=$(CFGP) .config.vhd

CLEANFILES += $(CFGP)/Configs/xconfig.tk $(CFGP)/Configs/xconfig.tk.mid

.config.vhd : .config
	build/scanconfig.pl .config >.config.vhd
	touch .config.vhd
