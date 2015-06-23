//Nama file : gen_inv_mul.c
//Deskripsi : pembangkit inv_mul
//Author    : Mas Adit
//Tanggal  :26 Agustus 2001

#include <genlib.h>

main()
{

DEF_LOFIG ("gen_inv_mul");

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
LOCON ("clk", IN, "clk");
LOCON ("start", IN, "start");
LOCON ("rst", IN, "rst");
LOCON ("finish", OUT, "finish");
LOCON ("o1[15:0]", OUT, "o1[15:0]");
LOCON ("o2[15:0]", OUT, "o2[15:0]");
LOCON ("o3[15:0]", OUT, "o3[15:0]");
LOCON ("o4[15:0]", OUT, "o4[15:0]");
LOCON ("o5[15:0]", OUT, "o5[15:0]");
LOCON ("o6[15:0]", OUT, "o6[15:0]");
LOCON ("o7[15:0]", OUT, "o7[15:0]");
LOCON ("o8[15:0]", OUT, "o8[15:0]");
LOCON ("o9[15:0]", OUT, "o9[15:0]");
LOCON ("o10[15:0]", OUT, "o10[15:0]");
LOCON ("o11[15:0]", OUT, "o11[15:0]");
LOCON ("o12[15:0]", OUT, "o12[15:0]");
LOCON ("o13[15:0]", OUT, "o13[15:0]");
LOCON ("o14[15:0]", OUT, "o14[15:0]");
LOCON ("o15[15:0]", OUT, "o15[15:0]");
LOCON ("o16[15:0]", OUT, "o16[15:0]");
LOCON ("o17[15:0]", OUT, "o17[15:0]");
LOCON ("o18[15:0]", OUT, "o18[15:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("mux288to16_latch", "mux1", "i1[15:0]", "i1[15:0]", "i1[15:0]", "i1[15:0]", "i1[15:0]", "i1[15:0]",
           "i1[15:0]", "i1[15:0]", "i1[15:0]", "i1[15:0]", "i1[15:0]", "i1[15:0]", "i1[15:0]", "i1[15:0]", "i1[15:0]", "i1[15:0]",
           "i1[15:0]", "i1[15:0]", "en_in", "rst", "sel_in[4:0]", "start", "zi[15:0]", "vdd", "vss", 0);
LOINS ("invmuls", "invmuls1", "zi[15:0]", "rst", "en_pipe", "sel", "start", "zo[15:0]", "vdd", "vss", 0);
LOINS ("kontrol_invmul", "kontrol_invmul1", "start", "clk", "rst", "finish", "en_in", "sel_in[4:0]", "sel", "en_pipe",
           "en_out", "sel_out[4:0]", "vdd", "vss", 0);
LOINS ("dec16to288_latch", "dec1", "zo[15:0]", "en_out", "rst", "sel_out[4:0]", "start", "o1[15:0]", "o2[15:0]",
           "o3[15:0]", "o4[15:0]", "o5[15:0]", "o6[15:0]", "o7[15:0]", "o8[15:0]", "o9[15:0]", "o10[15:0]", "o11[15:0]",
           "o12[15:0]", "o13[15:0]", "o14[15:0]", "o15[15:0]", "o16[15:0]", "o17[15:0]", "o18[15:0]", "vdd", "vss", 0);

SAVE_LOFIG ();
exit (0);
}