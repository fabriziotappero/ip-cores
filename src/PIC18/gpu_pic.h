//**************************************************************
//*G9 Impulse SDK - GPU.H
//*Provides essential GPU functionality for the PIC 16 and PIC18.
//*
//*
//**************************************************************

#ifndef _GPU_OPS_H
#define _GPU_OPS_H

//types
struct Point
{
	unsigned long  x;
	unsigned long  y;
};

struct Bitmap
{
	unsigned long 	address;
	unsigned		width;
	unsigned	  	lines;
};

struct Sprite
{
	struct Bitmap 	image;
	struct Point 	position;
	char  			alpha;
};

typedef struct Bitmap Bitmap;
typedef struct Point Point;
typedef struct Sprite Sprite;

//prototypes
void drawtobackground ( Bitmap source );
void drawsprite (Sprite sprite);
void load_alphaOp( bool alphaOp);
void load_l_size(unsigned size);
void load_s_lines(unsigned lines);
void load_t_addr(unsigned long address);
void load_s_addr(unsigned long address);

#endif
