/* File Name   : sm16plus1mul.c 	           			*/
/* Description : The synchronized modulo 2^16+1 multiplier	 	*/ 
/* Purpose     : To be used by GENLIB		  			*/ 
/* Date	       : Aug 23, 2001          					*/ 
/* Version     : 1.1                   					*/ 
/* Author      : Martadinata A.        					*/ 
/* Address     : VLSI RG, Dept. of Electrical Engineering ITB,  	*/
/*	         Bandung, Indonesia					*/
/* E-mail      : marta@ic.vlsi.itb.ac.id                        	*/

#include<genlib.h>
main()
{
 DEF_LOFIG("sm16plus1mul");
 LOCON("in1[0:15]",     IN,  "in1[0:15]"    );
 LOCON("in2[0:15]",     IN,  "in2[0:15]"    );
 LOCON("en",            IN,  "en"           );
 LOCON("clr",           IN,  "clr"          );
 LOCON("mulout[0:15]", OUT,  "mulout[0:15]" );
 LOCON("vdd",           IN,  "vdd"          );
 LOCON("vss",           IN,  "vss"          );

 LOINS("comp1_glopg","com1a","in1[15:0]","kout1a[16:0]","vdd","vss",0);
 LOINS("comp1_glopg","com1b","in2[15:0]","kout1b[16:0]","vdd","vss",0);
 LOINS("mul17_glopg","mul","kout1a[16:0]","kout1b[16:0]","res[31:0]","vdd","vss",0);
 LOINS("comp2_glopg","com2","vss","vdd","kout2[0:15]","res[16:31]","res[0:15]",0);
 LOINS("subtract16_glopg","sub","res[0:15]","res[16:31]","dif[0:15]","vdd","vss",0);
 LOINS("reg16_glopf","reg1","kout2[0:15]","en","clr","r1[0:15]","vdd","vss",0);
 LOINS("reg16_glopf","reg2","dif[0:15]","en","clr","r2[0:15]","vdd","vss",0); 
 LOINS("m16adder_glopg","add","r2[0:15]","r1[0:15]","mulout[0:15]","vdd","vss",0);
 SAVE_LOFIG();
 exit(0);
}
