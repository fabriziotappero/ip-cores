/*
	sintable: sine wave table generator
	Based on MAME's fm.c file.

  (c) Jose Tejada Gomez, May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada at ieee.org

*/

#include <iostream>
#include <cmath>
#include "../cpp/args.h"

using namespace std;

#define ENV_BITS        10
#define ENV_LEN         (1<<ENV_BITS)
#define ENV_STEP        (128.0/ENV_LEN)
#define TL_RES_LEN      (256) /* 8 bits addressing (real chip) */
#define SIN_BITS        10
#define SIN_LEN         (1<<SIN_BITS)
#define SIN_MASK        (SIN_LEN-1)

signed int tl_tab[TL_RES_LEN];
unsigned int sin_tab[SIN_LEN];

void init_tables(void) // copied from fm.c
{
	signed int i,x;
	signed int n;
	double o,m;

	for (x=0; x<TL_RES_LEN; x++)
	{
		m = (1<<16) / pow(2, (x+1) * (ENV_STEP/4.0) / 8.0);
		m = floor(m);

		/* we never reach (1<<16) here due to the (x+1) */
		/* result fits within 16 bits at maximum */

		n = (int)m;     /* 16 bits here */
		n >>= 4;        /* 12 bits here */
		if (n&1)        /* round to nearest */
			n = (n>>1)+1;
		else
			n = n>>1;
						/* 11 bits here (rounded) */
		n <<= 2;        /* 13 bits here (as in real chip) */
		tl_tab[ x ] = n;
	}

	for (i=0; i<SIN_LEN; i++)
	{
		/* non-standard sinus */
		m = sin( ((i*2)+1) * M_PI / SIN_LEN ); /* checked against the real chip */

		/* we never reach zero here due to ((i*2)+1) */
		if (m>0.0)
			o = 8*log(1.0/m)/log(2.0);  /* convert to 'decibels' */
		else
			o = 8*log(-1.0/m)/log(2.0); /* convert to 'decibels' */

		o = o / (ENV_STEP/4);

		n = (int)(2.0*o);
		if (n&1)                        /* round to nearest */
			n = (n>>1)+1;
		else
			n = n>>1;

		sin_tab[ i ] = n*2 + (m>=0.0? 0: 1 );
		/*logerror("FM.C: sin [%4i]= %4i (tl_tab value=%5i)\n", i, sin_tab[i],tl_tab[sin_tab[i]]);*/
	}
}

void dump_tl_tab() {
  for( int i=0; i<TL_RES_LEN; i++ ) {
    cout <<  tl_tab[i] << "\n";
  }
}

void dump_sin_tab() {
  for( int i=0; i<SIN_LEN; i++ ) {
    cout << sin_tab[i] << "\n";
  }
}

void dump_composite() {
  for( int i=0; i<SIN_LEN; i++ ) {
    int v = sin_tab[i];
    int m = (v>>1)&0xFF;
    int lin = tl_tab[m];
    int exp = v>>9;
    int adj0 = lin>>exp;
    int adj1 = (v&1) ? -1*adj0 : adj0;
    cout << v << "," << lin << "," << exp << "," << adj0 << "," << adj1 << "\n";
  }
}

unsigned conv( double x ) {
  double xmax = 0xFFFFF; // 20 bits, all ones
  return (unsigned)(xmax* 20*log(x+0.5));
}

int main(int argc, char *argv[]) {
  arg_vector_t legal_args;
  argument_t arg_hex( legal_args, "hex", argument_t::flag, 
    "set output to hexadecimal mode" );
  argument_t arg_sin( legal_args, "sin", argument_t::flag,
    "dump sine wave" );
  argument_t arg_pow( legal_args, "pow", argument_t::flag,
    "dump power table" );
  argument_t arg_comp( legal_args, "composite", argument_t::flag,
    "dump pow[ sine ] composite function" );
  Args args_parser( argc, argv, legal_args );
  if( args_parser.help_request() ) { return 0; }
  if( argc==1 ) { args_parser.show_help(); return 0; }
  init_tables();  

	if( arg_hex.is_set() ) cout.setf( ios::hex, ios::basefield );
	if( arg_pow.is_set() ) dump_tl_tab();
	if( arg_sin.is_set() ) dump_sin_tab();
	if( arg_comp.is_set() ) dump_composite();		
	return 0;
}
