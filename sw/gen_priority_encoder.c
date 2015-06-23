/************************************************************/
/* Filename   : gen_priority_encoder.c                      */
/* Description: Generates priority_encoder module.          */
/* Author     : Nikolaos Kavvadias, <nkavv@physics.auth.gr> */
/* Date       : Friday, 09/04/2004                          */
/* Revision   : 09/02/2010: Created common.[c|h].           */
/************************************************************/

#include <stdio.h>
#include <stdlib.h>   
#include <time.h>     
#include "common.h"                             

#define PRINT_DEBUG

                       
// FUNCTION PROTOTYPES 
void write_file_priority_encoder(FILE *outfile);


FILE *file_priority_encoder; /* VHDL source for the priority_encoder module of the 
                              * hw_looping unit (priority_encoder.vhd) */
char priority_encoder_file_name[32];
int nlp;
time_t t;


int main(int argc, char **argv) 
{ 
  int i;
  int gen_priority_encoder_file;
  char nlp_s[3];
  
  gen_priority_encoder_file = 0;
      
  if( argc < 3 )
  {
    printf("Usage: gen_priority_encoder <num loops> <output base>\n"); 
    printf("where:\n");                     
    printf("num loops   = give number of supported loops\n");
    printf("output base = output file base name. The generated files will be named:\n");
    printf("              \"<output base>.vhd\" for the module\n");
    //
    printf("\n");
    //
    return -1;
  }
  
  // Acquire number of supported loops
  strcpy(nlp_s,argv[1]);
  nlp = atoi(nlp_s);
                             
  // Filenames for the requested VHDL source files
  sprintf(priority_encoder_file_name,"%s_loops%s%s", argv[2], nlp_s, ".vhd");
  gen_priority_encoder_file = 1;                
    
    
  // DEBUG OUTPUT      
  #ifdef PRINT_DEBUG
    printf("\n");
    //
    printf("nlp = %d\n",nlp);
    printf("priority_encoder_file_name = %s\n", priority_encoder_file_name);
    //
  #endif        
    

  /******************************************************/
  /* Generate VHDL source for the priority_encoder unit */
  /******************************************************/
  if (gen_priority_encoder_file == 1)
  {
    file_priority_encoder = fopen(priority_encoder_file_name,"w");                            
    write_file_priority_encoder(file_priority_encoder);
    fclose(file_priority_encoder);
  }          

  return 0;

} 
    

