// File Name    : latch.c
// Description  : Latch in C
// Author       : Sigit Dewantoro
// Date         : March 27th, 2001

#include <genlib.h>

main()
{
 DEF_LOFIG ("latch");

 LOCON ("a", IN, "a");
 LOCON ("en", IN, "en");
 LOCON ("b", INOUT, "b");
 LOCON ("vdd", IN, "vdd");
 LOCON ("vss", IN, "vss");

 LOINS ("noa22_x1", "notorand1", "en", "a", "b", "q", "vdd", "vss", 0);
 LOINS ("inv_x1", "inv1", "a", "nota", "vdd", "vss", 0);
 LOINS ("noa22_x1", "notorand2", "en", "nota" , "q", "b", "vdd", "vss", 0);

 SAVE_LOFIG();
 exit(0);
}
