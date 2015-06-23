/*
 * Copyright (c) 1999-2001 Tony Givargis.  Permission to copy is granted
 * provided that this header remains intact.  This software is provided
 * with no warranties.
 *
 * Version : 2.9
 */

/*---------------------------------------------------------------------------*/

#include <reg51.h>
#include <math.h>

/*---------------------------------------------------------------------------*/

void main() {
    
    float x = 3.0;
    float y = 4.0;
    float xx, yy, xx_yy, sqrt_xx_yy;
    
    xx = x * x;
    P0 = (unsigned char)xx;
    
    yy = y * y;
    P1 = (unsigned char)yy;
    
    xx_yy = xx + yy;
    P2 = (unsigned char)xx_yy;
    
    sqrt_xx_yy = sqrt(xx_yy);
    P0 = (unsigned char)sqrt_xx_yy;
    
    while(1);
}
