#include "../support/support.h"
#include "../support/board.h"

#include "../drivers/tick.h"

extern int tick_int;

void udelay(void)
{
    while (!tick_int);
    tick_ack();
}

