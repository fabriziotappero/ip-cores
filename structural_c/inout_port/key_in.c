/* File Name    : key_in.c					 */
/* Description  : The key in block 		 		 */
/* Purpose	: To be used by GENLIB				 */
/* Date 	: Aug 30, 2001					 */
/* Version 	: 1.1						 */	
/* Author 	: Sigit Dewantoro				 */
/* Address      : VLSI RG, Dept. of Electrical Engineering ITB,  */
/*                Bandung, Indonesia                             */
/* E-mail       : sigit@ic.vlsi.itb.ac.id                        */

#include<genlib.h>
main()
{
 int i;
 DEF_LOFIG("key_in");
 LOCON("inkey[31:0]",      IN,  "inkey[31:0]"   ); 
 LOCON("key_sended",         IN,  "key_sended"      );
 LOCON("clk",               IN,  "clk"            );
 LOCON("rst",               IN,  "rst"            );
 LOCON("req_key",           OUT,  "req_key"         );
 LOCON("ikey_ready",       INOUT,  "ikey_ready"       );
 LOCON("inkey64[127:0]",   OUT,  "inkey64[127:0]" );
 LOCON("vdd",               IN,  "vdd"            );
 LOCON("vss",               IN,  "vss"            );


 LOINS("dec1to4","dec12","inkey[31:0]","n_block","en_bufin","rst","inkey64_total[127:95]",
			"inkey64_total[95:64]","inkey64_total[63:32]","inkey64_total[31:0]","vdd","vss",0);

 LOINS("in_key","ctrl_inkey","clk","rst","key_sended","en_bufin",
                        "req_key","ikey_ready","n_block", "vdd","vss",0);
 for(i=0;i<128;i++) 
    LOINS("buf_x2",NAME("buf%d",i),NAME("inkey64_total[%d]",i),NAME("inkey64[%d]",i),
                   "vdd","vss",0);
 
 SAVE_LOFIG();
 exit(0);
}
