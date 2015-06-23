// File Name    : fulladder17.c
// Description  : Full Adder 17 bit
// Author       : Mas Adit
// Date         : 29 Agustus 2001

#include <genlib.h>

main()
{
 int i;

 DEF_LOFIG ("fulladder17");

 LOCON ("a[16:0]", IN, "a[16:0]");
 LOCON ("b[16:0]", IN, "b[16:0]");
 LOCON ("sum[17:0]", OUT, "sum[17:0]");
 LOCON ("vdd", IN, "vdd");
 LOCON ("vss", IN, "vss");

 LOINS ("zero_x0", "zero1", "nol", "vdd", "vss", 0);
 LOINS ("fulladder", "fulladder1", "a[0]", "b[0]", "nol", "sum[0]", "cout0", "vdd", "vss", 0);

 for (i = 1; i < 16; i++)
 {
   LOINS ("fulladder", NAME("fulladder%d", i + 1), NAME("a[%d]", i), NAME("b[%d]", i),
           NAME("cout%d", i - 1), NAME("sum[%d]", i), NAME("cout%d", i), "vdd", "vss", 0);
 }

 LOINS ("fulladder", "fulladder17", "a[16]", "b[16]", "cout15", "sum[16]", "sum[17]", "vdd", "vss", 0);
 
 SAVE_LOFIG();
 exit(0);
}
