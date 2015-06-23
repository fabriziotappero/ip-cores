//---------------------------------------------------------------------------------------
//
// ihex2vlog.c by Moti Litochevski, Nov 12, 2011  
// This program reads an Intel HEX file and generates memory Verilog module or 
// Xilinx RAMB16/RAMB4 verilog initialization vectors. 
//
// This program uses the ihex.c functions by Paul Stoffregen.
//
// The project was compiled using the Tiny C Compiler using the following command line:
// 		tcc ihex2vlog.c ihex.c 
//
//---------------------------------------------------------------------------------------
//
// This file is released to the public domain under the BSD 2-clause license.
//
// Copyright (c) 2012, Moti Litochevski
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are 
// permitted provided that the following conditions are met:
//   o Redistributions of source code must retain the above copyright notice, this list 
//     of conditions and the following disclaimer.
//   o Redistributions in binary form must reproduce the above copyright notice, this 
//     list of conditions and the following disclaimer in the documentation and/or 
//     other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
//
//---------------------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// constants 
#define MAX_BUF_SIZE		65536 

/* this loads an intel hex file into the memory[] array */
int load_file(char *filename);

// the loaded memory is stored in a global variable with maximum size of 64K bytes 
int	memory[MAX_BUF_SIZE];

// Xilinx RAMB16 default parameters 
// total size of RAM memory block in bytes 
#define RAM_BLOCK_SIZE		2048
// maxmimum number of memory blocks - each memory block contains RAM_BLOCK_SIZE bytes 
#define RAM_BLOCKS			8 
// number of rows in RAM block initialization vectors 
#define RAM_ROWS			64 
// number of bytes per row in RAM block initialization vectors 
#define RAM_BYTEPERROW		32 
// Xilinx RAMB4 parameters 
#define RAMB4_BLOCK_SIZE	512
#define RAMB4_BLOCKS		32 
#define RAMB4_ROWS			16 
#define RAMB4_BYTEPERROW	32 

