//Nama file : mul17.c
//Deskripsi : blok multiplier 17 x 17 bit
//Author    : Mas Adit
//Tanggal  : 29 Agustus 2001

#include <genlib.h>

main()
{
int i;

DEF_LOFIG ("mul17");

LOCON ("p[16:0]", IN, "p[16:0]");
LOCON ("q[16:0]", IN, "q[16:0]");
LOCON ("has[33:0]", OUT, "has[33:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("multiplier17", "multiplier1", "p[16:0]", "q[16:0]", "r0[33:0]", "r1[33:0]", "r2[33:0]", "r3[33:0]", "r4[33:0]",
           "r5[33:0]", "r6[33:0]", "r7[33:0]", "r8[33:0]", "r9[33:0]", "r10[33:0]", "r11[33:0]", "r12[33:0]", "r13[33:0]",
           "r14[33:0]", "r15[33:0]", "r16[33:0]", "o0[33:0]", "o1[33:0]", "o2[33:0]", "o3[33:0]", "o4[33:0]", "o5[33:0]",
           "o6[33:0]", "o7[33:0]", "o8[33:0]", "o9[33:0]", "o10[33:0]", "o11[33:0]", "o12[33:0]", "o13[33:0]", "o14[33:0]",
           "o15[33:0]", "o16[33:0]", "has[33:0]", "vdd", "vss", 0);

SAVE_LOFIG ();
exit (0);
}