#include "systemc.h"
#include <iostream>
#include <fstream>

#define textLength 40 //The length of the bit-stream in the stimuli file

/** This function read in a text file into a local variable and export it
    in array format */
int* ReafFileData()
{
	int *values = new int[textLength];
 	int numValuesRead = 0;

	// open the file
	FILE* pFile = fopen("myfile.dat","r+t");

	while( ! feof( pFile ) )
	{
		int currentInt = 0;
		fscanf( pFile, "%d", &currentInt);
		values[numValuesRead] = currentInt ;
		numValuesRead++;
	}

	fclose(pFile);

	return values;

	delete pFile;
}

/** Read in the text file using the developed previous function
    and store the content into the arry called data */
static int *data = ReafFileData();

/** This module/block start reading the data from the array data
    when the clear signal is set to zero and at each rising edge of the clock */
SC_MODULE(stimuli) {
	// Input and Output Ports
	sc_in_clk 	clk;
	sc_in<bool> clr;
	sc_out<sc_uint<1> >	streamout;

    // Internal variable
    unsigned int count;

    // Constructor
    SC_CTOR(stimuli)
    {
        SC_METHOD(bitstream);
            sensitive << clr << clk.pos();
    }

    // Process
    void bitstream()
    {
        if (clr == true)
        {
            count = 0;
            streamout.write(0);
        }
        else
        {
            if (clk.posedge())
            {
                if (count < textLength)
                {
                    streamout.write(data[count]);
                    count = count + 1;
                }
                else
                {
                    count = 0;
                }
            }
        }
    }


};