void write_file_priority_encoder(
                      FILE *outfile     // Name for the output file -- e.g. mbloop_merger.vhd 
                     )
{
  int i;    
  
  // Get current time
  time(&t);            

  /* Generate interface for the VHDL file */
  fprintf(outfile,"----==============================================================----\n");
  fprintf(outfile,"----                                                              ----\n"); 
  fprintf(outfile,"---- Filename: %s                                   ----\n", priority_encoder_file_name);
  fprintf(outfile,"---- Module description: Priority encoder unit. Obtains           ----\n"); 
  fprintf(outfile,"----        increment and reset decisions for the loop indices.   ----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"---- Author: Nikolaos Kavvadias                                   ----\n");
  fprintf(outfile,"----         nkavv@physics.auth.gr                                ----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"---- Part of the hwlu OPENCORES project generated automatically   ----\n");
  fprintf(outfile,"---- with the use of the \"gen_priority_encoder\" tool              ----\n");
  fprintf(outfile,"----                                                              ----\n");
  fprintf(outfile,"---- To Do:                                                       ----\n");
  fprintf(outfile,"----         Considered stable for the time being                 ----\n");
  print_vhdl_header_common(outfile);
  
  /* Code generation for library inclusions */
  fprintf(outfile,"library IEEE;\n");
  fprintf(outfile,"use IEEE.std_logic_1164.all;\n");
  fprintf(outfile,"use IEEE.std_logic_unsigned.all;\n");
  fprintf(outfile,"\n");

  /* Generate entity declaration */
  fprintf(outfile,"entity priority_encoder is\n");            
  fprintf(outfile,"\tgeneric (\n");           
  fprintf(outfile,"\t\tNLP : integer := %d\n", nlp);                        
  fprintf(outfile,"\t);\n");            
  fprintf(outfile,"\tport (\n");
  fprintf(outfile,"\t\tflag           : in std_logic_vector(NLP-1 downto 0);\n");
  fprintf(outfile,"\t\ttask_loop%d_end : in std_logic;\n", nlp);
  fprintf(outfile,"\t\tincl           : out std_logic_vector(NLP-1 downto 0);\n");
  fprintf(outfile,"\t\treset_vct      : out std_logic_vector(NLP-1 downto 0);\n");
  fprintf(outfile,"\t\tloops_end      : out std_logic\n");
  fprintf(outfile,"\t);\n");            
  fprintf(outfile,"end priority_encoder;\n");
  fprintf(outfile,"\n");

  /* Generate architecture declaration */
  fprintf(outfile,"architecture rtl of priority_encoder is\n");           
  
  /* Add component declarations here if needed */   
       
  /* Add signal declarations here if needed */    
  
  /* Continue with the rest of the architecture declaration */          
  fprintf(outfile,"begin\n");
  fprintf(outfile,"\n");                        
  
  fprintf(outfile,"\t-- Fully-nested loop structure with %d loops\n", nlp);
  fprintf(outfile,"\t-- From outer to inner: ");
  //                                               
  i = nlp-1;
  fprintf(outfile,"%d", nlp-1);
  //
  if (nlp>=2)
  {                          
    for (i=nlp-2; i>=0; i--)
      fprintf(outfile,"-> %d",i);
  }   
  //
  fprintf(outfile,"\n");
  
  // Loop counter
  i = nlp-1;
  
  /********************/
  /* GENERATE process */
  /********************/
  
  fprintf(outfile,"\tprocess (flag, task_loop%d_end)\n", nlp);
  fprintf(outfile,"\tbegin\n");
  fprintf(outfile,"\t\t--\n");
  fprintf(outfile,"\t\t-- if loop%d is terminating:\n", i);
  fprintf(outfile,"\t\t-- reset loops %d-%d to initial index\n", i, 0);
  //
  fprintf(outfile,"\t\tif (flag(%d downto 0) = \"", i);
  print_binary_value_fbone( outfile, ipow(2,i+1)-1 );           
  fprintf(outfile,"\") then\n");
  //
  fprintf(outfile,"\t\t\tincl <= \"");
  print_binary_value( outfile, 0, nlp );           
  fprintf(outfile,"\";\n");
  //                 
  fprintf(outfile,"\t\t\treset_vct <= \"");
  print_binary_value( outfile, ipow(2,i+1)-1, nlp );           
  fprintf(outfile,"\";\n");
  //                 
  fprintf(outfile,"\t\t\tloops_end <= '1';\n");
  
  // Loop on all "elsif" cases: i=2 -> i=nlp                 
  for (i=nlp-2; i>=0; i--)
  {
    fprintf(outfile,"\t\t-- else if loop%d is terminating:\n", i);
    fprintf(outfile,"\t\t-- 1. increment loop%d index\n", i+1);
    fprintf(outfile,"\t\t-- 2. reset loop%d to initial index\n", i);
    //    
    fprintf(outfile,"\t\telsif (flag(%d downto 0) = \"", i);
    print_binary_value_fbone( outfile, ipow(2,i+1)-1 );           
    fprintf(outfile,"\") then\n");
    //
    fprintf(outfile,"\t\t\tincl <= \"");
    print_binary_value( outfile, ipow(2,i+1), nlp );           
    fprintf(outfile,"\";\n");
    //
    fprintf(outfile,"\t\t\treset_vct <= \"");
    print_binary_value( outfile, ipow(2,i+1)-1, nlp );           
    fprintf(outfile,"\";\n");
    //
    fprintf(outfile,"\t\t\tloops_end <= '0';\n");
  }                                       
  
  // Else increment inner loop                 
  fprintf(outfile,"\t\t-- else increment loop%d index\n", i);
  fprintf(outfile,"\t\telse\n");
  //                          
  fprintf(outfile,"\t\t\treset_vct <= \"");
  print_binary_value( outfile, 0, nlp );           
  fprintf(outfile,"\";\n");
  // 
  fprintf(outfile,"\t\t\tloops_end <= '0';\n");                       
  //
  fprintf(outfile,"\t\t\tif (task_loop%d_end = '1') then\n", nlp);
  fprintf(outfile,"\t\t\t\tincl <= \"");
  print_binary_value( outfile, ipow(2,i+1), nlp );           
  fprintf(outfile,"\";\n");                                       
  fprintf(outfile,"\t\t\telse\n");
  fprintf(outfile,"\t\t\t\tincl <= \"");
  print_binary_value( outfile, 0, nlp );           
  fprintf(outfile,"\";\n");     
  fprintf(outfile,"\t\t\tend if;\n");                       
  //                    
  fprintf(outfile,"\t\tend if;\n");                       
  fprintf(outfile,"\tend process;\n");                       
  fprintf(outfile,"\n");                        
  //
  fprintf(outfile,"end rtl;\n");                                                  
}
