SYSTEMC=/opt/systemc
VERILATOR_ROOT=/usr/share/verilator
VERIDIR=obj_dir
INCLUDES=-I.. -I$(SYSTEMC)/include -I$(VERIDIR) -I$(VERILATOR_ROOT)/include -I$(SYSTEMPERL)
LINKOPT=-L$(SYSTEMC)/lib-linux -lsystemc -lm
DEFINES=-DDEBUG
OBJFILES=app_env_top.o it_cfg_driver.o it_cfg_monitor.o load_ihex.o \
$(VERIDIR)/Vlcfg.o \
$(VERIDIR)/Vlcfg__Syms.o \
$(VERIDIR)/Vlcfg__Trace.o \
$(VERIDIR)/Vlcfg__Trace__Slow.o \
verilated_vcd_sc.o verilated_vcd_c.o verilated.o Sp.o
OPT_FAST=-O2

CXX=g++ -g $(OPT_FAST) $(INCLUDES) $(DEFINES)

app_env_top: $(OBJFILES)
	$(CXX) $^ -o $@ $(LINKOPT)

verilated.o : $(VERILATOR_ROOT)/include/verilated.cpp
	$(CXX) -c $^

verilated_vcd_sc.o : $(VERILATOR_ROOT)/include/verilated_vcd_sc.cpp
	$(CXX) -c $^

verilated_vcd_c.o : $(VERILATOR_ROOT)/include/verilated_vcd_c.cpp
	$(CXX) -c $^

$(VERIDIR)/Vlcfg.o:
	make OPT_FAST="$(OPT_FAST)" -f Vlcfg.mk -C $(VERIDIR) Vlcfg.o

$(VERIDIR)/Vlcfg__Syms.o:
	make OPT_FAST="$(OPT_FAST)" -f Vlcfg.mk -C $(VERIDIR) Vlcfg__Syms.o

$(VERIDIR)/Vlcfg__Trace.o:
	make OPT_FAST="$(OPT_FAST)" -f Vlcfg.mk -C $(VERIDIR) Vlcfg__Trace.o

$(VERIDIR)/Vlcfg__Trace__Slow.o:
	make -f Vlcfg.mk -C $(VERIDIR) Vlcfg__Trace__Slow.o

Sp.o: $(SYSTEMPERL)/Sp.cpp
	$(CXX) -I$(SYSTEMPERL) -c $^

newcode:
	rm -f obj_dir/*.o

clean:
	rm -f *.o
	rm -f obj_dir/*.o

