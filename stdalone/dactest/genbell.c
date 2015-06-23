/*
 * genbell.c -- 2-operator bell sound
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>


#define NUM_SEC		8		/* duration */

#define CLK		50000000	/* clock rate */
#define DIV		1024		/* clock divisor */
#define SAMPLE_RATE	(CLK / DIV)	/* in samples/sec */

#define PI		M_PI


void prolog(void) {
  printf("\t.export\tsamples\n");
  printf("\t.export\tendsmpl\n");
  printf("\n");
  printf("samples:\n");
}


void epilog(void) {
  printf("endsmpl:\n");
}


void wrtsample(short sample) {
  static int n = 0;
  unsigned w = (((unsigned) sample << 16) & 0xFFFF0000) |
               (((unsigned) sample <<  0) & 0x0000FFFF);
  if (n % 4 == 0) {
    printf("\t.word\t");
    n = 0;
  }
  printf("0x%08X", w);
  if (n % 4 == 3) {
    printf("\n");
  } else {
    printf(", ");
  }
  n++;
}


int main(int argc, char *argv[]) {
  double f0;
  int n, m;
  double a, alpha;
  double b, beta;
  double t;
  double modAmpl;
  double modulator;
  double carrAmpl;
  double carrier;
  short sample;
  int i;

  if (argc != 1) {
    printf("usage: %s\n", argv[0]);
    exit(1);
  }
  f0 = 49.0;
  n = 5;
  m = 7;
  a = 16000.0;
  alpha = 0.6140;
  b = 10.0;
  beta = 0.4605;
  prolog();
  for (i = 0; i < NUM_SEC * SAMPLE_RATE; i++) {
    t = i * (1.0 / SAMPLE_RATE);
    modAmpl = b * exp(-beta * t);
    modulator = modAmpl * sin(2.0 * PI * m * f0 * t);
    carrAmpl = a * exp(-alpha * t);
    carrier = carrAmpl * sin(2.0 * PI * n * f0 * t + modulator);
    sample = floor(carrier + 0.5);
    wrtsample(sample);
  }
  epilog();
  return 0;
}
