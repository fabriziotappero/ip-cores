#Makefile Mips R2000 developed by Igor Loi
#v 1.0 2004/12/05 21:42 Diee Cagliari
# Thanks to Nicolai Ascanium from IMM

TARGET_ARCH = linux

CC     = g++
OPT    = -O3
DEBUG  = -g
OTHER  = -Wall
CFLAGS = $(OPT) $(OTHER)
# CFLAGS = $(DEBUG) $(OTHER)
MODULE = mips2
SRCS = embedded_perif/decoder.cpp embedded_perif/mux.cpp top.cpp \
	   cpu/pc_stage.cpp cpu/pc_stage/reg_pc.cpp \
	   \
	   cpu/if_stage.cpp cpu/if_stage/reg_if.cpp cpu/if_stage/add.cpp cpu/if_stage/select_next_pc.cpp \
	      cpu/if_stage/if_ctrl.cpp\
	   cpu/id_stage/mux_writeregister.cpp cpu/id_stage/sign_extend.cpp cpu/id_stage/add_new_pc.cpp \
	      cpu/id_stage/mux_forward_select.cpp cpu/id_stage/mux_jump.cpp cpu/id_stage/mux_alu1.cpp \
	      cpu/id_stage/mux_alu2.cpp cpu/id_stage/comparator.cpp cpu/id_stage/forwarding_control.cpp \
	      cpu/id_stage/reg_id.cpp cpu/id_stage/control.cpp cpu/id_stage/regfile_high.cpp \
	      cpu/id_stage/decode_ctrl.cpp cpu/id_stage.cpp \
	   cpu/ex_stage/alu.cpp cpu/ex_stage/multiply.cpp cpu/ex_stage/backwrite.cpp cpu/ex_stage/reg_ex.cpp \
	      cpu/ex_stage/mux_lo.cpp cpu/ex_stage/mux_hi.cpp cpu/ex_stage/mux_rd.cpp cpu/ex_stage/execute_ctrl.cpp \
	      cpu/ex_stage/fsm.cpp cpu/ex_stage.cpp \
	   cpu/mem_stage.cpp cpu/mem_stage/select_mem.cpp cpu/mem_stage/multiplexer_mem.cpp \
	      cpu/mem_stage/reg_mem.cpp cpu/mem_stage/memstage_ctrl.cpp cpu/mem_stage/mux_interrupt.cpp \
	      cpu/mem_stage/flag_interr.cpp\
	   cpu/cp0.cpp cpu/cp0/set_stop_pc.cpp cpu/cp0/exception.cpp cpu/cp0/cp0_register.cpp \
	   cpu/sc_cpu.cpp cpu/sc_risc.cpp  generators/reset_gen.cpp generators/timer.cpp cpu/enable_stage.cpp \
	      cpu/writeback_ctrl.cpp cpu/mux_instaddr.cpp cpu/or_gate.cpp\
	   memory/memory2.cpp \
	   main.cpp top_debug.cpp
	   
OBJS 	= $(SRCS:.cpp=.o)
DEPS	= $(SRCS:.cpp=.d)


%.o : %.cpp
	$(CC) $(INCDIR) $(LIBDIR) $(EXTRA) $(CFLAGS) -c -o $@ $<

%.d: %.cpp
	set -e; $(CC) -MM $(INCDIR) $(LIBDIR) $(CFLAGS) $(EXTRA) $< | sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@; \
	[ -s $@ ] || rm -f $@

%.o : %.cc
	$(CC) $(INCDIR) $(LIBDIR) $(EXTRA) $(CFLAGS) -c -o $@ $<

%.d: %.cc
	set -e; $(CC) -MM $(INCDIR) $(LIBDIR) $(CFLAGS) $(EXTRA) $< | sed 's/\($*\)\.o[ :]*/\1.o $@ : /g' > $@; \
	[ -s $@ ] || rm -f $@


$(MODULE): $(OBJS)
	$(CC) $(CFLAGS) $(INCDIR) $(LIBDIR) -o $@ $(OBJS) $(LIBS) 2>&1 | c++filt


include ./Makefile.defs
