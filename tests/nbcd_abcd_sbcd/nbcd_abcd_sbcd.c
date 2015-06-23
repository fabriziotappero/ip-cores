/* 
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>

/*
struct from_68knotes_t {
	unsigned char operand;
	unsigned int x;
	unsigned char unadjusted;
	unsigned char adjusted;
	unsigned int v;
};
struct from_68knotes_t from_68knotes[] = {
	{ 0x00, 0, 0x00, 0x00, 0 },
	{ 0x00, 1, 0xFF, 0x99, 0 },
	{ 0xFF, 0, 0x01, 0x9B, 0 },
	{ 0xFF, 1, 0x00, 0x9A, 0 },
	{ 0x01, 0, 0xFF, 0x99, 0 },
	{ 0x01, 1, 0xFE, 0x98, 0 },
	{ 0x0F, 0, 0xF1, 0x8B, 0 },
	{ 0x0F, 1, 0xF0, 0x8A, 0 },
	{ 0xF0, 0, 0x10, 0xB0, 0 },
	{ 0xF0, 1, 0x0F, 0xA9, 0 },
	{ 0x9A, 0, 0x66, 0x00, 0 },
	{ 0x9A, 1, 0x65, 0xFF, 0 },
	{ 0x99, 0, 0x67, 0x01, 0 },
	{ 0x99, 1, 0x66, 0x00, 0 },
	{ 0x10, 0, 0xF0, 0x90, 0 },
	{ 0x10, 1, 0xEF, 0x89, 0 },
	{ 0x7F, 0, 0x81, 0x1B, 1 },
	{ 0x7F, 1, 0x80, 0x1A, 1 },
	{ 0x80, 0, 0x80, 0x20, 1 },
	{ 0x80, 1, 0x7F, 0x19, 0 },
	{ 0x81, 0, 0x7F, 0x19, 0 },
	{ 0x81, 1, 0x7E, 0x18, 0 }
};
*/

struct input_t {
	unsigned char src;
	unsigned char dst;
	
	unsigned int x;
	unsigned int z;
	unsigned int v;
};

struct output_t {
	unsigned char result;
	
	unsigned int c;
	unsigned int v;
	unsigned int z;
	unsigned int n;
	unsigned int x;
};

struct output_t uae_nbcd(struct input_t in) {	
	signed char src = in.dst;
	
	unsigned short newv_lo = - (src & 0xF) - in.x;
	unsigned short newv_hi = - (src & 0xF0);
	unsigned short newv;
	int cflg;
	if (newv_lo > 9) { newv_lo -= 6; }
	newv = newv_hi + newv_lo;	cflg = (newv & 0x1F0) > 0x90;
	if (cflg) newv -= 0x60;
	
	struct output_t out;
	out.c = cflg ? 1 : 0;
	out.x = out.c;
	out.z = in.z & ((((signed char)(newv)) == 0) ? 1 : 0);
	out.n = (((signed char)(newv)) < 0) ? 1 : 0;
	out.v = in.v;
	
	out.result = (newv) & 0xff;
	return out;
}
struct output_t verilog_nbcd(struct input_t in) {
	struct output_t out;
	
	unsigned char l = 25 - ((in.dst) & 0x0F);
	unsigned char h = 25 - (((in.dst) & 0xF0) >> 4);
	
	if( ((in.dst) & 0x0F) > 9 ) h -= 1;
	
	l &= 0x0F;
	h &= 0x0F;
	
	if(in.x == 0) {
		if(l == 9) {
			l = 0;
			h = (h==9) ? 0 : h+1;
		}
		else if(l == 0xF) {
			l = 0;
			h += 1;
		}
		else {
			l += 1;
		}
	}
	
	l &= 0x0F;
	h &= 0x0F;
	
	out.result = (h << 4) + l;
	
	out.v = in.v;
	out.z = in.z & ((out.result == 0) ? 1 : 0);
	out.c = out.x = (in.dst == 0 && in.x == 0) ? 0 : 1;
	out.n = (((out.result) & 0x80) == 0) ? 0 : 1;
	
	return out;
}

struct output_t uae_abcd(struct input_t in) {
	signed char src = in.src;
	signed char dst = in.dst;
	
	unsigned short newv_lo = (src & 0xF) + (dst & 0xF) + (in.x ? 1 : 0);
	unsigned short newv_hi = (src & 0xF0) + (dst & 0xF0);
	unsigned short newv, tmp_newv;
	int cflg;
	newv = tmp_newv = newv_hi + newv_lo;	if (newv_lo > 9) { newv += 6; }
	cflg = (newv & 0x3F0) > 0x90;
	if (cflg) newv += 0x60;
	
	struct output_t out;
	out.c = cflg;
	out.x = out.c;
	out.z = in.z & (((signed char)(newv)) == 0);
	out.n = ((signed char)(newv)) < 0;
	out.v = (tmp_newv & 0x80) == 0 && (newv & 0x80) != 0;
	out.result = (newv) & 0xff;
	
	return out;
}
struct output_t verilog_abcd(struct input_t in) {

	unsigned char l = (in.src & 0x0F) + (in.dst & 0x0F) + in.x;
	unsigned char h = ((in.src & 0xF0) >> 4) + ((in.dst & 0xF0) >> 4);
	
