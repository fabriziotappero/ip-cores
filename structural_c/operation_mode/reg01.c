// File Name    : reg01.c
// Description  : Register 1 bit in C
// Author       : Sigit Dewantoro
// Date         : July 3rd, 2001

#include<genlib.h>

main()
{
 int i;

 DEF_LOFIG("reg01");
 LOCON("a", IN, "a");
 LOCON("rst", IN, "rst");
 LOCON("en", IN, "en");
// LOCON("c", INOUT, "c");
 LOCON("b", INOUT, "b");
 LOCON("vdd", IN, "vdd");
 LOCON("vss", IN, "vss");

 LOINS ("a2_x2", "and1", "en", "a", "a1", "vdd", "vss", 0);
 LOINS ("no2_x1", "nor1", "a1", "b", "c", "vdd", "vss", 0);
 LOINS ("inv_x1", "inv1", "a", "nota", "vdd", "vss", 0);
 LOINS ("a2_x2", "and2", "en", "nota" , "a2", "vdd", "vss", 0);
 LOINS ("no3_x1", "nor2", "a2", "c", "rst", "b", "vdd", "vss", 0);

 SAVE_LOFIG();
 exit(0);
}
