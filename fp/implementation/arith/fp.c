#define sign_bit ((unsigned) 0x80000000)  \

#define ROUND_OFF 1
#define ROUND_UP 2
#define ROUND_DOWN 3
#define ROUND_NEAR 4 \

#define X_BIT (1<<8)
#define Z_BIT (1<<9)
#define U_BIT (1<<10)
#define O_BIT (1<<11)
#define I_BIT (1<<12)
#define W_BIT (1<<13)
#define V_BIT (1<<14)
#define D_BIT (1<<15)
#define E_BIT (1<<18)  \

#define zero_exponent (-1000)  \

#define bignum_prec 157 \

#define magic_offset 2112
#define origin 37 \

#define buf0 (buf+8)
#define buf_max (buf+777)  \

/*1:*/
#line 32 "./mmix-arith.w"

#include <stdio.h>
#include <string.h>
#include <ctype.h>
/*2:*/
#line 49 "./mmix-arith.w"

#ifdef __STDC__
#define ARGS(list) list
#else
#define ARGS(list) ()
#endif

/*:2*/
#line 36 "./mmix-arith.w"

typedef enum
{ false, true } bool;
/*3:*/
#line 60 "./mmix-arith.w"

typedef unsigned int tetra;

typedef struct
{
  tetra h, l;
} octa;

/*:3*/
#line 38 "./mmix-arith.w"

/*36:*/
#line 605 "./mmix-arith.w"

typedef enum
{ zro, num, inf, nan } ftype;

       /*:36*//*59: */
#line 1110 "./mmix-arith.w"

typedef struct
{
  int a;
  int b;
  tetra dat[bignum_prec];
} bignum;

/*:59*/
#line 39 "./mmix-arith.w"

/*4:*/
#line 67 "./mmix-arith.w"

octa zero_octa;
octa neg_one = { -1, -1 };
octa inf_octa = { 0x7ff00000, 0 };
octa standard_NaN = { 0x7ff80000, 0 };
octa aux;
bool overflow;

      /*:4*//*9: */
#line 174 "./mmix-arith.w"

extern octa aux;
extern bool overflow;

      /*:9*//*30: */
#line 464 "./mmix-arith.w"

int cur_round;

       /*:30*//*32: */
#line 528 "./mmix-arith.w"

int exceptions;

       /*:32*//*69: */
#line 1359 "./mmix-arith.w"

octa val;
char *next_char;

       /*:69*//*75: */
#line 1432 "./mmix-arith.w"

static char buf[785] = "00000000";

/*:75*/
#line 40 "./mmix-arith.w"

/*5:*/
#line 78 "./mmix-arith.w"

octa oplus ARGS ((octa, octa));
octa
oplus (y, z)
     octa y, z;
{
  octa x;
  x.h = y.h + z.h;
  x.l = y.l + z.l;
  if (x.l < y.l)
    x.h++;
  return x;
}

octa ominus ARGS ((octa, octa));
octa
ominus (y, z)
     octa y, z;
{
  octa x;
  x.h = y.h - z.h;
  x.l = y.l - z.l;
  if (x.l > y.l)
    x.h--;
  return x;
}

      /*:5*//*6: */
#line 102 "./mmix-arith.w"

octa incr ARGS ((octa, int));
octa
incr (y, delta)
     octa y;
     int delta;
{
  octa x;
  x.h = y.h;
  x.l = y.l + delta;
  if (delta >= 0)
    {
      if (x.l < y.l)
	x.h++;
    }
  else if (x.l > y.l)
    x.h--;
  return x;
}

      /*:6*//*7: */
#line 117 "./mmix-arith.w"

octa shift_left ARGS ((octa, int));
octa
shift_left (y, s)
     octa y;
     int s;
{
  while (s >= 32)
    y.h = y.l, y.l = 0, s -= 32;
  if (s)
    {
      register tetra yhl = y.h << s, ylh = y.l >> (32 - s);
      y.h = yhl + ylh;
      y.l <<= s;
    }
  return y;
}

octa shift_right ARGS ((octa, int, int));
octa
shift_right (y, s, u)
     octa y;
     int s, u;
{
  while (s >= 32)
    y.l = y.h, y.h = (u ? 0 : -(y.h >> 31)), s -= 32;
  if (s)
    {
      register tetra yhl = y.h << (32 - s), ylh = y.l >> s;
      y.h = (u ? 0 : (-(y.h >> 31)) << (32 - s)) + (y.h >> s);
      y.l = yhl + ylh;
    }
  return y;
}

      /*:7*//*8: */
#line 150 "./mmix-arith.w"

octa omult ARGS ((octa, octa));
octa
omult (y, z)
     octa y, z;
{
  register int i, j, k;
  tetra u[4], v[4], w[8];
  register tetra t;
  octa acc;
/*10:*/
#line 178 "./mmix-arith.w"

  u[3] = y.h >> 16, u[2] = y.h & 0xffff, u[1] = y.l >> 16, u[0] =
    y.l & 0xffff;
  v[3] = z.h >> 16, v[2] = z.h & 0xffff, v[1] = z.l >> 16, v[0] =
    z.l & 0xffff;

/*:10*/
#line 159 "./mmix-arith.w"
  ;
  for (j = 0; j < 4; j++)
    w[j] = 0;
  for (j = 0; j < 4; j++)
    if (!v[j])
      w[j + 4] = 0;
    else
      {
	for (i = k = 0; i < 4; i++)
	  {
	    t = u[i] * v[j] + w[i + j] + k;
	    w[i + j] = t & 0xffff, k = t >> 16;
	  }
	w[j + 4] = k;
      }
/*11:*/
#line 182 "./mmix-arith.w"

  aux.h = (w[7] << 16) + w[6], aux.l = (w[5] << 16) + w[4];
  acc.h = (w[3] << 16) + w[2], acc.l = (w[1] << 16) + w[0];

/*:11*/
#line 170 "./mmix-arith.w"
  ;
  return acc;
}

      /*:8*//*12: */
#line 191 "./mmix-arith.w"

octa signed_omult ARGS ((octa, octa));
octa
signed_omult (y, z)
     octa y, z;
{
  octa acc;
  acc = omult (y, z);
  if (y.h & sign_bit)
    aux = ominus (aux, z);
  if (z.h & sign_bit)
    aux = ominus (aux, y);
  overflow = (aux.h != aux.l || (aux.h ^ (aux.h >> 1) ^ (acc.h & sign_bit)));
  return acc;
}

       /*:12*//*13: */
#line 215 "./mmix-arith.w"

