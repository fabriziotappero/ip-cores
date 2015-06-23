//Nama file : kontrol_invadd.c
//Deskripsi : kontrol inv_add pada penggabungan
//Author    : Mas Adit
//Tanggal  : 29 Agustus 2001

#include <genlib.h>

main()
{
int i;

DEF_LOFIG ("kontrol_invadd");

LOCON ("start", IN, "start");
LOCON ("clk", IN, "clk");
LOCON ("rst", IN, "rst");
LOCON ("sel_in[4:0]", OUT, "sel_in[4:0]");
LOCON ("sel_out[4:0]", OUT, "sel_out[4:0]");
LOCON ("en_in", OUT, "en_in");
LOCON ("en_out", OUT, "en_out");
LOCON ("finish", OUT, "finish");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("kontrol_utama_invadd", "kontrol_utama_invadd1", "clk", "rst", "start", "sel_in[4:0]", "sel_out[4:0]",
           "c_cdtin", "en_cdtin", "c_cdtout", "en_cdtout", "en_out", "en_in", "finish", "vdd", "vss", 0);
LOINS ("count5_latch", "count1", "c_cdtin", "en_cdtin", "rst", "sel_in[4:0]", "vdd", "vss", 0);
LOINS ("count5_latch", "count2", "c_cdtout", "en_cdtout", "rst", "sel_out[4:0]", "vdd", "vss", 0);

SAVE_LOFIG ();
exit (0);
}