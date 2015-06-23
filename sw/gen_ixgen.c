/********************************************************************/
/* Filename   : gen_ixgen.c                                         */
/* Description: Generates the compact index generator (ixgen) unit. */
/* Author     : Nikolaos Kavvadias, <nkavv@physics.auth.gr>         */
/* Date       : Sunday, 14/02/2010                                  */
/* Revision   :                                                     */
/********************************************************************/

#include <stdio.h>
#include <stdlib.h>   
#include <time.h>                                  
#include "common.h"

#define PRINT_DEBUG

                       
// FUNCTION PROTOTYPES 
void write_file_ixgen(FILE *outfile);

FILE *file_ixgen; /* VHDL source for the top-level module of the 
                   * ixgen<num>_pf unit (ixgen<num>_pf.vhd) */

char ixgen_file_name[32];
int enable_nlp=0;
int nlp=1;
time_t t;


int main(int argc, char **argv) 
{ 
  int i;
  int gen_ixgen_file;
  
  gen_ixgen_file = 0;
  
  // Read input arguments
  if (argc < 3)
  {
    printf("Usage: gen_ixgen -nlp <num loops> <output base>\n"); 
    printf("where:\n");                     
    printf("-nlp <num>    = give number of supported loops (default = 1).\n");
    printf("<output base> = output file base name. The generated files will be named:\n");
    printf("              \"<output base><nlp>_pf.vhd\".\n");
    printf("\n");
    exit(1);
  }

  for (i = 1; i < argc; i++)
  {
    if (strcmp("-nlp",argv[i]) == 0)
    {
      enable_nlp = 1;
      if ((i+1) < argc)
      {
        i++;
        nlp = atoi(argv[i]);
      }
    }
    else //if (strcmp("-o",argv[i]) == 0)
    {
      if (i < argc)
      {
        sprintf(ixgen_file_name,"%s%d%s", argv[i], nlp, "_pf.vhd");
        gen_ixgen_file = 1;
      }
    }
  }

  // DEBUG OUTPUT      
#ifdef PRINT_DEBUG
  printf("\n");
  //
  printf("nlp = %d\n",nlp);
  printf("ixgen_file_name = %s\n", ixgen_file_name);
  //
#endif        
                                                      
  /********************************************/
  /* Generate VHDL source for the ixgen unit. */
  /********************************************/
  if (gen_ixgen_file == 1)
  {
    file_ixgen = fopen(ixgen_file_name, "w");                            
    write_file_ixgen(file_ixgen);
    fclose(file_ixgen);
  }          

  return 0;
} 
    
