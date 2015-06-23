#include "systemc.h"
#include "integrator.h"

int sc_main(int argc, char* argv[])
{
	sc_clock 			CLK("CLK", 10, SC_NS);
	sc_signal<bool> 	CLR;
	sc_signal<double> 	integratorIN;
	sc_signal<double> 	internal;
	sc_signal<double> 	integratorOUT;	
	
	integrator DUT0("DUT0");
	DUT0.CLR(CLR);
	DUT0.CLK(CLK);
	DUT0.integratorIN(integratorIN);
	DUT0.integratorOUT(internal);
	
	integrator DUT1("DUT1");
	DUT1.CLR(CLR);
	DUT1.CLK(CLK);
	DUT1.integratorIN(internal);
	DUT1.integratorOUT(integratorOUT);	
	
	sc_trace_file *fp;
	fp = sc_create_vcd_trace_file("wave");
	fp -> set_time_unit(100, SC_PS);

	sc_trace(fp, CLR, "CLR");
	sc_trace(fp, CLK, "CLK");
	sc_trace(fp, integratorIN, "integratorIN");
	sc_trace(fp, internal, "internal");
	sc_trace(fp, integratorOUT, "integratorOUT");
	sc_trace(fp, DUT0.r_delay, "delay0");
	sc_trace(fp, DUT1.r_delay, "delay1");	
	
	CLR = true;
	integratorIN = 0;
	sc_start(73, SC_NS);
	
	CLR = false;
	integratorIN = 1;
	sc_start(150, SC_NS);
	
	CLR = false;
	integratorIN = 0;
	sc_start(40, SC_NS);
	
	CLR = false;
	integratorIN = 1;
	sc_start(40, SC_NS);	
	
	sc_close_vcd_trace_file(fp);

	return 0;		
}

// g++ -I$SYSTEMC_HOME/include -L$SYSTEMC_HOME/lib-linux integrator.cpp -lsystemc -lm -o int.o
