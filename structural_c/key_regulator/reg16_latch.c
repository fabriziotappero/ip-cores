//Nama file : reg16_latch.c
//Deskripsi : reg 16 + latch
//Author    : Mas Adit
//Tanggal  : 27 Agustus 2001

#include <genlib.h>

main()
{
int i;
DEF_LOFIG ("reg16_latch");

LOCON ("a[15:0]", IN, "a[15:0]");
LOCON ("en", IN, "en");
LOCON ("clr", IN, "clr");
LOCON ("cke", IN, "cke");
LOCON ("b[15:0]", INOUT, "b[15:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("reg16", "reg1", "a[15:0]", "en", "clr", "x[15:0]", "vdd", "vss", 0);
for(i=0; i<16; i++)
{
LOINS ("latch", NAME("latch%d", i), NAME("x[%d]", i), "cke", NAME("b[%d]", i), "vdd", "vss", 0);
}

SAVE_LOFIG ();
exit (0);
}