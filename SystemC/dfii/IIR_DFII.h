/*
 * This is a semi-behavioral/structural description for digital IIR filter
 * Direct-Form II structure using Matlab notation
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
 */

#define orderFF 5
#define orderFB orderFF-1

template<class T>
SC_MODULE(IIR_DFII)
{
	/* Entity */
	sc_in<bool> CLR;								// Asynchronous active high reset
	sc_in<bool> CLK;								// Rising edge clock
	sc_in<T> 	iIIR;								// IIR input
	sc_out<T> 	oIIR;								// IIR ouput
	
	/* Internal Signals Declaration */
	sc_signal<T> oMultiplierFF[orderFF];			// FF multipliers output
	sc_signal<T> oAdderFF[orderFF];					// FF adders output
	sc_signal<T> oMultiplierFB[orderFF];			// FB multipliers output
	sc_signal<T> oAdderFB[orderFF];					// FB adders output	
	sc_signal<T> oDelay[orderFF];					// Delays output
	sc_signal<T> tIIR;								// Temporary intput
	
	/* Constructor Architecture */
	SC_HAS_PROCESS(IIR_DFII);
	
	IIR_DFII(sc_module_name name, T* _b, T* _a) :
		sc_module(name),
		b(_b),
		a(_a)
	{
		SC_METHOD(input);
			sensitive << CLK.neg();
	
		SC_METHOD(delays);
			sensitive << CLK.pos();
			
		SC_METHOD(multipliers);
			for (int i = 1; i < orderFF; i++)
				sensitive << oDelay[i];				
			
		SC_METHOD(addersFF);
			sensitive << oMultiplierFF[0];			
			
		SC_METHOD(addersFB);
			for (int i = 1; i < 2; i++)
			{
				sensitive << oMultiplierFB[i];	
				sensitive << oAdderFB[i];	
			}				
				
		SC_METHOD(output);
			sensitive << CLK.pos();
	}	
	
	void input()
	{
		tIIR.write(iIIR.read() + oAdderFB[1]);
		oDelay[0].write(iIIR.read() + oAdderFB[1]);
	}
	
	void delays()
	{
		for (int i = 1; i < orderFF; i++)
		{
			oDelay[i] = oDelay[i-1];
		}
	}
	
	void multipliers()
	{
		/* Feed-Forward */
		for (int i = 0; i < orderFF; i++)
		{
			oMultiplierFF[i] = oDelay[i] * b[i];
		}
		
		/* Feed-Back */
		for (int i = 0; i < orderFF; i++)
		{
			oMultiplierFB[i] = oDelay[i] * a[i];
		}		
	}
	
	void addersFF()
	{
		/* Feed-Forward */
		for (int i = 0; i < orderFF; i++)
		{
			if (i == 0)
			{		
				oAdderFF[i] = oMultiplierFF[i];
			}
			else
			{
				oAdderFF[i] = oMultiplierFF[i] + oAdderFF[i-1];
			}
		}
		cout << oAdderFF[0] << endl;
	}
	
	void addersFB()	
	{
		/* Feed-Back */
		for (int i = 0; i < orderFF; i++)
		{
			if (i == 0)
			{		
				oAdderFB[i] = 0;
			}
			else if (i < orderFB)
			{
				oAdderFB[i] = oMultiplierFB[i] + oAdderFB[i+1];
			}
			else
			{
				oAdderFB[i] =  oMultiplierFB[i];
			}
		}	
	}
	
	void output()
	{
		oIIR.write(oAdderFF[orderFF-1]);
	}
		
	/* Deconstructor */
	~IIR_DFII()
	{
	}
	
	T *b, *a;
};