void write_file_ixgen(FILE *outfile)
{
  unsigned int i, j;    
  
  // Get current time
  time(&t);            

  /* Generate interface for the VHDL file */
  fprintf(outfile, "----==============================================================----\n");
  fprintf(outfile, "----                                                              ----\n"); 
  fprintf(outfile, "---- Filename: %s                                      ----\n", ixgen_file_name);
  fprintf(outfile, "---- Description: Top-level file for the ixgen unit.              ----\n");
  fprintf(outfile, "----              Also implements I/O wrapping operations.        ----\n");
  fprintf(outfile, "----                                                              ----\n");
  fprintf(outfile, "---- Author: Nikolaos Kavvadias                                   ----\n");
  fprintf(outfile, "----         nkavv@physics.auth.gr                                ----\n");
  fprintf(outfile, "----                                                              ----\n");
  fprintf(outfile, "----                                                              ----\n");
  fprintf(outfile, "---- Part of the hwlu OPENCORES project generated automatically   ----\n");
  fprintf(outfile, "---- with the use of the \"gen_ixgen\" tool.                        ----\n");
  fprintf(outfile, "----                                                              ----\n");
  fprintf(outfile, "---- To Do:                                                       ----\n");
  fprintf(outfile, "----         Considered stable for the time being                 ----\n");
  print_vhdl_header_common(outfile);

  /* Code generation for library inclusions */
  fprintf(outfile, "library IEEE;\n");
  fprintf(outfile, "use IEEE.std_logic_1164.all;\n");
  fprintf(outfile, "use IEEE.std_logic_unsigned.all;\n");
  fprintf(outfile, "\n");

  /* Generate entity declaration */
  fprintf(outfile, "entity ixgen%d_pf is\n", nlp);            
  fprintf(outfile, "\tgeneric (\n");           
  fprintf(outfile, "\t\tNLP : integer := %d;\n", nlp);                        
  fprintf(outfile, "\t\tDW  : integer := 8\n");                       
  fprintf(outfile, "\t);\n");            
  fprintf(outfile, "\tport (\n");
  fprintf(outfile, "\t\tclk            : in std_logic;\n");
  fprintf(outfile, "\t\treset          : in std_logic;\n");
  fprintf(outfile, "\t\tinnerloop_end  : in std_logic;\n");
  fprintf(outfile, "\t\tloop_count     : in std_logic_vector(NLP*DW-1 downto 0);\n");
  fprintf(outfile, "\t\tindex          : out std_logic_vector(NLP*DW-1 downto 0);\n");    
  //
  fprintf(outfile, "\t\tloops_end      : out std_logic\n");            
  //
  fprintf(outfile, "\t);\n");            
  fprintf(outfile, "end ixgen%d_pf;\n", nlp);
  fprintf(outfile, "\n");

  /* Generate architecture declaration */
  fprintf(outfile,"architecture rtl of ixgen%d_pf is\n", nlp);            
  
  /* Add signal declarations here if needed */    
  fprintf(outfile, "--\n");
  fprintf(outfile, "-- Signal declarations\n");
  fprintf(outfile, "signal temp_index  : std_logic_vector(NLP*DW-1 downto 0);\n");
  for (i = 1; i <= nlp; i++)
  {
    fprintf(outfile, "alias  temp_index%d : std_logic_vector(DW-1 downto 0) is temp_index(%d*DW-1 downto %d*DW);\n",
    i, i, i-1);
  }
  for (i = 1; i <= nlp; i++)
  {
    fprintf(outfile, "alias  loop%d_count : std_logic_vector(DW-1 downto 0) is loop_count(%d*DW-1 downto %d*DW);\n",
    i, i, i-1);
  }
  fprintf(outfile,"--\n");
  
  /* Continue with the rest of the architecture declaration. */          
  fprintf(outfile, "begin\n");
  fprintf(outfile, "\n");                    
  
  /* Generate main process. */
  fprintf(outfile,"\tprocess (clk, reset, innerloop_end, temp_index, loop_count)\n");
  fprintf(outfile,"\tbegin\n");
  fprintf(outfile,"\t\tif (reset = '1') then\n");
  for (i = 1; i <= nlp; i++)
  {
    fprintf(outfile,"\t\t\ttemp_index%d <= (others => '0');\n", i);
  }
  fprintf(outfile, "\t\t\tloops_end <= '0';\n");
  fprintf(outfile, "\t\telsif (clk'EVENT and clk = '1') then\n");
  fprintf(outfile, "\t\t\tif (innerloop_end = '1') then\n");
  for (i = nlp; i >= 1; i--)
  {
    if (i == nlp) 
    {
      fprintf(outfile, "\t\t\t\tif (temp_index%d < loop%d_count) then\n", i, i);
    }
    else
    {
      fprintf(outfile, "\t\t\t\telsif (temp_index%d < loop%d_count) then\n", i, i);
    }
    for (j = nlp; j > i; j--)
    {
      fprintf(outfile, "\t\t\t\t\ttemp_index%d <= (others => '0');\n", j);
    }
    fprintf(outfile, "\t\t\t\t\ttemp_index%d <= temp_index%d + '1';\n", j);
  }
  fprintf(outfile, "\t\t\t\telse\n");
  for (i = 1; i <= nlp; i++)
  {  
    fprintf(outfile, "\t\t\t\t\ttemp_index%d <= (others => '0');\n", i);
  }
  fprintf(outfile, "\t\t\t\tend if;\n");
  fprintf(outfile, "\t\t\tend if;\n");
  fprintf(outfile, "\t\tend if;\n");
  fprintf(outfile, "\tend process;\n");
  fprintf(outfile, "\n");                        
  
  /***************************************/
  /* GENERATE OUTPUT WRAPPING ASSIGNMENTS */
  /***************************************/

  fprintf(outfile, "\tindex <= temp_index;\n");

  fprintf(outfile, "\n");                        
  fprintf(outfile, "end rtl;\n");                                                  
}
