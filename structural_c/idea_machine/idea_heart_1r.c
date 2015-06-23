/* File Name   : idea_heart_1r.c            			*/ 
/* Description : The one round idea processor heart  		*/ 
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
 DEF_LOFIG("idea_heart_1r");
 LOCON("en[1:7]",     IN,  "en[1:7]"  );
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
 LOCON("y1[0:15]", INOUT,  "y1[0:15]"  );
 LOCON("y2[0:15]", INOUT,  "y2[0:15]"  );
 LOCON("y3[0:15]", INOUT,  "y3[0:15]"  );
 LOCON("y4[0:15]", INOUT,  "y4[0:15]"  );
 LOCON("reset",       IN,  "reset"     );
 LOCON("vdd",         IN,  "vdd"       );
 LOCON("vss",         IN,  "vss"       );

 LOINS("sm16plus1mul_glopf","mul1","x1[0:15]","z1[0:15]","en[1]","reset","o_mul1[0:15]","vdd","vss",0);
 LOINS("sm16adder_glopf","add1","x2[0:15]","z2[0:15]","en[1]","reset","o_add1[0:15]","vdd","vss",0);
 LOINS("sm16adder_glopf","add2","x3[0:15]","z3[0:15]","en[1]","reset","o_add2[0:15]","vdd","vss",0);
 LOINS("sm16plus1mul_glopf","mul2","x4[0:15]","z4[0:15]","en[1]","reset","o_mul2[0:15]","vdd","vss",0);
 
 LOINS("s16xor_glopf","xr1","o_mul1[0:15]","o_add2[0:15]","en[2]","reset","o_xr1[0:15]","vdd","vss",0); 
 LOINS("s16xor_glopf","xr2","o_add1[0:15]","o_mul2[0:15]","en[2]","reset","o_xr2[0:15]","vdd","vss",0);
 
 LOINS("sm16plus1mul_glopf","mul3","o_xr1[0:15]","z5[0:15]","en[3]","reset","o_mul3[0:15]","vdd","vss",0);
 LOINS("sm16adder_glopf","add3","o_mul3[0:15]","o_xr2[0:15]","en[4]","reset","o_add3[0:15]","vdd","vss",0);
 LOINS("sm16plus1mul_glopf","mul4","o_add3[0:15]","z6[0:15]","en[5]","reset","o_mul4[0:15]","vdd","vss",0);
 LOINS("sm16adder_glopf","add4","o_mul3[0:15]","o_mul4[0:15]","en[6]","reset","o_add4[0:15]","vdd","vss",0);
 
 LOINS("s16xor_glopf","xr3","o_mul1[0:15]","o_mul4[0:15]","en[7]","reset","y1[0:15]","vdd","vss",0); 
 LOINS("s16xor_glopf","xr4","o_add2[0:15]","o_mul4[0:15]","en[7]","reset","y2[0:15]","vdd","vss",0); 
 LOINS("s16xor_glopf","xr5","o_add1[0:15]","o_add4[0:15]","en[7]","reset","y3[0:15]","vdd","vss",0); 
 LOINS("s16xor_glopf","xr6","o_mul2[0:15]","o_add4[0:15]","en[7]","reset","y4[0:15]","vdd","vss",0); 
 
 SAVE_LOFIG();
 exit(0);
}