octa odiv ARGS ((octa, octa, octa));
octa
odiv (x, y, z)
     octa x, y, z;
{
  register int i, j, k, n, d;
  tetra u[8], v[4], q[4], mask, qhat, rhat, vh, vmh;
  register tetra t;
  octa acc;
/*14:*/
#line 234 "./mmix-arith.w"

  if (x.h > z.h || (x.h == z.h && x.l >= z.l))
    {
      aux = y;
      return x;
    }

/*:14*/
#line 224 "./mmix-arith.w"
  ;
/*15:*/
#line 239 "./mmix-arith.w"

  u[7] = x.h >> 16, u[6] = x.h & 0xffff, u[5] = x.l >> 16, u[4] =
    x.l & 0xffff;
  u[3] = y.h >> 16, u[2] = y.h & 0xffff, u[1] = y.l >> 16, u[0] =
    y.l & 0xffff;
  v[3] = z.h >> 16, v[2] = z.h & 0xffff, v[1] = z.l >> 16, v[0] =
    z.l & 0xffff;

/*:15*/
#line 225 "./mmix-arith.w"
  ;
/*16:*/
#line 244 "./mmix-arith.w"

  for (n = 4; v[n - 1] == 0; n--);

/*:16*/
#line 226 "./mmix-arith.w"
  ;
/*17:*/
#line 250 "./mmix-arith.w"

  vh = v[n - 1];
  for (d = 0; vh < 0x8000; d++, vh <<= 1);
  for (j = k = 0; j < n + 4; j++)
    {
      t = (u[j] << d) + k;
      u[j] = t & 0xffff, k = t >> 16;
    }
  for (j = k = 0; j < n; j++)
    {
      t = (v[j] << d) + k;
      v[j] = t & 0xffff, k = t >> 16;
    }
  vh = v[n - 1];
  vmh = (n > 1 ? v[n - 2] : 0);

/*:17*/
#line 227 "./mmix-arith.w"
  ;
  for (j = 3; j >= 0; j--)	/*20: */
#line 276 "./mmix-arith.w"

    {
/*21:*/
#line 284 "./mmix-arith.w"

      t = (u[j + n] << 16) + u[j + n - 1];
      qhat = t / vh, rhat = t - vh * qhat;
      if (n > 1)
	while (qhat == 0x10000 || qhat * vmh > (rhat << 16) + u[j + n - 2])
	  {
	    qhat--, rhat += vh;
	    if (rhat >= 0x10000)
	      break;
	  }

/*:21*/
#line 278 "./mmix-arith.w"
      ;
/*22:*/
#line 296 "./mmix-arith.w"

      for (i = k = 0; i < n; i++)
	{
	  t = u[i + j] + 0xffff0000 - k - qhat * v[i];
	  u[i + j] = t & 0xffff, k = 0xffff - (t >> 16);
	}

/*:22*/
#line 279 "./mmix-arith.w"
      ;
/*23:*/
#line 305 "./mmix-arith.w"

      if (u[j + n] != k)
	{
	  qhat--;
	  for (i = k = 0; i < n; i++)
	    {
	      t = u[i + j] + v[i] + k;
	      u[i + j] = t & 0xffff, k = t >> 16;
	    }
	}

/*:23*/
#line 280 "./mmix-arith.w"
      ;
      q[j] = qhat;
    }

/*:20*/
#line 228 "./mmix-arith.w"
  ;
/*18:*/
#line 264 "./mmix-arith.w"

  mask = (1 << d) - 1;
  for (j = 3; j >= n; j--)
    u[j] = 0;
  for (k = 0; j >= 0; j--)
    {
      t = (k << 16) + u[j];
      u[j] = t >> d, k = t & mask;
    }

/*:18*/
#line 229 "./mmix-arith.w"
  ;
/*19:*/
#line 272 "./mmix-arith.w"

  acc.h = (q[3] << 16) + q[2], acc.l = (q[1] << 16) + q[0];
  aux.h = (u[3] << 16) + u[2], aux.l = (u[1] << 16) + u[0];

/*:19*/
#line 230 "./mmix-arith.w"
  ;
  return acc;
}

       /*:13*//*24: */
#line 317 "./mmix-arith.w"

octa signed_odiv ARGS ((octa, octa));
octa
signed_odiv (y, z)
     octa y, z;
{
  octa yy, zz, q;
  register int sy, sz;
  if (y.h & sign_bit)
    sy = 2, yy = ominus (zero_octa, y);
  else
    sy = 0, yy = y;
  if (z.h & sign_bit)
    sz = 1, zz = ominus (zero_octa, z);
  else
    sz = 0, zz = z;
  q = odiv (zero_octa, yy, zz);
  overflow = false;
  switch (sy + sz)
    {
    case 2 + 1:
      aux = ominus (zero_octa, aux);
      if (q.h == sign_bit)
	overflow = true;
    case 0 + 0:
      return q;
    case 2 + 0:
      if (aux.h || aux.l)
	aux = ominus (zz, aux);
      goto negate_q;
    case 0 + 1:
      if (aux.h || aux.l)
	aux = ominus (aux, zz);
    negate_q:if (aux.h || aux.l)
	return ominus (neg_one, q);
      else
	return ominus (zero_octa, q);
    }
}

       /*:24*//*25: */
#line 346 "./mmix-arith.w"

octa oand ARGS ((octa, octa));
octa
oand (y, z)
     octa y, z;
{
  octa x;
  x.h = y.h & z.h;
  x.l = y.l & z.l;
  return x;
}

octa oandn ARGS ((octa, octa));
octa
oandn (y, z)
     octa y, z;
{
  octa x;
  x.h = y.h & ~z.h;
  x.l = y.l & ~z.l;
  return x;
}

octa oxor ARGS ((octa, octa));
octa
oxor (y, z)
     octa y, z;
{
  octa x;
  x.h = y.h ^ z.h;
  x.l = y.l ^ z.l;
  return x;
}

       /*:25*//*26: */
#line 387 "./mmix-arith.w"

int count_bits ARGS ((tetra));
int
count_bits (x)
     tetra x;
{
  register int xx = x;
  xx = xx - ((xx >> 1) & 0x55555555);
  xx = (xx & 0x33333333) + ((xx >> 2) & 0x33333333);
  xx = (xx + (xx >> 4)) & 0x0f0f0f0f;
  xx = xx + (xx >> 8);
  return (xx + (xx >> 16)) & 0xff;
}

       /*:26*//*27: */
#line 403 "./mmix-arith.w"

tetra byte_diff ARGS ((tetra, tetra));
tetra
byte_diff (y, z)
     tetra y, z;
{
  register tetra d = (y & 0x00ff00ff) + 0x01000100 - (z & 0x00ff00ff);
  register tetra m = d & 0x01000100;
  register tetra x = d & (m - (m >> 8));
  d = ((y >> 8) & 0x00ff00ff) + 0x01000100 - ((z >> 8) & 0x00ff00ff);
  m = d & 0x01000100;
  return x + ((d & (m - (m >> 8))) << 8);
}

       /*:27*//*28: */
#line 421 "./mmix-arith.w"

tetra wyde_diff ARGS ((tetra, tetra));
tetra
wyde_diff (y, z)
     tetra y, z;
{
  register tetra a = ((y >> 16) - (z >> 16)) & 0x10000;
  register tetra b = ((y & 0xffff) - (z & 0xffff)) & 0x10000;
  return y - (z ^ ((y ^ z) & (b - a - (b >> 16))));
}

       /*:28*//*29: */
#line 434 "./mmix-arith.w"

octa bool_mult ARGS ((octa, octa, bool));
octa
bool_mult (y, z, xor)
     octa y, z;
     bool xor;
{
  octa o, x;
  register tetra a, b, c;
  register int k;
  for (k = 0, o = y, x = zero_octa; o.h || o.l;
       k++, o = shift_right (o, 8, 1))
    if (o.l & 0xff)
      {
	a = ((z.h >> k) & 0x01010101) * 0xff;
	b = ((z.l >> k) & 0x01010101) * 0xff;
	c = (o.l & 0xff) * 0x01010101;
	if (xor)
	  x.h ^= a & c, x.l ^= b & c;
	else
	  x.h |= a & c, x.l |= b & c;
      }
  return x;
}

       /*:29*//*31: */
