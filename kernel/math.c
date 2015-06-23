/*--------------------------------------------------------------------
 * TITLE: Plasma Floating Point Library
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 3/2/06
 * FILENAME: math.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Plasma Floating Point Library
 *--------------------------------------------------------------------
 * IEEE_fp = sign(1) | exponent(8) | fraction(23)
 * cos(x)=1-x^2/2!+x^4/4!-x^6/6!+...
 * exp(x)=1+x+x^2/2!+x^3/3!+...
 * e^x=2^y; ln2(e^x)=ln2(2^y); ln(e^x)/ln(2)=y; x/ln(2)=y; e^x=2^(x/ln(2))
 * ln(1+x)=x-x^2/2+x^3/3-x^4/4+...
 * atan(x)=x-x^3/3+x^5/5-x^7/7+...
 * pow(x,y)=exp(y*ln(x))
 * x=tan(a+b)=(tan(a)+tan(b))/(1-tan(a)*tan(b))
 * atan(x)=b+atan((x-atan(b))/(1+x*atan(b)))
 * ln(a*x)=ln(a)+ln(x); ln(x^n)=n*ln(x)
 * sqrt(x)=sqrt(f*2^e)=sqrt(f)*2^(e/2)
 *--------------------------------------------------------------------*/
#include "rtos.h"

//#define USE_SW_MULT
#if !defined(WIN32) && !defined(USE_SW_MULT)
#define USE_MULT64
#endif

#define PI ((float)3.1415926)
#define PI_2 ((float)(PI/2.0))
#define PI2 ((float)(PI*2.0))

#define FtoL(X) (*(unsigned long*)&(X))
#define LtoF(X) (*(float*)&(X))


float FP_Neg(float a_fp)
{
   unsigned long a;
   a = FtoL(a_fp);
   a ^= 0x80000000;
   return LtoF(a);
}


float FP_Add(float a_fp, float b_fp)
{
   unsigned long a, b, c;
   unsigned long as, bs, cs;     //sign
   long ae, af, be, bf, ce, cf;  //exponent and fraction
   a = FtoL(a_fp);
   b = FtoL(b_fp);
   as = a >> 31;                        //sign
   ae = (a >> 23) & 0xff;               //exponent
   af = 0x00800000 | (a & 0x007fffff);  //fraction
   bs = b >> 31;
   be = (b >> 23) & 0xff;
   bf = 0x00800000 | (b & 0x007fffff);
   if(ae > be) 
   {
      if(ae - be < 30) 
         bf >>= ae - be;
      else 
         bf = 0;
      ce = ae;
   } 
   else 
   {
      if(be - ae < 30) 
         af >>= be - ae;
      else 
         af = 0;
      ce = be;
   }
   cf = (as ? -af : af) + (bs ? -bf : bf);
   cs = cf < 0;
   cf = cf>=0 ? cf : -cf;
   if(cf == 0) 
      return LtoF(cf);
   while(cf & 0xff000000) 
   {
      ++ce;
      cf >>= 1;
   }
   while((cf & 0xff800000) == 0) 
   {
      --ce;
      cf <<= 1;
   }
   c = (cs << 31) | (ce << 23) | (cf & 0x007fffff);
   if(ce < 1) 
      c = 0;
   return LtoF(c);
}


float FP_Sub(float a_fp, float b_fp)
{
   return FP_Add(a_fp, FP_Neg(b_fp));
}


float FP_Mult(float a_fp, float b_fp)
{
   unsigned long a, b, c;
   unsigned long as, af, bs, bf, cs, cf;
   long ae, be, ce;
#ifndef USE_MULT64
   unsigned long a2, a1, b2, b1, med1, med2;
#endif
   unsigned long hi, lo;
   a = FtoL(a_fp);
   b = FtoL(b_fp);
   as = a >> 31;
   ae = (a >> 23) & 0xff;
   af = 0x00800000 | (a & 0x007fffff);
   bs = b >> 31;
   be = (b >> 23) & 0xff;
   bf = 0x00800000 | (b & 0x007fffff);
   cs = as ^ bs;
#ifndef USE_MULT64
   a1 = af & 0xffff;
   a2 = af >> 16;
   b1 = bf & 0xffff;
   b2 = bf >> 16;
   lo = a1 * b1;
   med1 = a2 * b1 + (lo >> 16);
   med2 = a1 * b2;
   hi = a2 * b2 + (med1 >> 16) + (med2 >> 16);
   med1 = (med1 & 0xffff) + (med2 & 0xffff);
   hi += (med1 >> 16);
   lo = (med1 << 16) | (lo & 0xffff);
#else
   lo = OS_AsmMult(af, bf, &hi);
#endif
   cf = (hi << 9) | (lo >> 23);
   ce = ae + be - 0x80 + 1;
   if(cf == 0) 
      return LtoF(cf);
   while(cf & 0xff000000) 
   {
      ++ce;
      cf >>= 1;
   }
   c = (cs << 31) | (ce << 23) | (cf & 0x007fffff);
   if(ce < 1) 
      c = 0;
   return LtoF(c);
}


