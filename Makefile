TOPDIR	:= $(CURDIR)
export TOPDIR

include build/Makefile.conf

subdir = build/config soft syn

all: armpctrl

dep:
	build/extract.pl vhdl/.dep vhdl >.Makefile.dep

clean: 
	rm -rf work tags
	for i in $(subdir) ; do $(MAKE) -f build/Makefile.clean obj=$$i cmd=doclean || exit 1; done

proper: clean
	find . -type f | grep "~$$\\|.o$$\\|.cmd$$\\|.bck$$" | xargs rm -f

config:
	-$(MAKE) -f build/Makefile.switch obj=build/config cmd=config

xconfig:
	-$(MAKE) -f build/Makefile.switch obj=build/config xconfig

menuconfig:
	-$(MAKE) -f build/Makefile.switch obj=build/config menuconfig

oldconfig:
	-$(MAKE) -f build/Makefile.switch obj=build/config oldconfig

vsim: tbench tsoft

sim:
	-$(MAKE) -f build/Makefile.switch obj=soft/sim sim

tsoft: 
	-$(MAKE) -f build/Makefile.switch obj=soft/tbenchsoft switchtarget



-include .Makefile.dep