#line 503 "./mmix-arith.w"

octa fpack ARGS ((octa, int, char, int));
octa
fpack (f, e, s, r)
     octa f;
     int e;
     char s;
     int r;
{
  octa o;
  if (e > 0x7fd)
    e = 0x7ff, o = zero_octa;
  else
    {
      if (e < 0)
	{
	  if (e < -54)
	    o.h = 0, o.l = 1;
	  else
	    {
	      octa oo;
	      o = shift_right (f, -e, 1);
	      oo = shift_left (o, -e);
	      if (oo.l != f.l || oo.h != f.h)
		o.l |= 1;

	    }
	  e = 0;
	}
      else
	o = f;
    }
/*33:*/
#line 533 "./mmix-arith.w"

  if (o.l & 3)
    exceptions |= X_BIT;
  switch (r)
    {
    case ROUND_DOWN:
      if (s == '-')
	o = incr (o, 3);
      break;
    case ROUND_UP:
      if (s != '-')
	o = incr (o, 3);
    case ROUND_OFF:
      break;
    case ROUND_NEAR:
      o = incr (o, o.l & 4 ? 2 : 1);
      break;
    }
  o = shift_right (o, 2, 1);
  o.h += e << 20;
  if (o.h >= 0x7ff00000)
    exceptions |= O_BIT + X_BIT;
  else if (o.h < 0x100000)
    exceptions |= U_BIT;
  if (s == '-')
    o.h |= sign_bit;
  return o;

/*:33*/
#line 525 "./mmix-arith.w"
  ;
}

       /*:31*//*34: */
#line 551 "./mmix-arith.w"

tetra sfpack ARGS ((octa, int, char, int));
tetra
sfpack (f, e, s, r)
     octa f;
     int e;
     char s;
     int r;
{
  register tetra o;
  if (e > 0x47d)
    e = 0x47f, o = 0;
  else
    {
      o = shift_left (f, 3).h;
      if (f.l & 0x1fffffff)
	o |= 1;
      if (e < 0x380)
	{
	  if (e < 0x380 - 25)
	    o = 1;
	  else
	    {
	      register tetra o0, oo;
	      o0 = o;
	      o = o >> (0x380 - e);
	      oo = o << (0x380 - e);
	      if (oo != o0)
		o |= 1;

	    }
	  e = 0x380;
	}
    }
/*35:*/
#line 579 "./mmix-arith.w"

  if (o & 3)
    exceptions |= X_BIT;
  switch (r)
    {
    case ROUND_DOWN:
      if (s == '-')
	o += 3;
      break;
    case ROUND_UP:
      if (s != '-')
	o += 3;
    case ROUND_OFF:
      break;
    case ROUND_NEAR:
      o += (o & 4 ? 2 : 1);
      break;
    }
  o = o >> 2;
  o += (e - 0x380) << 23;
  if (o >= 0x7f800000)
    exceptions |= O_BIT + X_BIT;
  else if (o < 0x100000)
    exceptions |= U_BIT;
  if (s == '-')
    o |= sign_bit;
  return o;

/*:35*/
#line 576 "./mmix-arith.w"
  ;
}

       /*:34*//*37: */
#line 608 "./mmix-arith.w"

ftype funpack ARGS ((octa, octa *, int *, char *));
ftype
funpack (x, f, e, s)
     octa x;
     octa *f;
     int *e;
     char *s;
{
  register int ee;
  exceptions = 0;
  *s = (x.h & sign_bit ? '-' : '+');
  *f = shift_left (x, 2);
  f->h &= 0x3fffff;
  ee = (x.h >> 20) & 0x7ff;
  if (ee)
    {
      *e = ee - 1;
      f->h |= 0x400000;
      return (ee < 0x7ff ? num : f->h == 0x400000 && !f->l ? inf : nan);
    }
  if (!x.l && !f->h)
    {
      *e = zero_exponent;
      return zro;
    }
  do
    {
      ee--;
      *f = shift_left (*f, 1);
    }
  while (!(f->h & 0x400000));
  *e = ee;
  return num;
}

       /*:37*//*38: */
#line 634 "./mmix-arith.w"

ftype sfunpack ARGS ((tetra, octa *, int *, char *));
ftype
sfunpack (x, f, e, s)
     tetra x;
     octa *f;
     int *e;
     char *s;
{
  register int ee;
  exceptions = 0;
  *s = (x & sign_bit ? '-' : '+');
  f->h = (x >> 1) & 0x3fffff, f->l = x << 31;
  ee = (x >> 23) & 0xff;
  if (ee)
    {
      *e = ee + 0x380 - 1;
      f->h |= 0x400000;
      return (ee < 0xff ? num : (x & 0x7fffffff) == 0x7f800000 ? inf : nan);
    }
  if (!(x & 0x7fffffff))
    {
      *e = zero_exponent;
      return zro;
    }
  do
    {
      ee--;
      *f = shift_left (*f, 1);
    }
  while (!(f->h & 0x400000));
  *e = ee + 0x380;
  return num;
}

       /*:38*//*39: */
#line 663 "./mmix-arith.w"

octa load_sf ARGS ((tetra));
octa
load_sf (z)
     tetra z;
{
  octa f, x;
  int e;
  char s;
  ftype t;
  t = sfunpack (z, &f, &e, &s);
  switch (t)
    {
    case zro:
      x = zero_octa;
      break;
    case num:
      return fpack (f, e, s, ROUND_OFF);
    case inf:
      x = inf_octa;
      break;
    case nan:
      x = shift_right (f, 2, 1);
      x.h |= 0x7ff00000;
      break;
    }
  if (s == '-')
    x.h |= sign_bit;
  return x;
}

       /*:39*//*40: */
#line 680 "./mmix-arith.w"

tetra store_sf ARGS ((octa));
tetra
store_sf (x)
     octa x;
{
  octa f;
  tetra z;
  int e;
  char s;
  ftype t;
  t = funpack (x, &f, &e, &s);
  switch (t)
    {
    case zro:
      z = 0;
      break;
    case num:
      return sfpack (f, e, s, cur_round);
    case inf:
      z = 0x7f800000;
      break;
    case nan:
      if (!(f.h & 0x200000))
	{
	  f.h |= 0x200000;
	  exceptions |= I_BIT;
	}
      z = 0x7f800000 | (f.h << 1) | (f.l >> 31);
      break;
    }
  if (s == '-')
    z |= sign_bit;
  return z;
}

       /*:40*//*41: */
#line 705 "./mmix-arith.w"

