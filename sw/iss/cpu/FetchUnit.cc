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

#include <assert.h>
#include "FetchUnit.hh"

namespace aemb
{

int FetchUnit::getPC()
{
	return r_pc;
}

void FetchUnit::setPC(const int pc)
{
	assert( !(pc & 0x03) ); // check for alignment
	r_pc = pc;
}
	
InstFormat FetchUnit::tokInst(const int opc)
{
	InstFormat tmp;
	tmp.word = opc;
	return tmp;
}

void FetchUnit::reset()
{
	setPC(0);
}

FetchUnit::FetchUnit()
{
}

FetchUnit::~FetchUnit()
{
}

}