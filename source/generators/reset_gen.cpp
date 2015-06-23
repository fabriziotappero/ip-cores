#include "reset_gen.h"

void reset_gen::do_reset() 
{
	reset.write(false);
        wait();
        wait();

        reset.write(true);

        wait();
        wait();
        wait();
        wait();
        reset.write(false);
        wait();
        wait();
        wait();
	wait();
}
