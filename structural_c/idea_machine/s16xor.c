/* File Name     : s16xor.c					 */
/* Description   : The synchronized 16-bit xor 		 	 */
/* Purpose	 : To be used by GENLIB				 */
/* Date 	 : Aug 23, 2001					 */
/* Version 	 : 1.1						 */
/* Author 	 : Martadinata A.				 */
/* Address       : VLSI RG, Dept. of Electrical Engineering ITB, */
/*                 Bandung, Indonesia                            */
/* E-mail        : marta@ic.vlsi.itb.ac.id                       */

#include<genlib.h>
main()
{
 DEF_LOFIG("s16xor");
 LOCON("a[0:15]",     IN,  "a[0:15]"  );
 LOCON("b[0:15]",     IN,  "b[0:15]"  );
 LOCON("en",          IN,  "en"       );
 LOCON("clr",         IN,  "clr"      );
 LOCON("q[0:15]",  INOUT,  "q[0:15]"  );
 LOCON("vdd",         IN,  "vdd"      );
 LOCON("vss",         IN,  "vss"      );

 LOINS("xor16_glopg","xr16","a[0:15]","b[0:15]","o_xr16[0:15]","vdd","vss",0);
 LOINS("reg16_glopf","rg16","o_xr16[0:15]","en","clr","q[0:15]","vdd","vss",0);

 SAVE_LOFIG();
 exit(0);
}
