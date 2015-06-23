#include "timer.h"

void sample_clock_generator::do_sample_clock_generator()
{
	if(reset.read() == true)
	   count = 0;
	else
	   count = count + 1 ;
	 
	if (count == 50)
	{
	   count = 0;
	   sample_clock.write(true);
	}
	else
	   sample_clock.write(false);
	 




} 
