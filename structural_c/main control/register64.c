// File Name    : register64.c
// Description  : Register 64 bit in C
// Author       : Sigit Dewantoro
// Date         : July 10th, 2001

#include<genlib.h>

main()
{
 int i;

 DEF_LOFIG("register64");
 LOCON("a[0:63]", IN, "a[0:63]");
 LOCON("rst", IN, "rst");
 LOCON("en", IN, "en");
 LOCON("b[0:63]", INOUT, "b[0:63]");
 LOCON("vdd", IN, "vdd");
 LOCON("vss", IN, "vss");

 for (i=0; i<64; i++)
   LOINS ("reg01", NAME("reg%d", i + 1), NAME("a[%d]", i), "rst", "en", NAME("b[%d]", i), "vdd", "vss", 0);

 SAVE_LOFIG();
 exit(0);
}
