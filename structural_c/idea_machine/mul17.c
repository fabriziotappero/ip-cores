/* File Name      : mul17.c					  */
/* Description    : The 17x17 bit multiplier		          */
/* Date		  : Aug 21, 2001				  */
/* Version        : 1.1						  */
/* Author         : Martadinata A.                                */
/* Adress         : VLSI RG, Dept. Electrical of Engineering ITB, */
/*                  Bandung, Indonesia                            */
/* E-mail         : marta@ic.vlsi.itb.ac.id                       */

#include <genlib.h>

main()
{
 int i;

 DEF_LOFIG ("mul17");

 LOCON ("a[16:0]", IN, "a[16:0]");
 LOCON ("b[16:0]", IN, "b[16:0]");
 LOCON ("sum[31:0]", OUT, "sum[31:0]");
 LOCON ("vdd", IN, "vdd");
 LOCON ("vss", IN, "vss");


 LOINS("leftshifter_glopg","lshifter", "a[16:0]",
                "b[15:0]", "r0[31:0]","r1[31:0]","r2[31:0]","r3[31:0]","r4[31:0]",
                "r5[31:0]","r6[31:0]","r7[31:0]","r8[31:0]","r9[31:0]","r10[31:0]",
                "r11[31:0]","r12[31:0]","r13[31:0]","r14[31:0]","r15[31:0]","r16[31:0]",
                "vdd", "vss", 0);

 for(i=0;i<=31;i++)
    LOINS ("zero_x0", NAME("zero%d",i), NAME("o_zero[%d]",i), "vdd", "vss", 0);
 
 LOINS ("m32adder_glopg", "m32add_1", "o_zero[31:0]", "r0[31:0]", "sum1[31:0]", "vdd", "vss", 0);

 for (i = 2; i <= 17; i++)
    LOINS("m32adder_glopg", NAME("m32add_%d", i), NAME("sum%d[31:0]", i-1),
                NAME("r%d[31:0]", i-1), NAME("sum%d[31:0]", i), "vdd", "vss", 0);

 for (i = 0; i <=31 ;i++)
    LOINS ("o2_x2", NAME("or2_%d",i),"b[16]",NAME("sum17[%d]",i),NAME("sum[%d]",i), 
    "vdd", "vss", 0);
 SAVE_LOFIG();
 exit(0);
}
