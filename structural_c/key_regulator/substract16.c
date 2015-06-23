//Nama file : substract16.c
//Deskripsi : blok substract 2 input 16 bit
//Author    : Mas Adit
//Tanggal  : 29 Agustus 2001

#include <genlib.h>

main()
{
int i;
DEF_LOFIG ("substract16");

LOCON ("a[15:0]", IN, "a[15:0]");
LOCON ("b[15:0]", IN, "b[15:0]");
LOCON ("bin", IN, "bin");
LOCON ("diff[15:0]", OUT, "diff[15:0]");
LOCON ("bout", OUT, "bout");
LOCON ("vdd", IN, "vdd");
LOCON ("vss", IN, "vss");

LOINS ("substract", "substract0", "a[0]", "b[0]", "bin", "diff[0]", "boutx[0]", "vdd", "vss", 0);
for (i=1; i<15; i++)
{
LOINS ("substract", NAME("substract%d", i), NAME("a[%d]", i), NAME("b[%d]", i), NAME("boutx[%d]", i - 1),
           NAME("diff[%d]", i), NAME("boutx[%d]", i), "vdd", "vss", 0);
}
LOINS ("substract", "substract15", "a[15]", "b[15]", "boutx[14]", "diff[15]", "bout", "vdd", "vss", 0);

SAVE_LOFIG ();
exit (0);
}