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

#ifndef DataMemory_H_
#define DataMemory_H_

#include <map>

using std::map;

class DataMemory
{
	map<int,int> mem;
public:
	/**
	 * Generic memory read
	 * @param addr Address to read.
	 * @return memory word read.
	 * */
	int getData(const int addr); 

	/**
	 * Generic memory write
	 * @param addr Address to write
	 * @param data Data to write
	 */
	void putData(const int addr, const int data);

	/**
	 * Align address
	 * @param addr Address to align
	 **/	

	DataMemory();
	virtual ~DataMemory();
};

#endif /*DataMemory_H_*/
