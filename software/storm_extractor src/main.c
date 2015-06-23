#include <stdio.h>
#include <stdlib.h>
#include <string.h>
  
void TextSpeichern (FILE *dateizeiger)
{
   char buffer[80] = "";
 
   printf ("\nDone!\n\n");
 
   fgets (buffer, 80, stdin);   /* von der Tastatur lesen (stdin) */
   return;
 
}
 
//**********************************************************************
// Hauptfunktion
//**********************************************************************
int main(int argc, char *argv[])
{
  FILE * pFile;
  char filename[80] = "a.out";
  long lSize;
  int m = 0;
  int adr_start;
  unsigned char * buffer;
  size_t result;
  
  FILE *f; // txt output file
  FILE *d; // binary output file


  if (argc > 1)
  {
     while(argv[1][m] != '\0')
     {
       filename[m] = argv[1][m];
       m++;
     }
  }

  //system("color 0a");

  pFile = fopen (filename , "rb" );
  if (pFile==NULL)
  {
   printf("Cannot open file 'a.out'\n");
   exit (1);
  }

  // obtain file size:
  fseek (pFile , 0 , SEEK_END);
  lSize = ftell (pFile);
  rewind (pFile);

  // allocate memory to contain the whole file:
  buffer = (unsigned char*) malloc (sizeof(unsigned char)*lSize);
  if (buffer == NULL)
  {
   printf("Memory error\n");
   exit (2);
  }

  // copy the file into the buffer:
  result = fread (buffer,1,lSize,pFile);
  if (result != lSize)
  {
   printf("Reading error\n");
   exit (3);
  }


  // Open txt output file
  f = fopen("storm_program.txt","w+");
  if(f == NULL)
  {
   printf("Error creating txt output file\n");
   exit(10);
  }

  // Open dat output file
  d = fopen("storm_program.bin","wb+");
  if(d == NULL)
  {
   printf("Error creating binary output file\n");
   exit(11);
  }
  
  if (buffer[45] == 1)
  {
       adr_start = 56;
  }
  else
  {
      adr_start = 88;
  }

  // Beginning of mnemomic part
  unsigned long mnemonic_beginning = 0;
  mnemonic_beginning = ((buffer[adr_start] << 24) | (buffer[adr_start+1] << 16) | (buffer[adr_start+2] << 8) | (buffer[adr_start+3]));
  //printf("Mnemonic start:  %u\n", mnemonic_beginning);

  // Length of mnemonic part
  unsigned long mnemonic_length = 0;
  mnemonic_length = ((buffer[adr_start+12] << 24) | (buffer[adr_start+13] << 16) | (buffer[adr_start+14] << 8) | (buffer[adr_start+15]));
  if(mnemonic_length == 0)
  {
   printf("Invalid assembler file\n"); //x38 x58
   exit(4);
  }

  if (mnemonic_length == 0)
  {
   printf("Assembler file is empty\n");
   exit(5);
  }

  printf("Program start: 0x%.8X\n", mnemonic_beginning);
  printf("Program size:  0x%.8X\n", mnemonic_length-4);

   int j = mnemonic_beginning;
   int i = 0;
   int k = 0;
   char txt_string[32];
   char dat_string;
   i = 0;

   sprintf(txt_string, "SMBR");
   txt_string[4] = (unsigned char)((mnemonic_length-4)>>24);
   txt_string[5] = (unsigned char)((mnemonic_length-4)>>16);
   txt_string[6] = (unsigned char)((mnemonic_length-4)>> 8);
   txt_string[7] = (unsigned char)((mnemonic_length-4)>> 0);
   fputc(txt_string[0], d);
   fputc(txt_string[1], d);
   fputc(txt_string[2], d);
   fputc(txt_string[3], d);
   fputc(txt_string[4], d);
   fputc(txt_string[5], d);
   fputc(txt_string[6], d);
   fputc(txt_string[7], d);

   while (j != (mnemonic_length + mnemonic_beginning))
   {
     unsigned long temp = 0;
     temp = ((buffer[j] << 24) | (buffer[j+1] << 16) | (buffer[j+2] << 8) | (buffer[j+3]));
     sprintf(txt_string, "%.6u\ => x\"%.8X\",\n", i ,temp);
     fputs(txt_string, f);
     for(k=0; k<=3; k++)
     {
      dat_string = (signed char) buffer[j+k];
      fputc(dat_string, d);
     }
     j=j+4;
     i++;
   }
   sprintf(txt_string, "others => x\"F0013007\"\n");
   fputs(txt_string, f);
   //printf("others => x\"F0013007\"\n"); // optimized NOP command

  // terminate
  fclose(pFile);
  fclose(f);
  fclose(d);
  free (buffer);
  return 0;
}
