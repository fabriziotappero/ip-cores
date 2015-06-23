/*
 * File       : gentestround.c                                                          
 * Description: Generator for test designs for evaluating signed/unsigned 
 *              fixed-point (sfixed/ufixed) rounding operators. 
 * Author     : Nikolaos Kavvadias <nikolaos.kavvadias@gmail.com>                
 * Copyright  : (C) Nikolaos Kavvadias 2011                 
 * Website    : http://www.nkavvadias.com                            
 *                                                                          
 * This file is part of fixed_extensions, and is distributed under the terms 
 * of the Modified BSD License.
 *
 * A copy of the Modified BSD License is included with this distrubution 
 * in the files /doc/COPYING.BSD.
 * fixed_extensions is free software: you can redistribute it and/or modify 
 * it under the terms of the Modified BSD License. 
 * fixed_extensions is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the Modified BSD License for more 
 * details.
 * 
 * You should have received a copy of the Modified BSD License along with 
 * fixed_extensions. If not, see <http://www.gnu.org/licenses/>. 
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

/* Absolute value of an integer. */
#define ABS(x)            ((x) >  0 ? (x) : (-x))

int enable_debug=0;
int iw_val=4, fw_val=4;
double step_val=0.25;
int enable_signed=0, enable_unsigned=1;


/* print_spaces:
 * Print a configurable number of space characters to an output file (specified 
 * by the given filename; the file is assumed already opened).
 */
void print_spaces(FILE *f, int nspaces)
{
  int i;  
  for (i = 0; i < nspaces; i++)
  {
    fprintf(f, " ");
  }
}

/* pfprintf: 
 * fprintf prefixed by a number of space characters. 
 */
void pfprintf(FILE *f, int nspaces, char *fmt, ...)
{
  va_list args;
  print_spaces(f, nspaces);
  va_start(args, fmt);
  vfprintf(f, fmt, args);
  va_end(args);
}

/* ipowul:
 * Calculate integer power supporting results up to 64-bits.
 */
unsigned long long int ipowul(int base, int exponent)
{
  unsigned long long int temp;
  int i;
  
  temp = 1;
  
  for (i = 0; i < exponent; i++)
  {
    temp *= (unsigned int)base;     
  }

  return (temp);
}

/* calculate_samples:
 * Calculate the number of samples needed for the test design.
 */
unsigned long long int calculate_samples(int iw, int fw, int step)
{
  unsigned long long int nsamples;
  
  /* FIXME: Should be the same for both cases! */
  /* Samples range: 0 to 2^IW-2^FW. */
  if (enable_unsigned == 1)
  {
//    nsamples = (ipowul(2, iw) - ipowul(2, -fw)) / ipowul(2, -fw) + 1;
    nsamples = ipowul(2, iw+fw);
  }
  /* Samples range: -2^(IW-1) to 2^(IW-1)-2^FW. */
  else if (enable_signed == 1)
  {
//    nsamples = ipowul(2, iw) / ipowul(2, fw);
    nsamples = ipowul(2, iw+fw);
  }
  
  return nsamples;
}

/* print_test_prologue:
 * Prints the prologue for the generated test design file. 
 */
void print_test_prologue(FILE *infile)
{
  pfprintf(infile, 0, "library IEEE;\n");
  pfprintf(infile, 0, "use IEEE.std_logic_1164.all;\n");
  pfprintf(infile, 0, "use IEEE.numeric_std.all;\n");
  pfprintf(infile, 0, "use WORK.fixed_float_types.all;\n");
  pfprintf(infile, 0, "use WORK.fixed_pkg.all;\n");
  pfprintf(infile, 0, "use WORK.fixed_extensions_pkg.all;\n");
  fprintf(infile, "\n");
}

/* print_test_entity:
 * Prints the entity of the generated test design file. 
 */
