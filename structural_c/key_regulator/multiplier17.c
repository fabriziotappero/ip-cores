// File Name    : multiplier17.c
// Description  : Multiplier 17 bit
// Author       : Mas Adit
// Date         : 29 Agustus 2001

#include <genlib.h>

main()
{
 int i;

 DEF_LOFIG ("multiplier17");

 LOCON ("a[16:0]", IN, "a[16:0]");
 LOCON ("b[16:0]", IN, "b[16:0]");
 //LOCON ("o[0:33]", OUT, "o[0:33]");
 LOCON ("o17[33:0]", OUT, "o17[33:0]");
 LOCON ("vdd", IN, "vdd");
 LOCON ("vss", IN, "vss");


 for (i = 0; i < 17; i++)
   LOINS(NAME("leftshiftregister%d", i), NAME("leftshiftregister%d", i + 1), "a[16:0]",
                NAME("b[%d]", i), NAME("r%d[33:0]", i), "vdd", "vss", 0);

 LOINS ("zero34", "zero34", "o0[33:0]", "vdd", "vss", 0);
 LOINS ("fulladder34", "fulladder341", "o0[33:0]", "r0[33:0]", "o1[33:0]", "vdd", "vss", 0);

 for (i = 1; i < 17; i++)
   LOINS("fulladder34", NAME("fulladder34%d", i + 1), NAME("o%d[33:0]", i),
                NAME("r%d[33:0]", i), NAME("o%d[33:0]", i + 1), "vdd", "vss", 0);

 SAVE_LOFIG();
 exit(0);
}
