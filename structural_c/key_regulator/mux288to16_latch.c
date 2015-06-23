//Nama file : mux288to16_latch.c
//Deskripsi : mux288to16.vbe + latch.c
//Author    : Mas Adit
//Tanggal  : 25 Agustus 2001

#include<genlib.h>

main()
{
int i;

DEF_LOFIG ("mux288to16_latch");

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
LOCON ("i13[15:0]", IN, "i13[15:0]");
LOCON ("i14[15:0]", IN, "i14[15:0]");
LOCON ("i15[15:0]", IN, "i15[15:0]");
LOCON ("i16[15:0]", IN, "i16[15:0]");
LOCON ("i17[15:0]", IN, "i17[15:0]");
LOCON ("i18[15:0]", IN, "i18[15:0]");
LOCON ("en", IN, "en");
LOCON ("clr", IN, "clr");
LOCON ("sel[4:0]", IN, "sel[4:0]");
LOCON ("cke", IN, "cke");
LOCON ("c[15:0]", INOUT, "c[15:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("mux288to16", "mux1", "i1[15:0]", "i2[15:0]", "i3[15:0]", "i4[15:0]", "i5[15:0]", "i6[15:0]", "i7[15:0]", "i8[15:0]", "i9[15:0]", "i10[15:0]", "i11[15:0]", "i12[15:0]", "i13[15:0]", "i14[15:0]", "i15[15:0]", "i16[15:0]", "i17[15:0]", "i18[15:0]", "en", "clr", "sel[4:0]", "b[15:0]", "vdd", "vss", 0);
for (i=0; i<16; i++)
{
LOINS ("latch", NAME("latch%d", i), NAME("b[%d]", i), "cke", NAME("c[%d]", i), "vdd", "vss", 0);
}

SAVE_LOFIG();
exit(0);
}
