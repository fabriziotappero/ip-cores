
#include <stdio.h>
#include <math.h>

static double decrelconst[4] = {
    (double)(1/39.28064),
    (double)(1/31.41608),
    (double)(1/26.17344),
    (double)(1/22.44608)
};

static double attackconst[4] = {
    (double)(1/2.82624),
    (double)(1/2.25280),
    (double)(1/1.88416),
    (double)(1/1.59744)
};

int main() {
    
    /*
    printf("DEPTH = 256;\n");
    printf("WIDTH = 17;\n");
    printf("ADDRESS_RADIX = DEC;\n");
    printf("DATA_RADIX = DEC;\n");
    printf("CONTENT\n");
    printf("BEGIN\n");
    
    int i=0;
    for(i=0; i<256; i++) printf("%d:    %d;\n", i, (int)(sin((double)i*2.0*M_PI/4.0/256.0) * 16384.0));
    printf("END;\n");
    */
    
    /*
    printf("DEPTH = 256;\n");
    printf("WIDTH = 17;\n");
    printf("ADDRESS_RADIX = DEC;\n");
    printf("DATA_RADIX = DEC;\n");
    printf("CONTENT\n");
    printf("BEGIN\n");
    
    int i=0;
    for(i=0; i<256; i++) {
        int toff      = (i >> 4) & 0xF;
        int decayrate = i & 0xF;
        
        double f = (double)(-7.4493*decrelconst[toff&3]/96000.0);
        
        printf("%d:    %d;\n", i+256, (int)(((double)(pow(2.0,f*pow(2.0,(double)(decayrate+(toff>>2))))))* 65536.0));
    }
    printf("END;\n");
    */
    
    /*
    printf("DEPTH = 256;\n");
    printf("WIDTH = 20;\n");
    printf("ADDRESS_RADIX = DEC;\n");
    printf("DATA_RADIX = DEC;\n");
    printf("CONTENT\n");
    printf("BEGIN\n");
    
    int i=0;
    for(i=0; i<256; i++) {
        int toff      = (i >> 4) & 0xF;
        int attackrate = i & 0xF;
        
        int val = (int)(pow(2.0,(double)attackrate+(toff>>2)-1)*attackconst[toff&3]/96000.0*65536.0*16.0);
        //if(val == 0) val = 1;
        
        printf("%d:    %d;\n", i, val);
        
    }
    printf("END;\n");
    */
    
    double cycle_in_ns = 33.333333;
    int i;
    for(i=0; i<256; i++) {
        double f = 1000000.0 / (256.0-i);
        
        double cycles_in_period = 1000000000.0 / (f * cycle_in_ns);
        printf("%d:     %d;\n", i, (int)cycles_in_period);
    }
        
    return 0;
}
