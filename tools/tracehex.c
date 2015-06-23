/***********************************************************
| tracehex by Steve Rhoads 12/25/01
| This tool modifies trace files from the free VHDL simulator 
| http://www.symphonyeda.com/.
| The binary numbers are converted to hex values.
************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define BUF_SIZE (1024*1024*4)
#define LINE_SIZE 10000

char drop_char[10000];

int main(int argc, char *argv[])
{
   FILE *file;
   char *buf,*ptr_in,*ptr_out,*line_store,*line;
   char *line_start,*source_start;
   int bytes,digits,value,isbinary,col,col_num,row,drop_cnt;
   int col_index,line_index,back_count,drop_start=0;
   int digits_length=0;
   (void)argc;
   (void)argv;

   printf("tracehex\n");

   /* Reading trace.txt */
   file=fopen("trace.txt","r");
   if(file==NULL) {
      printf("Can't open file\n");
      return -1;
   }
   line_store=(char*)malloc(LINE_SIZE);
   line_store[0]=' ';
   line=line_store+1;
   buf=(char*)malloc(BUF_SIZE*2);
   if(buf==NULL) {
      printf("Can't malloc!\n");
      return -1;
   }
   ptr_out=buf+BUF_SIZE;
   bytes=fread(buf,1,BUF_SIZE-1,file);
   buf[bytes]=0;
   fclose(file);

   digits=0;
   value=0;
   isbinary=0;
   col=0;
   col_num=0;
   row=0;
   line_start=ptr_out;
   source_start=buf;
   for(ptr_in=strstr(buf,"=");*ptr_in;++ptr_in) {
      ++col;
      if(drop_start==0&&*ptr_in==' ') {
         for(drop_start=3;drop_start<30;++drop_start) {
            if(ptr_in[drop_start]!=' ') {
               break;
            }
         }
         for(;drop_start<30;++drop_start) {
            if(ptr_in[drop_start]==' ') {
               break;
            }
         }
         drop_start-=2;
      }
      if(col<4) {
         drop_char[col]=1;
         continue;
      }
      if(drop_start<=col&&col<=drop_start+2) {
         drop_char[col]=1;
         continue;
      }
      if(col<drop_start) {
         *ptr_out++=*ptr_in;
         continue;
      }
      
      /* convert binary number to hex */
      if(isbinary&&(*ptr_in=='0'||*ptr_in=='1')) {
         value=value*2+*ptr_in-'0';
         ++digits;
         drop_char[col_num++]=1;
      } else if(isbinary&&*ptr_in=='Z') {
         value=1000;
         ++digits;
         drop_char[col_num++]=1;
      } else if(isbinary&&(*ptr_in=='U'||*ptr_in=='X')) {
         value=10000;
         ++digits;
         drop_char[col_num++]=1;
      } else {
         if(*ptr_in=='\n') {
            col=0;
            isbinary=0;
            ++row;
         }
         if(isspace(*ptr_in)) {
            if(col>10) {
               isbinary=1;
               col_num=col;
               for(digits_length=1;!isspace(ptr_in[digits_length]);++digits_length) ;
               --digits_length;
            }
         } else {
            isbinary=0;
         }
         *ptr_out++=*ptr_in;
         digits=0;
         value=0;
      }
      /* convert every four binary digits to a hex digit */
      if(digits&&(digits_length%4)==0) {
         drop_char[--col_num]=0;
         if(value<100) {
            *ptr_out++=value<10?value+'0':value-10+'A';
         } else if(value<5000) {
            *ptr_out++='Z';
         } else {
            *ptr_out++='U';
         }
         digits=0;
         value=0;
      }
      --digits_length;
   }
   *ptr_out=0;

   /* now process the header */
   file=fopen("trace2.txt","w");
   col=0;
   line[0]=0;
   for(ptr_in=buf;*ptr_in;++ptr_in) {
      if(*ptr_in=='=') {
         break;
      }
      line[col++]=*ptr_in;
      if(*ptr_in=='\n') {
         line[col]=0;
         line_index=0;
         for(col_index=0;col_index<col;++col_index) {
            if(drop_char[col_index]) {
               back_count=0;
               while(line[line_index-back_count]!=' '&&back_count<10) {
                  ++back_count;
               }
               if(line[line_index-back_count-1]!=' ') {
                  --back_count;
               }
               strcpy(line+line_index-back_count,line+line_index-back_count+1);
            } else {
               ++line_index;
            }
         }
         fprintf(file,"%s",line);
         col=0;
      }
   }
   drop_cnt=0;
   for(col_index=13;col_index<sizeof(drop_char);++col_index) {
      if(drop_char[col_index]) {
         ++drop_cnt;
      }
   }
   fprintf(file,"%s",buf+BUF_SIZE+drop_cnt);

   fclose(file);
   free(line_store);
   free(buf);
   return 0;
}
