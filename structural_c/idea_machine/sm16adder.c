/* File Name     : sm16adder.c					 */
/* Description   : The synchronized modulo 2^16 adder 		 */
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
 DEF_LOFIG("sm16adder");
 LOCON("a[0:15]",     IN,  "a[0:15]"  );
 LOCON("b[0:15]",     IN,  "b[0:15]"  );
 LOCON("en",          IN,  "en"       );
 LOCON("clr",         IN,  "clr"      );
 LOCON("s[0:15]",  INOUT,  "s[0:15]"  );
 LOCON("vdd",         IN,  "vdd"      );
 LOCON("vss",         IN,  "vss"      );

 LOINS("m16adder_glopg","sm16a","a[0:15]","b[0:15]","ss[0:15]","vdd","vss",0);
 LOINS("reg16_glopf","rg16","ss[0:15]","en","clr","s[0:15]","vdd","vss",0);
 
 SAVE_LOFIG();
 exit(0);
}
