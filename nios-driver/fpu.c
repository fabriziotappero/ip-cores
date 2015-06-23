#include <stdio.h>
#include "system.h"
#include <unistd.h>
#include "alt_types.h"
#include <stdlib.h>
#include <stdio.h>
#include "system.h"
#include <unistd.h>
#include "alt_types.h"
#include "io.h"
#include "fpu.h"
#include "sys/alt_timestamp.h"
#include "altera_avalon_performance_counter.h"
#include <time.h>
#include <sys/alt_irq.h>

/*******************************************************
 * To use this library/driver, add the fpu.[ch] files to your application
 * and add these linker flags. 
 * Click right on your application, choose properties, C/C++ Build
 * -> Linker -> General and type 
 * "-Wl,--wrap,__adddf3,--wrap,__subdf3,--wrap,__muldf3"
 * For each implemented function, add another --wrap,__functioname
 * *****************************************************/

#define MODE_ADD 0
#define MODE_SUB 4
#define MODE_MUL 8
#define MODE_DIV 12
/* See fpu_package.vhd for definition*/

double __wrap___adddf3(double a, double b)
{
    volatile alt_u32 * fpu_regs = (alt_u32 *) (OPENFPU64_0_BASE+0x80000000);
    volatile int dpcontext = alt_irq_disable_all();
    volatile double c;

    register alt_u32 * temp_a = (alt_u32 *) &a;
    register alt_u32 * temp_b = (alt_u32 *) &b;
    alt_u32 result2[2];

    /*
       printf("a0 %08lx!\n", temp_a[0]);
       printf("a1 %08lx!\n", temp_a[1]);
       printf("b0 %08lx!\n", temp_a[0]);
       printf("b1 %08lx!\n", temp_b[1]);
    /**/
    //PERF_BEGIN(PERFORMANCE_COUNTER_BASE,3);

    fpu_regs[0+MODE_ADD] = temp_a[1];
    fpu_regs[1] = temp_a[0];
    fpu_regs[2] = temp_b[1];
    fpu_regs[3] = temp_b[0];

    result2[1]=fpu_regs[0];
    result2[0]=fpu_regs[1];
    /*
       printf("result 0 %08lx!\n", result2[0]);
       printf("result 1 %08lx!\n", result2[1]);
    /**/
    c=*((double *) (result2));
    //PERF_END(PERFORMANCE_COUNTER_BASE,3);
    alt_irq_enable_all(dpcontext);
    return c;
} 


double __wrap___subdf3(double a, double b)
{
    volatile alt_u32 * fpu_regs = (alt_u32 *) (OPENFPU64_0_BASE+0x80000000);
    volatile int dpcontext = alt_irq_disable_all();
    volatile double c;

    register alt_u32 * temp_a = (alt_u32 *) &a;
    register alt_u32 * temp_b = (alt_u32 *) &b;
    alt_u32 result2[2];

    fpu_regs[0+MODE_SUB] = temp_a[1];
    fpu_regs[1] = temp_a[0];
    fpu_regs[2] = temp_b[1];
    fpu_regs[3] = temp_b[0];

    result2[1]=fpu_regs[0];
    result2[0]=fpu_regs[1];

    c=*((double *) (result2));

    alt_irq_enable_all(dpcontext);
    return c;
} 


double __wrap___muldf3 (double a , double b)
{
    //printf("mul called\n");
    volatile alt_u32 * fpu_regs = (alt_u32 *) (OPENFPU64_0_BASE+0x80000000);
    int dpcontext = alt_irq_disable_all();
    double c;

    register alt_u32 * temp_a = (alt_u32 *) &a;
    register alt_u32 * temp_b = (alt_u32 *) &b;
    alt_u32 result2[2];


    printf("a0 %08lx!\n", temp_a[0]);
    printf("a1 %08lx!\n", temp_a[1]);
    printf("b0 %08lx!\n", temp_a[0]);
    printf("b1 %08lx!\n", temp_b[1]);
    /**/
    //PERF_BEGIN(PERFORMANCE_COUNTER_BASE,3);

    fpu_regs[0+MODE_MUL] = temp_a[1];
    fpu_regs[1] = temp_a[0];
    fpu_regs[2] = temp_b[1];
    fpu_regs[3] = temp_b[0];

    result2[1]=fpu_regs[0];
    result2[0]=fpu_regs[1];

    printf("result 0 %08lx!\n", result2[0]);
    printf("result 1 %08lx!\n", result2[1]);
    /**/
    c=*((double *) (result2));
    //PERF_END(PERFORMANCE_COUNTER_BASE,3);

    alt_irq_enable_all(dpcontext);
    return c;
} 




double __wrap___divdf3 (double a , double b){
    printf("div called\n");
    return a;
};