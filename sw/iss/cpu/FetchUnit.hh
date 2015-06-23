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

#ifndef AEMBINSTRUCTION_H_
#define AEMBINSTRUCTION_H_

using namespace std;

namespace aemb
{
	typedef enum
	{
		OPC_ADD	= 000,
		OPC_RSUB = 001,
		OPC_ADDC = 002,
		OPC_RSUBC = 003,
		OPC_ADDK = 004,
		OPC_RSUBK = 005,
		OPC_ADDKC = 006,
		OPC_RSUBKC = 007,

		OPC_CMP = 005,
		OPC_CMPU = 005,
		
		OPC_ADDI = 010,
		OPC_RSUBI = 011,
		OPC_ADDIC = 012,
		OPC_RSUBIC = 013,
		OPC_ADDIK = 014,
		OPC_RSUBIK = 015,
		OPC_ADDIKC = 016,
		OPC_RSUBIKC = 017,
		
		OPC_MUL = 020,
		OPC_BSRL = 021,
		OPC_BSRA = 021,	
		OPC_BSLL = 021,
		OPC_MULI = 030,
		OPC_BSRLI = 031,
		OPC_BSRAI = 031,
		OPC_BSLLI = 031,
		
		OPC_IDIV = 032,
		OPC_IDIVU = 032,
		
		OPC_OR = 040,
		OPC_AND = 041,
		OPC_XOR = 042,
		OPC_ANDN = 043,
		
		
	} opcodes;

/**
 * FetchUnit formats.
 */
union uInstFormat
{
	int word;
	
	/**
	 * R-format opcode
 	 */
	struct sFormatR
	{
		int im:11; // reserved
		unsigned int rb:5; // rb
		unsigned int ra:5; // ra
		unsigned int rd:5; // rd
		unsigned int op:6; // opcode
	} r;

	/**
	 * I-format opcode
	 */
	struct sFormatI
	{
		int im:16; // immediate
		unsigned int ra:5; // ra
		unsigned int rd:5; // rd
		unsigned int op:6; // opcode
	} i;
};

typedef uInstFormat InstFormat;

class FetchUnit
{
	int r_pc;
	
public:

	void reset();

	/**
	 * Tokenise instructions.
	 * Decode the raw instructions into the opcode structure.
	 * @param opc Opcode raw value
	 * @return structure holding the opcode
	 */
	 
	InstFormat tokInst(const int opc);
	
	/**
	 * Get PC
	 */
	int getPC();
	
	/**
	 * Set PC
	 */
	void setPC(const int pc);
	
	FetchUnit();
	virtual ~FetchUnit();
};

}
#endif /*InstRUCTION_H_*/
