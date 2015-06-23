//Nama file : shift25.c
//Deskripsi : blok shift register 25 posisi ke kiri
//Author    : Mas Adit
//Tanggal  : 21 Agustus 2001

#include <genlib.h>

main ()
{
int i ;
DEF_LOFIG ("shift25");

LOCON ("in_key[127:0]", IN, "in_key[127:0]");
LOCON ("clr", IN, "clr");
LOCON ("en", IN, "en");
LOCON ("sel1", IN, "sel1");
LOCON ("sel2", IN, "sel2");
LOCON ("out_key[127:0]", OUT, "out_key[127:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("mux128", "mux1", "in_key[127:0]", "kunci_out[127:0]", "sel1", "kunci_in[127:0]", "vdd", "vss", 0);
LOINS ("shiftreg", "shiftreg1", "kunci_in[127:0]", "clr", "en", "kunci_out[127:0]", "vdd", "vss", 0);
LOINS ("mux128", "mux2", "in_key[127:0]", "kunci_out[127:0]", "sel2", "out_key[127:0]", "vdd", "vss", 0);

SAVE_LOFIG ();
exit (0);
}