void print_test_entity(FILE *infile, unsigned int iw, unsigned int fw)
{
  pfprintf(infile, 0, "entity testrounding is\n");
  pfprintf(infile, 2, "port (\n");
  pfprintf(infile, 4, "clk   : in  std_logic;\n");
  pfprintf(infile, 4, "reset : in  std_logic;\n");
  pfprintf(infile, 4, "start : in  std_logic;\n");
  pfprintf(infile, 4, "ok    : out sfixed(%d downto -%d)\n", iw-1, fw);
  pfprintf(infile, 2, ");\n");
  pfprintf(infile, 0, "end testrounding;\n\n");
}

/* print_test_architecture_prologue:
 * Prints the declaration part of the architecture for the generated test design 
 * file.
 */
void print_test_architecture_prologue(FILE *infile, unsigned int iw, unsigned int fw, unsigned int step)
{
  long long int i;
  unsigned long long int nsteps = calculate_samples(iw, fw, step);
  char c = 'X';
  if (enable_unsigned == 1)
  {
    c = 'u';
  }
  else if (enable_signed == 1)
  {
    c = 's';
  }
  
  pfprintf(infile, 0, "architecture fsmd of testrounding is\n");
  pfprintf(infile, 2, "type state_type is (S_ENTRY, S_EXIT,\n");

  for (i = 0; i < nsteps; i++)
  {
    pfprintf(infile, 4, "S_%08d_1,", i);
    fprintf(infile, " S_%08d_2", i);
    fprintf(infile, ", S_%08d_3", i);
    if (enable_signed == 1)
    {
      fprintf(infile, ", S_%08d_4", i);
    }
    if (i < nsteps-1)
    {
      fprintf(infile, ",");
    }
    fprintf(infile, "\n");
  }
  pfprintf(infile, 2, ");\n");
  pfprintf(infile, 2, "signal current_state, next_state: state_type;\n");
  pfprintf(infile, 2, "signal a_reg, a_next : %cfixed(%d downto -%d);\n", c, iw-1, fw);
  pfprintf(infile, 2, "signal y_ceil_reg, y_ceil_next : %cfixed(%d downto -%d);\n", c, iw-1, fw);
  pfprintf(infile, 2, "signal y_fix_reg, y_fix_next : %cfixed(%d downto -%d);\n", c, iw-1, fw);
  pfprintf(infile, 2, "signal y_floor_reg, y_floor_next : %cfixed(%d downto -%d);\n", c, iw-1, fw);
  pfprintf(infile, 2, "signal y_round_reg, y_round_next : %cfixed(%d downto -%d);\n", c, iw-1, fw);
  pfprintf(infile, 2, "signal y_nearest_reg, y_nearest_next : %cfixed(%d downto -%d);\n", c, iw-1, fw);
  pfprintf(infile, 2, "signal y_convergent_reg, y_convergent_next : %cfixed(%d downto -%d);\n", c, iw-1, fw);
  pfprintf(infile, 2, "signal ok_reg, ok_next : sfixed(%d downto -%d);\n", iw-1, fw);

  pfprintf(infile, 0, "begin\n");
}

/* print_test_architecture_csl:
 * Prints the current state logic process of the architecture for the generated 
 * test design file.
 */