float FP_Div(float a_fp, float b_fp)
{
   unsigned long a, b, c;
   unsigned long as, af, bs, bf, cs, cf;
   unsigned long a1, b1;
#ifndef USE_MULT64
   unsigned long a2, b2, med1, med2;
#endif
   unsigned long hi, lo;
   long ae, be, ce, d;
   a = FtoL(a_fp);
   b = FtoL(b_fp);
   as = a >> 31;
   ae = (a >> 23) & 0xff;
   af = 0x00800000 | (a & 0x007fffff);
   bs = b >> 31;
   be = (b >> 23) & 0xff;
   bf = 0x00800000 | (b & 0x007fffff);
   cs = as ^ bs;
   ce = ae - (be - 0x80) + 6 - 8;
   a1 = af << 4; //8
   b1 = bf >> 8;
   cf = a1 / b1;
   cf <<= 12; //8
#if 1                  /*non-quick*/
#ifndef USE_MULT64
   a1 = cf & 0xffff;
   a2 = cf >> 16;
   b1 = bf & 0xffff;
   b2 = bf >> 16;
   lo = a1 * b1;
   med1 =a2 * b1 + (lo >> 16);
   med2 = a1 * b2;
   hi = a2 * b2 + (med1 >> 16) + (med2 >> 16);
   med1 = (med1 & 0xffff) + (med2 & 0xffff);
   hi += (med1 >> 16);
   lo = (med1 << 16) | (lo & 0xffff);
#else
   lo = OS_AsmMult(cf, bf, &hi);
#endif
   lo = (hi << 8) | (lo >> 24);
   d = af - lo;    //remainder
   assert(-0xffff < d && d < 0xffff);
   d <<= 16;
   b1 = bf >> 8;
   d = d / (long)b1;
   cf += d;
#endif
   if(cf == 0) 
      return LtoF(cf);
   while(cf & 0xff000000) 
   {
      ++ce;
      cf >>= 1;
   }
   if(ce < 0) 
      ce = 0;
   c = (cs << 31) | (ce << 23) | (cf & 0x007fffff);
   if(ce < 1) 
      c = 0;
   return LtoF(c);
}


long FP_ToLong(float a_fp)
{
   unsigned long a;
   unsigned long as;
   long ae;
   long af, shift;
   a = FtoL(a_fp);
   as = a >> 31;
   ae = (a >> 23) & 0xff;
   af = 0x00800000 | (a & 0x007fffff);
   af <<= 7;
   shift = -(ae - 0x80 - 29);
   if(shift > 0) 
   {
      if(shift < 31) 
         af >>= shift;
      else 
         af = 0;
   }
   af = as ? -af: af;
   return af;
}


float FP_ToFloat(long af)
{
   unsigned long a;
   unsigned long as, ae;
   as = af>=0 ? 0: 1;
   af = af>=0 ? af: -af;
   ae = 0x80 + 22;
   if(af == 0) 
      return LtoF(af);
   while(af & 0xff000000) 
   {
      ++ae;
      af >>= 1;
   }
   while((af & 0xff800000) == 0) 
   {
      --ae;
      af <<= 1;
   }
   a = (as << 31) | (ae << 23) | (af & 0x007fffff);
   return LtoF(a);
}


