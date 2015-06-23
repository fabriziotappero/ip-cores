// File Name    : xor64.c
// Description  : xor 64 bit in C
// Author       : Sigit Dewantoro
// Date         : July 10th, 2001

#include<genlib.h>

main()
{
 int i;

 DEF_LOFIG("xor64");
 LOCON("a[0:63]", IN, "a[0:63]");
 LOCON("b[0:63]", IN, "b[0:63]");
// LOCON("rst", IN, "rst");
// LOCON("en", IN, "en");
 LOCON("o[0:63]", OUT, "o[0:63]");
 LOCON("vdd", IN, "vdd");
 LOCON("vss", IN, "vss");

 for (i=0; i<64; i++)
{
   LOINS ("xr2_x1", NAME("xor%d", i + 1), NAME("a[%d]", i), NAME("b[%d]",i), NAME("i[%d]", i), "vdd", "vss", 0);

   LOINS ("latch", NAME("en%d", i+1), NAME("i%d",i), "en", NAME("o%d",i),"vdd","vss",0);
} 
 SAVE_LOFIG();
 exit(0);
}
