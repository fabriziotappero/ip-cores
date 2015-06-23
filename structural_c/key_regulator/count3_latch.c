//Nama file : count3_latch.c
//Deskripsi : count3.vst + latch.vst
//Author    : Mas Adit
//Tanggal  : 31 Agustus 2001

#include <genlib.h>

main()
{
int i;
DEF_LOFIG ("count3_latch");
LOCON ("clk", IN, "clk");
LOCON ("en", IN, "en");
LOCON ("rst", IN, "rst");
LOCON ("q[2:0]", OUT, "q[2:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("count3", "count1", "clk", "rst", "p[2:0]", "vd", "vss", 0);
for (i=0; i<3; i++)
{
LOINS ("latch", NAME("latch%d", i), NAME("p[%d]", i), "en", NAME("q[%d]", i), "vdd", "vss", 0);
}

SAVE_LOFIG ();
exit (0);
}
