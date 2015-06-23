SYSTEMC=/opt/systemc
VERILATOR_ROOT=/usr/share/verilator
VERIDIR=../obj_dir
INCLUDES=-I$(SYSTEMC)/include -I$(VERIDIR) -I$(VERILATOR_ROOT)/include -I$(SYSTEMPERL)
LINKOPT=-L$(SYSTEMC)/lib-linux -lsystemc -lm
DEFINES=-DDEBUG
OBJFILES=sc_env_top.o env_memory.o tv_responder.o z80_decoder.o di_mux.o \
$(VERIDIR)/Vtv80s.o $(VERIDIR)/Vtv80s__Syms.o \
$(VERIDIR)/Vtv80s__Trace.o \
$(VERIDIR)/Vtv80s__Trace__Slow.o \
$(VERIDIR)/VT16450.o $(VERIDIR)/VT16450__Syms.o verilated.o verilated_vcd_c.o Sp.o
OPT_FAST=-O2

CXX=g++ -g $(OPT_FAST) $(INCLUDES) $(DEFINES)

all: sc_env_top

test: sc_env_top
	./sc_env_top

sc_env_top: $(OBJFILES)
	$(CXX) $^ -o $@ $(LINKOPT)

verilated.o : $(VERILATOR_ROOT)/include/verilated.cpp
	$(CXX) -c $^

verilated_vcd_sc.o : $(VERILATOR_ROOT)/include/verilated_vcd_sc.cpp
	$(CXX) -c $^

verilated_vcd_c.o : $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp
	$(CXX) -c $^

$(VERIDIR)/Vtv80s.o:
	make OPT_FAST="$(OPT_FAST)" -f $(VERIDIR)/Vtv80s.mk -C $(VERIDIR) Vtv80s.o
	#(cd $(VERIDIR); make -f Vtv80s.mk Vtv80s.o)

$(VERIDIR)/Vtv80s__Syms.o:
	make OPT_FAST="$(OPT_FAST)" -f $(VERIDIR)/Vtv80s.mk -C $(VERIDIR) Vtv80s__Syms.o
	#(cd $(VERIDIR); make -f Vtv80s.mk Vtv80s__Syms.o)

$(VERIDIR)/Vtv80s__Trace.o:
	(cd $(VERIDIR); make -f Vtv80s.mk Vtv80s__Trace.o)

$(VERIDIR)/Vtv80s__Trace__Slow.o:
	(cd $(VERIDIR); make -f Vtv80s.mk Vtv80s__Trace__Slow.o)

$(VERIDIR)/VT16450.o:
	make -C$(VERIDIR) -f VT16450.mk $(@F)

$(VERIDIR)/VT16450__Syms.o:
	make -C$(VERIDIR) -f VT16450.mk $(@F)

Sp.o: $(SYSTEMPERL)/Sp.cpp
	$(CXX) -I$(SYSTEMPERL) -c $^

clean:
	rm -f *.o
	rm -f ../obj_dir/*.o

