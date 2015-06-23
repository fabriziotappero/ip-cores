/* File Name   : idea_encryptor_pat_dec.c            		        */
/* Description : The decryption test patterns of IDEA encryption block  */
/* Purpose     : To be used by GENLIB					*/
/* Date	       : Aug 23, 2001          					*/
/* Version     : 1.1                   					*/
/* Author      : Martadinata A.        					*/
/* Address     : VLSI RG, Dept. of Electrical Engineering ITB,  	*/
/*	         Bandung, Indonesia					*/
/* E-mail      : marta@ic.vlsi.itb.ac.id                        	*/

#include <stdio.h>
#include "genpat.h"
#define interval 28

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
  int round,i;
  int time, max;

  DEF_GENPAT("idea_encryptor_decrypt");
  SETTUNIT ("ns");
  /* Inputs */
  /* for power supply */
  DECLAR ("vdd", ":2", "B", IN, "", "");
  DECLAR ("vss", ":2", "B", IN, "", "");
  /* for 64-bit input data */
  DECLAR ("x1", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("x2", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("x3", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("x4", ":2", "X", IN, "15 downto 0", "");
  /* for the 6 16-bit subkeys of each round */
  DECLAR ("z1", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("z2", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("z3", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("z4", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("z5", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("z6", ":2", "X", IN, "15 downto 0", "");
  /* for the 4 16-bit subkeys of output transformation state */
  DECLAR ("z19", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("z29", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("z39", ":2", "X", IN, "15 downto 0", "");
  DECLAR ("z49", ":2", "X", IN, "15 downto 0", "");

 /* for control signals */
  DECLAR ("clk", ":2", "B", IN, "", "");
  DECLAR ("rst", ":2", "B", IN, "", "");
  DECLAR ("start", ":2", "B", IN, "", "");
  DECLAR ("key_ready", ":2", "B", IN, "", "");

  DECLAR ("round", ":2", "B", OUT, "2 downto 0","");
  DECLAR ("en_key_out", ":2", "B", OUT, "","");
  DECLAR ("finish", ":2", "B", OUT, "","");

  /* Outputs */
  /* for 4 16-bit outpus */
  DECLAR ("y1", ":2", "X", OUT, "15 downto 0", "");
  DECLAR ("y2", ":2", "X", OUT, "15 downto 0", "");
  DECLAR ("y3", ":2", "X", OUT, "15 downto 0", "");
  DECLAR ("y4", ":2", "X", OUT, "15 downto 0", "");
  max =21;
  for (round=0; round<8; round++)
  {
     for (i=0;i<max;i++)
     {
        if(round == 0)
            time = ((round*max) + i) * interval ;
        else if(round ==1 ) {
            max = 16;
            time = ((round*max) + i + 5) * interval; }
        else {
            max = 16;
	    time = ((round*max) + i + 5) * interval; }
  
        AFFECT (inttostr(time), "vdd", "0b1");
	AFFECT (inttostr(time), "vss", "0b0");

         
	if(((time/interval)+2)% 2 == 0)
             AFFECT (inttostr(time), "clk", "0b0");
        else
             AFFECT (inttostr(time), "clk", "0b1");

        if((time/interval) < 2) 
             AFFECT (inttostr(time), "rst", "0b1");
        else
	     AFFECT (inttostr(time), "rst", "0b0");

        if((time/interval) < 5)
	{    AFFECT (inttostr(time), "start", "0b0");
             AFFECT (inttostr(time), "key_ready", "0b0");
        }
        else
 	{    AFFECT (inttostr(time), "start", "0b1");
             AFFECT (inttostr(time), "key_ready", "0b1");
	}	     	
                   	
        AFFECT (inttostr(time), "x1", "48226");
        AFFECT (inttostr(time), "x2", "26081");
	AFFECT (inttostr(time), "x3", "53476");
        AFFECT (inttostr(time), "x4", "29722");
        
        if(round == 0)
        {    LABEL ("round_1");
             AFFECT (inttostr(time), "z1", "26010");
             AFFECT (inttostr(time), "z2", "65088");
	     AFFECT (inttostr(time), "z3", "64960");
             AFFECT (inttostr(time), "z4", "59486");
	     AFFECT (inttostr(time), "z5", "40961");
             AFFECT (inttostr(time), "z6", "57346");
        }
        else if(round == 1)
        {    LABEL ("round_2");
             AFFECT (inttostr(time), "z1", "52428");
             AFFECT (inttostr(time), "z2", "57343");
	     AFFECT (inttostr(time), "z3", "8191");
             AFFECT (inttostr(time), "z4", "13109");
	     AFFECT (inttostr(time), "z5", "8192");
             AFFECT (inttostr(time), "z6", "24576");
        }
        else if(round == 2)
        {    LABEL ("round_3");
	     AFFECT (inttostr(time), "z1", "46227");
             AFFECT (inttostr(time), "z2", "65360");
	     AFFECT (inttostr(time), "z3", "65392");
             AFFECT (inttostr(time), "z4", "50098");
	     AFFECT (inttostr(time), "z5", "48");
             AFFECT (inttostr(time), "z6", "80");
        }
	else if(round == 3)
        {    LABEL ("round_4");
	     AFFECT (inttostr(time), "z1", "56170");
             AFFECT (inttostr(time), "z2", "65296");
	     AFFECT (inttostr(time), "z3", "47104");
             AFFECT (inttostr(time), "z4", "30600");
	     AFFECT (inttostr(time), "z5", "6144");
             AFFECT (inttostr(time), "z6", "10240");	
 	}
        else if(round == 4)
	{    LABEL ("round_5");
	     AFFECT (inttostr(time), "z1", "5955");
             AFFECT (inttostr(time), "z2", "34816");
	     AFFECT (inttostr(time), "z3", "38912");
             AFFECT (inttostr(time), "z4", "61680");
	     AFFECT (inttostr(time), "z5", "20");
             AFFECT (inttostr(time), "z6", "28");
        }
	else if(round == 5)
	{    LABEL ("round_6");
	     AFFECT (inttostr(time), "z1", "3781");
             AFFECT (inttostr(time), "z2", "65468");
	     AFFECT (inttostr(time), "z3", "65476");
             AFFECT (inttostr(time), "z4", "38230");
	     AFFECT (inttostr(time), "z5", "36");
             AFFECT (inttostr(time), "z6", "44");
	}
        else if(round == 6)
	{    LABEL ("round_7");
	     AFFECT (inttostr(time), "z1", "30238");
             AFFECT (inttostr(time), "z2", "56832");
	     AFFECT (inttostr(time), "z3", "57856");
             AFFECT (inttostr(time), "z4", "21803");
	     AFFECT (inttostr(time), "z5", "4608");
             AFFECT (inttostr(time), "z6", "5632");     		 
	}
	else 
	{    max=22;
             LABEL ("round_8");
	     AFFECT (inttostr(time), "z1", "30584");
             AFFECT (inttostr(time), "z2", "62976");
	     AFFECT (inttostr(time), "z3", "65519");
             AFFECT (inttostr(time), "z4", "28069");
	     AFFECT (inttostr(time), "z5", "11");
             AFFECT (inttostr(time), "z6", "13");
	}
	       
	AFFECT (inttostr(time), "z19", "21846");
        AFFECT (inttostr(time), "z29", "65531");
	AFFECT (inttostr(time), "z39", "65529");
        AFFECT (inttostr(time), "z49", "7282");    
	
      } 
    }
  SAV_GENPAT ();
}                              