octa fmult ARGS ((octa, octa));
octa
fmult (y, z)
     octa y, z;
{
  ftype yt, zt;
  int ye, ze;
  char ys, zs;
  octa x, xf, yf, zf;
  register int xe;
  register char xs;
  yt = funpack (y, &yf, &ye, &ys);
  zt = funpack (z, &zf, &ze, &zs);
  xs = ys + zs - '+';
  switch (4 * yt + zt)
    {
/*42:*/
#line 731 "./mmix-arith.w"

    case 4 * nan + nan:
      if (!(y.h & 0x80000))
	exceptions |= I_BIT;
    case 4 * zro + nan:
    case 4 * num + nan:
    case 4 * inf + nan:
      if (!(z.h & 0x80000))
	exceptions |= I_BIT, z.h |= 0x80000;
      return z;
    case 4 * nan + zro:
    case 4 * nan + num:
    case 4 * nan + inf:
      if (!(y.h & 0x80000))
	exceptions |= I_BIT, y.h |= 0x80000;
      return y;

/*:42*/
#line 720 "./mmix-arith.w"
      ;
    case 4 * zro + zro:
    case 4 * zro + num:
    case 4 * num + zro:
      x = zero_octa;
      break;
    case 4 * num + inf:
    case 4 * inf + num:
    case 4 * inf + inf:
      x = inf_octa;
      break;
    case 4 * zro + inf:
    case 4 * inf + zro:
      x = standard_NaN;
      exceptions |= I_BIT;
      break;
    case 4 * num + num:	/*43: */
#line 740 "./mmix-arith.w"

      xe = ye + ze - 0x3fd;
      x = omult (yf, shift_left (zf, 9));
      if (aux.h >= 0x400000)
	xf = aux;
      else
	xf = shift_left (aux, 1), xe--;
      if (x.h || x.l)
	xf.l |= 1;
      return fpack (xf, xe, xs, cur_round);

/*:43*/
#line 725 "./mmix-arith.w"
      ;
    }
  if (xs == '-')
    x.h |= sign_bit;
  return x;
}

       /*:41*//*44: */
#line 748 "./mmix-arith.w"

octa fdivide ARGS ((octa, octa));
octa
fdivide (y, z)
     octa y, z;
{
  ftype yt, zt;
  int ye, ze;
  char ys, zs;
  octa x, xf, yf, zf;
  register int xe;
  register char xs;
  yt = funpack (y, &yf, &ye, &ys);
  zt = funpack (z, &zf, &ze, &zs);
  xs = ys + zs - '+';
  switch (4 * yt + zt)
    {
/*42:*/
#line 731 "./mmix-arith.w"

    case 4 * nan + nan:
      if (!(y.h & 0x80000))
	exceptions |= I_BIT;
    case 4 * zro + nan:
    case 4 * num + nan:
    case 4 * inf + nan:
      if (!(z.h & 0x80000))
	exceptions |= I_BIT, z.h |= 0x80000;
      return z;
    case 4 * nan + zro:
    case 4 * nan + num:
    case 4 * nan + inf:
      if (!(y.h & 0x80000))
	exceptions |= I_BIT, y.h |= 0x80000;
      return y;

/*:42*/
#line 763 "./mmix-arith.w"
      ;
    case 4 * zro + inf:
    case 4 * zro + num:
    case 4 * num + inf:
      x = zero_octa;
      break;
    case 4 * num + zro:
      exceptions |= Z_BIT;
    case 4 * inf + num:
    case 4 * inf + zro:
      x = inf_octa;
      break;
    case 4 * zro + zro:
    case 4 * inf + inf:
      x = standard_NaN;
      exceptions |= I_BIT;
      break;
    case 4 * num + num:	/*45: */
#line 775 "./mmix-arith.w"

      xe = ye - ze + 0x3fd;
      xf = odiv (yf, zero_octa, shift_left (zf, 9));
      if (xf.h >= 0x800000)
	{
	  aux.l |= xf.l & 1;
	  xf = shift_right (xf, 1, 1);
	  xe++;
	}
      if (aux.h || aux.l)
	xf.l |= 1;
      return fpack (xf, xe, xs, cur_round);

/*:45*/
#line 769 "./mmix-arith.w"
      ;
    }
  if (xs == '-')
    x.h |= sign_bit;
  return x;
}

       /*:44*//*46: */
#line 790 "./mmix-arith.w"

octa fplus ARGS ((octa, octa));
octa
fplus (y, z)
     octa y, z;
{
  ftype yt, zt;
  int ye, ze;
  char ys, zs;
  octa x, xf, yf, zf;
  register int xe, d;
  register char xs;
  yt = funpack (y, &yf, &ye, &ys);
  zt = funpack (z, &zf, &ze, &zs);
  switch (4 * yt + zt)
    {
/*42:*/
#line 731 "./mmix-arith.w"

    case 4 * nan + nan:
      if (!(y.h & 0x80000))
	exceptions |= I_BIT;
    case 4 * zro + nan:
    case 4 * num + nan:
    case 4 * inf + nan:
      if (!(z.h & 0x80000))
	exceptions |= I_BIT, z.h |= 0x80000;
      return z;
    case 4 * nan + zro:
    case 4 * nan + num:
    case 4 * nan + inf:
      if (!(y.h & 0x80000))
	exceptions |= I_BIT, y.h |= 0x80000;
      return y;

/*:42*/
#line 804 "./mmix-arith.w"
      ;
    case 4 * zro + num:
      return fpack (zf, ze, zs, ROUND_OFF);
      break;
    case 4 * num + zro:
      return fpack (yf, ye, ys, ROUND_OFF);
      break;
    case 4 * inf + inf:
      if (ys != zs)
	{
	  exceptions |= I_BIT;
	  x = standard_NaN;
	  xs = zs;
	  break;
	}
    case 4 * num + inf:
    case 4 * zro + inf:
      x = inf_octa;
      xs = zs;
      break;
    case 4 * inf + num:
    case 4 * inf + zro:
      x = inf_octa;
      xs = ys;
      break;
    case 4 * num + num:
      if (y.h != (z.h ^ 0x80000000) || y.l != z.l)
/*47:*/
#line 821 "./mmix-arith.w"

	{
	  octa o, oo;
	  if (ye < ze
	      || (ye == ze && (yf.h < zf.h || (yf.h == zf.h && yf.l < zf.l))))
/*48:*/
#line 839 "./mmix-arith.w"

	    {
	      o = yf, yf = zf, zf = o;
	      d = ye, ye = ze, ze = d;
	      d = ys, ys = zs, zs = d;
	    }

/*:48*/
#line 824 "./mmix-arith.w"
	  ;
	  d = ye - ze;
	  xs = ys, xe = ye;
	  if (d)		/*49: */
#line 859 "./mmix-arith.w"

	    {
	      if (d <= 2)
		zf = shift_right (zf, d, 1);
	      else if (d > 53)
		zf.h = 0, zf.l = 1;
	      else
		{
		  if (ys != zs)
		    d--, xe--, yf = shift_left (yf, 1);
		  o = zf;
		  zf = shift_right (o, d, 1);
		  oo = shift_left (zf, d);
		  if (oo.l != o.l || oo.h != o.h)
		    zf.l |= 1;
		}
	    }

/*:49*/
#line 827 "./mmix-arith.w"
	  ;
	  if (ys == zs)
	    {
	      xf = oplus (yf, zf);
	      if (xf.h >= 0x800000)
		xe++, d = xf.l & 1, xf = shift_right (xf, 1, 1), xf.l |= d;
	    }
	  else
	    {
	      xf = ominus (yf, zf);
	      if (xf.h >= 0x800000)
		xe++, d = xf.l & 1, xf = shift_right (xf, 1, 1), xf.l |= d;
	      else
		while (xf.h < 0x400000)
		  xe--, xf = shift_left (xf, 1);
	    }
	  return fpack (xf, xe, xs, cur_round);
	}

/*:47*/
#line 813 "./mmix-arith.w"
      ;
    case 4 * zro + zro:
      x = zero_octa;
      xs = (ys == zs ? ys : cur_round == ROUND_DOWN ? '-' : '+');
      break;
    }
  if (xs == '-')
    x.h |= sign_bit;
  return x;
}

       /*:46*//*50: */
