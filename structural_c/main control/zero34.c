// File Name    : zero34.c
// Description  : Zero 34 bit
// Author       : Sigit Dewantoro
// Date         : June 21th, 2001

#include <genlib.h>

main()
{
 int i;

 DEF_LOFIG ("zero 34");

 LOCON ("zero[33:0]", OUT, "zero[33:0]");
 LOCON ("vdd", IN, "vdd");
 LOCON ("vss", IN, "vss");

 for (i = 0; i < 34; i++)
   LOINS ("zero_x0", NAME("zero%d", i + 1), NAME("zero[%d]", i), "vdd", "vss", 0);

 SAVE_LOFIG();
 exit(0);
}
