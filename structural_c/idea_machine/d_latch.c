/* File Name    :  d_latch.c					 */
/* Description  :  The D latch with an asynchronized clr 	 */ 
/* Purpose 	:  To be used by GENLIB				 */
/* Date		:  Aug 21, 2001					 */
/* Version	:  1.1						 */
/* Author	:  Martadinata A.				 */
/* Address	:  VLSI RG, Dept. of Electrical Engineering ITB, */
/*		   Bandung, Indonesia				 */
/* E-mail	:  marta@ic.vlsi.itb.ac.id			 */
				
#include<genlib.h>
main()
{
 DEF_LOFIG("d_latch");
 LOCON("d",       IN,  "d"  );
 LOCON("ck",      IN,  "ck" );
 LOCON("clr",     IN,  "clr");
 LOCON("q",    INOUT,  "q"  ); 
 LOCON("vdd",     IN,  "vdd");
 LOCON("vss",     IN,  "vss");

 LOINS("inv_x2","inv","d","o_inv","vdd","vss",0);
 LOINS("a2_x2","an1","o_inv","ck","o_an1","vdd","vss",0);
 LOINS("a2_x2","an2","d","ck","o_an2","vdd","vss",0);
 LOINS("no3_x4","nor1","o_an1","clr","o_nor2","q","vdd","vss",0);
 LOINS("no2_x4","nor2","q","o_an2","o_nor2","vdd","vss",0);   

 SAVE_LOFIG();
 exit(0);
}
