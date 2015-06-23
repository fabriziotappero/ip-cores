/* ***********************************************************************
  The Free IP Project
  Free-RISC8 -- Verilog 8-bit Microcontroller
  (c) 1999, The Free IP Project and Thomas Coonan


  FREE IP GENERAL PUBLIC LICENSE
  TERMS AND CONDITIONS FOR USE, COPYING, DISTRIBUTION, AND MODIFICATION

  1.  You may copy and distribute verbatim copies of this core, as long
      as this file, and the other associated files, remain intact and
      unmodified.  Modifications are outlined below.  
  2.  You may use this core in any way, be it academic, commercial, or
      military.  Modified or not.  
  3.  Distribution of this core must be free of charge.  Charging is
      allowed only for value added services.  Value added services
      would include copying fees, modifications, customizations, and
      inclusion in other products.
  4.  If a modified source code is distributed, the original unmodified
      source code must also be included (or a link to the Free IP web
      site).  In the modified source code there must be clear
      identification of the modified version.
  5.  Visit the Free IP web site for additional information.
      http://www.free-ip.com

*********************************************************************** */

// Intel HEX to Verilog converter.
//
// Usage:
//    hex2v <file>
//
// You probably want to simply redirect the output into a file.
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Input and Output file streams.
FILE *fpi;

// Well.. Let's read stuff in completely before outputting.. Programs
// should be pretty small..
//
#define MAX_MEMORY_SIZE  2048
struct {
   unsigned int  nAddress;
   unsigned int  byData;
} Memory[MAX_MEMORY_SIZE];

char szLine[80];
unsigned int  start_address, address, ndata_bytes, ndata_words;
unsigned int  data;
unsigned int  nMemoryCount;

int main (int argc, char *argv[])
{
   int  i;

   if (argc != 2) {
      printf ("\nThe Synthetic PIC --- Intel HEX File to Verilog memory file");
      printf ("\nUsage: hex2verilog <infile>");
      printf ("\n");
      return 0;
   }


   // Open input HEX file
   fpi=fopen(argv[1], "r");
   if (!fpi) {
      printf("\nCan't open input file %s.\n", argv[1]);
      return 1;
   }

   // Read in the HEX file
   //
   // !! Note, that things are a little strange for us, because the PIC is
   //    a 12-bit instruction, addresses are 16-bit, and the hex format is
   //    8-bit oriented!!
   //
   nMemoryCount = 0;
   while (!feof(fpi)) {
      // Get one Intel HEX line
      fgets (szLine, 80, fpi);
      if (strlen(szLine) >= 10) {
         // This is the PIC, with its 12-bit "words".  We're interested in these
         // words and not the bytes.  Read 4 hex digits at a time for each
         // address.
         //
         sscanf (&szLine[1], "%2x%4x", &ndata_bytes, &start_address);
         if (start_address >= 0 && start_address <= 20000 && ndata_bytes > 0) {
            // Suck up data bytes starting at 9th byte.
            i = 9;

            // Words.. not bytes..
            ndata_words   = ndata_bytes/2;
            start_address = start_address/2;

            // Spit out all the data that is supposed to be on this line.
            for (address = start_address; address < start_address + ndata_words; address++) {
               // Scan out 4 hex digits for a word.  This will be one address.
               sscanf (&szLine[i], "%04x", &data);

               // Need to swap bytes...
               data = ((data >> 8) & 0x00ff) | ((data << 8) & 0xff00);
               i += 4;

               // Store in our memory buffer
               Memory[nMemoryCount].nAddress = address;
               Memory[nMemoryCount].byData   = data;
               nMemoryCount++;
            }
         }
      }
   }
   fclose (fpi);

   // Now output the Verilog $readmemh format!
   //
   for (i = 0; i < nMemoryCount; i++) {
      printf ("\n@%03X %03X", Memory[i].nAddress, Memory[i].byData);
   }
   printf ("\n");

}
