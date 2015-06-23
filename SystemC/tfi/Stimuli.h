/** This function read in a text file into a local variable and export it
    in array format */
template<class T> T* ReafFileData(int Size)
{
	T *values = new T[Size];
 	int numValuesRead = 0;

	// open the file
	FILE* pFile = fopen("Step.txt","r+t");

	while( ! feof( pFile ) )
	{
		T currentInt = 0;
		fscanf( pFile, "%f", &currentInt);
		values[numValuesRead] = currentInt ;
		numValuesRead++;
	}

	fclose(pFile);

	return values;

	delete pFile;
}

/** This module/block start reading the data from the array data
    when the clear signal is set to zero and at each rising edge of the clock */
template<class T>
SC_MODULE(Stimuli) {
	// Input and Output Ports
	sc_in_clk 	clk;
	sc_in<bool> clr;
	sc_out<T >	streamout;

    // Internal variable
    unsigned int count;
	float *data;
	
    // Constructor  
    SC_HAS_PROCESS(Stimuli);
    
    Stimuli(sc_module_name name, int _Size):
    	sc_module(name),
    	Size(_Size)
    {
        SC_METHOD(bitstream);
            sensitive << clr << clk.pos();
        
        data = ReafFileData<float> (Size);    
    }

    // Process
    void bitstream()
    {
        if (clr == true)
        {
            count = 0;
            streamout.write(0.0);
        }
        else
        {
            if (clk.posedge())
            {
                if (count < Size)
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

	~Stimuli()
	{
	}
	
	int Size;
};