//0 iff a==b; 1 iff a>b; -1 iff a<b
int FP_Cmp(float a_fp, float b_fp)
{
   unsigned long a, b;
   unsigned long as, ae, af, bs, be, bf;
   int gt;
   a = FtoL(a_fp);
   b = FtoL(b_fp);
   if(a == b)
      return 0;
   as = a >> 31;
   bs = b >> 31;
   if(as > bs)
      return -1;
   if(as < bs)
      return 1;
   gt = as ? -1 : 1;
   ae = (a >> 23) & 0xff;
   be = (b >> 23) & 0xff;
   if(ae > be)
      return gt;
   if(ae < be)
      return -gt;
   af = 0x00800000 | (a & 0x007fffff);
   bf = 0x00800000 | (b & 0x007fffff);
   if(af > bf)
      return gt;
   return -gt;
}


int __ltsf2(float a, float b)
{
   return FP_Cmp(a, b);
}

int __lesf2(float a, float b)
{
   return FP_Cmp(a, b);
}

int __gtsf2(float a, float b)
{
   return FP_Cmp(a, b);
}

int __gesf2(float a, float b)
{
   return FP_Cmp(a, b);
}

int __eqsf2(float a, float b)
{
   return FtoL(a) != FtoL(b);
}

int __nesf2(float a, float b)
{
   return FtoL(a) != FtoL(b);
}


float FP_Sqrt(float a)
{
   float x1, y1, x2, y2, x3;
   long i;
   x1 = FP_ToFloat(1);
   y1 = FP_Sub(FP_Mult(x1, x1), a);  //y1=x1*x1-a;
   x2 = FP_ToFloat(100);
   y2 = FP_Sub(FP_Mult(x2, x2), a);
   for(i = 0; i < 10; ++i) 
   {
      if(FtoL(y1) == FtoL(y2)) 
         return x2;     
      //x3=x2-(x1-x2)*y2/(y1-y2);
      x3 = FP_Sub(x2, FP_Div(FP_Mult(FP_Sub(x1, x2), y2), FP_Sub(y1, y2)));
      x1 = x2;
      y1 = y2;
      x2 = x3;
      y2 = FP_Sub(FP_Mult(x2, x2), a);
   }
   return x2;
}


float FP_Cos(float rad)
{
   int n;
   float answer, x2, top, bottom, sign;
   while(FP_Cmp(rad, PI2) > 0) 
      rad = FP_Sub(rad, PI2);
   while(FP_Cmp(rad, (float)0.0) < 0) 
      rad = FP_Add(rad, PI2);
   answer = (float)1.0;
   sign = (float)1.0;
   if(FP_Cmp(rad, PI) >= 0) 
   {
      rad = FP_Sub(rad, PI);
      sign = FP_ToFloat(-1);
   }
   if(FP_Cmp(rad, PI_2) >= 0)
   {
      rad = FP_Sub(PI, rad);
      sign = FP_Neg(sign);
   }
   x2 = FP_Mult(rad, rad);
   top = (float)1.0;
   bottom = (float)1.0;
   for(n = 2; n < 12; n += 2) 
   {
      top = FP_Mult(top, FP_Neg(x2));
      bottom = FP_Mult(bottom, FP_ToFloat((n - 1) * n));
      answer = FP_Add(answer, FP_Div(top, bottom));
   }
   return FP_Mult(answer, sign);
}


float FP_Sin(float rad)
{
   const float pi_2=(float)(PI/2.0);
   return FP_Cos(FP_Sub(rad, pi_2));
}


float FP_Atan(float x)
{
   const float b=(float)(PI/8.0);
   const float atan_b=(float)0.37419668; //atan(b);
   int n;
   float answer, x2, top;
   if(FP_Cmp(x, (float)0.0) >= 0) 
   {
      if(FP_Cmp(x, (float)1.0) > 0) 
         return FP_Sub(PI_2, FP_Atan(FP_Div((float)1.0, x)));
   } 
   else 
   {
      if(FP_Cmp(x, (float)-1.0) > 0) 
         return FP_Sub(-PI_2, FP_Atan(FP_Div((float)1.0, x)));
   }
   if(FP_Cmp(x, (float)0.45) > 0) 
   {
      //answer = (x - atan_b) / (1 + x * atan_b);
      answer = FP_Div(FP_Sub(x, atan_b), FP_Add(1.0, FP_Mult(x, atan_b)));
      //answer = b + FP_Atan(answer) - (float)0.034633; /*FIXME fudge?*/
      answer = FP_Sub(FP_Add(b, FP_Atan(answer)), (float)0.034633);
      return answer;
   }
   if(FP_Cmp(x, (float)-0.45) < 0)
   {
      x = FP_Neg(x);
      //answer = (x - atan_b) / (1 + x * atan_b);
      answer = FP_Div(FP_Sub(x, atan_b), FP_Add(1.0, FP_Mult(x, atan_b)));
      //answer = b + FP_Atan(answer) - (float)0.034633; /*FIXME*/
      answer = FP_Sub(FP_Add(b, FP_Atan(answer)), (float)0.034633);
      return FP_Neg(answer);
   }
   answer = x;
   x2 = FP_Mult(FP_Neg(x), x);
   top = x;
   for(n = 3; n < 14; n += 2) 
   {
      top = FP_Mult(top, x2);
      answer = FP_Add(answer, FP_Div(top, FP_ToFloat(n)));
   }
   return answer;
}


