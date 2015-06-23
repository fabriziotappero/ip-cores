// File Name    : fulladder34.c
// Description  : Full Adder 34 bit
// Author       : Mas Adit
// Date         : 29 Agustus 2001

#include <genlib.h>

main()
{
 int i;

 DEF_LOFIG ("fulladder34");

 LOCON ("a[33:0]", IN, "a[33:0]");
 LOCON ("b[33:0]", IN, "b[33:0]");
 LOCON ("sum[33:0]", OUT, "sum[33:0]");
 LOCON ("vdd", IN, "vdd");
 LOCON ("vss", IN, "vss");

 LOINS ("zero_x0", "zero1", "nol", "vdd", "vss", 0);
 LOINS ("fulladder", "fulladder1", "a[0]", "b[0]", "nol", "sum[0]", "cout0", "vdd", "vss", 0);

 for (i = 1; i < 33; i++)
   LOINS("fulladder", NAME("fulladder%d", i + 1), NAME("a[%d]", i), NAME("b[%d]", i),
          NAME("cout%d", i - 1), NAME("sum[%d]", i), NAME("cout%d", i), "vdd", "vss", 0);

 LOINS ("fulladdercout", "fulladder34", "a[33]", "b[33]", "cout32", "sum[33]", "vdd", "vss", 0);

 SAVE_LOFIG();
 exit(0);
}
