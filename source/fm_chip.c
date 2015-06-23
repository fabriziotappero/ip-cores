/*
 * $Id: fm_chip.c,v 1.1 2008-06-26 08:04:45 arif_endro Exp $
 */

#include <genlib.h>

int main(void)
{
int i;
GENLIB_DEF_LOFIG("fm_chip");
GENLIB_LOCON("clk",         IN, "clk");
GENLIB_LOCON("reset",       IN, "reset");
GENLIB_LOCON("fmin[7:0]",   IN, "fmin[7:0]");
GENLIB_LOCON("dmout[11:0]", OUT, "dmout[11:0]");
GENLIB_LOCON("vdde",        IN, "vdde");
GENLIB_LOCON("vddi",        IN, "vddi");
GENLIB_LOCON("vsse",        IN, "vsse");
GENLIB_LOCON("vssi",        IN, "vssi");

GENLIB_LOINS("fm", "core", "clock", "rsti", "fmini[7:0]", "dmouti[11:0]", "vddi", "vssi", 0);
GENLIB_LOINS("pck_sp", "pclock", "clk", "clki", "vdde", "vddi", "vsse", "vssi", 0);
GENLIB_LOINS("pi_sp", "preset", "reset", "rsti", "clki", "vdde", "vddi", "vsse", "vssi", 0);

for(i = 7; i >= 0; i--)  GENLIB_LOINS("pi_sp", GENLIB_NAME("pfmin%d", i), GENLIB_ELM("fmin", i), GENLIB_ELM("fmini", i), "clki", "vdde", "vddi", "vsse", "vssi", 0);
for(i = 11; i >= 0; i--) GENLIB_LOINS("po_sp", GENLIB_NAME("pdmout%d", i), GENLIB_ELM("dmouti", i), GENLIB_ELM("dmout", i), "clki", "vdde", "vddi", "vsse", "vssi", 0);

GENLIB_LOINS("pvddeck_sp", "pvdde", "clock", "clki", "vdde", "vddi", "vsse", "vssi", 0);
GENLIB_LOINS("pvsseck_sp", "pvsse", "clock", "clki", "vdde", "vddi", "vsse", "vssi", 0);
GENLIB_LOINS("pvddick_sp", "pvddi", "clock", "clki", "vdde", "vddi", "vsse", "vssi", 0);
GENLIB_LOINS("pvssick_sp", "pvssi", "clock", "clki", "vdde", "vddi", "vsse", "vssi", 0);
GENLIB_SAVE_LOFIG();
exit(0);
}
