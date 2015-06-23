/*
 * This is a semi-behavioral/structural description for digital IIR filter
 * Direct-Form I structure
 * Direct-Form II Transposed structure using Matlab notation
 *
 * 			 \Sigma_{i=0}^{N} b[i]z^{-1}
 * H(z) = ---------------------------------
 *			1 - \Sigma_{i=1}^{N} a[i]z^{-1}
 * 
 * H(z): 	transfer function
 * b:		feed-forward coefficients
 * a: 		feed-back coefficients
 * N:		filter order
 *
 * U. Meyer-Baese, "Digital signal processing with field programmable gate arrays", Springer Verlag, 2004
 */
 
#define orderFF 4
#define orderFB orderFF-1

template<class T>
SC_MODULE(IIR_TFII)
{
	/* Entity */
	sc_in<bool> CLR;								// Asynchronous active high reset
	sc_in<bool> CLK;								// Rising edge clock
	sc_in<T> 	iIIR;								// IIR input
	sc_out<T> 	oIIR;								// IIR ouput
	
	/* Internal Signals Declaration */
	sc_signal<T> oMultiplierFF[orderFF];			// FF multipliers output
	sc_signal<T> oMultiplierFB[orderFF];			// FB multipliers output
	sc_signal<T> oAdder[orderFF];					// Adders output
	sc_signal<T> oDelay[orderFB];					// Delays output
		
	/* Constructor Architecture */
	SC_HAS_PROCESS(IIR_TFII);
	
	IIR_TFII(sc_module_name name, T* _b, T* _a) :
		sc_module(name),							// Arbitrary module name
		b(_b),										// Feed-Forward Coefficients
		a(_a)										// Feed-Back Coefficients
	{
		SC_METHOD(multipliers);
			sensitive << iIIR << oAdder[0];
			
		SC_METHOD(adders);
			for (int i = 0; i < orderFF; i++)
			{
				if (i < orderFB)
				{
					sensitive << oMultiplierFF[i];
					sensitive << oMultiplierFB[i];
					sensitive << oDelay[i];
				}
				else
				{
					sensitive << oMultiplierFF[i];
					sensitive << oMultiplierFB[i];				
				}
			}
	
		SC_METHOD(delays);
			sensitive << CLK.pos();
			
		SC_METHOD(output);
			sensitive << CLK.pos();			
	}
	
	void multipliers()
	{
		/* Feed-Forward */
		for (int i = 0; i < orderFF; i++)
		{
			oMultiplierFF[i] = iIIR.read() * b[i];
			cout << "FF MU [" << i << "]\t" << oMultiplierFF[i] << endl;
		}
		
		/* Feed-Back */
		for (int i = 0; i < orderFF; i++)
		{
			if (i == 0)
			{
				oMultiplierFB[i] = 0;
			}
			else
			{
				oMultiplierFB[i] = oAdder[0] * a[i];
			}
		}		
	}
	
	void adders()
	{
		for (int i = 0; i < orderFF; i++)
		{
			if (i < orderFB )
			{
				oAdder[i] = oMultiplierFF[i] + oMultiplierFB[i] + oDelay[i];
			}
			else
			{
				oAdder[i] = oMultiplierFF[i] + oMultiplierFB[i];
			}
		}
	}
	
	void delays()
	{
		for (int i = 0; i < orderFB; i++)
		{
			oDelay[i] = oAdder[i+1];
		}
	}
	
	void output()
	{
		oIIR.write(oAdder[0].read());
	}	
	
	/* Deconstructor */
	~IIR_TFII()
	{
	}
	
	T *a, *b;
};
