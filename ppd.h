#include "fir.h"
#include <math.h>

/* 
 * This function takes an array of FIR filter coefficients
 * and convert it to 2D matrix for polyphase decimation filter.
 */
double** eMat(int rows, int columns, double *h)
{
	double **m = new double*[rows];
	for (int i = 0; i < rows; i++) {m[i] = new double[columns];}
	
	for (int i = 0; i < rows; i++)
	{
		for (int j = 0; j < columns; j++)
		{
			m[i][j] = h[j*rows+i];
		}
	}
	
	return m;
}

/*
 * This function takes an 2D matrix, polyphase matrix,
 * and export an array for each phase or row in the
 * polyphase decimation filter. This is corresponding 
 * to the E's.
 */
double* eVec(int row, int columns, double **Matrix)
{
	double *v = new double[columns];
	
	for (int i = 0; i < columns; i++)
	{
		v[i] = Matrix[row][i];
	}
	
	return v;
}

/// Core/Static design constans, as VHDL generic list.
#define N 36		// Filter length
#define M 3			// Decimation factor
#define P 12		// P = ceil(N/M)
	
class ppd : public sc_module
{
	public:
	sc_in<bool> 	RST;
	sc_in<bool> 	CLOCK;
	sc_in<double> 	ppdIN;
	sc_out<double> 	ppdOUT;

	sc_signal<double> delay[M];
	sc_signal<double> sum[M];
	
	double **Matrix;
	double *tmpE;

	fir<double,P> *E[M];
	
	SC_HAS_PROCESS(ppd);
	
	ppd(sc_module_name name, double* _h) :
	sc_module(name),
	h(_h)
	{
		SC_METHOD(algorithm);
			sensitive << CLOCK.pos();
					
		Matrix = eMat(M,P,h);	
			
		for (unsigned int i = 0; i < M; i++)
		{
			tmpE = eVec(i,P,Matrix);
			E[i] = new fir<double,P>(sc_gen_unique_name("E"),tmpE);
		
			E[i] -> CLR 	(RST);
			E[i] -> CLK 	(CLOCK);
			E[i] -> firIN 	(delay[i]);
			E[i] -> firOUT 	(sum[i]);
		}	
	}
	
	void algorithm()
	{
		delay[0].write(ppdIN.read());
		
		double add = sum[0].read();
		
		for (unsigned int i = 1; i < M; i++)
		{
			delay[i].write(delay[i-1].read());
		}
		
		for (unsigned int i = 0; i < M; i++)
		{
			add = add + sum[i];
		}	
		
		ppdOUT.write(sum[0]);
		cout << ppdOUT << endl;	
	}
	
	~ppd()
	{
	}
	
	double* h;
};
