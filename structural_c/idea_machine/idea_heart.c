/* File Name   : idea_heart.c            			*/ 
/* Description : The idea processor heart 	 		*/ 
/* Purpose     : To be used by GENLIB				*/ 
/* Date	       : Aug 23, 2001          				*/ 
/* Version     : 1.1                   				*/ 
/* Author      : Martadinata A.        				*/ 
/* Address     : VLSI RG, Dept. of Electrical Engineering ITB,  */
/*	         Bandung, Indonesia				*/
/* E-mail      : marta@ic.vlsi.itb.ac.id                        */

#include<genlib.h>
main()
{
 DEF_LOFIG("idea_heart");
 LOCON("en[1:7]",     IN,  "en[1:7]"   );
 LOCON("en_out",      IN,  "en_out"    );
 LOCON("sel_in",      IN,  "sel_in"    );
 LOCON("x1[0:15]",    IN,  "x1[0:15]"  );
 LOCON("x2[0:15]",    IN,  "x2[0:15]"  );
 LOCON("x3[0:15]",    IN,  "x3[0:15]"  );
 LOCON("x4[0:15]",    IN,  "x4[0:15]"  ); 
 LOCON("z1[0:15]",    IN,  "z1[0:15]"  );
 LOCON("z2[0:15]",    IN,  "z2[0:15]"  );
 LOCON("z3[0:15]",    IN,  "z3[0:15]"  );
 LOCON("z4[0:15]",    IN,  "z4[0:15]"  );
 LOCON("z5[0:15]",    IN,  "z5[0:15]"  );
 LOCON("z6[0:15]",    IN,  "z6[0:15]"  );
 LOCON("z19[0:15]",   IN,  "z19[0:15]" );
 LOCON("z29[0:15]",   IN,  "z29[0:15]" );
 LOCON("z39[0:15]",   IN,  "z39[0:15]" );
 LOCON("z49[0:15]",   IN,  "z49[0:15]" );


 LOCON("y1[0:15]",    OUT,  "y1[0:15]"  );
 LOCON("y2[0:15]",  INOUT, "y2[0:15]"  );
 LOCON("y3[0:15]",  INOUT, "y3[0:15]"  );
 LOCON("y4[0:15]",    OUT,  "y4[0:15]"  );
 LOCON("reset",       IN,  "reset"     );
 LOCON("vdd",         IN,  "vdd"       );
 LOCON("vss",         IN,  "vss"       );

 LOINS("mux64_glopg","mux1","x1[15:0]","x2[15:0]","x3[15:0]","x4[15:0]",
		      "y1x[15:0]","y2x[15:0]","y3x[15:0]","y4x[15:0]",
		      "sel_in",
		      "o_mux1[15:0]","o_mux2[15:0]","o_mux3[15:0]","o_mux4[15:0]",
		      "vdd","vss",0);

 LOINS("idea_heart_1r_glopf","idea_h_1r","en[1:7]","o_mux1[0:15]","o_mux2[0:15]","o_mux3[0:15]",
        "o_mux4[0:15]",
        "z1[0:15]","z2[0:15]","z3[0:15]","z4[0:15]","z5[0:15]","z6[0:15]",
        "y1x[0:15]","y2x[0:15]","y3x[0:15]","y4x[0:15]","reset","vdd","vss",0);
        
 LOINS("out_trans_glopf","trans","en_out","y1x[0:15]","y2x[0:15]","y3x[0:15]","y4x[0:15]",
       "z19[0:15]","z29[0:15]","z39[0:15]","z49[0:15]","y1[0:15]","y2[0:15]","y3[0:15]",
       "y4[0:15]","reset","vdd","vss",0);
        
 SAVE_LOFIG();
 exit(0);
}
