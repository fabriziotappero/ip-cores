//Nama file : kontrol_invmul.c
//Deskripsi  : kontrol inv_mul mod(2^16 + 1)
//Author    : Mas Adit
//Tanggal  : 29 Agustus 2001

#include <genlib.h>

main()
{
DEF_LOFIG ("kontrol_invmul");

LOCON ("start", IN, "start");
LOCON ("clk", IN, "clk");
LOCON ("rst", IN, "rst");
LOCON ("finish", OUT, "finish");
LOCON ("en_in", OUT, "en_in");
LOCON ("sel_in[4:0]", OUT, "sel_in[4:0]");
LOCON ("sel", OUT, "sel");
LOCON ("en_pipe", OUT, "en_pipe");
LOCON ("en_out", OUT, "en_out");
LOCON ("sel_out[4:0]", OUT, "sel_out[4:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("kontrol_utama_invmul", "kontrol_utama_invmul1", "start", "clk", "rst", "n_stage[1:0]", "n_iterasi[3:0]",
           "sel_in[4:0]", "sel_out[4:0]", "en_cstage", "c_cstage", "en_cite", "c_cite", "en_cdtin", "c_cdtin",
           "en_cdtout", "c_cdtout", "en_in", "en_out", "en_pipe", "sel", "finish", "vdd", "vss", 0);
LOINS ("count2_latch", "count1", "c_cstage", "en_cstage", "rst", "n_stage[1:0]", "vdd", "vss", 0);
LOINS ("count4_latch", "count2", "c_cite", "en_cite", "rst", "n_iterasi[3:0]", "vdd", "vss", 0);
LOINS ("count5_latch", "count3", "c_cdtin", "en_cdtin", "rst", "sel_in[4:0]", "vdd", "vss", 0);
LOINS ("count5_latch", "count4", "c_cdtout", "en_cdtout", "rst", "sel_out[4:0]", "vdd", "vss", 0);

SAVE_LOFIG ();
exit (0);
}
