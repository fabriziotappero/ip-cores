//Nama file : ctr_enkey1.c
//Deskripsi : kontrol pembangkit kunci enkripsi pada penggabungan
//Author    : Mas Adit
//Tanggal  : 29 Agustus 2001

#include <genlib.h>

main()
{
DEF_LOFIG ("ctr_enkey1");

LOCON ("clk", IN, "clk");
LOCON ("start", IN, "start");
LOCON ("rst", IN, "rst");
LOCON ("qiu[2:0]", INOUT, "qiu[2:0]");
LOCON ("finish", OUT, "finish");
LOCON ("en_shft", OUT, "en_shft");
LOCON ("sel1", OUT, "sel1");
LOCON ("sel2", OUT, "sel2");
LOCON ("en_out", OUT, "en_out");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ( "ctr_enkey", "ctr_enkey0", "clk", "rst", "start", "qiu[2:0]", "en_shft", "count_en", "sel1", "sel2",
            "count_ck", "finish", "en_out", "vdd", "vss", 0);
LOINS ("count3_latch", "count1", "count_clk", "count_en", "rst", "qiu[2:0]", "vdd", "vss", 0);

SAVE_LOFIG ();
exit (0);
}