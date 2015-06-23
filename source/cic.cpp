#include <fstream>
using namespace std;

#include "systemc.h"
#include "cic.h"

int sc_main(int argc, char* argv[])
{
	sc_clock 			CLK("CLK", 10, SC_NS);
	sc_signal<bool> 	CLR;
	sc_signal<double> 	cicIN;
	sc_signal<double> 	cicOUT;	
	
	cic DUT("DUT");
	DUT.CLR(CLR);
	DUT.CLK(CLK);
	DUT.cicIN(cicIN);
	DUT.cicOUT(cicOUT);     
	
	sc_trace_file *fp;
	fp = sc_create_vcd_trace_file("wave");
	fp -> set_time_unit(100, SC_PS);

	sc_trace(fp, CLR, "CLR");
	sc_trace(fp, CLK, "CLK");
	sc_trace(fp, cicIN, "cicIN");
	sc_trace(fp, cicOUT, "cicOUT");
	
    for(int i = 0; i < N; i++)
    {
        char str[3];
        sprintf(str, "(%0d)",i);
        sc_trace(fp, DUT.internalI[i],"I" + string(str));
    }
    for(int i = 0; i < N; i++)
    {
        char str[3];
        sprintf(str, "(%0d)",i);
        sc_trace(fp, DUT.internalC[i],"C" + string(str));
    }    
	
	CLR = true;
	cicIN = 0;
	sc_start(73, SC_NS);
	
	CLR = false;
	cicIN = 1;
	sc_start(390, SC_NS);
	
	/*CLR = false;
	cicIN = 2;
	sc_start(10, SC_NS);
	
	CLR = false;
	cicIN = 3;
	sc_start(10, SC_NS);
	
	CLR = false;
	cicIN = 4;
	sc_start(10, SC_NS);	*/	
	
	sc_close_vcd_trace_file(fp);

	return 0;		
	
}
