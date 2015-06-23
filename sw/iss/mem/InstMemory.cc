/*!  
  AEMB INSTRUCTION SET SIMULATOR 
  Copyright (C) 2009 Shawn Tan <shawn.tan@aeste.net>
 
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see
  <http://www.gnu.org/licenses/>.
*/

#include "InstMemory.hh"

#include <utility>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

using namespace std;

namespace aemb
{

void InstMemory::putInst(const int addr, const int data)
{
	int word = addr >> 2; // word align the address
	mem.insert(make_pair(word, data));
}

int InstMemory::getInst(const int addr)
{
	int word = addr >> 2; // word align the address
	assert(!(addr & 0x03)); // check word alignment
	map<int,int>::iterator data = mem.find(word);
	assert(data != mem.end()); // check if the address is valid	
	return data->second;
} 

int InstMemory::readVmem()
{
	char str[255];
	char *tok = NULL;
	char *cend = NULL;
	long addr, data;

	while (fgets(str, 255, stdin) != NULL) {
		switch(str[0]) {
			case '@':
				// extract address
				tok = strtok(str," ");
				cend = tok;
				cend++;				
				addr = strtoul(cend, &cend, 16);
				
				#ifndef NDEBUG
				printf("\n");
				#endif
												
				// extract data
				//tok = strtok(NULL," ");				
				while ((tok = strtok(NULL, " ")) != NULL) {
					data = strtoul(tok, &cend, 16);
					putInst((addr << 2), data);

					#ifndef NDEBUG				
					printf("\t%X:%.8X", (unsigned int)addr,(unsigned int)data);
					#endif

					++addr;
				}		
			break;

			default: // ignored line
				//fprintf(stderr,"*** Error parsing VMEM format ***\n");
			break;			
		}
		
	}
	
	#ifndef NDEBUG
	printf("\nVMEM size: %d",mem.size());
	#endif
	
	return mem.size();	
}

void InstMemory::dumpMem()
{
	map<int,int>::iterator iter;
	
	for (iter = mem.begin(); iter != mem.end(); ++iter) {
		#ifndef NDEBUG
		printf("\n%X : %.8X",iter->first, iter->second);
		#endif
	}
	
}

InstMemory::InstMemory()
{
}

InstMemory::~InstMemory()
{
}

}