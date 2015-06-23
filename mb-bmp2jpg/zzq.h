#ifndef _ZZQ_H
#define _ZZQ_H 1

#define MATRIX_SIZE 8
#define NUMBER_OF_PIXELS MATRIX_SIZE*MATRIX_SIZE




/*
 * ZigZag order the pixelmatrix and quantify its values, if endode == 0 the
 * inverse operation will be caried out.
 */
void zzq_encode(signed short pixelmatrix[MATRIX_SIZE][MATRIX_SIZE], int color);
#else
#error "ERROR file zzq.h multiple times included"
#endif /* --- _ZZQ_H --- */

