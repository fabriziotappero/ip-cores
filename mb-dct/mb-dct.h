

#include <stdio.h>

/*
	Function Name: dct

	Operation: Find the 8x8 DCT of an array using separable DCT
	First, finds 1-d DCT along rows, storing the result in inter[][]
	Then, 1-d DCT along columns of inter[][] is found

	Input: pixels is the 8x8 input array

	Output: dct is the 8x8 output array
*/



void dct(signed char pixels[8][8], int color);

