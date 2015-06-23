/*
 * This is a behavioral description for an integrator stage.
 * The integrator consists of adder and single delay element.
 * It should be noted that the output is asynchronous, i.e.,
 * as soon as the input changes the output has to change 
 * instantaneously.
 */
 
SC_MODULE(integrator)
{
	/// Design entity
	sc_in<bool> 	CLR;			// Asynchronous active high reset
	sc_in<bool> 	CLK;			// Rising edge clock
	sc_in<double> 	integratorIN;	// Integrator stage input
	sc_out<double> 	integratorOUT;	// Integrator stage output
	
	/// Internal signals
	sc_signal<double> r_delay;		// Internal signal used for delay
	
	/// Constructor
	SC_CTOR(integrator)
	{
		SC_METHOD(algorithm);
			sensitive << integratorIN << r_delay;
			
		SC_METHOD(delay);
			sensitive << CLK.pos();
		
		integratorOUT.initialize(0);	
	}
	
	/// Concurrent processes
	/*
	 * This process emulates an adder stage. It adds the input
	 * and the a delayed version of the output, i.e., the prvious
	 * output sample.
	 */
	void algorithm()
	{	
		if (CLR.read() == true)
		{

		}
		else
		{	
			integratorOUT.write( integratorIN.read() + r_delay.read() );			
		}
	}

	/*
	 * This process emulates the recursive feedback from the
	 * output to the input through a delay path.
	 */
	void delay()
	{
		if (CLR.read() == true)
		{
			r_delay.write(0);
		}
		else
		{	
			r_delay.write(integratorOUT.read());
		}
	}
};


/* Integrator Stage
 
 		 ***
    --->* + *--------------->
 		 ***			|
		  ^   			|
		  |	  *****		|
		  ----* z *<-----
			  *****

*/
