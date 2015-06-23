/*
	Converts PWM output from 1942.v to .log file
	the output can be piped into log2wav in order to get the wav file

  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/

// Compile with  g++ pwm2wav.cc -o pwm2wav

#include <iostream>
#include <string.h>
#include <stdlib.h>

using namespace std;

struct ym_output {
  double a,b,c;
};

void parse( char *buf, int len, double pwm[6] ) {
  int k=0;
  buf=strtok( buf, ",");
  for( k=0; k<6; k++ ) {
    if( buf==NULL ) throw "incomplete line (1)";
    pwm[k] = (double)atoi( buf );
    if( pwm[k]!=0 && pwm[k]!=1 ) pwm[k]=0;
    buf=strtok( NULL, " ");
  }
}

void calc_voltage( double& vcap, double pwm[3] ) {
  const double res = 7.23;
  const double cap = 4e-6; // if RC=7.23 us => f0=22kHz 
  double dv=0;
  const double dt = 20e-9; 
  for(int k=0; k<3; k++ )
    dv += pwm[k] - vcap;
  vcap += dv*dt/res/cap;
}

int main( int argc, char *argv[] ) {
  double vcap_left=0, vcap_right=0;
  char buf[1024];
  int skip = 1; // lines to skip
  for(int k=0; k<skip; k++ )
    cin.getline( buf, sizeof(buf) ); 
  // conversion
  try {
    long int sample=0;
    // skip first line
		buf[0]=0;
		while( strncmp("1942 START",buf, 11 ) && !cin.eof() && !cin.fail() )
    	cin.getline( buf, sizeof(buf) );
    
    cin.getline( buf, sizeof(buf) );
    while( buf[0] && !cin.eof() ) {
      double pwm[6];
      parse( buf, sizeof(buf), pwm );
      calc_voltage( vcap_left, pwm );
      calc_voltage( vcap_right, &pwm[3] );      
      if( sample == 1134 ) {
        cout << (int)(vcap_left*65535) << "\n";
        cout << (int)(vcap_right*65535) << "\n";
        sample = 0;        
      } else sample++;
      cin.getline( buf, sizeof(buf) );      
    }
    return 0;
  }
  catch( const char *x ) {
    cout << "ERROR: " << x << "\n";
    return -1;
  }
}
