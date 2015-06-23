/* This is a very incomplete version of libc math.h 
 * Not all the funtions and Macros are implemented.
 * It has not been tested.
 * Special cases have not been catered for*/


/* globals */
const float M_PI=3.14159265359;

/*Taylor series approximation of Cosine function*/

float taylor(float angle){

    float old, approximation, sign, power, fact;
    unsigned count, i;

    approximation = 1.0;
    old = 0.0;
    sign = -1.0;
    count = 1;
    power = 1.0;
    fact = 1.0;

    for(i=2; approximation!=old; i+=2){
        old = approximation;

        while(count<=i){
            power*=angle;
            fact*=count;
            count++;
        }

        approximation += sign*(power/fact);
        sign = -sign;

    }
    return approximation;
}

/*return cos of angle in radians*/

float cos(float angle){
    return taylor(angle);
}

/*return sin of angle in radians*/

float sin(float angle){
    return cos(angle-(M_PI/2));
}

/*return tan of angle in radians*/

float tan(float n){
    return sin(n) / cos(n);
}

/* Return absolute value of a float n*/

float fabs(float n){
    if (n < 0.0) {
        return - n;
    } else {
        return n;
    }
}

/* Return absolute value of integer n*/

int abs(int n){
    if (n < 0) {
        return - n;
    } else {
        return n;
    }
}

/* return e ** x */

float exp(float x){

    float result = 1.0;
    unsigned n = 1;
    float power = 1.0;
    float factorial = 1.0;
    float old = 0.0;

    while(fabs(old - result) > 0.000001){
        old = result;
        power *= x;
        factorial *= n;
        result += (power/factorial);
        n++;
    }

    return result;

}

/* return log_e(n) */

float log(float n){
    float antilog, x, old;
    x = 10.0;
    old = 0.0;
    while(fabs(old - x) > 0.000001){
        old = x;
        antilog = exp(x);
        x -= (antilog - n)/antilog;
    }
    return x;
}

/* return log_10(n) */

float log10(float n){
    return log(n)/log(10);
}

/* return log_2(n) */

float log2(float n){
    return log(n)/log(2);
}
