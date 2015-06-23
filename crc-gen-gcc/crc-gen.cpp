/*
The MIT License

Copyright (c) 2009 OutputLogic.com, Evgeni Stavinov

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


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void print_verilog_crc(int lfsr_poly_size,
			   			int num_data_bits,
						unsigned int * lfsr_poly_array,
						unsigned int * lfsr_matrix);

void print_vhdl_crc(    int lfsr_poly_size,
			   			int num_data_bits,
						unsigned int * lfsr_poly_array,
						unsigned int * lfsr_matrix);

void build_crc_matrix(int lfsr_poly_size,
					  unsigned int * lfsr_poly_array, 
					  int num_data_bits,
					  unsigned int * lfsr_matrix);

void lfsr_serial_shift_crc( int num_bits_to_shift,
							int lfsr_poly_size,
							unsigned int * lfsr_poly, 
							unsigned int * lfsr_cur,
							unsigned int * lfsr_next,
							int num_data_bits,
							unsigned int * data_cur);




void print_usage()
{
    fprintf(stderr, "%s%s%s%s",
			"\nusage: \n\tcrc-gen language data_width poly_width poly_string",
			"\n\nparameters:",
			"\n\tlanguage    : verilog or vhdl"
			"\n\tdata_width  : data bus width {1..1024}"
			"\n\tpoly_width  : polynomial width {1..1024}"
			"\n\tpoly_string : polynomial string in hex",
			"\n\nexample: usb crc5 = x^5+x^2+1"
			"\n\tcrc-gen verilog 8 5 05\n\n");
}

int main(int argc, char * argv[])
{
	int data_width, poly_width;

	// those MAX values can be larger - as soon as the PC has enough memory to allocate the matrices
	const int DATA_WIDTH_MAX = 1024;
	const int POLY_WIDTH_MAX = 1024;

	bool is_vhdl;

	if (argc != 5)
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

	
	data_width = atoi(argv[2]);

	if(data_width < 1 || data_width > DATA_WIDTH_MAX)
	{
		fprintf(stderr,"\n\terror: invalid data_width\n");
		exit(1);
	}
	
	poly_width = atoi(argv[3]);

	if(poly_width < 1 || poly_width > POLY_WIDTH_MAX)
	{
		fprintf(stderr,"\n\terror: invalid poly_width\n");
		exit(1);
	}

    char * poly_str = argv[4];
    int poly_str_len = (int)strlen(poly_str);

	if(poly_str_len < (poly_width+3)/4)
	{
		fprintf(stderr,"\n\terror: invalid poly string\n");
		exit(1);
	}

	unsigned int * lfsr_poly_array = (unsigned int *)malloc(sizeof(unsigned int)*poly_width);
    unsigned int * lfsr_matrix     = (unsigned int *)malloc(sizeof(unsigned int)*(data_width+poly_width)*poly_width);

	if(!lfsr_poly_array || !lfsr_matrix)
	{
		fprintf(stderr,"\n\terror: falied mem allocation\n");
		exit(1);
	}

    for(int i=0;i<poly_width;i++)
	{
		char cur_byte = poly_str[poly_str_len - 1 - i/4];
        char nibble;

		if(cur_byte >= '0' && cur_byte <= '9')
            nibble = cur_byte - '0'; 
		else if(cur_byte >= 'a' && cur_byte <= 'f')
            nibble = 10 + cur_byte - 'a'; 
		else if(cur_byte >= 'A' && cur_byte <= 'F')
            nibble = 10 + cur_byte - 'A';
		else
		{
			free(lfsr_poly_array);
         	free(lfsr_matrix);
    		fprintf(stderr,"\n\terror: invalid poly string \n");
	    	exit(1);
		}

        lfsr_poly_array[i] = 1 & (nibble >> (i%4));  
	}

    memset(lfsr_matrix,0,sizeof(unsigned int)*(data_width+poly_width)*poly_width);


	build_crc_matrix(poly_width,
				      lfsr_poly_array, 
				      data_width,
				      lfsr_matrix);


	if(is_vhdl)
        print_vhdl_crc(poly_width,
					  data_width,
					  lfsr_poly_array,
					  lfsr_matrix);
	else
	    print_verilog_crc(poly_width,
						  data_width,
						  lfsr_poly_array,
						  lfsr_matrix);

	free(lfsr_poly_array);
	free(lfsr_matrix);
	return 0;
}


void build_crc_matrix(int lfsr_poly_size,
					  unsigned int * lfsr_poly_array, 
					  int num_data_bits,
					  unsigned int * lfsr_matrix)
{
	int N = lfsr_poly_size;
	int M = num_data_bits;
    int n1,n2,m1;

	unsigned int * lfsr_cur  = (unsigned int *)malloc(sizeof(unsigned int)*N);
	unsigned int * lfsr_next = (unsigned int *)malloc(sizeof(unsigned int)*N);
	unsigned int * data_cur  = (unsigned int *)malloc(sizeof(unsigned int)*M);


	////////////////////////////////////
	for(n1=0; n1<N; n1++)
        lfsr_cur[n1] = 0;

	for(m1=0; m1<M; m1++)
        data_cur[m1] = 0;

    // LFSR-2-LFSR matrix[NxN], data_cur=0
    for(n1=0; n1<N; n1++)
	{
		lfsr_cur[n1] = 1;

		if(n1)
			lfsr_cur[n1-1] = 0;

		lfsr_serial_shift_crc(M,
						  N,
						  lfsr_poly_array,
						  lfsr_cur,
						  lfsr_next,
						  M,
						  data_cur);

		for(n2=0; n2<N; n2++)
		{
			if(lfsr_next[n2])
                lfsr_matrix[n1*N+n2] = 1;  
		}
	}

	////////////////////////////////////
	for(n1=0; n1<N; n1++)
        lfsr_cur[n1] = 0;

	for(m1=0; m1<M; m1++)
        data_cur[m1] = 0;

	// Data-2-LFSR matrix[MxN], lfsr_cur=0
    for(m1=0; m1<M; m1++)
	{
		data_cur[m1] = 1;

		if(m1)
			data_cur[m1-1] = 0;

		lfsr_serial_shift_crc(M,
						  N,
						  lfsr_poly_array,
						  lfsr_cur,
						  lfsr_next,
						  M,
						  data_cur);

        // Data-2-LFSR matrix[MxN]
		// Invert CRC data bits
		for(n2=0; n2<N; n2++)
		{
			if(lfsr_next[n2])
                lfsr_matrix[N*N + (M-m1-1)*N + n2] = 1;  
		}
	}

	free(lfsr_cur);
	free(lfsr_next);
	free(data_cur); 

} // build_matrices_crc



//
// generate verilog code for this CRC
// 
void print_verilog_crc(int lfsr_poly_size,
			   			int num_data_bits,
						unsigned int * lfsr_poly_array,
						unsigned int * lfsr_matrix)
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


	int N = lfsr_poly_size;
	int M = num_data_bits;
    int n1,n2,m1;


	fprintf(stdout,"// CRC module for\n//\t data[%d:0]\n//\t crc[%d:0]=",num_data_bits-1,lfsr_poly_size-1);

    for(int l=0;l<lfsr_poly_size;l++)
	{
        if(lfsr_poly_array[l])
		{
			if(l)
                fprintf(stdout,"+x^%d",l);
			else
				fprintf(stdout,"1");
		}
	}
    fprintf(stdout,"+x^%d;\n//\n",lfsr_poly_size);
	fprintf(stdout,"module crc(\n");
	fprintf(stdout,"\tinput [%d:0] data_in,\n",num_data_bits-1);
	fprintf(stdout,"\tinput        crc_en,\n");
	fprintf(stdout,"\toutput [%d:0] crc_out,\n",lfsr_poly_size-1);
	fprintf(stdout,"\tinput        rst,\n");
	fprintf(stdout,"\tinput        clk);\n");
	
	fprintf(stdout,"\n\treg [%d:0] lfsr_q,\n",lfsr_poly_size-1);
	fprintf(stdout,"\t           lfsr_c;\n");

	fprintf(stdout,"\tassign crc_out = lfsr_q;\n");

	fprintf(stdout,"\talways @(*) begin");


    // print columns of LFSR[(N+M)xN] matrix
	// go thru each column[n2]
	for(n2=0; n2<N; n2++)
	{
		fprintf(stdout,"\n\t\tlfsr_c[%d] = ",n2);
        bool is_first = true;

		for(n1=0; n1<N; n1++)
		{
			if(lfsr_matrix[n1*N+n2])
			{
				if(is_first)
				{
                    fprintf(stdout,"lfsr_q[%d]",n1);
					is_first = false;
				}
				else
				{
                    fprintf(stdout," ^ lfsr_q[%d]",n1);
				}
			}
		}

		for(m1=0; m1<M; m1++)
		{
			if(lfsr_matrix[N*N+m1*N+n2])
			{
				if(is_first)
				{
                    fprintf(stdout,"data_in[%d]",m1);
					is_first = false;
				}
				else
				{
                    fprintf(stdout," ^ data_in[%d]",m1);
				}
			}
		}

		fprintf(stdout,";");

	}

	fprintf(stdout,"\n\n");

	fprintf(stdout,"\n\tend // always\n\n");

	fprintf(stdout,"\talways @(posedge clk, posedge rst) begin\n");
	fprintf(stdout,"\t\tif(rst) begin\n");
	fprintf(stdout,"\t\t\tlfsr_q  <= {%d{1'b1}};\n",lfsr_poly_size);
	fprintf(stdout,"\t\tend\n");
	
	fprintf(stdout,"\t\telse begin\n");
	fprintf(stdout,"\t\t\tlfsr_q  <= crc_en ? lfsr_c : lfsr_q;\n",lfsr_poly_size);
	fprintf(stdout,"\t\tend\n");
	fprintf(stdout,"\tend // always\n");
    fprintf(stdout,"endmodule // crc\n");        

} // print_verilog_crc


//
// Serially shift {data_in,lfsr_cur} N times to get {lfsr_next}
//
void lfsr_serial_shift_crc( int num_bits_to_shift,
							int lfsr_poly_size,
							unsigned int * lfsr_poly, 
							unsigned int * lfsr_cur,
							unsigned int * lfsr_next,
							int num_data_bits,
							unsigned int * data_cur)
{
    int i,j;

	if(num_bits_to_shift > num_data_bits)
	{
		fprintf(stderr,"error: [%d] > [%d]\n",num_bits_to_shift,num_data_bits);
        return;
	}

    for (i = 0; i < lfsr_poly_size; i++) 
        lfsr_next[i] = lfsr_cur[i];


	for (j = 0; j < num_bits_to_shift; j++) 
	{
        // shift the entire LFSR
		unsigned int lfsr_upper_bit = lfsr_next[lfsr_poly_size-1]; 

		for (i = lfsr_poly_size-1; i > 0 ; i--) 
		{
			if(lfsr_poly[i])
    		    lfsr_next[i] = lfsr_next[i-1] ^ lfsr_upper_bit ^ data_cur[j];
			else
    		    lfsr_next[i] = lfsr_next[i-1];
		}

		lfsr_next[0] = lfsr_upper_bit ^ data_cur[j];
	}
     
} // lfsr_serial_shift


void print_vhdl_crc(int lfsr_poly_size,
			   		int num_data_bits,
					unsigned int * lfsr_poly_array,
					unsigned int * lfsr_matrix)
{
	int N = lfsr_poly_size;
	int M = num_data_bits;
    int n1,n2,m1;

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

	fprintf(stdout,"// CRC module for\n//\t data(%d:0)\n//\t crc(%d:0)=",num_data_bits-1,lfsr_poly_size-1);

    for(int l=0;l<lfsr_poly_size;l++)
	{
        if(lfsr_poly_array[l])
		{
			if(l)
                fprintf(stdout,"+x^%d",l);
			else
				fprintf(stdout,"1");
		}
	}
    fprintf(stdout,"+x^%d;\n//\n",lfsr_poly_size);


  	fprintf(stdout,"library ieee;                   \n");       
  	fprintf(stdout,"use ieee.std_logic_1164.all;    \n");       
    fprintf(stdout,"\n-------------------------------------------------------------------------------\n");


    fprintf(stdout,"entity crc is \n");                 
  	fprintf(stdout,"   port ( data_in : in  std_logic_vector (%d downto 0);\n",num_data_bits-1);      
  	fprintf(stdout,"      crc_en , rst, clk : in  std_logic;\n");                     
  	fprintf(stdout,"      crc_out : out  std_logic_vector (%d downto 0));\n",lfsr_poly_size-1);   
  	fprintf(stdout,"end crc;\n\n");                                                                 

  	fprintf(stdout,"architecture imp_crc of crc is	 \n");                                
  	fprintf(stdout,"    signal lfsr_q: std_logic_vector (%d downto 0);	\n",lfsr_poly_size-1);   
  	fprintf(stdout,"    signal lfsr_c: std_logic_vector (%d downto 0);	\n",lfsr_poly_size-1);   
  	fprintf(stdout," begin	                                                      ");   

    fprintf(stdout,"\n    crc_out <= lfsr_q;\n"); 

    // print columns of LFSR[(N+M)xN] matrix
	// go thru each column
	for(n2=0; n2<N; n2++)
	{
		fprintf(stdout,"\n    lfsr_c(%d) <= ",n2);
        bool is_first = true;

		for(n1=0; n1<N; n1++)
		{
			if(lfsr_matrix[n1*N+n2])
			{
				if(is_first)
				{
                    fprintf(stdout,"lfsr_q(%d)",n1);
                    
					is_first = false;
				}
				else
				{
                    fprintf(stdout," xor lfsr_q(%d)",n1);
                    
				}
			}
		}

	    for(m1=0; m1<M; m1++)
	    {
	    	if(lfsr_matrix[N*N+m1*N+n2])
	    	{
	    		if(is_first)
	    		{
                    fprintf(stdout,"data_in(%d)",m1);
				    
	    			is_first = false;
	    		}
	    		else
	    		{
                   fprintf(stdout," xor data_in(%d)",m1);
    			    
	    		}
	    	}
	    }

		fprintf(stdout,";");
	}


	fprintf(stdout,"\n\n");


	fprintf(stdout,"\n\n   process (clk,rst)  begin \n");
	fprintf(stdout,"    if (rst = '1') then \n");

    fprintf(stdout,"     lfsr_q   <= b\"");
    for(int j=0; j<lfsr_poly_size; j++)
	{
		fprintf(stdout,"1");
    }

	fprintf(stdout,"\";\n");

    fprintf(stdout,"     elsif (clk'EVENT and clk = '1') then \n");

    fprintf(stdout,"       if (crc_en = '1') then \n");
	fprintf(stdout,"         lfsr_q <= lfsr_c; \n");
	fprintf(stdout,"       end if; \n");
    fprintf(stdout,"     end if;  \n");
    fprintf(stdout,"   end process; \n");
    fprintf(stdout," end architecture imp_crc; \n");


} // print_vhdl_crc
