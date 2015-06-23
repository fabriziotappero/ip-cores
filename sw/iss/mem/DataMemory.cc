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
#include "DataMemory.hh"
#include <utility>

using std::map;
using std::make_pair;

void DataMemory::putData(const int addr, const int data)
{
	int word = addr >> 2; // word align the address
	mem.insert(make_pair(word, data));
}

int DataMemory::getData(const int addr)
{
	int word = addr >> 2; // word align the address
	map<int,int>::iterator data = mem.find(word);
	return data->second;
} 

DataMemory::DataMemory()
{
}

DataMemory::~DataMemory()
{
}
