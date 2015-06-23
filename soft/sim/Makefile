# use "--enable-targets=all --enable-commonbfdlib=yes" to build binutils

BINUTILS = $(TOPDIR)/../binutils-2.14

targets		= sim

sim_target 	 = sim.exe 
sim_files	 = testcache.o   #load.o args.o io.o bucomm.o filemode.o
sim_hostcompile  = y
sim_subdirs	 = ti


LOCAL_CFLAGS += -I vhdl/mem/cache/c_model 

LDFLAGS_sim.exe	= vhdl/mem/cache/c_model/gencache.a vhdl/peripherals/mem/c_model/mctrl.a $(obj)/ti/ti.a


#LOCAL_CFLAGS	+= -I $(BINUTILS)/bfd -I $(BINUTILS)/libiberty -I $(BINUTILS)/include -I $(BINUTILS)/binutils
#$(BINUTILS)/opcodes/.libs/libopcodes.a $(BINUTILS)/bfd/.libs/libbfd.a $(BINUTILS)/libiberty/libiberty.a $(BINUTILS)/intl/libintl.a  $(obj)/ti/ti.a

sim:
	$(MAKE) -f build/Makefile.switch obj=soft/sim/ti cmd=dobuild 
	$(MAKE) -f build/Makefile.switch obj=vhdl cmd=dobuild 
	$(MAKE) -f build/Makefile.c obj=soft/sim target=sim cmd=dobuild 