void print_test_architecture_csl(FILE *infile)
{
  pfprintf(infile, 2, "-- current state logic\n");
  pfprintf(infile, 2, "process (clk, reset)\n");
  pfprintf(infile, 4, "begin\n");
  pfprintf(infile, 6, "if (reset = '1') then\n");
  pfprintf(infile, 6, "current_state <= S_ENTRY;\n");
  pfprintf(infile, 6, "a_reg <= (others => '0');\n");
  pfprintf(infile, 6, "y_ceil_reg <= (others => '0');\n");
  pfprintf(infile, 6, "y_fix_reg <= (others => '0');\n");
  pfprintf(infile, 6, "y_floor_reg <= (others => '0');\n");
  pfprintf(infile, 6, "y_round_reg <= (others => '0');\n");
  pfprintf(infile, 6, "y_nearest_reg <= (others => '0');\n");
  pfprintf(infile, 6, "y_convergent_reg <= (others => '0');\n");
  pfprintf(infile, 6, "ok_reg <= (others => '0');\n");
  pfprintf(infile, 4, "elsif (clk = '1' and clk'EVENT) then\n");
  pfprintf(infile, 6, "current_state <= next_state;\n");
  pfprintf(infile, 6, "a_reg <= a_next;\n");
  pfprintf(infile, 6, "y_ceil_reg <= y_ceil_next;\n");
  pfprintf(infile, 6, "y_fix_reg <= y_fix_next;\n");
  pfprintf(infile, 6, "y_floor_reg <= y_floor_next;\n");
  pfprintf(infile, 6, "y_round_reg <= y_round_next;\n");
  pfprintf(infile, 6, "y_nearest_reg <= y_nearest_next;\n");
  pfprintf(infile, 6, "y_convergent_reg <= y_convergent_next;\n");
  pfprintf(infile, 6, "ok_reg <= ok_next;\n");
  pfprintf(infile, 4, "end if;\n");
  pfprintf(infile, 2, "end process;\n\n");
}
  
/* print_test_architecture_nsol_prologue:
 * Prints the next state and output logic process prologue of the architecture 
 * for the generated test design file.
 */
void print_test_architecture_nsol_prologue(FILE *infile)
{
  pfprintf(infile, 2, "-- next state and output logic\n");
  pfprintf(infile, 2, "process (current_state, start,\n");
  pfprintf(infile, 4, "ok_reg,\n");
  pfprintf(infile, 4, "a_reg, a_next,\n");
  pfprintf(infile, 4, "y_ceil_reg, y_ceil_next,\n");
  pfprintf(infile, 4, "y_fix_reg, y_fix_next,\n");
  pfprintf(infile, 4, "y_floor_reg, y_floor_next,\n");
  pfprintf(infile, 4, "y_round_reg, y_round_next,\n");
  pfprintf(infile, 4, "y_nearest_reg, y_nearest_next,\n");
  pfprintf(infile, 4, "y_convergent_reg, y_convergent_next\n");
  pfprintf(infile, 2, ")\n");
  pfprintf(infile, 2, "begin\n");
  pfprintf(infile, 4, "a_next <= a_reg;\n");
  pfprintf(infile, 4, "y_ceil_next <= y_ceil_reg;\n");
  pfprintf(infile, 4, "y_fix_next <= y_fix_reg;\n");
  pfprintf(infile, 4, "y_floor_next <= y_floor_reg;\n");
  pfprintf(infile, 4, "y_round_next <= y_round_reg;\n");
  pfprintf(infile, 4, "y_nearest_next <= y_nearest_reg;\n");
  pfprintf(infile, 4, "y_convergent_next <= y_convergent_reg;\n");
  pfprintf(infile, 4, "ok_next <= ok_reg;\n");
}

/* print_test_architecture_nsol_csdec:
 * Prints the current state decoding part. It resides in the next state and 
 * output logic process of the architecture for the generated test design file.
 */
