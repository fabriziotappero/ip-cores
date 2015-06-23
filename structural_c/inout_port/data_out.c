/* File Name    : data_out.c					 */
/* Description  : The data out block 		 		 */
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
 DEF_LOFIG("data_out");
 LOCON("data64out[63:0]",   IN,  "data64out[63:0]" ); 
 LOCON("cp_ready",          IN,  "cp_ready"        );
 LOCON("emp_bufout",        IN,  "emp_bufout"      );
 LOCON("clk",               IN,  "clk"             );
 LOCON("rst",               IN,  "rst"             );
 LOCON("req_cp",           OUT,  "req_cp"          );
 LOCON("cp_sended",        OUT,  "cp_sended"       );
 LOCON("dataout[31:0]",    OUT,  "dataout[31:0]"   );
 LOCON("vdd",               IN,  "vdd"             );
 LOCON("vss",               IN,  "vss"             );


 LOINS("mux2to1","mux","data64out[63:0]","n_block","en_bufout","rst",
		    "dataout[31:0]","vdd","vss",0);

 LOINS("control_dataout","ctrl_dtout","clk","rst","cp_ready","emp_bufout",
		   "en_bufout","req_cp","cp_sended","n_block","vdd","vss",0);   

 SAVE_LOFIG();  exit(0);
}
