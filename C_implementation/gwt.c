/* gwt.c
** Ronald L. Rivest
** 5/14/08
** Routines to work with differential properties of g
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
  for (i=0;xx!=0;i++)
    { y = y ^ xx;
      xx = xx << ell;
    }
  z = 0;
  yy = y;
  for (i=0;yy!=0;i++)
    { z = z ^ yy;
      yy = yy >> r;
    }
  return z;
}

int wt(md6_word x)
{
  int i,c=0;
  for (i=0;i<w;i++)
    c += ( 1 & (x>>i) ) ;
  return c;
}

// standard shift table, for MD6 as of 6/1/08
int Ar[16] =   { 28,18,1,15,12, 5,6,22,23,10,3,13,32,10,11,4 };
int Aell[16] = { 14,15,3,13,29,20,3, 7,15,24,9, 8, 4,19, 6,5};

int test1()
// print out difference tables for possibly useful r,ell pairs
{ int i,r,ell;
  md6_word x;
  int wt_table_g[w+1];
  int wt_table_ginv[w+1];
  if (w>16){ printf("w=%d too large!",w); return 1; }
  for (r=1;r<w;r++)
    for (ell=1;ell<=w;ell++)
      {
	if (r==ell) continue;
	if (r+ell>=w) continue;

	// compute difference table for g
	for (i=0;i<=w;i++) wt_table_g[i] = 2*w;
	for (x=0;;x++)
	  {
	    int in_wt = wt(x);
	    int out_wt = wt(g(x,r,ell));
	    wt_table_g[in_wt] = min(wt_table_g[in_wt],out_wt);
	    if (x==(md6_word)(-1)) break;
	  }

	// compute difference table for ginv
	for (i=0;i<=w;i++) wt_table_ginv[i] = 2*w;
	for (x=0;;x++)
	  {
	    int in_wt = wt(x);
	    int out_wt = wt(ginv(x,r,ell));
	    wt_table_ginv[in_wt] = min(wt_table_ginv[in_wt],out_wt);
	    if (x==(md6_word)(-1)) break;
	  }
	
	// print results
	if (wt_table_ginv[1]>2)
	  { printf("r=%2d,ell=%2d ",r,ell);
	    for (i=0;i<=w;i++) printf("%2d ",wt_table_g[i]);
	    printf("\n");
	    printf("r=%2d,ell=%2d ",r,ell);
	    for (i=0;i<=w;i++) printf("%2d ",wt_table_ginv[i]);
	    printf("\n\n");
	  }
      }
  return 0;
}

int test2()
{
  int r,ell;
  md6_word x;
  int gamma[w][w];  // gamma[r][ell] is min weight of ginv(x,r,ell) for 
                    // weight-one inputs x

  printf("Table of weights of min-weight ginv outputs for ginv inputs of weight 1 (i.e. of gamma(r,ell))\n");
  printf("  ell=");
  for (ell=1;ell<w;ell++) printf("%2d ",ell);
  printf("\n");
  for (r=1;r<w;r++)
    {
      printf("r=%2d: ",r);
      for (ell=1;ell<w;ell++)
	{
	  gamma[r][ell] = 2*w;
	  for (x=1;x>0;x=x<<1)
	    gamma[r][ell] = min(gamma[r][ell],wt(ginv(x,r,ell)));
	  printf("%2d ",gamma[r][ell]);
	  if (gamma[r][ell]==2 &&
              ( (r != 2*ell) &&
		(r != ell) &&
		(ell != 2*r) &&
		(2*r+ell<=w) ) )
	      printf("\nConjecture wrong! r=%d ell=%d",r,ell);
	}
      printf("\n");
      }
  return 0;

}

int main()
{
  // return test1();
  return test2();
}
