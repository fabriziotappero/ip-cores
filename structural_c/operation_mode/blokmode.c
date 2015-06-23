// File Name    : blokmode.c
// Description  : blokmode in C
// Author       : Sigit Dewantoro
// Date         : July 10th, 2001

#include<genlib.h>

main()
{
 int i;

 DEF_LOFIG("blokmode");
 LOCON("data_in[0:63]", IN, "data_in[0:63]");
 LOCON("ideam_out[0:63]", IN, "ideam_out[0:63]");
 LOCON("rst", IN, "rst");
 LOCON("clk", IN, "clk");
 LOCON("en_in", IN, "en_in");
 LOCON("en_iv", IN, "en_iv");
 LOCON("en_rcbc", IN, "en_rcbc");
 LOCON("en_out", IN, "en_out");
 LOCON("sel1[0:1]", IN, "sel1[0:1]");
 LOCON("sel2[0:1]", IN, "sel2[0:1]");
 LOCON("sel3[0:1]", IN, "sel3[0:1]");
 LOCON("dt_inidea[0:63]", OUT, "dt_inidea[0:63]");
 LOCON("cp_out[0:63]", OUT, "cp_out[0:63]");
 LOCON("vdd", IN, "vdd");
 LOCON("vss", IN, "vss");

 for (i=0;i<64;i++) 
 LOINS ("zero_x0", NAME("zero%d",i), NAME("zero64[%d]",i), "vdd", "vss", 0);  

 LOINS ("register64", "reg_in", "data_in[0:63]", "rst","en_in", "reg_in[0:63]", "vdd", "vss", 0);
 LOINS ("mux64", "mux1", "xor2[63:0]", "reg_in[63:0]", "zero64[63:0]", "sel1[1:0]", "mux1[63:0]", "vdd", "vss", 0); 
 LOINS ("register64", "reg_iv","mux1[0:63]", "rst", "en_iv", "reg_iv[0:63]", "vdd", "vss", 0);
 LOINS ("mux64", "mux2", "xor2[63:0]", "reg_iv[63:0]", "zero64[63:0]", "sel2[1:0]", "mux2[63:0]","vdd", "vss", 0);
 LOINS ("xor64", "xor1", "mux1[63:0]", "mux2[63:0]", "dt_inidea[63:0]", "vdd", "vss", 0);
 LOINS ("register64", "reg_cbc", "reg_iv[0:63]", "rst","en_rcbc", "reg_cbc[0:63]", "vdd", "vss", 0);
 LOINS ("mux64", "mux3", "reg_cbc[63:0]", "reg_in[63:0]", "zero64[63:0]", "sel3[1:0]","mux3[63:0]","vdd", "vss", 0);
 LOINS ("xor64", "xor2", "ideam_out[63:0]", "mux3[63:0]", "xor2[63:0]", "vdd", "vss", 0);
 LOINS ("register64", "reg_out","xor2[0:63]", "rst","en_out","cp_out[0:63]", "vdd", "vss", 0); 

 SAVE_LOFIG();
 exit(0);
}
