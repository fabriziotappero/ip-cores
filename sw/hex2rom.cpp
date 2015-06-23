//
// Binary and intel/motorola hex to VHDL ROM converter
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
//	No support for wrapped intel segments
//	Requires stl to compile
//
// File history :
//
// 0146 : Initial release
//
// 0150 : Added binary read
//
// 0208 : Changed some errors to warnings
//
// 0215 : Added support for synchronous ROM
//
// 0220 : Changed array ROM format, added support for Xilinx .UCF generation
//
// 0221 : Fixed small .UCF generation for small ROMs
//
// 0244 : Added Leonardo .UCF option
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

class MemBlock
{
public:
	unsigned long m_startAddress;
	vector<unsigned char> m_bytes;
};

class File
{
public:
	explicit File(const char *fileName, const char *mode)
	{
		m_file = fopen(fileName, mode);
		if (m_file != NULL)
		{
			return;
		}
		string errorStr = "Error opening ";
		errorStr += fileName;
		errorStr += "\n";
		throw errorStr;
	}

	~File()
	{
		fclose(m_file);
	}

	// Read binary file
	void ReadBin(unsigned long limit)
	{
		m_top = 0;

		m_chunks.push_back(MemBlock());
		m_chunks.back().m_startAddress = 0;

		cerr << "Reading binary file\n";

		int tmp = fgetc(m_file);

		while (!feof(m_file))
		{
			m_chunks.back().m_bytes.push_back(tmp);

			if (m_chunks.back().m_bytes.size() > limit + 1)
			{
				m_chunks.back().m_bytes.pop_back();
				m_top = m_chunks.back().m_bytes.size() - 1;
				cerr << "Ignoring data above address space!\n";
				cerr << " Limit: " << limit << "\n";
				return;
			}

			tmp = fgetc(m_file);
		}

		m_top = m_chunks.back().m_bytes.size() - 1;

		if (!m_chunks.back().m_bytes.size())
		{
			cerr << "No data!\n";

			m_chunks.pop_back();
		}
	}