void print_test_architecture_nsol_csdec(FILE *infile, unsigned int iw, unsigned int fw, unsigned int step)
{
  long long int i;
  int k;
  unsigned long long int nsteps = calculate_samples(iw, fw, step);
  double val = 0.0;
  char c = 'X';
  if (enable_unsigned == 1)
  {
    c = 'u';
  }
  else if (enable_signed == 1)
  {
    c = 's';
  }
  
  pfprintf(infile, 4, "case current_state is\n");
  pfprintf(infile, 6, "when S_ENTRY =>\n");
  pfprintf(infile, 8, "if (start = '1') then\n");
  pfprintf(infile, 10, "next_state <= S_00000001_1;\n");
  pfprintf(infile, 8, "else\n");
  pfprintf(infile, 10, "next_state <= S_ENTRY;\n");
  pfprintf(infile, 8, "end if;\n");

  if (enable_unsigned == 1)
  {
    val = 0.0;
  }
  else if (enable_signed == 1)
  {
    val = - 1.0 * ipowul(2, iw-1);
  }
  for (i = 0; i < nsteps; i++)
  {
    pfprintf(infile, 6, "when S_%08d_1 =>\n", i);
    pfprintf(infile, 8, "a_next <= to_%cfixed(%lf, %d, -%d);\n", c, val, iw-1, fw);
    val += 1.0/(float)ipowul(2, fw);
    pfprintf(infile, 8, "next_state <= S_%08d_2;\n", i);
    //
    if (enable_signed == 1)
    {
      pfprintf(infile, 6, "when S_%08d_2 =>\n", i);
      if (val < 0.0)
      {
        pfprintf(infile, 8, "a_next <= resize(-a_reg, a_next'high, a_next'low);\n");
      }
      pfprintf(infile, 8, "next_state <= S_%08d_3;\n", i);
      k++;
    }
    //
    if (enable_unsigned == 1)
    {
      pfprintf(infile, 6, "when S_%08d_2 =>\n", i);
    }
    else if (enable_signed == 1)
    {
      pfprintf(infile, 6, "when S_%08d_3 =>\n", i);
    }
    pfprintf(infile, 8, "y_ceil_next       <= ceil(a_reg);\n");
    pfprintf(infile, 8, "y_fix_next        <= fix(a_reg);\n");
    pfprintf(infile, 8, "y_floor_next      <= floor(a_reg);\n");
    pfprintf(infile, 8, "y_round_next      <= round(a_reg);\n");
    pfprintf(infile, 8, "y_nearest_next    <= nearest(a_reg);\n");
    pfprintf(infile, 8, "y_convergent_next <= convergent(a_reg);\n");
    if (enable_unsigned == 1)
    {
      pfprintf(infile, 8, "next_state <= S_%08d_3;\n", i);
    }
    else if (enable_signed == 1)
    {
      pfprintf(infile, 8, "next_state <= S_%08d_4;\n", i);
    }
    //
    if (enable_unsigned == 1)
    {
      pfprintf(infile, 6, "when S_%08d_3 =>\n", i);
    }
    else if (enable_signed == 1)
    {
      pfprintf(infile, 6, "when S_%08d_4 =>\n", i);
    }
    pfprintf(infile, 8, "assert false report \"a_reg            = \" & to_bstring(a_reg) severity note;\n");
    pfprintf(infile, 8, "assert false report \"y_ceil_reg       = \" & to_bstring(y_ceil_reg) severity note;\n");
    pfprintf(infile, 8, "assert false report \"y_fix_reg        = \" & to_bstring(y_fix_reg) severity note;\n");
    pfprintf(infile, 8, "assert false report \"y_floor_reg      = \" & to_bstring(y_floor_reg) severity note;\n");
    pfprintf(infile, 8, "assert false report \"y_round_reg      = \" & to_bstring(y_round_reg) severity note;\n");
    pfprintf(infile, 8, "assert false report \"y_nearest_reg    = \" & to_bstring(y_nearest_reg) severity note;\n");
    pfprintf(infile, 8, "assert false report \"y_convergent_reg = \" & to_bstring(y_convergent_reg) severity note;\n");
    if (i == nsteps-1)
    {
      pfprintf(infile, 8, "next_state <= S_EXIT;\n");
    }
    else
    {
      pfprintf(infile, 8, "next_state <= S_%08d_1;\n", i+1);
    }
  }
  pfprintf(infile, 6, "when S_EXIT =>\n");
  pfprintf(infile, 8, "ok_next <= to_sfixed(%lf, %d, %d);\n", 1.0, iw-1, -fw);
  pfprintf(infile, 8, "assert false report \"DONE!\" severity note;\n");
  pfprintf(infile, 8, "next_state <= S_ENTRY;\n");
  pfprintf(infile, 4, "end case;\n");
}

