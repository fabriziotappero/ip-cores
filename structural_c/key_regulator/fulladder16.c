// File Name    : fulladder16.c
// Description  : Full Adder 16 bit
// Author       : Mas Adit
// Date         : 29 Agustus 2001

#include <genlib.h>

main()
{
 int i;

 DEF_LOFIG ("fulladder16");

 LOCON ("a[15:0]", IN, "a[15:0]");
 LOCON ("b[15:0]", IN, "b[15:0]");
 LOCON ("sum[15:0]", OUT, "sum[15:0]");
 LOCON ("vdd", IN, "vdd");
 LOCON ("vss", IN, "vss");

 LOINS ("zero_x0", "zero1", "nol", "vdd", "vss", 0);
 LOINS ("fulladder", "fulladder1", "a[0]", "b[0]", "nol", "sum[0]", "cout0", "vdd", "vss", 0);

 for (i = 1; i < 15; i++)
   LOINS("fulladder", NAME("fulladder%d", i + 1), NAME("a[%d]", i), NAME("b[%d]", i),
          NAME("cout%d", i - 1), NAME("sum[%d]", i), NAME("cout%d", i), "vdd", "vss", 0);

 LOINS ("fulladdercout", "fulladder16", "a[15]", "b[15]", "cout14", "sum[15]", "vdd", "vss", 0);

 SAVE_LOFIG();
 exit(0);
}
