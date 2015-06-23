#include "systemc.h"
#include "IIR_TFI.h"
#include "Stimuli.h"

int sc_main(int argc, char* argv[])
{
	sc_clock 			CLOCK("CLOCK", 1, SC_US);
	sc_signal<bool> 	RST;
	sc_signal<float > 	iIIR;
	sc_signal<float > 	oIIR;
	
	float b[orderFF] = {0.0995,0.1486,0.1481,0.0999};
	float a[orderFB] = {0.9828,-0.5450,0.0671};
	const int Size = 16;
	
	IIR_TFI<float > DUT("DUT", b, a);
	DUT.CLR(RST);
	DUT.CLK(CLOCK);
	DUT.iIIR(iIIR);
	DUT.oIIR(oIIR);
	
	Stimuli<float > inputVector("Stimuli", Size);
    inputVector.clr(RST);
    inputVector.clk(CLOCK);
    inputVector.streamout(iIIR);
    
    cout << "FF Order \t" << orderFF << endl;
    cout << "FB Order \t" << orderFB << endl;
    
	sc_trace_file *fp;
	fp = sc_create_vcd_trace_file("wave");
	fp -> set_time_unit(100, SC_PS);

	sc_trace(fp, RST, "RST");
	sc_trace(fp, CLOCK, "CLOCK");
	sc_trace(fp, iIIR, "IP");
	sc_trace(fp, oIIR, "OP");
	
	sc_trace(fp, DUT.oMultiplierFF[0], "oMU_FF(0)");
	sc_trace(fp, DUT.oMultiplierFF[1], "oMU_FF(1)");
	sc_trace(fp, DUT.oMultiplierFF[2], "oMU_FF(2)");
	sc_trace(fp, DUT.oMultiplierFF[3], "oMU_FF(3)");
	
	sc_trace(fp, DUT.oAdderFF[0], "oAD_FF(0)");
	sc_trace(fp, DUT.oAdderFF[1], "oAD_FF(1)");
	sc_trace(fp, DUT.oAdderFF[2], "oAD_FF(2)");
	sc_trace(fp, DUT.oAdderFF[3], "oAD_FF(3)");	
	
	sc_trace(fp, DUT.oDelayFF[0], "oDL_FF(0)");
	sc_trace(fp, DUT.oDelayFF[1], "oDL_FF(1)");
	sc_trace(fp, DUT.oDelayFF[2], "oDL_FF(2)");
	sc_trace(fp, DUT.oDelayFF[3], "oDL_FF(3)");		
	
	sc_trace(fp, DUT.oMultiplierFB[0], "oMU_FB(0)");
	sc_trace(fp, DUT.oMultiplierFB[1], "oMU_FB(1)");
	sc_trace(fp, DUT.oMultiplierFB[2], "oMU_FB(2)");

	RST = true;
	sc_start(3, SC_US);
	RST = false;cout << " RESET " << endl;
	sc_start(16, SC_US);

	sc_close_vcd_trace_file(fp);
		
	return 0;
}

// g++ -I$SYSTEMC_HOME/include -L$SYSTEMC_HOME/lib-linux IIR_TFI.cpp -lsystemc -lm -o iir.o
// g++ -I$SYSTEMC_HOME/include -L$SYSTEMC_HOME/lib-linux IIR_TFI.cpp -lsystemc -lm -o sdm.o -DSC_INCLUDE_FX