#line 883 "./mmix-arith.w"

int fepscomp ARGS ((octa, octa, octa, int));
int
fepscomp (y, z, e, s)
     octa y, z, e;
     int s;
{
  octa yf, zf, ef, o, oo;
  int ye, ze, ee;
  char ys, zs, es;
  register int yt, zt, et, d;
  et = funpack (e, &ef, &ee, &es);
  if (es == '-')
    return 2;
  switch (et)
    {
    case nan:
      return 2;
    case inf:
      ee = 10000;
    case num:
    case zro:
      break;
    }
  yt = funpack (y, &yf, &ye, &ys);
  zt = funpack (z, &zf, &ze, &zs);
  switch (4 * yt + zt)
    {
    case 4 * nan + nan:
    case 4 * nan + inf:
    case 4 * nan + num:
    case 4 * nan + zro:
    case 4 * inf + nan:
    case 4 * num + nan:
    case 4 * zro + nan:
      return 2;
    case 4 * inf + inf:
      return (ys == zs || ee >= 1023);
    case 4 * inf + num:
    case 4 * inf + zro:
    case 4 * num + inf:
    case 4 * zro + inf:
      return (s && ee >= 1022);
    case 4 * zro + zro:
      return 1;
    case 4 * zro + num:
    case 4 * num + zro:
      if (!s)
	return 0;
    case 4 * num + num:
      break;
    }
/*51:*/
#line 919 "./mmix-arith.w"

/*52:*/
#line 934 "./mmix-arith.w"

  if (ye < 0 && yt != zro)
    yf = shift_left (y, 2), ye = 0;
  if (ze < 0 && zt != zro)
    zf = shift_left (z, 2), ze = 0;

/*:52*/
#line 920 "./mmix-arith.w"
  ;
  if (ye < ze || (ye == ze && (yf.h < zf.h || (yf.h == zf.h && yf.l < zf.l))))
/*48:*/
#line 839 "./mmix-arith.w"

    {
      o = yf, yf = zf, zf = o;
      d = ye, ye = ze, ze = d;
      d = ys, ys = zs, zs = d;
    }

/*:48*/
#line 922 "./mmix-arith.w"
  ;
  if (ze == zero_exponent)
    ze = ye;
  d = ye - ze;
  if (!s)
    ee -= d;
  if (ee >= 1023)
    return 1;
/*53:*/
#line 956 "./mmix-arith.w"

  if (d > 54)
    o = zero_octa, oo = zf;
  else
    o = shift_right (zf, d, 1), oo = shift_left (o, d);
  if (oo.h != zf.h || oo.l != zf.l)
    {
      if (ee < 1020)
	return 0;
      o = incr (o, ys == zs ? 0 : 1);
    }
  o = (ys == zs ? ominus (yf, o) : oplus (yf, o));

/*:53*/
#line 927 "./mmix-arith.w"
  ;
  if (!o.h && !o.l)
    return 1;
  if (ee < 968)
    return 0;
  if (ee >= 1021)
    ef = shift_left (ef, ee - 1021);
  else
    ef = shift_right (ef, 1021 - ee, 1);
  return o.h < ef.h || (o.h == ef.h && o.l <= ef.l);

/*:51*/
#line 912 "./mmix-arith.w"
  ;
}

       /*:50*//*54: */
#line 972 "./mmix-arith.w"

static void bignum_times_ten ARGS ((bignum *));
static void bignum_dec ARGS ((bignum *, bignum *, tetra));
static int bignum_compare ARGS ((bignum *, bignum *));
void print_float ARGS ((octa));
void
print_float (x)
     octa x;
{
/*56:*/
#line 1035 "./mmix-arith.w"

  octa f, g;
  register int e;
  register int j, k;

  /*:56*//*66: */
#line 1281 "./mmix-arith.w"

  bignum ff, gg;
  bignum tt;
  char s[18];
  register char *p;

/*:66*/
#line 980 "./mmix-arith.w"
  ;
  if (x.h & sign_bit)
    printf ("-");
/*55:*/
#line 1019 "./mmix-arith.w"

  f = shift_left (x, 1);
  e = f.h >> 21;
  f.h &= 0x1fffff;
  if (!f.h && !f.l)		/*57: */
#line 1045 "./mmix-arith.w"

    {
      if (!e)
	{
	  printf ("0.");
	  return;
	}
      if (e == 0x7ff)
	{
	  printf ("Inf");
	  return;
	}
      e--;
      f.h = 0x3fffff, f.l = 0xffffffff;
      g.h = 0x400000, g.l = 2;
    }

/*:57*/
#line 1023 "./mmix-arith.w"

  else
    {
      g = incr (f, 1);
      f = incr (f, -1);
      if (!e)
	e = 1;
      else if (e == 0x7ff)
	{
	  printf ("NaN");
	  if (g.h == 0x100000 && g.l == 1)
	    return;
	  e = 0x3ff;
	}
      else
	f.h |= 0x200000, g.h |= 0x200000;
    }

/*:55*/
#line 983 "./mmix-arith.w"
  ;
/*63:*/
#line 1195 "./mmix-arith.w"

  k = (magic_offset - e) / 28;
  ff.dat[k - 1] =
    shift_right (f, magic_offset + 28 - e - 28 * k, 1).l & 0xfffffff;
  gg.dat[k - 1] =
    shift_right (g, magic_offset + 28 - e - 28 * k, 1).l & 0xfffffff;
  ff.dat[k] = shift_right (f, magic_offset - e - 28 * k, 1).l & 0xfffffff;
  gg.dat[k] = shift_right (g, magic_offset - e - 28 * k, 1).l & 0xfffffff;
  ff.dat[k + 1] =
    shift_left (f, e + 28 * k - (magic_offset - 28)).l & 0xfffffff;
  gg.dat[k + 1] =
    shift_left (g, e + 28 * k - (magic_offset - 28)).l & 0xfffffff;
  ff.a = (ff.dat[k - 1] ? k - 1 : k);
  ff.b = (ff.dat[k + 1] ? k + 1 : k);
  gg.a = (gg.dat[k - 1] ? k - 1 : k);
  gg.b = (gg.dat[k + 1] ? k + 1 : k);

/*:63*/
#line 984 "./mmix-arith.w"
  ;
/*64:*/
#line 1223 "./mmix-arith.w"

  if (e > 0x401)		/*65: */
#line 1254 "./mmix-arith.w"

    {
      register int open = x.l & 1;
      tt.dat[origin] = 10;
      tt.a = tt.b = origin;
      for (e = 1; bignum_compare (&gg, &tt) >= open; e++)
	bignum_times_ten (&tt);
      p = s;
      while (1)
	{
	  bignum_times_ten (&ff);
	  bignum_times_ten (&gg);
	  for (j = '0'; bignum_compare (&ff, &tt) >= 0; j++)
	    bignum_dec (&ff, &tt, 0x10000000), bignum_dec (&gg, &tt,
							   0x10000000);
	  if (bignum_compare (&gg, &tt) >= open)
	    break;
	  *p++ = j;
	  if (ff.a == bignum_prec - 1 && !open)
	    goto done;
	}
      for (k = j; bignum_compare (&gg, &tt) >= open; k++)
	bignum_dec (&gg, &tt, 0x10000000);
      *p++ = (j + 1 + k) >> 1;
    done:;
    }

/*:65*/
#line 1224 "./mmix-arith.w"

  else
    {
      if (ff.a > origin)
	ff.dat[origin] = 0;
      for (e = 1, p = s; gg.a > origin || ff.dat[origin] == gg.dat[origin];)
	{
	  if (gg.a > origin)
	    e--;
	  else
	    *p++ = ff.dat[origin] + '0', ff.dat[origin] = 0, gg.dat[origin] =
	      0;
	  bignum_times_ten (&ff);
	  bignum_times_ten (&gg);
	}
      *p++ = ((ff.dat[origin] + 1 + gg.dat[origin]) >> 1) + '0';
    }
  *p = '\0';

/*:64*/
#line 985 "./mmix-arith.w"
  ;
/*67:*/
#line 1296 "./mmix-arith.w"

  if (e > 17 || e < (int) strlen (s) - 17)
    printf ("%c%s%se%d", s[0], (s[1] ? "." : ""), s + 1, e - 1);
  else if (e < 0)
    printf (".%0*d%s", -e, 0, s);
  else if (strlen (s) >= e)
    printf ("%.*s.%s", e, s, s + e);
  else
    printf ("%s%0*d.", s, e - (int) strlen (s), 0);

/*:67*/
#line 986 "./mmix-arith.w"
  ;
}

       /*:54*//*60: */
