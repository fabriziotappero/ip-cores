//
// Risc5x
// www.OpenCores.Org - November 2001
//
//
// This library is free software; you can distribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU Lesser General Public License for more details.
//
// A RISC CPU core.
//
// (c) Mike Johnson 2001. All Rights Reserved.
// mikej@opencores.org for support or any other issues.
//
// Revision list
//
// version 1.0 initial opencores release
//

#include <stdio.h>
#include <stdlib.h>

#include <iostream>
#include <fstream>
#include <list>
#include <vector>
#include <string>
using namespace std;

#define ROM_SIZE 0x800

class cLine
{
	string line;
public:

	typedef std::vector<cLine> List;
	cLine(string l) : line(l) {}
	string get() {return line;}
};

int hex_to_int(string hex, int start, int len)
{
	int result = 0;

	for (int i = start; i < (start + len); i++) {
	  result <<= 4;
	  if      (hex[i] >= '0' && hex[i] <= '9')
		  result += (hex[i] - '0');
	  else if (hex[i] >= 'A' && hex[i] <= 'F')
		  result += (hex[i] - 'A') +10;
	  else if (hex[i] >= 'a' && hex[i] <= 'f')
		  result += (hex[i] - 'a') +10;
	  else
	  {
		  printf("hex to int error \n");
		  exit (1);
	  }
	}
	return result;
}

int main(int argc, char* argv[])

{
	// read file
	cLine::List l;
	string buffer;
	ifstream infile;

	if(argc != 2)
	{
		printf("no input file \n");
		return -1;
	}

	infile.open(argv[1]);
	if(infile.fail()) {
	   printf("Could not open input file \n");
	   return -1;
	}
	do
	{
		std::getline(infile,buffer,infile.widen('\n'));
		if(!buffer.empty())
		{
		   string::size_type sz1 = buffer.find(":");
		   if(sz1 != string::npos)
		  {
					sz1+=1;
					string::size_type sz2 = buffer.find(";");
					string real(&buffer[sz1]);
					l.push_back(cLine(real));
		   }

		}
	} while(!infile.fail());
	infile.close();

	// process
	int mem[ROM_SIZE];
	string line;
	int len =  l.size();
	int i,j,k,sum;
	int wc,type,data;
	int file_addr = 0;
	int addr = 0;
	int offset = 0;
	int mask = 0;

	// clear mem
	for (i = 0; i < ROM_SIZE; i++) mem[i] = 0;

	// process file
	for (j = 0; j < len-1; j++) {

	  line = l[j].get();
	  wc = hex_to_int(line,0,2);
	  file_addr = hex_to_int(line,2,4);
	  type = hex_to_int(line,6,2);

	  sum = 0;
	  for (i = 0; i < wc*2 + 9; i +=2) {
		sum += hex_to_int(line,i,2);
	  }
	  if ((sum & 0xff) != 0)
		  printf("incorrect checksum line %d \n", j+1);
	  int value = 0;

	  if (type == 0) {
		for (i = 0; i < wc*2; i +=4) {
		  value = hex_to_int(line,i + 8,2) + hex_to_int(line,i+10,2) * 256;
		  mem[addr] = value;
		  addr ++;
		}
	  }
	}
	// print attribute statements
	/*
	for (k = 0; k < 6; k ++){
	  mask = 0x3 << (k*2);

	  printf("\n\n");
	  for (j = 0; j < (ROM_SIZE/128); j++) {
		printf("attribute INIT_%02X of inst%d : label is \042",j,k);
		for (i = 0; i < 128; i+=4) {

		  data  = ((mem[(j*128) + (127 - i)] & mask) >> k*2);
		  data <<= 2;
		  data += ((mem[(j*128) + (126 - i)] & mask) >> k*2);
		  data <<= 2;
		  data += ((mem[(j*128) + (125 - i)] & mask) >> k*2);
		  data <<= 2;
		  data += ((mem[(j*128) + (124 - i)] & mask) >> k*2);
		  printf("%02X",data);
		}
		printf("\042;\n");
	  }
	}
	*/

	// print ucf statements
	for (k = 0; k < 6; k ++){
	  mask = 0x3 << (k*2);

	  printf("\n\n");
	  for (j = 0; j < (ROM_SIZE/128); j++) {
		printf("INST PRAMS_%d_INST INIT_%02X = ",k,j);
		for (i = 0; i < 128; i+=4) {

		  data  = ((mem[(j*128) + (127 - i)] & mask) >> k*2);
		  data <<= 2;
		  data += ((mem[(j*128) + (126 - i)] & mask) >> k*2);
		  data <<= 2;
		  data += ((mem[(j*128) + (125 - i)] & mask) >> k*2);
		  data <<= 2;
		  data += ((mem[(j*128) + (124 - i)] & mask) >> k*2);
		  printf("%02X",data);
		}
		printf(";\n");
	  }
	}

	return 0;
}
