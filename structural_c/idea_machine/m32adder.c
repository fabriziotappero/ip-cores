/* File Name    :  m32adder.c                                    */
/* Description  :  The modulo 2^32 adder                         */
/* Date         :  Aug 22, 2001                                  */
/* Version      :  1.1                                           */
/* Author       :  Martadinata A.                                */
/* Adress       :  VLSI RG, Dept. Electrical of Engineering ITB, */
/*                 Bandung, Indonesia                            */
/* E-mail       :  marta@ic.vlsi.itb.ac.id                       */


#include <genlib.h>

main()
{
 int i;

 DEF_LOFIG ("m32adder");

 LOCON ("a[31:0]", IN, "a[31:0]");
 LOCON ("b[31:0]", IN, "b[31:0]");
 LOCON ("sum[31:0]", OUT, "sum[31:0]");
 LOCON ("vdd", IN, "vdd");
 LOCON ("vss", IN, "vss");

 LOINS ("halfadder_glopf", "halfadder", "a[0]", "b[0]", "cout0", "sum[0]","vdd", "vss", 0);

 for (i = 1; i <= 30; i++)
   LOINS("fulladder_glopg", NAME("fulladder%d", i), NAME("a[%d]", i),NAME("b[%d]", i),
          NAME("cout%d", i-1), NAME("cout%d", i), NAME("sum[%d]", i), "vdd", "vss", 0);

 LOINS ("xr2_x1", "xr1", "a[31]", "b[31]", "o_xr1", "vdd", "vss", 0);
 LOINS ("xr2_x1", "xr2", "o_xr1", "cout30", "sum[31]", "vdd", "vss", 0);
 SAVE_LOFIG();
 exit(0);
}