	// Read hex file
	void ReadHex(unsigned long limit)
	{
		char szLine[1024];
		bool formatDetected = false;
		bool intel;
		bool endSeen = false;
		bool linear = true;				// Only used for intel hex
		unsigned long addressBase = 0;	// Only used for intel hex
		unsigned long dataRecords = 0;	// Only used for s-record
		while (!feof(m_file))
		{
			if (fgets(szLine, 1024, m_file) == 0)
			{
				if (ferror(m_file))
				{
					throw "Error reading input!\n";
				}
				continue;
			}

			if (szLine[strlen(szLine) - 1] == 0xA || szLine[strlen(szLine) - 1] == 0xD)
			{
				szLine[strlen(szLine) - 1] = 0;
			}

			if (szLine[strlen(szLine) - 1] == 0xA || szLine[strlen(szLine) - 1] == 0xD)
			{
				szLine[strlen(szLine) - 1] = 0;
			}

			if (strlen(szLine) == 1023)
			{
				throw "Hex file lines to long!\n";
			}
			// Ignore blank lines
			if (szLine[0] == '\n')
			{
				continue;
			}
			// Detect format and warn if garbage lines are found
			if (!formatDetected)
			{
				if (szLine[0] != ':' && szLine[0] != 'S')
				{
					cerr << "Ignoring garbage line!\n";
					continue;
				}
				if (szLine[0] == 'S')
				{
					intel = false;
					cerr << "Detected S-Record\n";
				}
				else
				{
					intel = true;
					cerr << "Detected intel hex file\n";
				}
				formatDetected = true;
			}
			else if ((intel && szLine[0] != ':') ||
					(!intel && szLine[0] != 'S'))
			{
				cerr << "Ignoring garbage line!\n";
				continue;
			}

			if (endSeen)
			{
				throw "Hex line after end of file record!\n";
			}

			if (intel)
			{
				unsigned long	dataBytes;
				unsigned long	startAddress;
				unsigned long	type;
				if (sscanf(&szLine[1], "%2lx%4lx%2lx", &dataBytes, &startAddress, &type) != 3)
				{
					throw "Hex line beginning corrupt!\n";
				}
				// Check line length
				if (szLine[11 + dataBytes * 2] != '\n' && szLine[11 + dataBytes * 2] != 0)
				{
					throw "Hex line length incorrect!\n";
				}
				// Check line checksum
				unsigned char	checkSum = 0;
				unsigned long	tmp;
				for (unsigned int i = 0; i <= dataBytes + 4; ++i)
				{
					if (sscanf(&szLine[1 + i * 2], "%2lx", &tmp) != 1)
					{
						throw "Hex line data corrupt!\n";
					}
					checkSum += tmp;
				}
				if (checkSum != 0)
				{
					throw "Hex line checksum error!\n";
				}

				switch (type)
				{
				case 0:
					// Data record
					if (!linear)
					{
						// Segmented
						unsigned long test = startAddress;
						test += dataBytes;
						if (test > 0xffff)
						{
							throw "Can't handle wrapped segments!\n";
						}
					}
					if (!m_chunks.size() ||
						m_chunks.back().m_startAddress + m_chunks.back().m_bytes.size() !=
						addressBase + startAddress)
					{
						m_chunks.push_back(MemBlock());
						m_chunks.back().m_startAddress = addressBase + startAddress;
					}
					{
						unsigned char i = 0;
						for (i = 0; i < dataBytes; ++i)
						{
							sscanf(&szLine[9 + i * 2], "%2lx", &tmp);
							if (addressBase + startAddress + i > limit)
							{
								cerr << "Ignoring data above address space!\n";
								cerr << "Data address: " << addressBase + startAddress + i;
								cerr << " Limit: " << limit << "\n";
								if (!m_chunks.back().m_bytes.size())
								{
									m_chunks.pop_back();
								}
								continue;
							}
							m_chunks.back().m_bytes.push_back(tmp);
						}
					}
					break;

				case 1:
					// End-of-file record
					if (dataBytes != 0)
					{
						cerr << "Warning: End of file record not zero length!\n";
					}
					if (startAddress != 0)
					{
						cerr << "Warning: End of file record address not zero!\n";
					}
					endSeen = true;
					break;

				case 2:
					// Extended segment address record
					if (dataBytes != 2)
					{
						throw "Length field must be 2 in extended segment address record!\n";
					}
					if (startAddress != 0)
					{
						throw "Address field must be zero in extended segment address record!\n";
					}
					sscanf(&szLine[9], "%4lx", &startAddress);
					addressBase = startAddress << 4;
					linear = false;
					break;

				case 3:
					// Start segment address record
					if (dataBytes != 4)
					{
						cerr << "Warning: Length field must be 4 in start segment address record!\n";
					}
					if (startAddress != 0)
					{
						cerr << "Warning: Address field must be zero in start segment address record!\n";
					}
					if (dataBytes == 4)
					{
						unsigned long ssa;
						char	ssaStr[16];
						sscanf(&szLine[9], "%8lx", &ssa);
						sprintf(ssaStr, "%08X\n", ssa);
						cerr << "Segment start address (CS/IP): ";
						cerr << ssaStr;
					}
					break;

				case 4:
					// Extended linear address record
					if (dataBytes != 2)
					{
						throw "Length field must be 2 in extended linear address record!\n";
					}
					if (startAddress != 0)
					{
						throw "Address field must be zero in extended linear address record!\n";
					}
					sscanf(&szLine[9], "%4lx", &startAddress);
					addressBase = ((unsigned long)startAddress) << 16;
					linear = true;
					break;

				case 5:
					// Start linear address record
					if (dataBytes != 4)
					{
						cerr << "Warning: Length field must be 4 in start linear address record!\n";
					}
					if (startAddress != 0)
					{
						cerr << "Warning: Address field must be zero in start linear address record!\n";
					}
					if (dataBytes == 4)
					{
						unsigned long lsa;
						char	lsaStr[16];
						sscanf(&szLine[9], "%8lx", &lsa);
						sprintf(lsaStr, "%08X\n", lsa);
						cerr << "Linear start address: ";
						cerr << lsaStr;
					}
					break;

				default:
					cerr << "Waring: Unknown record found!\n";
				}
			}
			else
			{
				// S-record
				unsigned long	count;
				char			type;
				if (sscanf(&szLine[1], "%c%2lx", &type, &count) != 2)
				{
					throw "Hex line beginning corrupt!\n";
				}
				// Check line length
				if (szLine[4 + count * 2] != '\n' && szLine[4 + count * 2] != 0)
				{
					throw "Hex line length incorrect!\n";
				}
				// Check line checksum
				unsigned char	checkSum = 0;
				unsigned long	tmp;
				for (unsigned int i = 0; i < count + 1; ++i)
				{
					if (sscanf(&szLine[2 + i * 2], "%2lx", &tmp) != 1)
					{
						throw "Hex line data corrupt!\n";
					}
					checkSum += tmp;
				}
				if (checkSum != 255)
				{
					throw "Hex line checksum error!\n";
				}

				switch (type)
				{
				case '0':
					// Header record
					{
						char header[256];
						unsigned char i = 0;
						for (i = 0; i + 3 < count; ++i)
						{
							sscanf(&szLine[8 + i * 2], "%2lx", &tmp);
							header[i] = tmp;
						}
						header[i] = 0;
						if (i > 0)
						{
							cerr << "Module name: " << header << "\n";
						}
					}
					break;

				case '1':
				case '2':
				case '3':
					// Data record
					{
						dataRecords++;
						unsigned long	startAddress;
						if (type == '1')
						{
							sscanf(&szLine[4], "%4lx", &startAddress);
						}
						else if (type == '2')
						{
							sscanf(&szLine[4], "%6lx", &startAddress);
						}
						else
						{
							sscanf(&szLine[4], "%8lx", &startAddress);
						}

						if (!m_chunks.size() ||
							m_chunks.back().m_startAddress + m_chunks.back().m_bytes.size() !=
							startAddress)
						{
							m_chunks.push_back(MemBlock());
							m_chunks.back().m_startAddress = startAddress;
						}
						unsigned char i = 0;
						for (i = (type - '1'); i + 3 < count; ++i)
						{
							sscanf(&szLine[8 + i * 2], "%2lx", &tmp);
							if (startAddress + i > limit)
							{
								cerr << "Ignoring data above address space!\n";
								cerr << "Data address: " << startAddress + i;
								cerr << " Limit: " << limit << "\n";
								if (!m_chunks.back().m_bytes.size())
								{
									m_chunks.pop_back();
								}
								continue;
							}
							m_chunks.back().m_bytes.push_back(tmp);
						}
					}
					break;

				case '5':
					// Count record
					{
						unsigned long	address;
						sscanf(&szLine[4], "%4lx", &address);
						if (address != dataRecords)
						{
							throw "Wrong number of data records!\n";
						}
					}
					break;

				case '7':
				case '8':
				case '9':
					// Start address record
					cerr << "Ignoring start address record!\n";
					break;

				default:
					cerr << "Unknown record found!\n";
				}
			}
		}
		if (intel && !endSeen)
		{
			cerr << "No end of file record!\n";
		}
		if (!m_chunks.size())
		{
			throw "No data in file!\n";
		}
		vector<MemBlock>::iterator	vi;
		m_top = 0;
		for (vi = m_chunks.begin(); vi < m_chunks.end(); vi++)
		{
			m_top = max(m_top, vi->m_startAddress + vi->m_bytes.size() - 1);
		}
	}

