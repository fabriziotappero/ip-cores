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

DEF_GENPAT("sha512");
SETTUNIT("ns");

/* interface */
DECLAR ("clk", ":1", "B", IN , ""           , "" );
DECLAR ("rst", ":1", "B", IN , ""           , "" );
DECLAR ( "ld", ":1", "B", IN , ""           , "" );
DECLAR (  "m", ":2", "X", IN , "63 downto 0", "" );
DECLAR ("init", ":2", "B", IN , ""          , "" );
DECLAR ( "md", ":2", "X", OUT, "63 downto 0", "" );
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
AFFECT (  "0",   "m", "0x0000000000000000");
AFFECT (  "0","init", "0b0");
AFFECT ("+100", "clk", "0b1");
AFFECT ("+100", "clk", "0b0");
AFFECT ( "+0", "rst", "0b0");
AFFECT ( "+0",  "ld", "0b1");
AFFECT ( "+0","init", "0b1");

  AFFECT ( "+0",   "m", "0x6162638000000000");
  AFFECT ("+100", "clk", "0b1" );
  AFFECT ("+100", "clk", "0b0" );
  AFFECT ( "+0",   "m", "0x0000000000000000");
  i=1;
for (;i<0xf; i++)
{
  AFFECT ("+100", "clk", "0b1" );
  AFFECT ("+100", "clk", "0b0" );
}
  AFFECT ( "+0",   "m", "0x0000000000000018");
  AFFECT ("+100", "clk", "0b1" );
  AFFECT ("+100", "clk", "0b0" );
  i++;
  AFFECT ( "+0",   "m", "0x0000000000000000");
  AFFECT ( "+0",  "ld", "0b0");
  AFFECT ( "+0","init", "0b0");

for (; i<0x5f+1; i++)
{
  AFFECT ("+100", "clk", "0b1" );
  AFFECT ("+100", "clk", "0b0" );
}

AFFECT ("+100", "clk", "0b1");
AFFECT ("+100", "clk", "0b0");
AFFECT ( "+0", "rst", "0b0");
AFFECT ( "+0",  "ld", "0b1");
AFFECT ( "+0","init", "0b1");

AFFECT ( "+0",   "m", "0x6162636465666768");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6263646566676869");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x636465666768696a");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6465666768696a6b");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x65666768696a6b6c");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x666768696a6b6c6d");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6768696a6b6c6d6e");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x68696a6b6c6d6e6f");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x696a6b6c6d6e6f70");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6a6b6c6d6e6f7071");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6b6c6d6e6f707172");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6c6d6e6f70717273");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6d6e6f7071727374");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x6e6f707172737475");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x8000000000000000");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x0000000000000000");
AFFECT ("+100", "clk", "0b1" );
AFFECT ("+100", "clk", "0b0" );

AFFECT ( "+0",   "m", "0x0000000000000000");
AFFECT ( "+0",  "ld", "0b0");
AFFECT ( "+0","init", "0b0");

for (; i<0xaf+1; i++)
{
  AFFECT ("+100", "clk", "0b1" );
  AFFECT ("+100", "clk", "0b0" );
}

for (; i<0xbf;i++)
{
AFFECT ( "+0",  "ld", "0b1");
AFFECT ("+100", "clk", "0b1");
AFFECT ("+100", "clk", "0b0");
}

AFFECT ( "+0",   "m", "0x0000000000000380");
AFFECT ("+100", "clk", "0b1");
AFFECT ("+100", "clk", "0b0");
AFFECT ( "+0",   "m", "0x0000000000000000");
AFFECT ( "+0",  "ld", "0b0");

for (; i<0x11f+1; i++)
{
  AFFECT ("+100", "clk", "0b1" );
  AFFECT ("+100", "clk", "0b0" );
}

SAV_GENPAT ();
}

