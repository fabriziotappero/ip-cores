
#include "debug.h"

static const unsigned char debug_chars[] = "0123456789abcdef";

unsigned char *debug_convert(unsigned long int src,unsigned char *debug_text,unsigned long int num,unsigned long int adic){
	unsigned char *p;
	unsigned long int s;
	unsigned long int div;
	unsigned long int mod;

	// init(tail is nal)
	p	= debug_text + num;
	*p	= '\0';

	// convert
	s	= src;
	while ( debug_text!=p ) {
		p--;
		div	= s / adic;		// heavy
		//mod	= s % adic;		// heavy
		mod	= s - (div * adic);	// light
		*p	= debug_chars[ mod ];
		s	= div;
		if (0==s) break;		// finish
	}

	// space pack
	while ( debug_text!=p ) {
		p--;
		*p = ' ';
	}

	// return
	return debug_text;
}

