/*
 * This is a semi-behavioral/structural description for digital IIR filter
 * Direct-Form II structure
 * Direct-Form I Transposed structure using Matlab notation
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

#define order 3
#define orderFF order+1
#define orderFB orderFF-1
 
template<class T>
SC_MODULE(IIR_TFI)
{
	/* Entity */
	sc_in<bool> CLR;								// Asynchronous active high reset
	sc_in<bool> CLK;								// Rising edge clock
	sc_in<T> 	iIIR;								// IIR input
	sc_out<T> 	oIIR;								// IIR ouput
	
	/* Internal Signals Declaration */
	sc_signal<T> oMultiplierFF[orderFF];			// FF multipliers output
	sc_signal<T> oAdderFF[orderFF];					// FF adders output
	sc_signal<T> oDelayFF[orderFF];					// FF delays output
	sc_signal<T> oMultiplierFB[orderFB];			// FB multipliers output
	sc_signal<T> oAdderFB[orderFB];					// FB adders output
	sc_signal<T> oDelayFB[orderFB];					// FB delays output
	sc_signal<T> tIIR;								// Temporary intput
	
	/* Constructor Architecture */
	SC_HAS_PROCESS(IIR_TFI);
	
	IIR_TFI(sc_module_name name, T* _b, T* _a)  :
		sc_module(name),							// Arbitrary module name
		b(_b),										// Feed-Forward Coefficients
		a(_a)										// Feed-Back Coefficients
	{
		SC_METHOD(multipliers);
			sensitive << tIIR;
			
		SC_METHOD(adders);
			for (int i = 0; i < orderFF; i++)
			{
				sensitive << oMultiplierFF[i];
				sensitive << oDelayFF[i];			
			}
			
		SC_METHOD(delays);
			sensitive << CLK.pos();	
			
		SC_METHOD(input);
			sensitive << iIIR << oDelayFB[orderFB-1];						
	}
	
	void multipliers()
	{
		/* Feed-Forward */
		for (int i = 0; i < orderFF; i++)
		{
			oMultiplierFF[i] = tIIR * b[i]; 
		}
		
		/* Feed-Back */
		for (int i = 0; i < orderFB; i++)
		{
			oMultiplierFB[i] = tIIR * a[orderFB-1-i];
		}		
	}
	
	void adders()
	{
		/* Feed-Forward */
		for (int i = 0; i < orderFF; i++)
		{
			if (i < (orderFF-1))
			{
				oAdderFF[i] = oMultiplierFF[i] + oDelayFF[i];
			}
			else
			{
				oAdderFF[i] = oMultiplierFF[i];
			}
		}
			
		/* Feed-Back */
		for (int i = 0; i < orderFB; i++)
		{
			if (i == 0)
			{
				oAdderFB[i] = oMultiplierFB[i];
			}
			else
			{
				oAdderFB[i] = oMultiplierFB[i] + oDelayFB[i-1];
			}
		}			
	}
	
	void delays()
	{
		/* Feed-Forward */
		for (int i = 0; i < orderFF-1; i++)
		{
			oDelayFF[i] = oAdderFF[i+1];
		}		
		
		/* Feed-Back */
		for (int i = 0; i < orderFB; i++)
		{
			oDelayFB[i] = oAdderFB[i];
		}		
	}
	
	void input()
	{
		tIIR.write(iIIR.read() + oDelayFB[orderFB-1]);
	}
	
	/* Deconstructor */
	~IIR_TFI()
	{
	}
	
	T *b, *a;
};
