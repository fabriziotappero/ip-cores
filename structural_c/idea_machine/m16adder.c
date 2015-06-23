/* File Name   : m16adder.c            				*/ 
/* Description : The modulo 2^16 adder 				*/
/* Purpose     : To be used by GENLIB				*/
/* Date	       : Aug 21, 2001          				*/
/* Version     : 1.1                   				*/
/* Author      : Martadinata A.        				*/
/* Address     : VLSI RG, Dept. of Electrical Engineering ITB,  */
/*	         Bandung, Indonesia				*/
/* E-mail      : marta@ic.vlsi.itb.ac.id                        */

#include<genlib.h>
main()
{
 int i;
 DEF_LOFIG("m16adder");
 LOCON("a[0:15]",     IN,  "a[0:15]"  );
 LOCON("b[0:15]",     IN,  "b[0:15]"  );
 LOCON("s[0:15]",    OUT,  "s[0:15]"  );
 LOCON("vdd",         IN,  "vdd"      );
 LOCON("vss",         IN,  "vss"      );

 for(i=0;i<=15;i++)
    if(i==0)
    LOINS("halfadder_glopf","ha","a[0]","b[0]","c[0]","s[0]","vdd","vss",0);

    else if(i==15) {  
        LOINS("xr2_x1","xr1",NAME("a[%d]",i),NAME("b[%d]",i),"o_xr1","vdd","vss",0);
        LOINS("xr2_x1","xr2","o_xr1",NAME("c[%d]",i-1),NAME("s[%d]",i),"vdd","vss",0); 
    }
    else
	LOINS("fulladder_glopg",NAME("fa%d",i),
		NAME("a[%d]",i),NAME("b[%d]",i),NAME("c[%d]",i-1),
                NAME("c[%d]",i),NAME("s[%d]",i),"vdd","vss",0); 

 SAVE_LOFIG();
 exit(0);
}