	// Rather inefficient this one, fix sometime
	bool GetByte(const unsigned long address, unsigned char &chr)
	{
		vector<MemBlock>::iterator	vi;

		for (vi = m_chunks.begin(); vi < m_chunks.end(); vi++)
		{
			if (vi->m_startAddress + vi->m_bytes.size() > address && vi->m_startAddress <= address)
			{
				break;
			}
		}
		if (vi == m_chunks.end())
		{
			return false;
		}
		chr = vi->m_bytes[address - vi->m_startAddress];
		return true;
	}

	bool BitString(const unsigned long address, const unsigned char bits, const bool lEndian, string &str)
	{
		bool			ok = false;
		long			i;
		unsigned char	chr;
		unsigned long	data = 0;
		unsigned long	tmp;

		if (lEndian)
		{
			for (i = 0; i < (bits + 7) / 8; ++i)
			{
				ok |= GetByte(address + i, chr);
				tmp = chr;
				data |= tmp << (8 * i);
			}
		}
		else
		{
			for (i = 0; i < (bits + 7) / 8; ++i)
			{
				ok |= GetByte(address + i, chr);
				tmp = chr;
				data |= tmp << (8 * ((bits + 7) / 8 - i - 1));
			}
		}

		if (!ok)
		{
			return false;
		}

		unsigned long mask = 1;

		str = "";
		for (i = 0; i < bits; i++)
		{
			if (data & mask)
			{
				str.insert(0,"1");
			}
			else
			{
				str.insert(0,"0");
			}
			mask <<= 1;
		}
		return true;
	}

