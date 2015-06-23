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
  /*------------------------------*/
  /* end of the description       */
  /*------------------------------*/

main ()
{
int i;

DEF_GENPAT("keyexpansion-tst");
SETTUNIT("ns");

/* interface */
DECLAR ("clk", ":1", "B", IN , ""           , "" );
DECLAR ("rst", ":1", "B", IN , ""           , "" );
DECLAR ("ld" , ":1", "B", IN , ""           , "" );
DECLAR ("key", ":1", "X", IN ,"31  downto 0", "" );
DECLAR ("Nk" , ":1", "X", IN ,  "3 downto 0", "" );
DECLAR ("w"  , ":1", "X", OUT,"31  downto 0", "" );
DECLAR ("v"  , ":1", "B", OUT, ""           , "" );
DECLAR ("vss", ":1", "B", IN , ""           , "" );
DECLAR ("vdd", ":1", "B", IN , ""           , "" );

AFFECT ("0", "vss", "0b0");
AFFECT ("0", "vdd", "0b1");

AFFECT (   "0", "clk", "0b0");
AFFECT (   "0", "rst", "0b1");
AFFECT (   "0", "ld" , "0b0");
AFFECT (   "0", "key", "0x00000000");
AFFECT (   "0", "Nk" , "0x0");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "rst", "0b0");
AFFECT ("  +0", "ld" , "0b1");
AFFECT ("  +0", "key", "0x2b7e1516");
AFFECT ("  +0", "Nk" , "0x4");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x28aed2a6");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0xabf71588");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x09cf4f3c");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "ld" , "0b0");
AFFECT ("  +0", "key", "0x00000000");
AFFECT ("+100", "clk", "0b1");

for (i=0; i<56; i++)
{
  AFFECT ("+100", "clk", "0b0" );
  AFFECT ("+100", "clk", "0b1" );
}

AFFECT ("+100", "clk", "0b0" );
AFFECT (  "+0", "rst", "0b1");
AFFECT (  "+0", "ld" , "0b0");
AFFECT (  "+0", "key", "0x00000000");
AFFECT (  "+0", "Nk" , "0x0");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "rst", "0b0");
AFFECT ("  +0", "ld" , "0b1");
AFFECT ("  +0", "key", "0x8e73b0f7");
AFFECT ("  +0", "Nk" , "0x6");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0xda0e6452");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0xc810f32b");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x809079e5");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x62f8ead2");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x522c6b7b");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "ld" , "0b0");
AFFECT ("  +0", "key", "0x00000000");
AFFECT ("+100", "clk", "0b1");

for (i=0; i<56; i++)
{
  AFFECT ("+100", "clk", "0b0" );
  AFFECT ("+100", "clk", "0b1" );
}

AFFECT ("+100", "clk", "0b0" );
AFFECT (  "+0", "rst", "0b1");
AFFECT (  "+0", "ld" , "0b0");
AFFECT (  "+0", "key", "0x00000000");
AFFECT (  "+0", "Nk" , "0x0");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "rst", "0b0");
AFFECT ("  +0", "ld" , "0b1");
AFFECT ("  +0", "key", "0x603deb10");
AFFECT ("  +0", "Nk" , "0x8");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x15ca71be");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x2b73aef0");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x857d7781");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x1f352c07");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x3b6108d7");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x2d9810a3");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "key", "0x0914dff4");
AFFECT ("+100", "clk", "0b1");

AFFECT ("+100", "clk", "0b0");
AFFECT ("  +0", "ld" , "0b0");
AFFECT ("  +0", "key", "0x00000000");
AFFECT ("+100", "clk", "0b1");

for (i=0; i<56; i++)
{
  AFFECT ("+100", "clk", "0b0" );
  AFFECT ("+100", "clk", "0b1" );
}

AFFECT ("+100", "clk", "0b0");
SAV_GENPAT ();

}

