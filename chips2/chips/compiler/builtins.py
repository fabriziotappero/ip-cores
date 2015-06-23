#!/usr/bin/env python
"""Support Library for builtin Functionality"""

__author__ = "Jon Dawson"
__copyright__ = "Copyright (C) 2013, Jonathan P Dawson"
__version__ = "0.1"

builtins="""

unsigned unsigned_modulo_yyyy;
unsigned unsigned_divide_xxxx(unsigned dividend, unsigned divisor){
    unsigned remainder = 0;
    unsigned quotient = 0;
    unsigned i = 0;

    while(1){
        if( dividend & (1 << 15) ){
            remainder |= 1;
        }
        if( remainder >= divisor ){
            quotient |= 1;
            remainder -= divisor;
        }
        if(i==15) break;
        i++;
        quotient <<= 1;
        remainder <<= 1;
        dividend <<= 1;
    }

    unsigned_modulo_yyyy = remainder;
    return quotient;
}

unsigned unsigned_modulo_xxxx(unsigned dividend, unsigned divisor){
    unsigned_divide_xxxx(dividend, divisor);
    return unsigned_modulo_yyyy;
}

int divide_xxxx(int dividend, int divisor){
    unsigned udividend, udivisor, uquotient;
    unsigned dividend_sign, divisor_sign, quotient_sign;
    dividend_sign = dividend & 0x8000u;
    divisor_sign = divisor & 0x8000u;
    quotient_sign = dividend_sign ^ divisor_sign;
    udividend = dividend_sign ? -dividend : dividend;
    udivisor = divisor_sign ? -divisor : divisor;
    uquotient = unsigned_divide_xxxx(udividend, udivisor);
    return quotient_sign ? -uquotient : uquotient;
}

int modulo_xxxx(int dividend, int divisor){
    unsigned udividend, udivisor, uquotient;
    unsigned dividend_sign, divisor_sign;
    int modulo;
    dividend_sign = dividend & 0x8000u;
    divisor_sign = divisor & 0x8000u;
    udividend = dividend_sign ? -dividend : dividend;
    udivisor = divisor_sign ? -divisor : divisor;
    modulo = unsigned_modulo_xxxx(udividend, udivisor);
    modulo = dividend_sign ? -modulo : modulo;
    return modulo;
}

long unsigned long_unsigned_modulo_yyyy;
long unsigned long_unsigned_divide_xxxx(long unsigned dividend, long unsigned divisor){
    long unsigned remainder = 0;
    long unsigned quotient = 0;
    unsigned i = 0;

    while(1){
        if( dividend & (1 << 31) ){
            remainder |= 1;
        }
        if( remainder >= divisor ){
            quotient |= 1;
            remainder -= divisor;
        }
        if(i==31) break;
        i++;
        quotient <<= 1;
        remainder <<= 1;
        dividend <<= 1;
    }
    long_unsigned_modulo_yyyy = remainder;
    return quotient;
}

long int long_divide_xxxx(long int dividend, long int divisor){
    long unsigned udividend, udivisor, uquotient;
    long unsigned dividend_sign, divisor_sign, quotient_sign;
    dividend_sign = dividend & 0x80000000ul;
    divisor_sign = divisor & 0x80000000ul;
    quotient_sign = dividend_sign ^ divisor_sign;
    udividend = dividend_sign ? -dividend : dividend;
    udivisor = divisor_sign ? -divisor : divisor;
    uquotient = long_unsigned_divide_xxxx(udividend, udivisor);
    return quotient_sign ? -uquotient : uquotient;
}


long unsigned long_unsigned_modulo_xxxx(long unsigned dividend, long unsigned divisor){
    long_unsigned_divide_xxxx(dividend, divisor);
    return long_unsigned_modulo_yyyy;
}

long int long_modulo_xxxx(long int dividend, long int divisor){
    long unsigned udividend, udivisor;
    long unsigned dividend_sign, divisor_sign, quotient_sign;
    long int modulo;
    dividend_sign = dividend & 0x80000000ul;
    divisor_sign = divisor & 0x80000000ul;
    udividend = dividend_sign ? -dividend : dividend;
    udivisor = divisor_sign ? -divisor : divisor;
    modulo = long_unsigned_modulo_xxxx(udividend, udivisor);
    modulo = dividend_sign ? -modulo : modulo;
    return modulo;
}

int float_equal_xxxx(long int a, long int b){
    if (a < 0) {
        a = 0x80000000ul - a;
    }
    if (b < 0) {
        b = 0x80000000ul - b;
    }
    return  a == b;
}

int float_ne_xxxx(long int a, long int b){
    if (a < 0) {
        a = 0x80000000ul - a;
    }
    if (b < 0) {
        b = 0x80000000ul - b;
    }
    return  a != b;
}

int float_lt_xxxx(long int a, long int b){
    if (a < 0) {
        a = 0x80000000ul - a;
    }
    if (b < 0) {
        b = 0x80000000ul - b;
    }
    return  a < b;
}

int float_gt_xxxx(long int a, long int b){
    if (a < 0) {
        a = 0x80000000ul - a;
    }
    if (b < 0) {
        b = 0x80000000ul - b;
    }
    return  a > b;
}

int float_le_xxxx(long int a, long int b){
    if (a < 0) {
        a = 0x80000000ul - a;
    }
    if (b < 0) {
        b = 0x80000000ul - b;
    }
    return  a <= b;
}

int float_ge_xxxx(long int a, long int b){
    if (a < 0) {
        a = 0x80000000ul - a;
    }
    if (b < 0) {
        b = 0x80000000ul - b;
    }
    return  a >= b;
}

"""
