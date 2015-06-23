SC_MODULE(comb)
{
	/// Design entity
	sc_in<bool> 	CLR;			// Asynchronous active high reset
	sc_in<bool> 	CLK;			// Rising edge clock
	sc_in<double> 	combIN;			// Comb stage input
	sc_out<double> 	combOUT;		// Comb stage output
	
	/// Internal signals
	sc_signal<double> r, r_delay;	// Internal signal used for delay
	
	/// Constructor
	SC_CTOR(comb)
	{
		SC_METHOD(algorithm);
			sensitive << combIN ;//<< r_delay;
		
		SC_METHOD(delay);
			sensitive << CLK.pos();
			
		combOUT.initialize(0);	
	}
	
	/// Concurrent processes
	void algorithm()
	{
		if (CLR.read() == true)
		{
			r.write(0);
		}
		else
		{	
			r.write(combIN.read());
			combOUT.write( combIN.read() - r_delay.read() );
		}	
	}
			
	/*
	 * This process emulates the non-recursive feedback from the
	 * input to the output through a delay path.
	 */	
	void delay()
	{
		if (CLR.read() == true)
		{
			r_delay.write(0);
		}
		else
		{	
			r_delay.write(r.read());
		}				
	}
	
};


/* Comb Stage
 
 		 				***
    ------------------>* - *--->
 		  |				***			
		  |   			 ^
		  |	  *****		 |
		  --->* z *------
			  *****

*/
