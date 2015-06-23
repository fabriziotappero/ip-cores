//Nama file : adder17.c
//Deskripsi : blok adder 17 bit 2 input
//Author    : Mas Adit
//Tanggal  : 29 Agustus 2001

#include <genlib.h>
main()
{
int i;

DEF_LOFIG ("adder17");

LOCON ("a[16:0]", IN, "a[16:0]");
LOCON ("b[16:0]", IN, "b[16:0]");
LOCON ("res[17:0]", OUT, "res[17:0]");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("zero_x0", "zero1", "nol", "vdd", "vss", 0);
LOINS ("adder01", "adder0", "a[0]", "b[0]", "nol", "res[0]", "cout[0]", "vdd", "vss", 0);
for (i=1; i<16; i++)
{
LOINS ("adder01", NAME("adder%d", i), NAME("a[%d]", i), NAME("b[%d]", i), NAME("cout[%d]", i - 1),
           NAME("res[%d]", i), NAME("cout[%d]", i), "vdd", "vss", 0);
}
LOINS ("adder01", "adder16", "a[16]", "b[16]", "cout[15]", "res[16]", "res[17]", "vdd", "vss", 0);

SAVE_LOFIG ();
exit (0);
}
