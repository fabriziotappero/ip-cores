#include <stdio.h>
#include "genpat.h"

char *inttostr(entier)
int entier;
 {
 char *str;
 str = (char *) mbkalloc (32 * sizeof (char));
 sprintf (str, "%d",entier);
 return(str);
 }

main ()
{
int i;

DEF_GENPAT("sha256");
SETTUNIT("ns");

/* interface */
DECLAR ("clk", ":1", "B", IN , ""           , "" );
DECLAR ("rst", ":1", "B", IN , ""           , "" );
DECLAR ( "ld", ":1", "B", IN , ""           , "" );
DECLAR (  "m", ":2", "X", IN , "31 downto 0", "" );
DECLAR ("init", ":2", "B", IN , ""          , "" );
DECLAR ( "md", ":2", "X", OUT, "31 downto 0", "" );
DECLAR (  "v", ":1", "B", OUT, ""           , "" );
//DECLAR ("ctr2p", ":1", "X", OUT, " 3 downto 0", "" );
//DECLAR ("ctr3p", ":1", "X", OUT, " 5 downto 0", "" );
//DECLAR ("w_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("k_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("a_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("b_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("c_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("d_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("e_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("f_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("g_prb", ":2", "X", OUT, "31 downto 0", "" );
//DECLAR ("h_prb", ":2", "X", OUT, "31 downto 0", "" );
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");

AFFECT (  "0", "rst", "0b1");
AFFECT (  "0", "clk", "0b0");
AFFECT (  "0",  "ld", "0b0");
AFFECT (  "0",   "m", "0x00000000");
AFFECT (  "0","init", "0b0");
AFFECT ("+50", "clk", "0b1");
AFFECT ("+50", "clk", "0b0");
AFFECT ( "+0", "rst", "0b0");
AFFECT ( "+0",  "ld", "0b1");
AFFECT ( "+0","init", "0b1");

  AFFECT ( "+0",   "m", "0x61626380");
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
  AFFECT ( "+0",   "m", "0x00000000");
  i=1;
for (;i<0xf; i++)
{
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
}
  AFFECT ( "+0",   "m", "0x00000018");
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
  i++;
  AFFECT ( "+0",   "m", "0x00000000");
  AFFECT ( "+0",  "ld", "0b0");
  AFFECT ( "+0","init", "0b0");

for (; i<0x5f+1; i++)
{
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
}

AFFECT ("+50", "clk", "0b1");
AFFECT ("+50", "clk", "0b0");
AFFECT ( "+0", "rst", "0b0");
AFFECT ( "+0",  "ld", "0b1");
AFFECT ( "+0","init", "0b1");

AFFECT ( "+0",   "m", "0x61626364");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x62636465");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x63646566");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x64656667");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x65666768");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x66676869");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6768696a");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x68696a6b");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x696a6b6c");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6a6b6c6d");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6b6c6d6e");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6c6d6e6f");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6d6e6f70");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6e6f7071");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x80000000");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x00000000");
AFFECT ("+50", "clk", "0b1" );
AFFECT ("+50", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x00000000");
AFFECT ( "+0",  "ld", "0b0");
AFFECT ( "+0","init", "0b0");

for (; i<0xaf+1; i++)
{
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
}

for (; i<0xbf;i++)
{
AFFECT ( "+0",  "ld", "0b1");
AFFECT ("+50", "clk", "0b1");
AFFECT ("+50", "clk", "0b0");
}

AFFECT ( "+0",   "m", "0x000001c0");
AFFECT ("+50", "clk", "0b1");
AFFECT ("+50", "clk", "0b0");
AFFECT ( "+0",   "m", "0x00000000");
AFFECT ( "+0",  "ld", "0b0");

for (; i<0x11f+1; i++)
{
  AFFECT ("+50", "clk", "0b1" );
  AFFECT ("+50", "clk", "0b0" );
}

SAV_GENPAT ();
}

