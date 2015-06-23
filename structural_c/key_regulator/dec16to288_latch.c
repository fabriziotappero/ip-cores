//Nama file : dec16to288_latch.c
//Deskripsi : dec 16 to 288 16 bit + latch
//Author    : Mas Adit
//Tanggal  : 27 Agustus 2001

#include <genlib.h>

main()
{
int i;
DEF_LOFIG ("dec16to288_latch");
LOCON ("a[15:0]", IN, "a[15:0]");
LOCON ("en", IN, "en");
LOCON ("clr", IN, "clr");
LOCON ("sel[4:0]", IN, "sel[4:0]");
LOCON ("cke", IN, "cke");
LOCON ("o1[15:0]", INOUT, "o1[15:0]");
LOCON ("o2[15:0]", INOUT, "o2[15:0]");
LOCON ("o3[15:0]", INOUT, "o3[15:0]");
LOCON ("o4[15:0]", INOUT, "o4[15:0]");
LOCON ("o5[15:0]", INOUT, "o5[15:0]");
LOCON ("o6[15:0]", INOUT, "o6[15:0]");


LOCON ("o7[15:0]", INOUT, "o7[15:0]");
LOCON ("o8[15:0]", INOUT, "o8[15:0]");
LOCON ("o9[15:0]", INOUT, "o9[15:0]");
LOCON ("o10[15:0]", INOUT, "o10[15:0]");
LOCON ("o11[15:0]", INOUT, "o11[15:0]");
LOCON ("o12[15:0]", INOUT, "o12[15:0]");
LOCON ("o13[15:0]", INOUT, "o13[15:0]");
LOCON ("o14[15:0]", INOUT, "o14[15:0]");
LOCON ("o15[15:0]", INOUT, "o15[15:0]");
LOCON ("o16[15:0]", INOUT, "o16[15:0]");
LOCON ("o17[15:0]", INOUT, "o17[15:0]");
LOCON ("o18[15:0]", INOUT, "o18[15:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss" , IN, "vss");

LOINS ("dec16to288", "dec1", "a[15:0]", "en", "clr", "sel[4:0]", "x1[15:0]", "x2[15:0]", "x3[15:0]", "x[15:0]", "x5[15:0]", "x6[15:0]", "x7[15:0]", "x8[15:0]", "x9[15:0]", "x10[15:0]", "x11[15:0]", "x12[15:0]", "x13[15:0]", "x14[15:0]", "x15[15:0]", "x16[15:0]", "x17[15:0]", "x18[15:0]", "vdd", "vss", 0);
for (i=0; i<16; i++)
{
LOINS ("latch", NAME("latch%d", i), NAME("x1[%d]", i), "cke", NAME("o1[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 16), NAME("x2[%d]", i), "cke", NAME("o2[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 32), NAME("x3[%d]", i), "cke", NAME("o3[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 48), NAME("x4[%d]", i), "cke", NAME("o4[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 64), NAME("x5[%d]", i), "cke", NAME("o5[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 80), NAME("x6[%d]", i), "cke", NAME("o6[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 96), NAME("x7[%d]", i), "cke", NAME("o1[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 112), NAME("x8[%d]", i), "cke", NAME("o2[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 128), NAME("x9[%d]", i), "cke", NAME("o3[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 144), NAME("x10[%d]", i), "cke", NAME("o4[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 160), NAME("x11[%d]", i), "cke", NAME("o5[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 176), NAME("x12[%d]", i), "cke", NAME("o6[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 192), NAME("x13[%d]", i), "cke", NAME("o1[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 208), NAME("x14[%d]", i), "cke", NAME("o2[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 224), NAME("x15[%d]", i), "cke", NAME("o3[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 240), NAME("x16[%d]", i), "cke", NAME("o4[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 256), NAME("x17[%d]", i), "cke", NAME("o5[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 272), NAME("x18[%d]", i), "cke", NAME("o6[%d]", i), "vdd", "vss", 0);

 }

SAVE_LOFIG();
exit(0);
}

