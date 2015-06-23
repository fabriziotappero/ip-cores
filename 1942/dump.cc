/*
	Converts binary ROM dump to hexadecimal format
	so Verilog can read it
	
	Requirements:
		  TV80, Z80 Verilog module
		 	Dump of Z80 ROM from 1942 board

  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org
	
*/

// Compile with: g++ dump.cc -o dump

#include <fstream>
#include <iostream>

using namespace std;

int main( int argc, char *argv[]) {
  if( argc!=2 ) {
    cout << "Usage: dump filename\n";
    return -1;
  }
  ifstream f( argv[1] );
  unsigned char *buffer = new unsigned char[16*1024];
  f.read( (char*)buffer, 16*1024 );
  cout << hex;
  unsigned char *aux=buffer;
  // swap all bytes
  /*
  for(int k=0;k<32*1024; k+=2) {
    unsigned char*p = aux;
    unsigned char x0 = *aux++;
    unsigned char x1 = *aux;
    *p=x1;
    *aux=x0;
    aux=p+2;
  }
  aux=buffer;*/
  for(int k=0; k<16*1024; k++ ) {
    unsigned val = *aux++;
    cout << val << "\n";
  }
  
  delete [] buffer;
  return 0;
}
