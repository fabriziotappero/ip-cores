/*
  File for analysis of an architecture's instructions in binary format

  Julius Baxter, julius.baxter@orsoc.se

*/

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <arpa/inet.h> // for htonl()

#include "insnanalysis.h"

// Access to list management functions
#include "insn-lists.h"

int analyse_insn(instruction insn,
		 instruction_properties *insn_props)
{
  // For now no other instruction sets supported
  return or1k_32_analyse_insn(insn, insn_props);
}


void print_insn(instruction_properties *insn_props)
{
  if (insn_props->insn_string != NULL)
    printf("%s", insn_props->insn_string);
}

void collect_stats(instruction insn,
		   instruction_properties *insn_props, int record_unique)
{
  or1k_32_collect_stats(insn, insn_props, record_unique);
}


void generate_stats(FILE * stream)
{
  or1k_32_generate_stats(stream);
}

int main(int argc, char *argv[])
{
  FILE *ifp, *ofp;

  char insn_buff[INSN_SIZE_BYTES]; // Buffer for instruction data

  int insns_seen_total = 0; // Keep track of total number of instructions read

  char *infilename = NULL;
  char *outfilename = NULL;

  int outfile_flag = 0; // default is not to use an output file

  int opterr = 0;

  int uniquecount_flag = 0;
  
  int c;

  // Look for:
  // -f filename : Input file name (required)
  // [ -o filename] : Output file name (optional)
  // [ -u ] : Do unique instruction analysis (option)
  while ((c = getopt(argc, argv, "f:o:u::")) != -1)
    switch (c)
      {
      case 'f':
	infilename = optarg;
	break;

      case 'o':
	outfile_flag = 1;
	outfilename = optarg;
	break;

      case 'u':
	uniquecount_flag = 1;
	break;
	
      default:
	abort();
      }

  
  // Try to open the input file
  if((ifp = fopen(infilename, "rb"))==NULL) {
    printf("Cannot open input file, %s\n", infilename);
    exit(1);
  }
                
  int filesize_bytes, filesize_insns;
  // Determine filesize
  if ( fseek(ifp, 0, SEEK_END))
    {
      fclose(ifp);
      fprintf(stderr, "Error detecting input file size\n");
      return -1;
    }
  
  filesize_bytes = ftell(ifp);
  filesize_insns = filesize_bytes / INSN_SIZE_BYTES;

#ifdef DISPLAY_STRING  
  printf("\nAnalysing file:\t%s\tSize: %d MB\n",
	 infilename,((filesize_bytes/1024)/1024));
#endif

  // Reset pointer
  rewind(ifp);

  instruction * insn = (instruction *)insn_buff;

  instruction_properties insn_props;
  
  // Go through the file, collect stats about instructions
  
  // What is one-percent of instructions
  float file_one_percent = ((float)filesize_insns / 100.0f );
  float percent_of_percent=0; int percent=0;

  insn_lists_init();

  while(!feof(ifp)) {
    
    if (fread(insn_buff, INSN_SIZE_BYTES, 1, ifp) != 1)
      break;
    
    // Endianness is little when read in from binary file created with 
    // or32-elf-objcopy, so swap;
    *insn = htonl(*insn);
    
    if (*insn == 0) // most probably dead space in binary, skip
      continue;

    reset_instruction_properties(&insn_props);

    if (analyse_insn(*insn, &insn_props) == 0)
      {

	insns_seen_total++;
	
	collect_stats(*insn, &insn_props, uniquecount_flag);
      
      }
    else
      {
	// Non-zero return from analyse_insn(): problem analysing instruction.

	// Is a NOP for now, but do something here if needed

	do{ } while(0);
      }

    // Progress indicator
    percent_of_percent += 1.0f;
    if (percent_of_percent >= file_one_percent)
      {
	percent++;
	fprintf(stderr, "\r%d%%", percent);
	percent_of_percent = 0;
      }
  }

  fclose(ifp);
  
  fprintf(stderr, "\rDone\n", percent);
  
  // Try to open the output file
  if (outfile_flag)
    {
      if((ofp = fopen(outfilename, "wb+"))==NULL) {
	printf("Cannot open output file.\n");
	exit(1);
      }
    }
  else
    // Otherwise we'll use stdout
    ofp = (FILE *)stdout;

#ifdef DISPLAY_STRING
  fprintf(ofp, "Saw %d instructions\n", insns_seen_total);
#endif
#ifdef DISPLAY_CSV
  fprintf(ofp, "\"File:\",\"%s\",\"Num insns:\",%d,\n",
	  infilename, insns_seen_total);
#endif

  // Generate output
  generate_stats(ofp);
  
  insn_lists_free();
  
  return 0;

}
