/*
	Converts output from 1942.v to .wav file

  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/

// Compile with  g++ log2wav.cc -o log2wav

#include <iostream>
#include <fstream>
#include <vector>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <string>
#include <signal.h>

using namespace std;

class Args {
public:
  int skip;
  string filename;
  string outputfile;
  bool stereo;
	const char *waitline;
  Args( int argc, char *argv[]) : 
		skip(0), outputfile("out.wav"), stereo(false), waitline(NULL)
	{
    int k=1;    
    bool filename_known=false;
    while( k < argc ) {    
      if( strcmp(argv[k],"-l")==0 ) {
        k++;
        if( k >= argc ) throw "Expected number of lines to skip after -l";
        skip = atoi( argv[k] );
        cout << skip << " lines will be skipped\n";
        k++;
        continue;
      }
      if( strcmp(argv[k],"-o")==0 ) {
        k++;
        if( k >= argc ) throw "Expected output file name after -o";
        outputfile = argv[k];
        k++;
        continue;
      }      
      if( strcmp(argv[k],"--wait")==0 ) {
        k++;
        if( k >= argc ) throw "Expected output file name after --wait";
        waitline = argv[k];
        k++;
        continue;
      }    
      if( strcmp(argv[k],"-s")==0 ) { // stereo
        k++;
        stereo = true;
        continue;
      }      
      if( filename_known ) { 
        cout << "Unknown parameter " << argv[k] << "\n";
        throw "Incorrect command line";
      }
      filename = argv[k];
      filename_known = true;
      k++;
    }
    if( filename=="-" || !filename_known ) filename=string("/dev/stdin");
  }
};

bool sigint_abort=false;

void sigint_handle(int x ) {
	sigint_abort = true;	
}

int main(int argc, char *argv[]) {
	try {
		ifstream fin;
		Args ar( argc, argv );
		cout << "Input file " << ar.filename << "\n";
		fin.open(ar.filename.c_str());
		ofstream fout(ar.outputfile.c_str());
		if( fin.bad() || fin.fail() ) throw "Cannot open input file";
		if( fout.bad() || fout.fail() ) throw "Cannot open output file";		
		assert( sizeof(short int)==2 );
		char buffer[1024];
		int data=0;
				
		// depending on the simulator the following "while"
		// section might no be needed or modified
		// It just skips simulator output until the real data
		// starts to come out	
		for( int k=0; k<ar.skip && !fin.eof(); k++ ) {
			fin.getline( buffer, sizeof(buffer) );
			//if( strcmp(buffer,"ncsim> run" )==0) break;
		} 
		// wait for a given line in the output
		buffer[0]=0;
		if( ar.waitline ) 
			while( !fin.eof() && strcmp( buffer, ar.waitline) ) 
				fin.getline( buffer, sizeof(buffer) );
		
		// start conversion
		if( fin.eof() ) throw "Data not found";
		fout.seekp(44);
		signal( 2, sigint_handle ); // capture CTRL+C in order to save the
		// WAV header before quiting
		while( !fin.eof() && !fin.bad() && !fin.fail() && !sigint_abort ) {
			short int value;
			fin.getline( buffer, sizeof(buffer) );
			
			if( buffer[0]=='S' ) break; // reached line "Simulation complete"
			value = atoi( buffer );
			fout.write( (char*) &value, sizeof(value) );
			data++;
		}
		cout << data << " samples written\n";
		// Write the header
		const char *RIFF = "RIFF";
		fout.seekp(0);
		fout.write( RIFF, 4 );
		int aux=36+2*data;
		fout.write( (char*)&aux, 4 );
		const char *WAVE = "WAVE";
		fout.write( WAVE, 4 );
		const char *fmt = "fmt ";
		fout.write( fmt, 4 );
		aux=16;
		fout.write( (char*)&aux, 4 );// suubchunk 1 size
		short int aux_short = 1; 
		fout.write( (char*)&aux_short, 2 ); // audio format (1)
		aux_short = ar.stereo ? 2 : 1;
		fout.write( (char*)&aux_short, 2 ); // num channels (1)
		aux=44100;
		fout.write( (char*)&aux, 4 );
		aux=44100*1*2 * (ar.stereo?2:1);		
		fout.write( (char*)&aux, 4 ); // byte rate
		aux_short= ar.stereo ? 4 : 2;		
		fout.write( (char*)&aux_short, 2 ); // block align		
		aux_short=16;		
		fout.write( (char*)&aux_short, 2 ); // bits per sample
		RIFF="data";
		fout.write( RIFF, 4 );
		aux = data*2;
		fout.write( (char*)&aux, 4 ); // data size		
		return 0;
	}
	catch( const char *msg ) {
    cout << msg << "\n";
    return -1;
  }
}