/* print_test_architecture_epilogue:
 * Prints the epilogue of the architecture for the generated test design file.
 */
void print_test_architecture_epilogue(FILE *infile)
{
  pfprintf(infile, 2, "end process;\n\n");
  pfprintf(infile, 2, "ok <= ok_reg;\n\n");
  pfprintf(infile, 0, "end fsmd;\n");
}

/* print_test_design:
 * Prints the generated test design file.
 */
void print_test_design(FILE *infile, unsigned int iw, unsigned int fw, unsigned step)
{
  print_test_prologue(infile);
  print_test_entity(infile, iw, fw);
  print_test_architecture_prologue(infile, iw, fw, step);
  print_test_architecture_csl(infile);
  print_test_architecture_nsol_prologue(infile);
  print_test_architecture_nsol_csdec(infile, iw, fw, step);
  print_test_architecture_epilogue(infile);
}

/* print_usage:
 * Print usage instructions for the "gentestround" program.
 */
static void print_usage()
{
  printf("\n");
  printf("* Usage:\n");
  printf("* gentestround [options]\n");
  printf("* \n");
  printf("* Options:\n");
  printf("* \n");
  printf("*   -h:\n");
  printf("*         Print this help.\n");
  printf("*   -d:\n");
  printf("*         Enable debug/diagnostic output.\n");
  printf("*   -iw <num>:\n");
  printf("*         Set the integral part width of the fixed-point numbers. Default: 4.\n");
  printf("*   -fw <num>:\n");
  printf("*         Set the fractional part width of the fixed-point numbers. Default: 4.\n");
  printf("*   -step <num>:\n");
  printf("*         Set the step value indicating the difference between two consecutive\n");
  printf("*         samples. Default: 0.25\n");
  printf("*   -signed:\n");
  printf("*         Generate test design for sfixed vectors.\n");
  printf("*   -unsigned:\n");
  printf("*         Generate test design for ufixed vectors (default).\n");
  printf("* \n");
  printf("* For further information, please refer to the website:\n");
  printf("* http://www.nkavvadias.com\n");
}

/* main:
 * Program entry.
 */
int main(int argc, char *argv[]) 
{
  int i;
  FILE *file_o;
   
  // Read input arguments
  for (i=1; i < argc; i++)
  {
    if (strcmp("-h", argv[i]) == 0)
    {
      print_usage();
      exit(1);
    }
    else if (strcmp("-d", argv[i]) == 0)
    {
      enable_debug = 1;
    }
    else if (strcmp("-unsigned", argv[i]) == 0)
    {
      enable_unsigned = 1;
      enable_signed   = 0;
    }
    else if (strcmp("-signed", argv[i]) == 0)
    {
      enable_unsigned = 0;
      enable_signed   = 1;
    }
    else if (strcmp("-iw",argv[i]) == 0)
    {
      if ((i+1) < argc)
      {
        i++;
        iw_val = atoi(argv[i]);
      }
    }    
    else if (strcmp("-fw",argv[i]) == 0)
    {
      if ((i+1) < argc)
      {
        i++;
        fw_val = atoi(argv[i]);
      }
    }    
    else if (strcmp("-step",argv[i]) == 0)
    {
      if ((i+1) < argc)
      {
        i++;
        step_val = atof(argv[i]);
      }
    }    
    else
    {
      if (argv[i][0] != '-')
      {
        file_o = fopen(argv[i], "wb");
        if (file_o == NULL)
        {
          fprintf(stderr,"Error: Can't write %s!\n", argv[i]);
          return -1;
        }
      }
    }
  }
  
  if (iw_val <= 0)
  {
    fprintf(stderr, "Error: IW must be greater than zero.\n");
    exit(1);
  }
  if (fw_val < 0)
  {
    fprintf(stderr, "Error: FW must be greater than or equal to zero.\n");
    exit(1);
  }

  /* Generate the test design. */
  print_test_design(file_o, iw_val, fw_val, step_val);
  fclose(file_o);

  return 0;
}