	FILE *Handle() { return m_file; };
	vector<MemBlock>	m_chunks;
	unsigned long		m_top;
private:
	FILE				*m_file;
};


int main (int argc, char *argv[])
{
	cerr << "Hex to VHDL ROM converter by Daniel Wallner. Version 0244\n";

	try
	{
		unsigned long aWidth;
		unsigned long dWidth;
		char endian;
		char O = 0;

		if (!(argc == 4 || argc == 5))
		{
			cerr << "\nUsage: hex2rom [-b] <input file> <entity name> <format>\n";
			cerr << "\nIf the -b option is specified the file is read as a binary file\n";
			cerr << "Hex input files must be intel hex or motorola s-record\n";
			cerr << "\nThe format string has the format AEDOS where:\n";
			cerr << "  A = Address bits\n";
			cerr << "  E = Endianness, l or b\n";
			cerr << "  D = Data bits\n";
			cerr << "  O = ROM type: (one optional character)\n";
			cerr << "      z for tri-state output\n";
			cerr << "      a for array ROM\n";
			cerr << "      s for synchronous ROM\n";
			cerr << "      u for XST ucf\n";
			cerr << "      l for Leonardo ucf\n";
			cerr << "  S = SelectRAM usage in 1/16 parts (only used when O = u)\n";
			cerr << "\nExample:\n";
			cerr << "  hex2rom test.hex Test_ROM 18b16z\n\n";
			return -1;
		}

		string	inFileName;
		string	outFileName;

		unsigned long	bytes;
		unsigned long	select = 0;

		if (argc == 5)
		{
			if (strcmp(argv[1], "-b"))
			{
				throw "Error in arguments!\n";
			}
		}

		int result;

		result = sscanf(argv[argc - 1], "%lu%c%lu%c%lu", &aWidth, &endian, &dWidth, &O, &select);
		if (result < 3)
		{
			throw "Error in output format argument!\n";
		}

		if (aWidth > 32 || (endian != 'l' && endian != 'b') || dWidth > 32 || (result > 3 && O != 'z' && O != 'a' && O != 's' && O != 'u' && O != 'l'))
		{
			throw "Error in output format argument!\n";
		}
		inFileName = argv[argc - 3];
		outFileName = argv[argc - 2];

		bytes = (dWidth + 7) / 8;

		File	inFile(inFileName.c_str(), "rb");

		if (argc == 4)
		{
			inFile.ReadHex((1UL << aWidth) * bytes - 1);
		}
		else
		{
			inFile.ReadBin((1UL << aWidth) * bytes - 1);
		}

		string				line;

		unsigned long	words = 1;
		unsigned long	i = inFile.m_top;
		i /= bytes;

		while (i != 0)
		{
			i >>= 1;
			words <<= 1;
		}

		if (O != 'u' && O != 'l')
		{
			printf("-- This file was generated with hex2rom written by Daniel Wallner\n");
			printf("\nlibrary IEEE;");
			printf("\nuse IEEE.std_logic_1164.all;");
			printf("\nuse IEEE.numeric_std.all;");
			printf("\n\nentity %s is", outFileName.c_str());
			printf("\n\tport(");
			if (O == 'z')
			{
				printf("\n\t\tCE_n\t: in std_logic;", dWidth - 1);
				printf("\n\t\tOE_n\t: in std_logic;", dWidth - 1);
			}
			if (O == 's')
			{
				printf("\n\t\tClk\t: in std_logic;", dWidth - 1);
			}
			printf("\n\t\tA\t: in std_logic_vector(%d downto 0);", aWidth - 1);
			printf("\n\t\tD\t: out std_logic_vector(%d downto 0)", dWidth - 1);
			printf("\n\t);");
			printf("\nend %s;", outFileName.c_str());
			printf("\n\narchitecture rtl of %s is", outFileName.c_str());
			if (!O)
			{
				printf("\nbegin");
				printf("\n\tprocess (A)");
				printf("\n\tbegin");
				printf("\n\t\tcase to_integer(unsigned(A)) is");
			}
			else if (O == 's')
			{
				printf("\n\tsignal A_r : std_logic_vector(%d downto 0);", aWidth - 1);
				printf("\nbegin");
				printf("\n\tprocess (Clk)");
				printf("\n\tbegin");
				printf("\n\t\tif Clk'event and Clk = '1' then");
				printf("\n\t\t\tA_r <= A;");
				printf("\n\t\tend if;");
				printf("\n\tend process;");
				printf("\n\tprocess (A_r)");
				printf("\n\tbegin");
				printf("\n\t\tcase to_integer(unsigned(A_r)) is");
			}
			else
			{
				printf("\n\tsubtype ROM_WORD is std_logic_vector(%d downto 0);", dWidth - 1);
				printf("\n\ttype ROM_TABLE is array(0 to %d) of ROM_WORD;", words - 1);
				printf("\n\tconstant ROM: ROM_TABLE := ROM_TABLE'(");
			}

			string str;
			string strDC;
			for (i = 0; i < dWidth; i++)
			{
				strDC.insert(0, "-");
			}
			for (i = 0; i < words; i++)
			{
				if (!inFile.BitString(i * bytes, dWidth, endian == 'l', str))
				{
					str = strDC;
				}
				if (!O || O == 's')
				{
					if (inFile.m_top / bytes >= i)
					{
						printf("\n\t\twhen %06d => D <= \"%s\";",i, str.c_str());
						printf("\t-- 0x%04X", i * bytes);
					}
				}
				else
				{
					printf("\n\t\t\"%s", str.c_str());
					if (i != words - 1)
					{
						printf("\",");
					}
					else
					{
						printf("\");");
					}
					printf("\t-- 0x%04X", i * bytes);
				}
			}

			if (!O || O == 's')
			{
				printf("\n\t\twhen others => D <= \"%s\";", strDC.c_str());
				printf("\n\t\tend case;");
				printf("\n\tend process;");
			}
			else
			{
				printf("\nbegin");
				if (O == 'z')
				{
					printf("\n\tD <= ROM(to_integer(unsigned(A))) when CE_n = '0' and OE_n = '0' else (others => 'Z');");
				}
				else
				{
					printf("\n\tD <= ROM(to_integer(unsigned(A)));");
				}
			}
			printf("\nend;\n");
		}
		else
		{
			unsigned long selectIter = 0;
			unsigned long blockIter = 0;

			if (!select)
			{
				blockIter = ((1UL << aWidth) + 511) / 512;
			}
			else if (select == 16)
			{
				selectIter = ((1UL << aWidth) + 15) / 16;
			}
			else
			{
				blockIter = ((1UL << aWidth) * (16 - select) / 16 + 511) / 512;
				selectIter = ((1UL << aWidth) - blockIter * 512 + 15) / 16;
			}

			cerr << "Creating .ucf file with " << selectIter * bytes;
			cerr << " LUTs and "  << blockIter * bytes << " block RAMs\n";

			unsigned long blockTotal = ((1UL << aWidth) + 511) / 512;

			printf("# This file was generated with hex2rom written by Daniel Wallner\n");

			for (i = 0; i < selectIter; i++)
			{
				unsigned long base = i * 16 * bytes;
				unsigned long j;
				unsigned char c;
				unsigned long pos;

				// Check that there is any actual data in segment
				bool init = false;
				for (pos = 0; pos < bytes * 16; pos++)
				{
					init = inFile.GetByte(base + pos, c);
					if (init)
					{
						break;
					}
				}

				if (init)
				{
					for (j = 0; j < dWidth; j++)
					{
						unsigned long bitMask = 1;
						unsigned long bits = 0;

						for (pos = 0; pos < 16; pos++)
						{
							unsigned long addr;

							if (endian = 'l')
							{
								addr = base + bytes * pos + j / 8;
							}
							else
							{
								addr = base + bytes * pos + bytes - j / 8 - 1;
							}

							c = 0;
							inFile.GetByte(addr, c);
							if (c & (1 << (j % 8)))
							{
								bits |= bitMask;
							}
							bitMask <<= 1;
						}

						if (O == 'u')
						{
							if (selectIter == 1)
							{
								printf("\nINST *s%s%d INIT = %04X;", outFileName.c_str(), j, bits);
							}
							else
							{
								printf("\nINST *s%s%d%d INIT = %04X;", outFileName.c_str(), i, j, bits);
							}
						}
						else
						{
							if (selectIter == 1)
							{
								printf("\nINST *sG1_%d_S%s INIT = %04X;", j, outFileName.c_str(), bits);
							}
							else
							{
								printf("\nINST *sG1_%d_sG2_%d_S%s INIT = %04X;", i, j, outFileName.c_str(), bits);
							}
						}
					}
				}
			}

			for (i = blockTotal - blockIter; i < blockTotal; i++)
			{
				unsigned long j;
				for (j = 0; j < bytes; j++)
				{
					unsigned long k;
					for (k = 0; k < 16; k++)
					{
						unsigned long base = i * 512 * bytes + k * 32 * bytes;
						unsigned char c;
						unsigned long pos;

						// Check that there is any actual data in segment
						bool init = false;
						for (pos = 0; pos < 32; pos++)
						{
							init = inFile.GetByte(base + bytes * pos + j, c);
							if (init)
							{
								break;
							}
						}

						if (init)
						{
							if (O == 'u')
							{
								if (blockIter == 1)
								{
									printf("\nINST *b%s%d INIT_%02X = ", outFileName.c_str(), j, k);
								}
								else
								{
									printf("\nINST *b%s%d%d INIT_%02X = ", outFileName.c_str(), i, j, k);
								}
							}
							else
							{
								if (blockIter == 1)
								{
									printf("\nINST *bG1_%d_B%s INIT_%02X = ", j, outFileName.c_str(), k);
								}
								else
								{
									printf("\nINST *bG1_%d_bG2_%d_B%s INIT_%02X = ", i, j, outFileName.c_str(), k);
								}
							}
							for (pos = 0; pos < 32; pos++)
							{
								unsigned long addr;

								if (endian = 'l')
								{
									addr = base + bytes * (31 - pos) + j;
								}
								else
								{
									addr = base + bytes * (31 - pos) + bytes - j - 1;
								}

								c = 0;
								inFile.GetByte(addr, c);
								printf("%02X", c);
							}
							printf(";");
						}
					}
				}
			}
			printf("\n");
		}
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
