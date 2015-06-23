#include <string.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "../common/tagScan.h"

#define TAG_FILE_HDR_BEGIN  "-- <File header>"
#define TAG_FILE_HDR_END    "-- </File header>"
#define TAG_FILE_INFO_BEGIN "-- <File info>"
#define TAG_FILE_INFO_END   "-- </File info>"
#define TAG_FILE_BODY_BEGIN "-- <File body>"
#define TAG_FILE_BODY_END   "-- </File body>"

#define TAGGED_PARAGRAPHS_SEPARATOR "\n\n\n\n"



int main(int argc, char * argv[]) {
   FILE *fStr1;
   scanTag_t stag;
   long int pos1, pos2;
   char *tStr1, *tStr2;
   char chr;

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

         // Make room for template header, 2x(CR+LF), and string terminator.
         tStr1 = (char *) malloc(pos2-pos1+4+2);
         tStr2 = (char *) malloc(1+2);
         strcpy(tStr1, "\n");
         fseek(fStr1, 0L, SEEK_SET);
         while (feof(fStr1) == 0)
         {
            fread(&chr, 1, 1, fStr1);
            if (feof(fStr1) == 0)
            {
               sprintf(tStr2, "%c", chr);
               strcat(tStr1, tStr2);
            }
         }

         // Scan VHDL source and modify the paragraph tagged by `-- <File Header>' `-- </File Header>'.
         scanTag_t_writeTaggedText(TAG_FILE_HDR_BEGIN, TAG_FILE_HDR_END, tStr1, argv[1], &stag);
         free(tStr1);
         free(tStr2);
      }
      else
      {
         exit(1);
      }


      fprintf(stdout, "status=%s\n", scanTag_t_getStatus(&stag));
      scanTag_t_destruct(&stag);
   }
   else
   {
      fprintf(stdout, "Usage: this_executable vhdl_src template_hdr\n");
   }
   return 0;
}
