//
// Xilinx VHDL ROM generator
//
// Version : 0244
//
// Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org)
//
// All rights reserved
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
//
// Neither the name of the author nor the names of other contributors may
// be used to endorse or promote products derived from this software without
// specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
// THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//
// Please report bugs to the author, but before you do so, please
// make sure that this is not a derivative work and that
// you have the latest version of this file.
//
// The latest version of this file can be found at:
//	http://www.opencores.org/cvsweb.shtml/t51/
//
// Limitations :
//	Not all address/data widths produce working code
//	Requires stl to compile
//
// File history :
//
// 0220 : Initial release
//
// 0221 : Fixed block ROMs with partial bytes
//
// 0241 : Updated for WebPack 5.1
//
// 0244 : Added -n option and component declaration
//

#include <stdio.h>
#include <string>
#include <vector>
#include <iostream>

using namespace std;

#if !(defined(max)) && _MSC_VER
	// VC fix
	#define max __max
#endif

int main (int argc, char *argv[])
{
	cerr << "Xilinx VHDL ROM generator by Daniel Wallner. Version 0244\n";

	try
	{
		unsigned long aWidth;
		unsigned long dWidth;
		unsigned long select = 0;
		unsigned long length = 0;
		char z = 0;

		if (argc < 4)
		{
			cerr << "\nUsage: xrom <entity name> <address bits> <data bits> <options>\n";
			cerr << "\nThe options can be:\n";
			cerr << "  -[decimal number] = SelectRAM usage in 1/16 parts\n";
			cerr << "  -z = use tri-state buses\n";
			cerr << "  -n [decimal size] = limit rom size\n";
			cerr << "\nExample:\n";
			cerr << "  xrom Test_ROM 13 8 -6\n\n";
			return -1;
		}

		int result;

		result = sscanf(argv[2], "%lu", &aWidth);
		if (result < 1)
		{
			throw "Error in address bits argument!\n";
		}

		result = sscanf(argv[3], "%lu", &dWidth);
		if (result < 1)
		{
			throw "Error in data bits argument!\n";
		}

		int argument = 4;

		while (argument < argc)
		{
			char tmpC = 0;
			unsigned long tmpL = 0;

			result = sscanf(argv[argument], "%c%lu", &tmpC, &tmpL);
			if (result < 1 || tmpC != '-' )
			{
				throw "Error in options!\n";
			}

			if (result < 2)
			{
				sscanf(argv[argument], "%c%c", &tmpC, &tmpC);
				if (tmpC != 'z' && tmpC != 'n')
				{
					throw "Unkown option!\n";
				}
				if (tmpC == 'z')
				{
					z = tmpC;
				}
				else
				{
					argument++;

					if (argument == argc)
					{
						throw "No memory size argument!\n";
					}

					result = sscanf(argv[argument], "%lu", &tmpL);
					if (!result)
					{
						throw "Memory size not a number!\n";
					}
					length = tmpL;
				}
			}
			else
			{
				select = tmpL;
			}
			argument++;
		}

		unsigned long selectIter = 0;
		unsigned long blockIter = 0;
		unsigned long bytes = (dWidth + 7) / 8;

		if (!select)
		{
			blockIter = ((1UL << aWidth) + 511) / 512;
			if (length && length < blockIter * 512)
			{
				blockIter = (length + 511) / 512;
			}
		}
		else if (select == 16)
		{
			selectIter = ((1UL << aWidth) + 15) / 16;
			if (length && length < selectIter * 16)
			{
				selectIter = (length + 15) / 16;
			}
		}
		else
		{
			blockIter = ((1UL << aWidth) * (16 - select) / 16 + 511) / 512;
			selectIter = ((1UL << aWidth) - blockIter * 512 + 15) / 16;
		}

		unsigned long blockTotal = ((1UL << aWidth) + 511) / 512;
		if (length && length < blockTotal * 512)
		{
			blockTotal = (length + 511) / 512;
		}

		if (length)
		{
			if (length > selectIter * 16)
			{
				blockIter -= ((1UL << aWidth) + 511) / 512 - blockTotal;
			}
			else
			{
				blockIter = 0;
			}
		}
		if (length && !blockIter && length < selectIter * 16)
		{
			selectIter = (length + 15) / 16;
		}

		cerr << "Creating ROM with " << selectIter * bytes;
		cerr << " RAM16X1S and "  << blockIter * bytes << " RAMB4_S8\n";

		printf("-- This file was generated with xrom written by Daniel Wallner\n");
		printf("\nlibrary IEEE;");
		printf("\nuse IEEE.std_logic_1164.all;");
		printf("\nuse IEEE.numeric_std.all;");
		printf("\n\nentity %s is", argv[1]);
		printf("\n\tport(");
		printf("\n\t\tClk\t: in std_logic;");
		printf("\n\t\tA\t: in std_logic_vector(%d downto 0);", aWidth - 1);
		printf("\n\t\tD\t: out std_logic_vector(%d downto 0)", dWidth - 1);
		printf("\n\t);");
		printf("\nend %s;", argv[1]);
		printf("\n\narchitecture rtl of %s is", argv[1]);

		if (selectIter)
		{
			printf("\n\tcomponent RAM16X1S");
			printf("\n\t\tport(");
			printf("\n\t\t\tO    : out std_ulogic;");
			printf("\n\t\t\tA0   : in std_ulogic;");
			printf("\n\t\t\tA1   : in std_ulogic;");
			printf("\n\t\t\tA2   : in std_ulogic;");
			printf("\n\t\t\tA3   : in std_ulogic;");
			printf("\n\t\t\tD    : in std_ulogic;");
			printf("\n\t\t\tWCLK : in std_ulogic;");
			printf("\n\t\t\tWE   : in std_ulogic);");
			printf("\n\tend component;\n");
		}
		if (blockIter)
		{
			printf("\n\tcomponent RAMB4_S8");
			printf("\n\t\tport(");
			printf("\n\t\t\tDO     : out std_logic_vector(7 downto 0);");
			printf("\n\t\t\tADDR   : in std_logic_vector(8 downto 0);");
			printf("\n\t\t\tCLK    : in std_ulogic;");
			printf("\n\t\t\tDI     : in std_logic_vector(7 downto 0);");
			printf("\n\t\t\tEN     : in std_ulogic;");
			printf("\n\t\t\tRST    : in std_ulogic;");
			printf("\n\t\t\tWE     : in std_ulogic);");
			printf("\n\tend component;\n");
		}

		if (selectIter > 0)
		{
			printf("\n\tsignal A_r: unsigned(A'range);");
		}
		if (selectIter > 1)
		{
			printf("\n\ttype sRAMOut_a is array(0 to %d) of std_logic_vector(D'range);", selectIter - 1);
			printf("\n\tsignal sRAMOut : sRAMOut_a;");
			printf("\n\tsignal siA_r : integer;");
		}
		if (selectIter && blockIter)
		{
			printf("\n\tsignal sD : std_logic_vector(D'range);");
		}
		if (blockIter == 1)
		{
			printf("\n\tsignal bRAMOut : std_logic_vector(%d downto 0);", bytes * 8 - 1);
		}
		if (blockIter > 1)
		{
			printf("\n\ttype bRAMOut_a is array(%d to %d) of std_logic_vector(%d downto 0);", blockTotal - blockIter, blockTotal - 1, bytes * 8 - 1);
			printf("\n\tsignal bRAMOut : bRAMOut_a;");
			printf("\n\tsignal biA_r : integer;");
			if (!selectIter)
			{
				printf("\n\tsignal A_r : unsigned(A'left downto 9);");
			}
		}
		if (selectIter && blockIter)
		{
			printf("\n\tsignal bD : std_logic_vector(D'range);");
		}

		printf("\nbegin");

		if (selectIter > 0 || blockIter > 1)
		{
			printf("\n\tprocess (Clk)");
			printf("\n\tbegin");
			printf("\n\t\tif Clk'event and Clk = '1' then");
			if (!selectIter)
			{
				printf("\n\t\t\tA_r <= unsigned(A(A'left downto 9));");
			}
			else
			{
				printf("\n\t\t\tA_r <= unsigned(A);");
			}
			printf("\n\t\tend if;");
			printf("\n\tend process;");
		}

		if (selectIter == 1)
		{
			printf("\n\n\tsG1: for I in 0 to %d generate", dWidth - 1);
			printf("\n\t\tS%s : RAM16X1S\n\t\t\tport map (", argv[1]);
			if (blockIter)
			{
				printf("s");
			}
			printf("WE => '0', WCLK => '0', D => '0', O => D(I), A0 => A_r(0), A1 => A_r(1), A2 => A_r(2), A3 => A_r(3));");
			printf("\n\tend generate;");
		}
		if (selectIter > 1)
		{
			printf("\n\n\tsiA_r <= to_integer(A_r(A'left downto 4));");
			printf("\n\n\tsG1: for I in 0 to %d generate", selectIter - 1);
			printf("\n\t\tsG2: for J in 0 to %d generate", dWidth - 1);
			printf("\n\t\t\tS%s : RAM16X1S\n\t\t\t\tport map (WE => '0', WCLK => '0', D => '0', O => sRAMOut(I)(J), A0 => A_r(0), A1 => A_r(1), A2 => A_r(2), A3 => A_r(3));", argv[1]);
			printf("\n\t\tend generate;");
			if (z == 'z')
			{
				printf("\n\t\t");
				if (blockIter)
				{
					printf("s");
				}
				printf("D <= sRAMOut(I) when siA_r = I else (others => 'Z');");
			}
			printf("\n\tend generate;");
			if (z != 'z')
			{
				printf("\n\n\tprocess (siA_r, sRAMOut)\n\tbegin\n\t\t");
				if (blockIter)
				{
					printf("s");
				}
				printf("D <= sRAMOut(0);");
				printf("\n\t\tfor I in 1 to %d loop", selectIter - 1);
				printf("\n\t\t\tif siA_r = I then\n\t\t\t\t");
				if (blockIter)
				{
					printf("s");
				}
				printf("D <= sRAMOut(I);\n\t\t\tend if;");
				printf("\n\t\tend loop;\n\tend process;");
			}
		}

		if (blockIter == 1)
		{
			printf("\n\n\tbG1: for J in 0 to %d generate", bytes - 1);
			printf("\n\t\tB%s : RAMB4_S8", argv[1]);
			printf("\n\t\t\tport map (DI => \"00000000\", EN => '1', RST => '0', WE => '0', CLK => Clk, ADDR => A(8 downto 0), DO => bRAMOut(7 + 8 * J downto 8 * J));", argv[1]);
			printf("\n\tend generate;");
			printf("\n\n\t");
			if (selectIter)
			{
				printf("b");
			}
			printf("D <= bRAMOut(D'range);");
		}
		if (blockIter > 1)
		{
			printf("\n\n\tbiA_r <= to_integer(A_r(A'left downto 9));");
			printf("\n\n\tbG1: for I in %d to %d generate", blockTotal - blockIter, blockTotal - 1);
			printf("\n\t\tbG2: for J in 0 to %d generate", bytes - 1);
			printf("\n\t\t\tB%s : RAMB4_S8\n\t\t\t\tport map (DI => \"00000000\", EN => '1', RST => '0', WE => '0', CLK => Clk, ADDR => A(8 downto 0), DO => bRAMOut(I)(7 + 8 * J downto 8 * J));", argv[1]);
			printf("\n\t\tend generate;");
			if (z == 'z')
			{
				printf("\n\t\t");
				if (selectIter)
				{
					printf("b");
				}
				printf("D <= bRAMOut(I) when biA_r = I else (others => 'Z');");
			}
			printf("\n\tend generate;");
			if (z != 'z')
			{
				printf("\n\n\tprocess (biA_r, bRAMOut)\n\tbegin\n\t\t");
				if (selectIter)
				{
					printf("b");
				}
				printf("D <= bRAMOut(%d)(D'range);", blockTotal - blockIter);
				printf("\n\t\tfor I in %d to %d loop", blockTotal - blockIter + 1, blockTotal - 1);
				printf("\n\t\t\tif biA_r = I then\n\t\t\t\t");
				if (selectIter)
				{
					printf("b");
				}
				printf("D <= bRAMOut(I)(D'range);\n\t\t\tend if;");
				printf("\n\t\tend loop;\n\tend process;");
			}
		}

		if (selectIter && blockIter)
		{
			printf("\n\n\tD <= bD when A_r(A'left downto 9) >= %d else sD;", blockTotal - blockIter);
		}

		printf("\nend;\n");

		return 0;
	}
	catch (string error)
	{
		cerr << "Fatal: " << error;
	}
	catch (const char *error)
	{
		cerr << "Fatal: " << error;
	}
	return -1;
}
