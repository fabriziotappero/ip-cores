#include "systemc.h"
#include "top.h"
#include "./constants/constants.h"
#include "./constants/debug_signal.h"
#include "stdio.h"
#include "fstream.h"
#include "iostream.h"

SC_MODULE(top_debug)
{
   sc_in<bool> in_clk;

   void debug_signals();
   
   FILE *fp;
   top *top_level;

   typedef top_debug SC_CURRENT_USER_MODULE;
   top_debug(sc_module_name name, char *contents_file)
   {
      top_level = new top("Top-level", contents_file);
      top_level->in_clk(in_clk);
  
  
      fp = fopen("LOG.txt","wt");
      fprintf(fp,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
      fprintf(fp,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    MIPS R2000    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
      fprintf(fp,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx     LOG FILE     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
      fprintf(fp,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx      V 1.0       xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
      fprintf(fp,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  DIEE  Igor Loi  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
      fprintf(fp,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
  
      SC_METHOD(debug_signals);
      sensitive_pos << in_clk;
   }
};
