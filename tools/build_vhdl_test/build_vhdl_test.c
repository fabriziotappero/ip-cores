#include <string.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "../common/tagScan.h"

#define TAG_CLK_CNT_BEGIN      "-- <Clk Cnt>"
#define TAG_CLK_CNT_END        "-- </Clk Cnt>"
#define TAG_INSTRUCTIONS_BEGIN "-- <Instructions>"
#define TAG_INSTRUCTIONS_END   "-- </Instructions>"

#define CLK_OFFSET 100
//#define K1 "         if std_logic_vector_to_nat(cnt)<"
//#define K2 " then\n"
#define K3 "               when "
#define K4 " => tmpv1 := pm_setup("
#define K5 ", 16#"
#define K6 "#);\n"



int main(int argc, char * argv[]) {
   FILE *fStr1;
   scanTag_t stag;
   long int pos1, pos2;
   char *tStr1, *tStr2;
   int instr;
   int addr;

   if (argc > 2)
   {
      scanTag_t_construct(&stag);

      fStr1 = fopen(argv[2], "rb");
      if (fStr1 != NULL)
      {
         fseek(fStr1, 0L, SEEK_SET);
         pos1 = ftell(fStr1);
         fseek(fStr1, 0L, SEEK_END);
         pos2 = ftell(fStr1);

         tStr1 = (char *) malloc(10+2);
         tStr2 = (char *) malloc(10+2);
         sprintf(tStr2, "%li", CLK_OFFSET+(pos2-pos1)/2);
         strcpy(tStr1, "\n");
         //strcat(tStr1, K1);
         strcat(tStr1, tStr2);
         strcat(tStr1, "\n");
         //strcat(tStr1, K2);

         // Scan VHDL source and modify the paragraph tagged by `-- <Clk Cnt>' `-- </Clk Cnt>'.
         scanTag_t_writeTaggedText(TAG_CLK_CNT_BEGIN, TAG_CLK_CNT_END, tStr1, argv[1], &stag);

         free(tStr1);
         tStr1 = (char *) malloc((pos2-pos1)*(sizeof(K3)+10+sizeof(K4)+10+sizeof(K5)+10+sizeof(K6))+2);
         strcpy(tStr1, "\n");
         fseek(fStr1, 0L, SEEK_SET);
         addr = 0;
         while (feof(fStr1) == 0)
         {
            fread(&instr, 2, 1, fStr1);
            if (feof(fStr1) == 0)
            {
               strcat(tStr1, K3);
               sprintf(tStr2, "%i", addr+CLK_OFFSET);
               strcat(tStr1, tStr2);
               strcat(tStr1, K4);
               sprintf(tStr2, "%i", addr);
               strcat(tStr1, tStr2);
               strcat(tStr1, K5);
               sprintf(tStr2, "%04x", instr);
               strcat(tStr1, tStr2);
               strcat(tStr1, K6);
               addr++;
            }
         }

         // Scan VHDL source and modify the paragraph tagged by `-- <Instructions>' `-- </Instructions>'.
         scanTag_t_writeTaggedText(TAG_INSTRUCTIONS_BEGIN, TAG_INSTRUCTIONS_END, tStr1, argv[1], &stag);
         free(tStr1);
         free(tStr2);
      }
      else
      {
         exit(1);
      }


      fprintf(stdout, "%s\n", scanTag_t_getStatus(&stag));
      scanTag_t_destruct(&stag);
   }
   else
   {
      fprintf(stderr, "Usage: this_executable.exe src.vhd prog.bin\n");
   }
   return 0;
}
