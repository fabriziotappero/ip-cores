/*
 * This is a behavioral model for direct-form FIR digital filters.
 * The template parameters are:
 * T: 		defines the prefered data type for the FIR filter
 * order: 	defines the filter length
 * The constractor parameters are:
 * name: 	any given name to the module
 * h: 		filter coefficients array
 */
 
template<class T, int order>
SC_MODULE(fir)
{
	/// Design entity
	sc_in<bool> CLR;			// Asynchronous active high reset
	sc_in<bool> CLK;			// Rising edge clock
	sc_in<T> 	firIN;			// Comb stage input
	sc_out<T> 	firOUT;			// Comb stage output
	
	/// Internal signals
	sc_signal<T> delay[order];	// Internal signal used for delay
	
	/// Constructor
	SC_HAS_PROCESS(fir);
	
	fir(sc_module_name name, T* _h) :
	sc_module(name),
	h(_h)
	{	
		SC_METHOD(algorithm);
			sensitive << CLR << CLK.pos();	
			firOUT.initialize(0);
			
	}
	
	/// Concurrent processes
	/*
	 * This process emulates the direct-form FIR filter algorithm.
	 */
	void algorithm()
	{
		delay[0].write(firIN.read());
		
		T add = h[0] * firIN.read();	
		
		for (unsigned int i = 1; i < order; i++)
		{
			delay[i].write(delay[i-1].read());	
		}		
		
		for (unsigned int i = 1; i < order; i++)
		{
			add = add + h[i] * delay[i-1];	
		}
		
		firOUT.write(add);
	}
	
	/// Deconstructor
	~fir()
	{
	}

	/// Constructor parent variables
	T* h; 

};
