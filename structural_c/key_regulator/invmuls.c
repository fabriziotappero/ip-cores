//Nama file : invmuls.c
//Deskripsi : invers multiplication modulo (2^16 + 1)
//Author    : Mas Adit
//Tanggal  : 26 Agustus 2001

#include <genlib.h>

main()
{

DEF_LOFIG ("invmuls");

LOCON ("zi[15:0]", IN, "zi[15:0]");
LOCON ("rst", IN, "rst");
LOCON ("en_pipe", IN, "en_pipe");
LOCON ("sel", IN, "sel");
LOCON ("cke", IN, "cke");
LOCON ("zo[15:0]", OUT, "zo[15:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("mux16", "mux_L", "zo[15:0]", "zi[15:0]", "sel", "o_mux_L[15:0]", "vdd", "vss", 0);
LOINS ("mux16", "mux_R", "ost3_R[15:0]", "zi[15:0]", "sel", "o_mux_R[15:0]", "vdd", "vss", 0);
LOINS ("reg16_latch", "reg1_L", "o_mux_L[15:0]", "en", "clr", "cke", "ost1_L[15:0]", "vdd", "vss", 0);
LOINS ("reg16_latch", "reg1_R", "o_mux_R[15:0]", "en", "clr", "cke", "ost1_R[15:0]", "vdd", "vss", 0);
LOINS ("reg16_latch", "reg2_L", "ost1_L[15:0]", "en", "clr", "cke", "ost2_L[15:0]", "vdd", "vss", 0);
LOINS ("mulmod", "mulmod_R", "ost1_R[15:0]", "ost1_R[15:0]", "en", "clr", "cke", "ost2_R[15:0]", "vdd", "vss", 0);
LOINS ("mulmod", "mulmod_L", "ost2_L[15:0]", "ost2_R[15:0]", "en", "clr", "cke", "zo[15:0]", "vdd", "vss", 0);
LOINS ("reg16_latch", "reg2_R", "ost2_R[15:0]", "en", "clr", "cke", "ost3_R[15:0]", "vdd", "vss", 0);

SAVE_LOFIG ();
exit (0);
}
