//Nama file : count4_latch.c
//Deskripsi : count4.vst + latch.vst
//Author    : Mas Adit
//Tanggal  : 31 Agustus 2001

#include <genlib.h>

main()
{
int i;
DEF_LOFIG ("count4_latch");
LOCON ("clk", IN, "clk");
LOCON ("en", IN, "en");
LOCON ("rst", IN, "rst");
LOCON ("q[3:0]", OUT, "q[3:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("count4", "count1", "clk", "rst", "p[3:0]", "vd", "vss", 0);
for (i=0; i<4; i++)
{
LOINS ("latch", NAME("latch%d", i), NAME("p[%d]", i), "en", NAME("q[%d]", i), "vdd", "vss", 0);
}

SAVE_LOFIG ();
exit (0);
}
