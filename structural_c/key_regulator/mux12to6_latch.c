//Nama file : mux12to6_latch.c
//Deskripsi : mux 12 to 6 16 bit + latch
//Author    : Mas Adit
//Tanggal  : 27 Agustus 2001

#include <genlib.h>

main()
{
int i;
DEF_LOFIG ("mux12to6_latch");
LOCON ("i1[15:0]", IN, "i1[15:0]");
LOCON ("i2[15:0]", IN, "i2[15:0]");
LOCON ("i3[15:0]", IN, "i3[15:0]");
LOCON ("i4[15:0]", IN, "i4[15:0]");
LOCON ("i5[15:0]", IN, "i5[15:0]");
LOCON ("i6[15:0]", IN, "i6[15:0]");
LOCON ("i7[15:0]", IN, "i7[15:0]");
LOCON ("i8[15:0]", IN, "i8[15:0]");
LOCON ("i9[15:0]", IN, "i9[15:0]");
LOCON ("i10[15:0]", IN, "i10[15:0]");
LOCON ("i11[15:0]", IN, "i11[15:0]");
LOCON ("i12[15:0]", IN, "i12[15:0]");
LOCON ("en", IN, "en");
LOCON ("clr", IN, "clr");
LOCON ("sel", IN, "sel");
LOCON ("cke", IN, "cke");
LOCON ("o1[15:0]", INOUT, "o1[15:0]");
LOCON ("o2[15:0]", INOUT, "o2[15:0]");
LOCON ("o3[15:0]", INOUT, "o3[15:0]");
LOCON ("o4[15:0]", INOUT, "o4[15:0]");
LOCON ("o5[15:0]", INOUT, "o5[15:0]");
LOCON ("o6[15:0]", INOUT, "o6[15:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss" , IN, "vss");

LOINS ("mux12to6", "mux1", "i1[15:0]", "i2[15:0]", "i3[15:0]", "i4[15:0]", "i5[15:0]", "i6[15:0]", "i7[15:0]", "i8[15:0]", "i9[15:0]", "i10[15:0]", "i11[15:0]", "i12[15:0]", "en", "clr", "sel", "x1[15:0]", "x2[15:0]", "x3[15:0]", "x4[15:0]", "x5[15:0]", "x6[15:0]", "vdd", "vss", 0);
for (i=0; i<16; i++)
{
LOINS ("latch", NAME("latch%d", i), NAME("x1[%d]", i), "cke", NAME("o1[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 16), NAME("x2[%d]", i), "cke", NAME("o2[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 32), NAME("x3[%d]", i), "cke", NAME("o3[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 48), NAME("x4[%d]", i), "cke", NAME("o4[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 64), NAME("x5[%d]", i), "cke", NAME("o5[%d]", i), "vdd", "vss", 0);
LOINS ("latch", NAME("latch%d", i + 80), NAME("x6[%d]", i), "cke", NAME("o6[%d]", i), "vdd", "vss", 0);

 }

SAVE_LOFIG();
exit(0);
}