#line 1120 "./mmix-arith.w"

static void
bignum_times_ten (f)
     bignum *f;
{
  register tetra *p, *q;
  register tetra x, carry;
  for (p = &f->dat[f->b], q = &f->dat[f->a], carry = 0; p >= q; p--)
    {
      x = *p * 10 + carry;
      *p = x & 0xfffffff;
      carry = x >> 28;
    }
  *p = carry;
  if (carry)
    f->a--;
  if (f->dat[f->b] == 0 && f->b > f->a)
    f->b--;
}

       /*:60*//*61: */
#line 1138 "./mmix-arith.w"

static int
bignum_compare (f, g)
     bignum *f, *g;
{
  register tetra *p, *pp, *q, *qq;
  if (f->a != g->a)
    return f->a > g->a ? -1 : 1;
  pp = &f->dat[f->b], qq = &g->dat[g->b];
  for (p = &f->dat[f->a], q = &g->dat[g->a]; p <= pp; p++, q++)
    {
      if (*p != *q)
	return *p < *q ? -1 : 1;
      if (q == qq)
	return p < pp;
    }
  return -1;
}

       /*:61*//*62: */
#line 1155 "./mmix-arith.w"

static void
bignum_dec (f, g, r)
     bignum *f, *g;
     tetra r;
{
  register tetra *p, *q, *qq;
  register int x, borrow;
  while (g->b > f->b)
    f->dat[++f->b] = 0;
  qq = &g->dat[g->a];
  for (p = &f->dat[g->b], q = &g->dat[g->b], borrow = 0; q >= qq; p--, q--)
    {
      x = *p - *q - borrow;
      if (x >= 0)
	borrow = 0, *p = x;
      else
	borrow = 1, *p = x + r;
    }
  for (; borrow; p--)
    if (*p)
      borrow = 0, *p = *p - 1;
    else
      *p = r - 1;
  while (f->dat[f->a] == 0)
    {
      if (f->a == f->b)
	{
	  f->a = f->b = bignum_prec - 1, f->dat[bignum_prec - 1] = 0;
	  return;
	}
      f->a++;
    }
  while (f->dat[f->b] == 0)
    f->b--;
}

       /*:62*//*68: */
#line 1340 "./mmix-arith.w"

