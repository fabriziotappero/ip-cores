/* File Name   : subtract16.c            			*/
/* Description : The 16-bit subtractor 			        */
/* Purpose     : To be used by GENLIB				*/
/* Date	       : Aug 22, 2001          				*/
/* Version     : 1.1                   				*/
/* Author      : Martadinata A.        				*/
/* Address     : VLSI RG, Dept. of Electrical Engineering ITB,  */
/*	         Bandung, Indonesia				*/
/* E-mail      : marta@ic.vlsi.itb.ac.id                        */

#include<genlib.h>
main()
{
 int i;
 DEF_LOFIG("subtract16");
 LOCON("a[0:15]",     IN,  "a[0:15]"  );
 LOCON("b[0:15]",     IN,  "b[0:15]"  );
 LOCON("s[0:15]",    OUT,  "s[0:15]"  );
 LOCON("vdd",         IN,  "vdd"      );
 LOCON("vss",         IN,  "vss"      );

 LOINS("zero_x0","zero","o_zero","vdd","vss",0);
 for(i=0;i<=15;i++)
    if (i==0)
       LOINS("fsub_glopg",NAME("fs%d",i),NAME("a[%d]",i),NAME("b[%d]",i),"o_zero",
       		    NAME("s[%d]",i),NAME("bo[%d]",i),"vdd","vss",0);	     
    else if(i==15) { 
       LOINS("xr2_x1","xr2",NAME("a[%d]",i),NAME("b[%d]",i),"o_xr2","vdd","vss",0);
       LOINS("xr2_x1","xr3","o_xr2",NAME("bo[%d]",i-1),NAME("s[%d]",i),"vdd","vss",0);
    } 
    else 
       LOINS("fsub_glopg",NAME("fs%d",i),NAME("a[%d]",i),NAME("b[%d]",i),NAME("bo[%d]",i-1),
                                  NAME("s[%d]",i),NAME("bo[%d]",i),"vdd","vss",0); 

 SAVE_LOFIG();
 exit(0);
}
