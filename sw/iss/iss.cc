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

#include "mem/InstMemory.hh"
#include "cpu/FetchUnit.hh"

#include <stdio.h>

using namespace std;
using namespace aemb;

int main(int argc, char *argv[])
{
	
	printf("AEMB-ISS  Copyright (C) 2009 Shawn Tan <shawn.tan@aeste.net>\n");
	printf("This program comes with ABSOLUTELY NO WARRANTY.\n");
	printf("This is free software, and you are welcome to redistribute it under certain conditions.\n");
	
	InstMemory imem;
	FetchUnit inst;
	
	imem.readVmem();
	//imem.dumpMem();

	InstFormat i;

	for (int j=0x100; j<512; j += 4) {	
		i = inst.tokInst(imem.getInst(j)); //inst.getDecoded(imem.getInst(0));	
		printf("\nOPC:%.2o RD:%.2d RA:%.2d RB:%.2d", i.r.op, i.r.rd, i.r.ra, i.r.rb);
		printf("\nOPC:%.2o RD:%.2d RA:%.2d IMM:%.8x", i.i.op, i.i.rd, i.i.ra, i.i.im);
	}
	return 0;
}