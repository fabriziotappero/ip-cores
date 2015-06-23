//Nama file : count5_latch.c
//Deskripsi : count5.vst + latch.vst
//Author    : Mas Adit
//Tanggal  : 31 Agustus 2001

#include <genlib.h>

main()
{
int i;
DEF_LOFIG ("count5_latch");
LOCON ("clk", IN, "clk");
LOCON ("en", IN, "en");
LOCON ("rst", IN, "rst");
LOCON ("q[4:0]", OUT, "q[4:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("count5", "count1", "clk", "rst", "p[4:0]", "vd", "vss", 0);
for (i=0; i<5; i++)
{
LOINS ("latch", NAME("latch%d", i), NAME("p[%d]", i), "en", NAME("q[%d]", i), "vdd", "vss", 0);
}

SAVE_LOFIG ();
exit (0);
}
