/* File Name    : idea_encryptor.c				 */
/* Description  : The enncryption block of IDEA processor        */
/* Purpose	: To be used by GENLIB				 */
/* Date 	: Aug 22, 2001					 */
/* Version 	: 1.1						 */	
/* Author 	: Martadinata A.				 */
/* Address      : VLSI RG, Dept. of Electrical Engineering ITB,  */
/*                Bandung, Indonesia                             */
/* E-mail       : marta@ic.vlsi.itb.ac.id                        */

#include<genlib.h>
main()
{
 DEF_LOFIG("idea_encryptor");
 LOCON("clk",          IN,  "clk"        );
 LOCON("rst",          IN,  "rst"        );
 LOCON("start",        IN,  "start"      );
 LOCON("key_ready",    IN,  "key_ready"  );
 LOCON("x1[15:0]",     IN,  "x1[15:0]"   );
 LOCON("x2[15:0]",     IN,  "x2[15:0]"   );
 LOCON("x3[15:0]",     IN,  "x3[15:0]"   );
 LOCON("x4[15:0]",     IN,  "x4[15:0]"   );

 LOCON("z1[15:0]",     IN,  "z1[15:0]"   );
 LOCON("z2[15:0]",     IN,  "z2[15:0]"   );
 LOCON("z3[15:0]",     IN,  "z3[15:0]"   );
 LOCON("z4[15:0]",     IN,  "z4[15:0]"   );
 LOCON("z5[15:0]",     IN,  "z5[15:0]"   );
 LOCON("z6[15:0]",     IN,  "z6[15:0]"   );
 LOCON("z19[15:0]",    IN,  "z19[15:0]"  );
 LOCON("z29[15:0]",    IN,  "z29[15:0]"  );
 LOCON("z39[15:0]",    IN,  "z39[15:0]"  );
 LOCON("z49[15:0]",    IN,  "z49[15:0]"  );
 LOCON("y1[15:0]",    OUT,  "y1[15:0]"   );
 LOCON("y2[15:0]",  INOUT,  "y2[15:0]"   );
 LOCON("y3[15:0]",  INOUT,  "y3[15:0]"   );
 LOCON("y4[15:0]",    OUT,  "y4[15:0]"   );
 LOCON("round[2:0]",  OUT,  "round[2:0]" );
 LOCON("en_key_out",  OUT,  "en_key_out" );
 LOCON("finish",      OUT,  "finish"     );
 LOCON("vdd",         IN,   "vdd"        );
 LOCON("vss",         IN,   "vss"        );

 LOINS("idea_heart_glopf","heart","en[1:7]","en_out","clk","sel_in","x1[0:15]","x2[0:15]",
     "x3[0:15]","x4[0:15]","z1[0:15]","z2[0:15]","z3[0:15]","z4[0:15]","z5[0:15]",
     "z6[0:15]","z19[0:15]","z29[0:15]","z39[0:15]","z49[0:15]","y1[0:15]","y2[0:15]",
      "y3[0:15]","y4[0:15]","rst","vdd","vss",0);

 LOINS("heart_ctrl_glopg","h_ctrl","clk","rst","start","key_ready","round[2:0]","en[1:7]",
       "en_out","en_key_out","sel_in","finish","vdd","vss",0);

 SAVE_LOFIG();
 exit(0);
}
