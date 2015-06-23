#include "systemc.h"
#include "ppd.h"
#include "stimuli.h"

int sc_main(int argc, char* argv[]) 
{
	sc_clock CLK("CLK", 10, SC_NS);
	sc_signal<bool> 	CLR;	
	sc_signal<double> 	ppdIN;
	sc_signal<double> 	ppdOUT;
	
	double h[N] = {0.0017,0.0073,0.0107,0.0151,0.0162,0.0128,0.0039,-0.0093,-0.0232,-0.0329,-0.0326,-0.0182,0.0115,0.0536,0.1013,0.1454,0.1765,0.1877,0.1765,0.1454,0.1013,0.0536,0.0115,-0.0182,-0.0326,-0.0329,-0.0232,-0.0093,0.0039,0.0128,0.0162,0.0151,0.0107,0.0073,0.0017,0.0};
	
	ppd DUT("DUT", h);
	DUT.RST(CLR);
	DUT.CLOCK(CLK);
	DUT.ppdIN(ppdIN);
	DUT.ppdOUT(ppdOUT);
	
	stimuli STIMULUS("STIMULUS");
	STIMULUS.CLR(CLR);
	STIMULUS.CLK(CLK);
	STIMULUS.firIN(ppdIN);
	
	sc_trace_file *fp;
	fp = sc_create_vcd_trace_file("wave");
	fp -> set_time_unit(100, SC_PS);

	sc_trace(fp, CLR, "CLR");
	sc_trace(fp, CLK, "CLK");
	sc_trace(fp, ppdIN, "ppdIN");
	sc_trace(fp, ppdOUT, "ppdOUT");
	sc_trace(fp, DUT.sum[0], "sum0");
	sc_trace(fp, DUT.sum[1], "sum1");
	sc_trace(fp, DUT.sum[2], "sum2");

	CLR = true;
	sc_start(73, SC_NS);
	
	CLR = false;
	sc_start(360, SC_NS);

	sc_close_vcd_trace_file(fp);

	return 0;	
}