static void bignum_double ARGS ((bignum *));
int scan_const ARGS ((char *));
int
scan_const (s)
     char *s;
{
/*70:*/
#line 1363 "./mmix-arith.w"

  register char *p, *q;
  register bool NaN;
  int sign;

  /*:70*//*76: */
#line 1435 "./mmix-arith.w"

  register char *dec_pt;
  register int exp;
  register int zeros;

  /*:76*//*81: */
#line 1503 "./mmix-arith.w"

  register int k, x;
  register char *pp;
  bignum ff, tt;

/*:81*/
#line 1346 "./mmix-arith.w"
  ;
  val.h = val.l = 0;
  p = s;
  if (*p == '+' || *p == '-')
    sign = *p++;
  else
    sign = '+';
  if (strncmp (p, "NaN", 3) == 0)
    NaN = true, p += 3;
  else
    NaN = false;
  if ((isdigit (*p) && !NaN) || (*p == '.' && isdigit (*(p + 1))))
/*73:*/
#line 1396 "./mmix-arith.w"

    {
      for (q = buf0, dec_pt = (char *) 0; isdigit (*p); p++)
	{
	  val = oplus (val, shift_left (val, 2));
	  val = incr (shift_left (val, 1), *p - '0');
	  if (q > buf0 || *p != '0')
	    if (q < buf_max)
	      *q++ = *p;
	    else if (*(q - 1) == '0')
	      *(q - 1) = *p;
	}
      if (NaN)
	*q++ = '1';
      if (*p == '.')		/*74: */
#line 1415 "./mmix-arith.w"

	{
	  dec_pt = q;
	  p++;
	  for (zeros = 0; isdigit (*p); p++)
	    if (*p == '0' && q == buf0)
	      zeros++;
	    else if (q < buf_max)
	      *q++ = *p;
	    else if (*(q - 1) == '0')
	      *(q - 1) = *p;
	}

/*:74*/
#line 1406 "./mmix-arith.w"
      ;
      next_char = p;
      if (*p == 'e' && !NaN)	/*77: */
#line 1447 "./mmix-arith.w"

	{
	  register char exp_sign;
	  p++;
	  if (*p == '+' || *p == '-')
	    exp_sign = *p++;
	  else
	    exp_sign = '+';
	  if (isdigit (*p))
	    {
	      for (exp = *p++ - '0'; isdigit (*p); p++)
		if (exp < 1000)
		  exp = 10 * exp + *p - '0';
	      if (!dec_pt)
		dec_pt = q, zeros = 0;
	      if (exp_sign == '-')
		exp = -exp;
	      next_char = p;
	    }
	}

/*:77*/
#line 1408 "./mmix-arith.w"

      else
	exp = 0;
      if (dec_pt)		/*78: */
#line 1460 "./mmix-arith.w"

	{
/*79:*/
#line 1477 "./mmix-arith.w"

	  x = buf + 341 + zeros - dec_pt - exp;
	  if (q == buf0 || x >= 1413)
	    {
	    make_it_zero:exp = -99999;
	      goto packit;
	    }
	  if (x < 0)
	    {
	    make_it_infinite:exp = 99999;
	      goto packit;
	    }
	  ff.a = x / 9;
	  for (p = q; p < q + 8; p++)
	    *p = '0';
	  q = q - 1 - (q + 341 + zeros - dec_pt - exp) % 9;
	  for (p = buf0 - x % 9, k = ff.a; p <= q && k <= 156; p += 9, k++)
/*80:*/
#line 1497 "./mmix-arith.w"

	    {
	      for (x = *p - '0', pp = p + 1; pp < p + 9; pp++)
		x = 10 * x + *pp - '0';
	      ff.dat[k] = x;
	    }

/*:80*/
#line 1490 "./mmix-arith.w"
	  ;
	  ff.b = k - 1;
	  for (x = 0; p <= q; p += 9)
	    if (strncmp (p, "000000000", 9) != 0)
	      x = 1;
	  ff.dat[156] += x;

	  while (ff.dat[ff.b] == 0)
	    ff.b--;

/*:79*/
#line 1462 "./mmix-arith.w"
	  ;
/*83:*/
#line 1526 "./mmix-arith.w"

	  val = zero_octa;
	  if (ff.a > 36)
	    {
	      for (exp = 0x3fe; ff.a > 36; exp--)
		bignum_double (&ff);
	      for (k = 54; k; k--)
		{
		  if (ff.dat[36])
		    {
		      if (k >= 32)
			val.h |= 1 << (k - 32);
		      else
			val.l |= 1 << k;
		      ff.dat[36] = 0;
		      if (ff.b == 36)
			break;
		    }
		  bignum_double (&ff);
		}
	    }
	  else
	    {
	      tt.a = tt.b = 36, tt.dat[36] = 2;
	      for (exp = 0x3fe; bignum_compare (&ff, &tt) >= 0; exp++)
		bignum_double (&tt);
	      for (k = 54; k; k--)
		{
		  bignum_double (&ff);
		  if (bignum_compare (&ff, &tt) >= 0)
		    {
		      if (k >= 32)
			val.h |= 1 << (k - 32);
		      else
			val.l |= 1 << k;
		      bignum_dec (&ff, &tt, 1000000000);
		      if (ff.a == bignum_prec - 1)
			break;
		    }
		}
	    }
	  if (k == 0)
	    val.l |= 1;

/*:83*/
#line 1463 "./mmix-arith.w"
	  ;
	packit:		/*84: */
#line 1559 "./mmix-arith.w"

	  val = fpack (val, exp, sign, ROUND_NEAR);
	  if (NaN)
	    {
	      if ((val.h & 0x7fffffff) == 0x40000000)
		val.h |= 0x7fffffff, val.l = 0xffffffff;
	      else if ((val.h & 0x7fffffff) == 0x3ff00000 && !val.l)
		val.h |= 0x40000000, val.l = 1;
	      else
		val.h |= 0x40000000;
	    }

/*:84*/
#line 1464 "./mmix-arith.w"
	  ;
	  return 1;
	}

/*:78*/
#line 1410 "./mmix-arith.w"
      ;
      if (sign == '-')
	val = ominus (zero_octa, val);
      return 0;
    }

/*:73*/
#line 1353 "./mmix-arith.w"
  ;
  if (NaN)			/*71: */
#line 1368 "./mmix-arith.w"

    {
      next_char = p;
      val.h = 0x600000, exp = 0x3fe;
      goto packit;
    }

/*:71*/
#line 1354 "./mmix-arith.w"
  ;
  if (strncmp (p, "Inf", 3) == 0)	/*72: */
#line 1375 "./mmix-arith.w"

    {
      next_char = p + 3;
      goto make_it_infinite;
    }

/*:72*/
#line 1355 "./mmix-arith.w"
  ;
no_const_found:next_char = s;
  return -1;
}

       /*:68*//*82: */
#line 1511 "./mmix-arith.w"

static void
bignum_double (f)
     bignum *f;
{
  register tetra *p, *q;
  register int x, carry;
  for (p = &f->dat[f->b], q = &f->dat[f->a], carry = 0; p >= q; p--)
    {
      x = *p + *p + carry;
      if (x >= 1000000000)
	carry = 1, *p = x - 1000000000;
      else
	carry = 0, *p = x;
    }
  *p = carry;
  if (carry)
    f->a--;
  if (f->dat[f->b] == 0 && f->b > f->a)
    f->b--;
}

       /*:82*//*85: */
#line 1575 "./mmix-arith.w"

int fcomp ARGS ((octa, octa));
int
fcomp (y, z)
     octa y, z;
{
  ftype yt, zt;
  int ye, ze;
  char ys, zs;
  octa yf, zf;
  register int x;
  yt = funpack (y, &yf, &ye, &ys);
  zt = funpack (z, &zf, &ze, &zs);
  switch (4 * yt + zt)
    {
    case 4 * nan + nan:
    case 4 * zro + nan:
    case 4 * num + nan:
    case 4 * inf + nan:
    case 4 * nan + zro:
    case 4 * nan + num:
    case 4 * nan + inf:
      return 2;
    case 4 * zro + zro:
      return 0;
    case 4 * zro + num:
    case 4 * num + zro:
    case 4 * zro + inf:
    case 4 * inf + zro:
    case 4 * num + num:
    case 4 * num + inf:
    case 4 * inf + num:
    case 4 * inf + inf:
      if (ys != zs)
	x = 1;
      else if (y.h > z.h)
	x = 1;
      else if (y.h < z.h)
	x = -1;
      else if (y.l > z.l)
	x = 1;
      else if (y.l < z.l)
	x = -1;
      else
	return 0;
      break;
    }
  return (ys == '-' ? -x : x);
}

       /*:85*//*86: */
#line 1608 "./mmix-arith.w"

octa fintegerize ARGS ((octa, int));
octa
fintegerize (z, r)
     octa z;
     int r;
{
  ftype zt;
  int ze;
  char zs;
  octa xf, zf;
  zt = funpack (z, &zf, &ze, &zs);
  if (!r)
    r = cur_round;
  switch (zt)
    {
    case nan:
      if (!(z.h & 0x80000))
	{
	  exceptions |= I_BIT;
	  z.h |= 0x80000;
	}
    case inf:
    case zro:
      return z;
    case num:			/*87: */
#line 1627 "./mmix-arith.w"

      if (ze >= 1074)
	return fpack (zf, ze, zs, ROUND_OFF);
      if (ze <= 1020)
	xf.h = 0, xf.l = 1;
      else
	{
	  octa oo;
	  xf = shift_right (zf, 1074 - ze, 1);
	  oo = shift_left (xf, 1074 - ze);
	  if (oo.l != zf.l || oo.h != zf.h)
	    xf.l |= 1;

	}
      switch (r)
	{
	case ROUND_DOWN:
	  if (zs == '-')
	    xf = incr (xf, 3);
	  break;
	case ROUND_UP:
	  if (zs != '-')
	    xf = incr (xf, 3);
	case ROUND_OFF:
	  break;
	case ROUND_NEAR:
	  xf = incr (xf, xf.l & 4 ? 2 : 1);
	  break;
	}
      xf.l &= 0xfffffffc;
      if (ze >= 1022)
	return fpack (shift_left (xf, 1074 - ze), ze, zs, ROUND_OFF);
      if (xf.l)
	xf.h = 0x3ff00000, xf.l = 0;
      if (zs == '-')
	xf.h |= sign_bit;
      return xf;

/*:87*/
#line 1623 "./mmix-arith.w"
      ;
    }
}

       /*:86*//*88: */
#line 1650 "./mmix-arith.w"

