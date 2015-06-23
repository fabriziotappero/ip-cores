// File Name    : fullsubstractor16.c
// Description  : Full Substractor 16 bit
// Author       : Mas Adit
// Date         : 29 Agustus 2001
#include <genlib.h>

main()
{
 int i;

 DEF_LOFIG ("fullsubstractor16");

 LOCON ("a[15:0]", IN, "a[15:0]");
 LOCON ("b[15:0]", IN, "b[15:0]");
 LOCON ("diff[15:0]", OUT, "diff[15:0]");
 LOCON ("vdd", IN, "vdd");
 LOCON ("vss", IN, "vss");

 LOINS ("zero_x0", "zero1", "nol", "vdd", "vss", 0);
 LOINS ("fullsubstractor", "fullsubstractor1", "a[0]", "b[0]", "nol", "diff[0]", "bout0", "vdd", "vss", 0);

 for (i = 1; i < 15; i++)
   LOINS("fullsubstractor", NAME("fullsubstractor%d", i + 1), NAME("a[%d]", i), NAME("b[%d]", i),
          NAME("bout%d", i - 1), NAME("diff[%d]", i), NAME("bout%d", i), "vdd", "vss", 0);

 LOINS ("fullsubstractorbout", "fullsubstarctor16", "a[15]", "b[15]", "bout14", "diff[15]", "vdd", "vss", 0);

 SAVE_LOFIG();
 exit(0);
}
