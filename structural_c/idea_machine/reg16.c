/* File Name     : reg16.c					 */
/* Description   : The 16-bit register 		 		 */
/* Purpose	 : To be used by GENLIB				 */
/* Date 	 : Aug 22, 2001					 */
/* Version 	 : 1.1						 */	
/* Author 	 : Martadinata A.				 */
/* Address      :  VLSI RG, Dept. of Electrical Engineering ITB, */
/*                 Bandung, Indonesia                            */
/* E-mail       :  marta@ic.vlsi.itb.ac.id                       */

#include<genlib.h>
main()
{
 int i;
 DEF_LOFIG("reg16");
 LOCON("d[0:15]",     IN,  "d[0:15]"  );
 LOCON("en",          IN,  "en"       );
 LOCON("clr",         IN,  "clr"      );
 LOCON("q[0:15]",   INOUT,  "q[0:15]" );
 LOCON("vdd",         IN,  "vdd"      );
 LOCON("vss",         IN,  "vss"      );
 
 for(i=0;i<=15;i++)
 {
  LOINS("d_latch_glopf",NAME("latch%d",i),NAME("d[%d]",i),"en","clr",NAME("q[%d]",i),"vdd","vss",0);
 }
 
 SAVE_LOFIG();
 exit(0);
}
