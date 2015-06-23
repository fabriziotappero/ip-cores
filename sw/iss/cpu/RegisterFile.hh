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

#ifndef _AEMBREGISTERGP_H_
#define _AEMBREGISTERGP_H_

#include <vector>

using std::vector;

namespace aemb {

/**
 * List of special function registers
 */
typedef enum
{
	SFR_PC = 0,
	SFR_MSR = 1,
	SFR_EAR = 3,
	SFR_ESR = 5,	
} SpecialRegs;

/**
   Behavioral class for the general purpose register file that can
   only be read from and written to. It has internal mechanisms to
   check for data hazards.
*/

class RegisterFile
{
	vector<int> regfile; ///< internal general purpose register file
	int rsfr;	
public:
	
	void reset();

	/**
	 * Put a value into a register.
	 * @param gpr Register number [0:31].
	 * @param data Register data to write
	 */  
	 
	void setRegister(const int gpr, const int data);
	
  	/**
  	 * Get a value from a register.
  	 * @param gpr Register number [0:31].
  	 * @return Value of the register.
  	 */
  	 
  	int getRegister(const int gpr);
  	
  	/**
  	 * Get the value of a special register.
  	 * @param sfr Special register number
  	 * @return Special register value
  	 */
  	 
  	int getSpecial(const int sfr);
  	
  	/**
  	 * Set the value of a special register
  	 * @param sfr Special register number
  	 * @param imm32 Special register value
  	 */
  	 
  	void setSpecial(const int sfr, const int imm32);
  	
  	int clrSpecial(const int imm14);
  	int setSpecial(const int imm14);
  
  	RegisterFile();
  	~RegisterFile();
};

}
#endif