#include <fstream>
using namespace std;

#include "systemc.h"
#include "downsample.h"

int sc_main(int argc, char* argv[])
{
	sc_clock 			CLK("CLK", 10, SC_NS);
	sc_signal<bool> 	CLR;
	sc_signal<double> 	samplesIN;
	sc_signal<double> 	sampleOUT;	
	sc_signal<bool> 	SCLK;
	
	downsample DUT("DUT");
	DUT.CLR(CLR);
	DUT.CLK(CLK);
	DUT.samplesIN(samplesIN);
	DUT.sampleOUT(sampleOUT);
	DUT.SCLK(SCLK);
	
	sc_trace_file *fp;
	fp = sc_create_vcd_trace_file("wave");
	fp -> set_time_unit(100, SC_PS);

	sc_trace(fp, CLR, "CLR");
	sc_trace(fp, CLK, "CLK");
	sc_trace(fp, SCLK, "SCLK");
	sc_trace(fp, samplesIN, "samplesIN");
	sc_trace(fp, sampleOUT, "sampleOUT");
	for (int i = 0; i < M; i++)
	{
		char str[3];
		sprintf(str, "(%0d)", i);
		sc_trace(fp, DUT.reg[i], "reg"+string(str));
	}

	CLR = true;
	samplesIN = 0;
	sc_start(73, SC_NS);
	
	CLR = false;
	samplesIN = 1;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 4;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 5;
	sc_start(10, SC_NS);	

	CLR = false;
	samplesIN = 10;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 32;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 17;
	sc_start(10, SC_NS);

	CLR = false;
	samplesIN = 19;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 84;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 51;
	sc_start(10, SC_NS);	

	CLR = false;
	samplesIN = 14;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 31;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 11;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 116;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 47;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 5653;
	sc_start(10, SC_NS);	

	CLR = false;
	samplesIN = 10;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 39;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 66;
	sc_start(10, SC_NS);

	CLR = false;
	samplesIN = 98;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 123;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 47;
	sc_start(10, SC_NS);	

	CLR = false;
	samplesIN = 25;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 56;
	sc_start(10, SC_NS);
	
	CLR = false;
	samplesIN = 78;
	sc_start(10, SC_NS);	
			
	sc_close_vcd_trace_file(fp);

	return 0;		
	
}