float FP_Atan2(float y, float x)
{
   float answer,r;
   r = y / x;
   answer = FP_Atan(r);
   if(FP_Cmp(x, (float)0.0) < 0) 
   {
      if(FP_Cmp(y, (float)0.0) > 0) 
         answer = FP_Add(answer, PI);
      else 
         answer = FP_Sub(answer, PI);
   }
   return answer;
}


float FP_Exp(float x)
{
   const float e2=(float)7.389056099;
   const float inv_e2=(float)0.135335283;
   float answer, top, bottom, mult;
   int n;

   mult = (float)1.0;
   while(FP_Cmp(x, (float)2.0) > 0) 
   {
      mult = FP_Mult(mult, e2);
      x = FP_Add(x, (float)-2.0);
   }
   while(FP_Cmp(x, (float)-2.0) < 0)
   {
      mult = FP_Mult(mult, inv_e2);
      x = FP_Add(x, (float)2.0);
   }
   answer = FP_Add((float)1.0, x);
   top = x;
   bottom = (float)1.0;
   for(n = 2; n < 15; ++n) 
   {
      top = FP_Mult(top, x);
      bottom = FP_Mult(bottom, FP_ToFloat(n));
      answer = FP_Add(answer, FP_Div(top, bottom));
   }
   return FP_Mult(answer, mult);
}


float FP_Log(float x)
{
   const float log_2=(float)0.69314718; /*log(2.0)*/
   int n;
   float answer, top, add;
   add = (float)0.0;
   while(FP_Cmp(x, (float)16.0) > 0)
   {
      x = FP_Mult(x, (float)0.0625);
      add = FP_Add(add, (float)(log_2 * 4));
   }
   while(FP_Cmp(x, (float)1.5) > 0)
   {
      x = FP_Mult(x, (float)0.5);
      add = FP_Add(add, log_2);
   }
   while(FP_Cmp(x, 0.5) < 0)
   {
      x = FP_Mult(x, (float)2.0);
      add = FP_Sub(add, log_2);
   }
   x = FP_Sub(x, (float)1.0);
   answer = (float)0.0;
   top = (float)-1.0;
   for(n = 1; n < 14; ++n) 
   {
      top = FP_Mult(top, FP_Neg(x));
      answer = FP_Add(answer, FP_Div(top, FP_ToFloat(n)));
   }
   return FP_Add(answer, add);
}


float FP_Pow(float x, float y)
{
   return FP_Exp(y * FP_Log(x));
}


/********************************************/
//These five functions will only be used if the flag "-mno-mul" is enabled
#ifdef USE_SW_MULT
unsigned long __mulsi3(unsigned long a, unsigned long b)
{
   unsigned long answer = 0;
   while(b)
   {
      if(b & 1)
         answer += a;
      a <<= 1;
      b >>= 1;
   }
   return answer;
}


static unsigned long DivideMod(unsigned long a, unsigned long b, int doMod)
{
   unsigned long upper=a, lower=0;
   int i;
   a = b << 31;
   for(i = 0; i < 32; ++i)
   {
      lower = lower << 1;
      if(upper >= a && a && b < 2)
      {
         upper = upper - a;
         lower |= 1;
      }
      a = ((b&2) << 30) | (a >> 1);
      b = b >> 1;
   }
   if(!doMod)
      return lower;
   return upper;
}


unsigned long __udivsi3(unsigned long a, unsigned long b)
{
   return DivideMod(a, b, 0);
}


