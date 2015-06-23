/* ginv.c
** Ronald L. Rivest
** 5/14/08
** Routines to work with g and ginv
*/

#include <stdio.h>

#include <stdint.h>
typedef uint64_t md6_word;
#define w 64

/* Useful macros: min and max */
#define min(a,b) ((a)<(b)? (a) : (b))
#define max(a,b) ((a)>(b)? (a) : (b))

md6_word g(md6_word x,int r,int ell)
{
  x = x ^ (x >> r);
  x = x ^ (x << ell);
  return x;
}

md6_word ginv(md6_word x, int r,int ell)
{
  int i;
  md6_word y,z,xx,yy;
  y = 0;
  xx = x;
  for (i=0;i<w;i++)
    { y = y ^ xx;
      xx = xx << ell;
    }
  z = 0;
  yy = y;
  for (i=0;i<w;i++)
    { z = z ^ yy;
      yy = yy >> r;
    }
  return z;
}

int wt(md6_word x)
{
  int i,c=0;
  for (i=0;i<w;i++)
    c += 1 & (x>>i);
  return c;
}

int Ar[16] =   { 28,18,1,15,12,5,6,22,23,10,3,13,32,10,11,4 };
int Aell[16] = { 14,15,3,13,29,20,3,7,15,24,9,8,4,19,6,5};

int main()
{ int i,i1,i2,minwt,r,ell,j;
  md6_word x,y;
  for (j=0;j<16;j++)
    {
      r = Ar[j];
      ell = Aell[j];
      printf("r=%d ell=%d: g(x,r,ell)=y ginv(y,r,ell)=x\n",r,ell);

      minwt = 64;
      for (i=0;i<w;i++)
	{
	  x = ((md6_word)1)<<i;
	  y = g(x,r,ell);
	  minwt = min(minwt,wt(y));
	}
      printf("g:    r=%d ell=%d xwt=1, minywt=%d\n",r,ell,minwt);

      minwt = 64;
      for (i=0;i<w;i++)
	{
	  y = ((md6_word)1)<<i;
	  x = ginv(y,r,ell);
	  minwt = min(minwt,wt(x));
	}
      printf("ginv: r=%d ell=%d ywt=1, minxwt=%d\n",r,ell,minwt);

      minwt = 64;
      for (i1=0;i1<w;i1++)
	for (i2=i1+1;i2<w;i2++)
	  {
	    x = (1LL<<i1)+(1LL<<i2);
	    y = g(x,r,ell);
	    minwt = min(minwt,wt(y));
	  }
      printf("g:    r=%d ell=%d xwt=2, minywt=%d\n",r,ell,minwt);

      minwt = 64;
      for (i1=0;i1<w;i1++)
	for (i2=i1+1;i2<w;i2++)
	  {
	    y = (1LL<<i1)+(1LL<<i2);
	    x = ginv(y,r,ell);
	    minwt = min(minwt,wt(x));
	  }
      printf("ginv: r=%d ell=%d ywt=2, minxwt=%d\n",r,ell,minwt);

    }
  return 0;
}
