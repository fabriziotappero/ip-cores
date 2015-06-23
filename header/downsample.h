#define M 2

SC_MODULE(downsample)
{
	sc_in<bool> 	CLR;
	sc_in<bool> 	CLK;
	sc_in<double> 	samplesIN;
	sc_out<double> 	sampleOUT;
	sc_out<bool> 	SCLK;
	
	sc_signal<double> reg[M];
	
	int count, scount;
	
	SC_CTOR(downsample)
	{
		SC_METHOD(lifo);
			sensitive << CLK.pos();
			
		SC_METHOD(output);
			sensitive << SCLK.pos();
			
		SC_METHOD(slowclock);
			sensitive << CLK.neg();				
	}
	
	void lifo()
	{
		if (CLR.read() == true)
		{
			count = 0;
		}
		else
		{
			if (CLK.posedge())
			{
				for (int i = 0; i < M; i++)
				{
					if (i == 0)
					{
						reg[i].write( samplesIN.read() );
					}
					else 
					{
						reg[i].write( reg[i-1] );
					
					}
				}
			}
		}
	}
	
	void slowclock()
	{
		if (CLR.read() == true)
		{
			scount = 0;
		}
		else
		{	
			if (CLK.negedge())
			{
				if (scount < M/2)
				{
					SCLK.write(1);
					scount++;
				}
				else if (scount < M-1)
				{
					SCLK.write(0);
					scount++;
				}
				else
				{
					SCLK.write(0);
					scount = 0;
				}
			}
		}
	}
	
	void output()
	{
		sampleOUT.write(reg[0].read());
	}
};
