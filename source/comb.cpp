#include "systemc.h"
#include "comb.h"

int sc_main(int argc, char* argv[])
{
	sc_clock 			CLK("CLK", 10, SC_NS);
	sc_signal<bool> 	CLR;
	sc_signal<double> 	combIN;
	sc_signal<double> 	combOUT;	
	sc_signal<double> 	internal;
	
	comb DUT0("DUT0");
	DUT0.CLR(CLR);
	DUT0.CLK(CLK);
	DUT0.combIN(combIN);
	DUT0.combOUT(internal);
	
	comb DUT1("DUT1");
	DUT1.CLR(CLR);
	DUT1.CLK(CLK);
	DUT1.combIN(internal);
	DUT1.combOUT(combOUT);	
	
	sc_trace_file *fp;
	fp = sc_create_vcd_trace_file("wave");
	fp -> set_time_unit(100, SC_PS);

	sc_trace(fp, CLR, "CLR");
	sc_trace(fp, CLK, "CLK");
	sc_trace(fp, combIN, "combIN");
	sc_trace(fp, internal, "internal");
	sc_trace(fp, combOUT, "combOUT");
	
	sc_trace(fp, DUT0.r, "r0");
	sc_trace(fp, DUT0.r_delay, "delay0");
	sc_trace(fp, DUT1.r, "r1");
	sc_trace(fp, DUT1.r_delay, "delay1");
	
	CLR = true;
	combIN = 0;
	sc_start(9, SC_NS);
	
	CLR = false;
	combIN = 1;
	sc_start(10, SC_NS);
	
	CLR = false;
	combIN = 4;
	sc_start(10, SC_NS);
	
	CLR = false;
	combIN = 10;
	sc_start(10, SC_NS);
	
	CLR = false;
	combIN = 20;
	sc_start(10, SC_NS);	
		
	CLR = false;
	combIN = 35;
	sc_start(10, SC_NS);
	
	CLR = false;
	combIN = 56;
	sc_start(10, SC_NS);
			
	sc_close_vcd_trace_file(fp);

	return 0;		
	
}

// g++ -I$SYSTEMC_HOME/include -L$SYSTEMC_HOME/lib-linux comb.cpp -lsystemc -lm -o comb.o

