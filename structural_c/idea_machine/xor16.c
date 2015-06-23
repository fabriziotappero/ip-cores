/* File Name     : xor16.c					 */
/* Description   : The 16-bit xor 		 	         */
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
 int i;
 DEF_LOFIG("xor16");
 LOCON("a[0:15]",     IN,  "a[0:15]"  );
 LOCON("b[0:15]",     IN,  "b[0:15]"  );
 LOCON("q[0:15]",    OUT,  "q[0:15]"  );
 LOCON("vdd",         IN,  "vdd"      );
 LOCON("vss",         IN,  "vss"      );

 for(i=0;i<16;i++)
 LOINS("xr2_x4",NAME("xr%d",i),NAME("a[%d]",i),NAME("b[%d]",i),NAME("q[%d]",i),"vdd","vss",0);

 SAVE_LOFIG();
 exit(0);
}