long __divsi3(long a, long b)
{
   long answer, negate=0;
   if(a < 0)
   {
      a = -a;
      negate = !negate;
   }
   if(b < 0)
   {
      b = -b;
      negate = !negate;
   }
   answer = DivideMod(a, b, 0);
   if(negate)
      answer = -answer;
   return answer;
}


unsigned long __umodsi3(unsigned long a, unsigned long b)
{
   return DivideMod(a, b, 1);
}
#endif


/*************** Test *****************/
#ifdef WIN32
#undef _LIBC
#include <math.h>
struct {
   char *name;
   float low, high;
   double (*func1)(double);
   float (*func2)(float);
} test_info[]={
   {"cos", -2*PI, 2*PI, cos, FP_Cos},
   {"sin", -2*PI, 2*PI, sin, FP_Sin},
   {"atan", -3.0, 2.0, atan, FP_Atan},
   {"log", (float)0.01, (float)4.0, log, FP_Log},
   {"exp", (float)-5.01, (float)30.0, exp, FP_Exp},
   {"sqrt", (float)0.01, (float)1000.0, sqrt, FP_Sqrt}
};


void TestMathFull(void)
{
   float a, b, c, d;
   float error1, error2, error3, error4, error5;
   int test;

   a = PI * PI;
   b = PI;
   c = FP_Div(a, b);
   printf("%10f %10f %10f %10f %10f\n",
      (double)a, (double)b, (double)(a/b), (double)c, (double)(a/b-c));
   a = a * 200;
   for(b = -(float)2.718281828*100; b < 300; b += (float)23.678) 
   {
      c = FP_Div(a, b);
      d = a / b - c;
      printf("%10f %10f %10f %10f %10f\n",
         (double)a, (double)b, (double)(a/b), (double)c, (double)(a/b-c));
   }
   //getch();

   for(test = 0; test < 6; ++test) 
   {
      printf("\nTesting %s\n", test_info[test].name);
      for(a = test_info[test].low; 
          a <= test_info[test].high;
          a += (test_info[test].high-test_info[test].low)/(float)20.0) 
      {
         b = (float)test_info[test].func1(a);
         c = test_info[test].func2(a);
         d = b - c;
         printf("%s %10f %10f %10f %10f\n", test_info[test].name, a, b, c, d);
      }
      //getch();
   }

   a = FP_ToFloat((long)6.0);
   b = FP_ToFloat((long)2.0);
   printf("%f %f\n", (double)a, (double)b);
   c = FP_Add(a, b);
   printf("add %f %f\n", (double)(a + b), (double)c);
   c = FP_Sub(a, b);
   printf("sub %f %f\n", (double)(a - b), (double)c);
   c = FP_Mult(a, b);
   printf("mult %f %f\n", (double)(a * b), (double)c);
   c = FP_Div(a, b);
   printf("div %f %f\n", (double)(a / b), (double)c);
   //getch();

   for(a = (float)-13756.54; a < (float)17400.0; a += (float)64.45) 
   {
      for(b = (float)-875.36; b < (float)935.8; b += (float)36.7) 
      {
         error1 = (float)1.0 - (a + b) / FP_Add(a, b);
         error2 = (float)1.0 - (a * b) / FP_Mult(a, b);
         error3 = (float)1.0 - (a / b) / FP_Div(a, b);
         error4 = (float)1.0 - a / FP_ToFloat(FP_ToLong(a));
         error5 = error1 + error2 + error3 + error4;
         if(error5 < 0.00005) 
            continue;
         printf("ERROR!\n");
         printf("a=%f b=%f\n", (double)a, (double)b);
         printf("  a+b=%f %f\n", (double)(a+b), (double)FP_Add(a, b));
         printf("  a*b=%f %f\n", (double)(a*b), (double)FP_Mult(a, b));
         printf("  a/b=%f %f\n", (double)(a/b), (double)FP_Div(a, b));
         printf("  a=%f %ld %f\n", (double)a, FP_ToLong(a),
                                   (double)FP_ToFloat((long)a));
         printf("  %f %f %f %f\n", (double)error1, (double)error2,
            (double)error3, (double)error4);
         //if(error5 > 0.001) 
         //   getch();
      }
   }
   printf("done.\n");
   //getch();
}
#endif