//------------------------------------------------------------------------------
int main (int argc, char *argv[])
{
FILE *file;
int index, hex_len, block_num, iblock, irow;
int address, value, argi;
int block_size, blocks_num, raws_num, bytes_num;
char *argstr, modname[24];

	// init block size to zero to sign generic Verilog code 
	block_size = 0;
	// default address width 
	raws_num = 16;
	bytes_num = 0;
	// set default module name 
	strcpy(modname, "ram_image");
	
	// announce program start 
	printf("ihex2vlog conversion tool:\n");

	// check program usage 
	if (argc < 3) {
		printf("\n");
		printf("ERROR: incorrect usage of program.\n");
		printf("\n");
		printf("Usage: ihex2vlog [-a/s/m/4/16] <in.hex> <out.v>\n");
		printf("optional parameters:\n");
		printf("     -a<width>  generate initialization vectors for generic Verilog\n");
		printf("                code with specified address bus width. value should be\n");
		printf("                in the range 8 to 16.\n");
		printf("                this is the default option with width = 16\n");
		printf("     -s<value>  set size of generic verilog memory size.\n");
		printf("                value should be in the range 256 to 65536.\n");
		printf("                default value is 2**<width> (address width defined above).\n");
		printf("     -m<name>   set module name for generic verilog memory.\n");
		printf("                default value is \"ram_image\".\n");
		printf("     -4         generate initialization vectors for Xilinx RAMB4.\n");
		printf("     -16        generate initialization vectors for Xilinx RAMB16.\n");
		printf("\n");
		printf("Example: ihex2vlog test.ihx ram_image.v\n");
		return -1;
	}
	
	// clear the memory array 
	for (index = 0; index < MAX_BUF_SIZE; index++) {
		memory[index] = 0;
	}

	// check optional options 
	argi = 1;
	argstr = argv[argi];
	while (argstr[0]=='-') {
		// check Xilinx RAMB4 option 
		if (argstr[1] == '4') {
			// init block definition values for Xilinx RAMB4 block size 
			block_size = RAMB4_BLOCK_SIZE;
			blocks_num = RAMB4_BLOCKS;
			raws_num = RAMB4_ROWS;
			bytes_num = RAMB4_BYTEPERROW;
		} 
		else if ((argstr[1] == '1') & (argstr[2] == '6')) {
			// init block definition values for Xilinx RAMB16 block size 
			block_size = RAM_BLOCK_SIZE;
			blocks_num = RAM_BLOCKS;
			raws_num = RAM_ROWS;
			bytes_num = RAM_BYTEPERROW;
		}
		else if (argstr[1] == 'a') {
			// for generic infered RAM Verilog code this option specifies the 
			// address bus width 
			sscanf(&argstr[2], "%d", &raws_num);
			if ((raws_num < 8) | (raws_num > 16)) {
				printf("\nERROR: Address width value error (%d)\n\n", raws_num);
				return -1;
			}
			//check if memory length should be calculated 
			if (bytes_num == 0) {
				// calculate the actual memory size 
				bytes_num=1;
				for (index=0; index<raws_num; index++)
					bytes_num=bytes_num*2;
			}
		}
		else if (argstr[1] == 's') {
			// set memory size option 
			sscanf(&argstr[2], "%d", &bytes_num);
			if ((bytes_num < 256) | (bytes_num > MAX_BUF_SIZE)) {
				printf("\nERROR: Memory size value error (%d)\n\n", bytes_num);
				return -1;
			}
		}
		else if (argstr[1] == 'm') {
			// set generic verilog memory module name 
			strcpy(modname, &argstr[2]);
		}
		else 
			printf("\nERROR: Unsupported option \"%s\"\n\n", argstr);
		// update parameter index 
		argi++;
		argstr = argv[argi];
	}
	
	// read input hex file into the memory array 
	hex_len = load_file(argv[argi]);
	printf("HEX memory top address %d\n", hex_len);
	// check if file loaded OK 
	if (hex_len < 1) {
		printf("ERROR: Can't read '%s'!\n", argv[argi]);
		return -1;
	}
	
	// announce output file name 
	printf("Writing output file to: %s\n", argv[argi+1]);
	// open output file 
	file = fopen(argv[argi+1], "wt");
	if (file == NULL) {
		printf("ERROR: Can't write '%s'!\n", argv[argi+1]);
		return -1;
	}

	// check if Xilinx RAMB memory is used or generic verilog RAM 
	if (block_size) {
		// calculate the number of required RAM blocks 
		block_num = hex_len / block_size;
		printf("HEX file requires %d RAM blocks\n", block_num+1);
	
		// write file header 
		fprintf(file, "// RAM image for input code file: %s\n", argv[argi]);
		// write memory block defines to enable only required memory blocks 
		fprintf(file, "// enable memory blocks \n");
		fprintf(file, "`ifdef EN_ALL_BLOCKS\n");
		for (iblock = 0; iblock < blocks_num; iblock++) {
			fprintf(file, "`define EN_BLOCK%d     1 \n", iblock);
		}
		fprintf(file, "`else\n");
		// write the memory block enable flags 
		for (iblock = 0; iblock < block_num+1; iblock++) {
			fprintf(file, "`define EN_BLOCK%d     1 \n", iblock);
		}
		fprintf(file, "`endif\n");
		fprintf(file, "\n");
	
		// write memory blocks 
		for (iblock = 0; iblock <= block_num; iblock++) {
			// write memory block header 
			fprintf(file, "// block %d \n", iblock);
			
			// loop though block rows 
			for (irow = 0; irow < raws_num; irow++) {
				// write start of line 
				fprintf(file, "defparam mem%d.INIT_%X%X = 256'h", iblock, irow/16, irow & 0xf);
				
				// write memory bytes 
				for (index = 0; index < bytes_num; index++) {
					address = iblock*block_size + irow*bytes_num + bytes_num - index - 1;
					
					if (address < hex_len) 
						value = memory[address] & 0xff;
					else 
						value = 0;
					
					fprintf(file, "%x%x", value/16, value & 0xf);
				}
				fprintf(file, ";\n");
			}
		}
	}
	else {
		// generate generic Verilog RAM code 
		printf("Generate generic Verilog RAM code.\n");
		
		// write output file header 
		fprintf(file, "//-----------------------------------------------------------------------------\n");
		fprintf(file, "//\n");
		fprintf(file, "// RAM image for input code file: %s\n", argv[argi]);
		fprintf(file, "//\n");
		fprintf(file, "//-----------------------------------------------------------------------------\n");
		fprintf(file, "module %s\n", modname);
		fprintf(file, "(\n");
		fprintf(file, "	clk, addr, \n");
		fprintf(file, "	we, din, dout\n");
		fprintf(file, ");\n");
		fprintf(file, "//-----------------------------------------------------------------------------\n");
		fprintf(file, "input           clk;\n");
		fprintf(file, "input   [%d:0]  addr;\n", raws_num-1);
		fprintf(file, "input           we;\n");
		fprintf(file, "input   [7:0]   din;\n");
		fprintf(file, "output  [7:0]   dout;\n");
		fprintf(file, "//-----------------------------------------------------------------------------\n");
		fprintf(file, "reg [7:0] dout;\n");
		fprintf(file, "reg [7:0] ram [%d:0];\n", bytes_num-1);
		fprintf(file, "//-----------------------------------------------------------------------------\n");
		fprintf(file, "initial \n");
		fprintf(file, "begin\n");
		// dump memory values as RAM init values 
		for (index=0; index<bytes_num; index++) {
			if ((index&3) == 0) fprintf(file, "    ");
			fprintf(file, "ram[%d] = 8\'h%x%x; ", index, (memory[index]/16)&0xf, memory[index]&0xf); 
			if ((index&3) == 3) fprintf(file, "\n");
		}
		fprintf(file, "end\n");
		fprintf(file, "\n");
		fprintf(file, "//-----------------------------------------------------------------------------\n");
		fprintf(file, "always @(posedge clk)\n");
		fprintf(file, "begin\n");
		fprintf(file, "    if (we)\n");
		fprintf(file, "    begin\n");
		fprintf(file, "        ram[addr] <= din;\n");
		fprintf(file, "        dout <= din;\n");
		fprintf(file, "    end\n");
		fprintf(file, "    else\n");
		fprintf(file, "        dout <= ram[addr];\n");
		fprintf(file, "end\n");
		fprintf(file, "\n");
		fprintf(file, "endmodule\n");
		fprintf(file, "//-----------------------------------------------------------------------------\n");
	}
	
	// close output file 
	fclose(file); 
	return 0;
}
//------------------------------------------------------------------------------