octa fixit ARGS ((octa, int));
octa
fixit (z, r)
     octa z;
     int r;
{
  ftype zt;
  int ze;
  char zs;
  octa zf, o;
  zt = funpack (z, &zf, &ze, &zs);
  if (!r)
    r = cur_round;
  switch (zt)
    {
    case nan:
    case inf:
      exceptions |= I_BIT;
      return z;
    case zro:
      return zero_octa;
    case num:
      if (funpack (fintegerize (z, r), &zf, &ze, &zs) == zro)
	return zero_octa;
      if (ze <= 1076)
	o = shift_right (zf, 1076 - ze, 1);
      else
	{
	  if (ze > 1085 || (ze == 1085 && (zf.h > 0x400000 ||
					   (zf.h == 0x400000
					    && (zf.l || zs != '-')))))
	    exceptions |= W_BIT;
	  if (ze >= 1140)
	    return zero_octa;
	  o = shift_left (zf, ze - 1076);
	}
      return (zs == '-' ? ominus (zero_octa, o) : o);
    }
}

       /*:88*//*89: */
#line 1681 "./mmix-arith.w"

octa floatit ARGS ((octa, int, int, int));
octa
floatit (z, r, u, p)
     octa z;
     int r;
     int u;
     int p;
{
  int e;
  char s;
  register int t;
  exceptions = 0;
  if (!z.h && !z.l)
    return zero_octa;
  if (!r)
    r = cur_round;
  if (!u && (z.h & sign_bit))
    s = '-', z = ominus (zero_octa, z);
  else
    s = '+';
  e = 1076;
  while (z.h < 0x400000)
    e--, z = shift_left (z, 1);
  while (z.h >= 0x800000)
    {
      e++;
      t = z.l & 1;
      z = shift_right (z, 1, 1);
      z.l |= t;
    }
  if (p)			/*90: */
#line 1707 "./mmix-arith.w"

    {
      register int ex;
      register tetra t;
      t = sfpack (z, e, s, r);
      ex = exceptions;
      sfunpack (t, &z, &e, &s);
      exceptions = ex;
    }

/*:90*/
#line 1703 "./mmix-arith.w"
  ;
  return fpack (z, e, s, r);
}

       /*:89*//*91: */
#line 1718 "./mmix-arith.w"

octa froot ARGS ((octa, int));
octa
froot (z, r)
     octa z;
     int r;
{
  ftype zt;
  int ze;
  char zs;
  octa x, xf, rf, zf;
  register int xe, k;
  if (!r)
    r = cur_round;
  zt = funpack (z, &zf, &ze, &zs);
  if (zs == '-' && zt != zro)
    exceptions |= I_BIT, x = standard_NaN;
  else
    switch (zt)
      {
      case nan:
	if (!(z.h & 0x80000))
	  exceptions |= I_BIT, z.h |= 0x80000;
	return z;
      case inf:
      case zro:
	x = z;
	break;
      case num:		/*92: */
#line 1750 "./mmix-arith.w"

	xf.h = 0, xf.l = 2;
	xe = (ze + 0x3fe) >> 1;
	if (ze & 1)
	  zf = shift_left (zf, 1);
	rf.h = 0, rf.l = (zf.h >> 22) - 1;
	for (k = 53; k; k--)
	  {
	    rf = shift_left (rf, 2);
	    xf = shift_left (xf, 1);
	    if (k >= 43)
	      rf = incr (rf, (zf.h >> (2 * (k - 43))) & 3);
	    else if (k >= 27)
	      rf = incr (rf, (zf.l >> (2 * (k - 27))) & 3);
	    if ((rf.l > xf.l && rf.h >= xf.h) || rf.h > xf.h)
	      {
		xf.l++;
		rf = ominus (rf, xf);
		xf.l++;
	      }
	  }
	if (rf.h || rf.l)
	  xf.l++;
	return fpack (xf, xe, '+', r);

/*:92*/
#line 1736 "./mmix-arith.w"
	;
      }
  if (zs == '-')
    x.h |= sign_bit;
  return x;
}

       /*:91*//*93: */
#line 1774 "./mmix-arith.w"

octa fremstep ARGS ((octa, octa, int));
octa
fremstep (y, z, delta)
     octa y, z;
     int delta;
{
  ftype yt, zt;
  int ye, ze;
  char xs, ys, zs;
  octa x, xf, yf, zf;
  register int xe, thresh, odd;
  yt = funpack (y, &yf, &ye, &ys);
  zt = funpack (z, &zf, &ze, &zs);
  switch (4 * yt + zt)
    {
/*42:*/
#line 731 "./mmix-arith.w"

    case 4 * nan + nan:
      if (!(y.h & 0x80000))
	exceptions |= I_BIT;
    case 4 * zro + nan:
    case 4 * num + nan:
    case 4 * inf + nan:
      if (!(z.h & 0x80000))
	exceptions |= I_BIT, z.h |= 0x80000;
      return z;
    case 4 * nan + zro:
    case 4 * nan + num:
    case 4 * nan + inf:
      if (!(y.h & 0x80000))
	exceptions |= I_BIT, y.h |= 0x80000;
      return y;

/*:42*/
#line 1788 "./mmix-arith.w"
      ;
    case 4 * zro + zro:
    case 4 * num + zro:
    case 4 * inf + zro:
    case 4 * inf + num:
    case 4 * inf + inf:
      x = standard_NaN;
      exceptions |= I_BIT;
      break;
    case 4 * zro + num:
    case 4 * zro + inf:
    case 4 * num + inf:
      return y;
    case 4 * num + num:	/*94: */
#line 1809 "./mmix-arith.w"

      odd = 0;
      thresh = ye - delta;
      if (thresh < ze)
	thresh = ze;
      while (ye >= thresh)	/*95: */
#line 1830 "./mmix-arith.w"

	{
	  if (yf.h == zf.h && yf.l == zf.l)
	    goto zero_out;
	  if (yf.h < zf.h || (yf.h == zf.h && yf.l < zf.l))
	    {
	      if (ye == ze)
		goto try_complement;
	      ye--, yf = shift_left (yf, 1);
	    }
	  yf = ominus (yf, zf);
	  if (ye == ze)
	    odd = 1;
	  while (yf.h < 0x400000)
	    ye--, yf = shift_left (yf, 1);
	}

/*:95*/
#line 1815 "./mmix-arith.w"
      ;
      if (ye >= ze)
	{
	  exceptions |= E_BIT;
	  return fpack (yf, ye, ys, ROUND_OFF);
	}
      if (ye < ze - 1)
	return fpack (yf, ye, ys, ROUND_OFF);
      yf = shift_right (yf, 1, 1);
    try_complement:xf = ominus (zf, yf), xe = ze, xs = '+' + '-' - ys;
      if (xf.h > yf.h
	  || (xf.h == yf.h && (xf.l > yf.l || (xf.l == yf.l && !odd))))
	xf = yf, xs = ys;
      while (xf.h < 0x400000)
	xe--, xf = shift_left (xf, 1);
      return fpack (xf, xe, xs, ROUND_OFF);

/*:94*/
#line 1793 "./mmix-arith.w"
      ;
    zero_out:x = zero_octa;
    }
  if (ys == '-')
    x.h |= sign_bit;
  return x;
}

/*:93*/
#line 41 "./mmix-arith.w"


/*:1*/