	int tmp = (in.src + in.dst + in.x) & 0x80;
	
	l = (l > 0x09) ? (l+6) : l;
	h = (l > 0x1F) ? (h+2) :
		(l > 0x0F) ? (h+1) : h;
	h = (h > 0x09) ? (h+6) : h;
	
	struct output_t out;
	out.c = (h > 0x09) ? 1 : 0;
	out.x = out.c;
	
	l &= 0x0F;
	h &= 0x0F;
	
	out.result = (h << 4) + l;
	
	out.z = in.z & (out.result == 0);
	out.n = ((out.result & 0x80) == 0x80) ? 1 : 0;
	out.v = (tmp == 0) && ((out.result & 0x80) != 0);
	
	return out;
}

struct output_t uae_sbcd(struct input_t in) {
	signed char src = in.src;
	signed char dst = in.dst;
	
	unsigned short newv_lo = (dst & 0xF) - (src & 0xF) - (in.x ? 1 : 0);
	unsigned short newv_hi = (dst & 0xF0) - (src & 0xF0);
	unsigned short newv, tmp_newv;
	int bcd = 0;
	newv = tmp_newv = newv_hi + newv_lo;
	if (newv_lo & 0xF0) { newv -= 6; bcd = 6; };
	if ((((dst & 0xFF) - (src & 0xFF) - (in.x ? 1 : 0)) & 0x100) > 0xFF) { newv -= 0x60; }
	
	struct output_t out;
	out.c = (((dst & 0xFF) - (src & 0xFF) - bcd - (in.x ? 1 : 0)) & 0x300) > 0xFF;
	out.x = out.c;
	out.z = in.z & (((signed char)(newv)) == 0);
	out.n = ((signed char)(newv)) < 0;
	out.v = (tmp_newv & 0x80) != 0 && (newv & 0x80) == 0;
	out.result = (newv) & 0xff;
	
	return out;
}

struct output_t verilog_sbcd(struct input_t in) {
	
	unsigned char l = 32 + (in.dst & 0x0F) - (in.src & 0x0F) - in.x;
	unsigned char h = 32 + ((in.dst & 0xF0) >> 4) - ((in.src & 0xF0) >> 4);
	
	int tmp = in.dst - in.src - in.x;
	
	l = (l < 32) ? (l-6) : l;
	h = (l < 16) ? (h-2) :
		(l < 32) ? (h-1) : h;
	h = (h < 32 && (tmp & 0x100) > 0xFF) ? (h-6) : h;
	
	struct output_t out;
	out.c = (h < 32) ? 1 : 0;
	out.x = out.c;
	
	l &= 0x0F;
	h &= 0x0F;
	
	out.result = (h << 4) + l;
	
	out.z = in.z & (out.result == 0);
	out.n = ((out.result & 0x80) == 0x80) ? 1 : 0;
	out.v = ((tmp & 0x80) != 0) && ((out.result & 0x80) == 0);
	
	return out;
}

int test_failed = 0;
void compare(struct input_t in, struct output_t uae, struct output_t verilog) {
	if( uae.result == verilog.result &&
		uae.c == verilog.c &&
		uae.v == verilog.v &&
		uae.z == verilog.z &&
		uae.n == verilog.n &&
		uae.x == verilog.x
	) return;

	//printf("%hhx + %hhx + %x: | ", in.dst, in.src, in.x);
	//printf("%hhx - %hhx - %x: | ", in.dst, in.src, in.x);

	printf("[Mismatch: in.dst: %hhx, in.src: %hhx, in.x: %x] ", in.dst, in.src, in.x);

	if( uae.result != verilog.result ) 		printf("result: %hhx != %hhx | ", uae.result, verilog.result);
	if( uae.c != verilog.c ) 			printf("c: %x != %x | ", uae.c, verilog.c);
	if( uae.v != verilog.v ) 			printf("v: %x != %x | ", uae.v, verilog.v);
	if( uae.z != verilog.z ) 			printf("z: %x != %x | ", uae.z, verilog.z);
	if( uae.n != verilog.n ) 			printf("n: %x != %x | ", uae.n, verilog.n);
	if( uae.x != verilog.x ) 			printf("x: %x != %x | ", uae.x, verilog.x);
	printf("\n");
	
	test_failed = 1;
}

int main(int argc, char **argv) {
	struct input_t in;
	
	int i,j,k,l,m;
	for(i=0; i<256; i++) {
		for(j=0; j<256; j++) {
			for(k=0; k<2; k++) {
				for(l=0; l<2; l++) {
					for(m=0; m<2; m++) {
						in.src = i;
						in.dst = j;
						in.x = k;
						in.z = l;
						in.v = m;
						
						struct output_t uae0 = uae_nbcd(in);
						struct output_t verilog0 = verilog_nbcd(in);
						
						compare(in, uae0, verilog0);
						
						struct output_t uae1 = uae_abcd(in);
						struct output_t verilog1 = verilog_abcd(in);
						
						compare(in, uae1, verilog1);
						
						struct output_t uae2 = uae_sbcd(in);
						struct output_t verilog2 = verilog_sbcd(in);
						
						compare(in, uae2, verilog2);
					}
				}
			}
		}
	}
	if(test_failed) printf("Test FAILED.\n");
	else            printf("Test OK.\n");
	
	return 0;
}

