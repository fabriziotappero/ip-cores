/* File Name    : data_in.c					 */
/* Description  : The data in block 		 		 */
/* Purpose	: To be used by GENLIB				 */
/* Date 	: Aug 30, 2001					 */
/* Version 	: 1.1						 */	
/* Author 	: Martadinata A.				 */
/* Address      : VLSI RG, Dept. of Electrical Engineering ITB,  */
/*                Bandung, Indonesia                             */
/* E-mail       : marta@ic.vlsi.itb.ac.id                        */

#include<genlib.h>
main()
{
 int i;
 DEF_LOFIG("data_in");
 LOCON("datain[31:0]",      IN,  "datain[31:0]"   ); 
 LOCON("dt_sended",         IN,  "dt_sended"      );
 LOCON("emp_buf",           IN,  "emp_buf"        );
 LOCON("clk",               IN,  "clk"            );
 LOCON("rst",               IN,  "rst"            );
 LOCON("req_dt",           OUT,  "req_dt"         );
 LOCON("dt_ready",       INOUT,  "dt_ready"       );
 LOCON("data64in[63:0]",   OUT,  "data64in[63:0]" );
 LOCON("vdd",               IN,  "vdd"            );
 LOCON("vss",               IN,  "vss"            );


 LOINS("dec1to2","dec12","datain[31:0]","n_block","en_bufin","rst","data64in_t[63:32]",
			"data64in_t[31:0]","vdd","vss",0);

 LOINS("control_datain","ctrl_dtin","clk","rst","dt_sended","emp_buf","en_bufin",
                        "req_dt","dt_ready","n_block", "vdd","vss",0);
 for(i=0;i<=63;i++) 
    LOINS("buf_x2",NAME("buf%d",i),NAME("data64in_t[%d]",i),NAME("data64in[%d]",i),
                   "vdd","vss",0);
 
 SAVE_LOFIG();
 exit(0);
}
