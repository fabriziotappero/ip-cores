/* File Name     : out_trans.c					 */
/* Description   : The output transformation                     */
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
 DEF_LOFIG("out_trans");
 LOCON("en",          IN,  "en"        );
 LOCON("x1[0:15]",    IN,  "x1[0:15]"  );
 LOCON("x2[0:15]",    IN,  "x2[0:15]"  );
 LOCON("x3[0:15]",    IN,  "x3[0:15]"  );
 LOCON("x4[0:15]",    IN,  "x4[0:15]"  ); 
 LOCON("z1[0:15]",    IN,  "z1[0:15]"  );
 LOCON("z2[0:15]",    IN,  "z2[0:15]"  );
 LOCON("z3[0:15]",    IN,  "z3[0:15]"  );
 LOCON("z4[0:15]",    IN,  "z4[0:15]"  );
 LOCON("y1[0:15]",   OUT, "y1[0:15]"   );
 LOCON("y2[0:15]",  INOUT, "y2[0:15]"  );
 LOCON("y3[0:15]",  INOUT, "y3[0:15]"  );
 LOCON("y4[0:15]",    OUT, "y4[0:15]"  );
 LOCON("reset",       IN,  "reset"     );
 LOCON("vdd",         IN,  "vdd"       );
 LOCON("vss",         IN,  "vss"       );

 LOINS("sm16plus1mul_glopf","trans1","x1[0:15]","z1[0:15]","en","reset","y1[0:15]","vdd","vss",0);
 LOINS("sm16adder_glopf","trans2","x3[0:15]","z2[0:15]","en","reset","y2[0:15]","vdd","vss",0);
 LOINS("sm16adder_glopf","trans3","x2[0:15]","z3[0:15]","en","reset","y3[0:15]","vdd","vss",0);
 LOINS("sm16plus1mul_glopf","trans4","x4[0:15]","z4[0:15]","en","reset","y4[0:15]","vdd","vss",0);
 
 SAVE_LOFIG();
 exit(0);
}
