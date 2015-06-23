/*
The MIT License

Copyright (c) 2009 OutputLogic.com

Permission is hereby granted, free of charge, to any person 
obtaining a copy of this software and associated 
documentation files (the "Software"), to deal in the 
Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, 
sublicense, and/or sell copies of the Software, and to 
permit persons to whom the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice shall 
be included in all copies or substantial portions of the 
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY 
KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS 
OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT 
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH 
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


// lfsr-counter-generator.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// taps for LFSR polynomials
static unsigned lfsr_taps[64][6] = 
{
	{ 0 },{0},{0}, // 0..2 : not in use
	{ 3, 2 },    // 3
	{ 4, 3 }, { 5, 3 },	{ 6, 5 }, { 7, 6 },  // 4..7
	{ 8, 6, 5, 4 }, { 9, 5 }, { 10, 7 }, { 11, 9 }, // 8..11
	{ 12, 6, 4, 1 }, { 13, 4, 3, 1 }, { 14, 5, 3, 1 }, { 15, 14 },
	{ 16, 15, 13, 4 }, { 17, 14 }, { 18, 11 }, { 19, 6, 2, 1 },
	{ 20, 17 }, { 21, 19 }, { 22, 21 }, { 23, 18 },
	{ 24, 23, 22, 17 }, { 25, 22 }, { 26, 6, 2, 1 }, { 27, 5, 2, 1 },
	{ 28, 25 }, { 29, 27 }, { 30, 6, 4, 1 }, { 31, 28 }, // 28..31
	{32,22,2,1},{33,20},{34,27,2,1},{35,33}, // 32..35
	{36,25},{37,5,4,3,2,1},{38,6,5,1},{39,35},
	{40,38,21,19},{41,38},{42,41,20,19},{43,42,38,37},
	{44,43,18,17},{45,44,42,41},{46,45,26,25},{47,42},
	{48,47,21,20},{49,40},{50,49,24,23},{51,50,36,35},
	{52,49},{53,52,38,37},{54,53,18,17},{55,31},
	{56,55,35,34},{57,50},{58,39},{59,58,38,37},
	{60,59},{61,60,46,45},{62,61,6,5},{63,62}
};

void print_verilog_lfsr_counter(int num_bits,unsigned __int64 lfsr);
void print_vhdl_lfsr_counter(int num_bits,unsigned __int64 lfsr);

void print_usage()
{
    fprintf(stderr, "%s%s%s",
			"\nusage: \n\tlfsr-counter-generator language count",
			"\n\nparameters:",
			"\n\tlanguage: verilog or vhdl"
			"\n\tcount   : counter value in hex or decimal format, e.g. 1234, 0x1234\n");
}

int main(int argc, char * argv[])
{
	unsigned __int64 count_val,i,temp,lfsr,cmp_val;

    bool is_hex  = false;
	bool is_vhdl;

	if (argc != 3)
	{
		print_usage();
	    exit(1);
	}

	if(!strcmp(argv[1], "verilog"))
	{
        is_vhdl = false;
	}
	else if(!strcmp(argv[1], "vhdl"))
	{
        is_vhdl = true;
	}
	else
	{
		print_usage();
		exit(1);
	}

	
	count_val = _strtoui64(argv[2], NULL, 10);

	if(count_val == 0 || count_val == _UI64_MAX)
	{
        count_val = _strtoui64(argv[2], NULL, 16);
		is_hex = 1;
	}

	if(count_val == 0 || count_val == _UI64_MAX)
	{
		fprintf(stderr,"error: invalid counter value\n");
		exit(1);
	}

	if(count_val < 8)
	{
		fprintf(stderr,"\n\terror: for counter values less than 8 you can use a binary counter\n");
		exit(1);
	}
	

	int num_bits = 0;
	cmp_val = 1; 

    while(count_val >= cmp_val && num_bits < 63)
	{
        num_bits++;
		cmp_val *= 2;
	}

	if(is_hex)
	    fprintf(stdout, "\ncount = 0x%I64X num_bits=%d\n", count_val,num_bits);
	else
	    fprintf(stdout, "\ncount = %I64u num_bits=%d\n", count_val,num_bits);

	if(num_bits > 30)
		fprintf(stdout,"\ngenerating...it can take a long time...\n\n");
	else
		fprintf(stdout,"\ngenerating...\n\n");

	lfsr = 0;
	
	for(i=0;i<count_val-1; i++)
	{
		temp = 0;

		// advance LFSR
		for (int j = 0; j < 6 && lfsr_taps[num_bits][j]; j++)
			temp ^= (lfsr >> ((lfsr_taps[num_bits][j]) - 1)) & 1;

		lfsr = ((lfsr << 1) & ((1 << num_bits) - 1)) ^ !temp;
	}

	if(is_vhdl)
        print_vhdl_lfsr_counter(num_bits,lfsr);
	else
        print_verilog_lfsr_counter(num_bits,lfsr);

	return 0;
}

//
// generate verilog code for this LFSR counter
// 
void print_verilog_lfsr_counter(int num_bits,unsigned __int64 lfsr)
{
    fprintf(stdout,"\n//-----------------------------------------------------------------------------");
    fprintf(stdout,"\n// Copyright (C) 2009 OutputLogic.com ");
    fprintf(stdout,"\n// This source file may be used and distributed without restriction ");
    fprintf(stdout,"\n// provided that this copyright statement is not removed from the file ");
    fprintf(stdout,"\n// and that any derivative work contains the original copyright notice ");
    fprintf(stdout,"\n// and the associated disclaimer.    ");
    fprintf(stdout,"\n// THIS SOURCE FILE IS PROVIDED \"AS IS\" AND WITHOUT ANY EXPRESS ");
    fprintf(stdout,"\n// OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED	");
    fprintf(stdout,"\n// WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. ");
	fprintf(stdout,"\n//-----------------------------------------------------------------------------\n");
    fprintf(stdout, "module lfsr_counter(\n\tinput clk,\n\tinput reset,\n\tinput ce,\n\toutput reg lfsr_done);\n\n");
	fprintf(stdout, "reg [%d:0] lfsr;\r\nwire d0,lfsr_equal;\n\n",num_bits-1);
    fprintf(stdout, "xnor(d0");

	for (int j = 0; (j < 6) && lfsr_taps[num_bits][j]; j++)
	{
	    fprintf(stdout,",lfsr[%d]",lfsr_taps[num_bits][j]-1);
	}
    fprintf(stdout,");\n");
	fprintf(stdout,"assign lfsr_equal = (lfsr == %d'h%X);\n\n",num_bits,lfsr);
    fprintf(stdout,"always @(posedge clk,posedge reset) begin\n");
    fprintf(stdout,"    if(reset) begin\n");
    fprintf(stdout,"        lfsr <= 0;\r\n");
    fprintf(stdout,"        lfsr_done <= 0;\n");
    fprintf(stdout,"    end\n");
    fprintf(stdout,"    else begin\n");

	fprintf(stdout,"        if(ce)\n            lfsr <= lfsr_equal ? %d'h0 : {lfsr[%d:0],d0};\r\n",num_bits,num_bits-2);
    
    fprintf(stdout,"        lfsr_done <= lfsr_equal;\n");
    fprintf(stdout,"    end\n");
    fprintf(stdout,"end\n");
	fprintf(stdout, "endmodule\n");

} // print_verilog_lfsr_counter


void print_vhdl_lfsr_counter(int num_bits,unsigned __int64 lfsr)
{
    fprintf(stdout,"\n-------------------------------------------------------------------------------");
    fprintf(stdout,"\n-- Copyright (C) 2009 OutputLogic.com ");
    fprintf(stdout,"\n-- This source file may be used and distributed without restriction ");
    fprintf(stdout,"\n-- provided that this copyright statement is not removed from the file ");
    fprintf(stdout,"\n-- and that any derivative work contains the original copyright notice ");
    fprintf(stdout,"\n-- and the associated disclaimer.   ");
    fprintf(stdout,"\n-- THIS SOURCE FILE IS PROVIDED \"AS IS\" AND WITHOUT ANY EXPRESS ");
    fprintf(stdout,"\n-- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED	");
    fprintf(stdout,"\n-- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. ");
    fprintf(stdout,"\n-------------------------------------------------------------------------------\n");



  	fprintf(stdout,"library ieee;                   \n");       
  	fprintf(stdout,"use ieee.std_logic_1164.all;    \n");       
  	fprintf(stdout,"use ieee.std_logic_unsigned.all;\n");       

  	fprintf(stdout,"entity lfsr_counter is \n");                            
  	fprintf(stdout," port (ce , rst, clk : in  std_logic;\n");
  	fprintf(stdout,"       lfsr_done : out  std_logic);\n");     
  	fprintf(stdout,"end lfsr_counter; \n\n");                             


  	fprintf(stdout,"architecture imp_lfsr_counter of lfsr_counter is\n");    
  	fprintf(stdout,"    signal lfsr: std_logic_vector (%d downto 0);\n",num_bits-1); 
  	fprintf(stdout,"    signal d0, lfsr_equal: std_logic;\n");                     
  	fprintf(stdout," begin\n\n");

	fprintf(stdout," d0 <= ");

    bool is_first = true;

	for (int j = 0; (j < 6) && lfsr_taps[num_bits][j]; j++)
	{
	    if(is_first)
		{
	        fprintf(stdout,"lfsr(%d) ",lfsr_taps[num_bits][j]-1);
			is_first = false;
		}
		else
		{
	        fprintf(stdout,"xnor lfsr(%d) ",lfsr_taps[num_bits][j]-1);
		}
	}
    fprintf(stdout,";\n\n");

    fprintf(stdout," process(lfsr) begin \n");

	fprintf(stdout,"  if(lfsr = x\"%X\") then \n",lfsr); 
	fprintf(stdout,"   lfsr_equal <= '1';\n");		  
	fprintf(stdout,"  else \n");							  
	fprintf(stdout,"   lfsr_equal <= '0';\n");		  
    fprintf(stdout,"  end if;\n");
    fprintf(stdout," end process;  \n\n");


	fprintf(stdout," process (clk,rst)  begin \n");
	fprintf(stdout,"  if (rst = '1') then \n");

    fprintf(stdout,"   lfsr <= b\"");
    for(int j=0; j<num_bits; j++)
	{
	    fprintf(stdout,"0");
    }
    fprintf(stdout,"\";\n");
    fprintf(stdout,"   lfsr_done <= '0'; \n");

    fprintf(stdout,"  elsif (clk'EVENT and clk = '1') then \n");

    fprintf(stdout,"   lfsr_done <= lfsr_equal; \n");

    fprintf(stdout,"   if (ce = '1') then \n");
	fprintf(stdout,"    if(lfsr_equal = '1') then \n");
	fprintf(stdout,"     lfsr <= b\"");

    for(int j=0; j<num_bits; j++)
	{
        fprintf(stdout,"0");
	}

    fprintf(stdout,"\";\n");
	fprintf(stdout,"   else  \n");

	fprintf(stdout,"   lfsr <= lfsr(%d downto 0) & d0; \n",(num_bits-2));  
	fprintf(stdout,"   end if; \n");
    fprintf(stdout,"   end if;  \n");
    fprintf(stdout,"  end if;  \n");
    fprintf(stdout," end process; \n");
    fprintf(stdout,"end architecture imp_lfsr_counter; \n\n");

} // print_vhdl_lfsr_counter