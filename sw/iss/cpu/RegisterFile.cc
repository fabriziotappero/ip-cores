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

#include "RegisterFile.hh"

using namespace std;

namespace aemb {

void RegisterFile::setRegister(const int gpr, const int data)
{
	regfile.at(gpr) = data;
}

int RegisterFile::getRegister(const int gpr)
{
  	return (gpr > 0) ? regfile.at(gpr) : 0;
}

int RegisterFile::getSpecial(const int sfr)
{
	int tmp;
	switch (sfr) {
		case SFR_MSR:
			tmp = rsfr;
		break;
		default: // invalid sfr
			assert(0);
		break;
	}
	return tmp;
}

void RegisterFile::setSpecial(const int sfr, const int imm32)
{
	switch (sfr) {
		case SFR_MSR:
			rsfr = imm32;
		break;
		default: // invalid sfr
			assert(0);
		break;
	}
}

void RegisterFile::reset()
{
	regfile.clear();
	for (int i=0; i<32; ++i) {
    	regfile.push_back(0);
  	}	
}

RegisterFile::RegisterFile()
{
}

RegisterFile::~RegisterFile()
{ 
}

}