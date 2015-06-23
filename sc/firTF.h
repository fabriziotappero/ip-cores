#include "systemc.h"

#define order 18 // Filter Length

/** This function exports the internal signals of the transposed-form FIR filter into a text file.
  * The text file entitled "fir_output.txt", which can be changed within this function.
  * The function inputs are the three internal signals between multiplier -> adder, delay -> adder, and adder_delay respectively.
  * Then there is the filter order defined by count, and finally the number of clock cycles defined by c.
  * P.S. Delete the text file before you re-simulate the design.
  */
void text( sc_signal<sc_int<15> > _multi_add[order], sc_signal<sc_int<15> > _delay_add[order], sc_signal<sc_int<15> > _add_delay[order], unsigned int count, unsigned int c )
{
    FILE *myFile;
    myFile = fopen("fir_output.txt", "a"); // Text file name


    if (c == 0)
    {
        fprintf(myFile, "CLK \t MU-AD \t \t \t DL-AD \t \t \t AD-DL \t \n");
        fprintf(myFile, "-------------------------------------------------------------------------\n");
        for (unsigned int i = 0; i < count; i++)
        {
            fprintf(myFile, "%d \t multi_add[%d] \t %d \t delay_add[%d] \t %d \t add_delay[%d] \t %d \n", c, i, _multi_add[i].read().to_int(), i, _delay_add[i].read().to_int(),  i, _add_delay[i].read().to_int());
        }
    }
    else
    {
        for (unsigned int i = 0; i < count; i++)
        {
            fprintf(myFile, "%d \t multi_add[%d] \t %d \t delay_add[%d] \t %d \t add_delay[%d] \t %d \n", c, i, _multi_add[i].read().to_int(), i, _delay_add[i].read().to_int(),  i, _add_delay[i].read().to_int());
        }
    }

    fprintf(myFile, "\n");

    fclose(myFile);
}

SC_MODULE(firTF)
{
    // Entity Ports
    sc_in<bool >        fir_clr;    // RESET
    sc_in<bool >        fir_clk;    // CLOCK
    sc_in<sc_uint<1> >  fir_in;     // INPUT
    sc_out<sc_int<15> > fir_out;    // OUTPUT

    // Internal Signals
    sc_signal<sc_int<15> > multi_add[order];            // multiplier's output
    sc_signal<sc_int<15> > add_delay[order];            // adder's output and delay's input
    sc_signal<sc_int<15> > delay_add[order];            // delay's output and adder's input

    // Constructor Process Sensitivity
    SC_CTOR(firTF)
    {
        // combinational, not clocked
        SC_METHOD(multipliers);
            sensitive << fir_in;

        fir_out.initialize(0);

        SC_METHOD(delays);
           sensitive << fir_clk.pos() ;

        // combinationl
        SC_METHOD(adders);
           for (unsigned int i = 0; i< order; i++)
            {
                sensitive << multi_add[i];
                sensitive << delay_add[i];
            }

        SC_METHOD(output)
            sensitive << add_delay[0];
    }

    void multipliers()
    {
        // Filter Coefficients
        static const sc_int<12> fir_coeff[order] = {-51,25,128,77,-203,-372,70,1122,2047,2047,1122,70,-372,-203,77,128,25,-51};

        // COEFFMULTIs
        for (unsigned int i = 0; i < order; i++)
        {
            {
                multi_add[i].write(fir_in.read() * fir_coeff[i]);
            }
        }
    }

    void delays()
    {
        // COEFFDELAY
        for (unsigned int i = 0; i < order-1; i++)
        {
            delay_add[i].write(add_delay[i+1].read());
        }
    }

    void adders()
    {
        // COEFFADD
        for (unsigned int i = 0; i < order; i++)
        {
            if (i < order-1)
            {
                add_delay[i].write(multi_add[i].read() + delay_add[i].read());
            }
            else
            {
                add_delay[i].write(multi_add[i].read());
            }
        }
    }

    void output()
    {
        // Internal variables
        static unsigned int clkCount = 0;

        // Output assignment
        fir_out.write(add_delay[0].read());

        // Exporting data into text file
        text(multi_add, delay_add, add_delay, order, clkCount);
        clkCount++;
    }

};
