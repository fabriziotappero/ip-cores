/* sqrt.c */
/* Jonathan P Dawson */
/* 2013-12-23 */

/* find absolute value of a floating point number*/

float fabs(float n){
    if (n < 0.0) {
        return - n;
    } else {
        return n;
    }
}

/* approximate sqrt using newton's method*/

float sqrt(float n){
    float square, x, old;
    x = 10.0;
    old = 0.0;
    while(fabs(old - x) > 0.000001){
        old = x;
        x -= (x*x-n)/(2*x);
    }
    return x;
}

/* test sqrt function*/

void main(){
    float x;
    for(x=0.0; x <= 10.0; x+= 0.1){
        file_write(x, "x");
        file_write(sqrt(x), "sqrt_x");
    }
}
