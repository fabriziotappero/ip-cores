
/*!
 ************************************************************************
 *  \file
 *     ifunctions.h
 *
 *  \brief
 *     define some inline functions that are used within the encoder.
 *
 *  \author
 *      Main contributors (see contributors.h for copyright, address and affiliation details)
 *      - Karsten Sühring                 <suehring@hhi.de>
 *      - Alexis Tourapis                 <alexismt@ieee.org>
 *
 ************************************************************************
 */

#ifndef _IFUNCTIONS_H_
#define _IFUNCTIONS_H_

# if defined(WIN32) || (__STDC_VERSION__ >= 199901L)
static inline int imin(int a, int b)
{
  return ((a) < (b)) ? (a) : (b);
}

static inline int imax(int a, int b)
{
  return ((a) > (b)) ? (a) : (b);
}

static inline double dmin(double a, double b)
{
  return ((a) < (b)) ? (a) : (b);
}

static inline double dmax(double a, double b)
{
  return ((a) > (b)) ? (a) : (b);
}

static inline int64 i64min(int64 a, int64 b)
{
  return ((a) < (b)) ? (a) : (b);
}

static inline int64 i64max(int64 a, int64 b)
{
  return ((a) > (b)) ? (a) : (b);
}

static inline int iabs(int x)
{
  return ((x) < 0) ? -(x) : (x);
}

static inline double dabs(double x)
{
  return ((x) < 0) ? -(x) : (x);
}

static inline int isign(int x)
{
  return ((x) < 0) ? -1 : 1;
}

static inline int isignab(int a, int b)
{
  return ((b) < 0) ? -iabs(a) : iabs(a);
}

static inline int rshift_rnd(int x, int a)
{
  return (a > 0) ? ((x + (1 << (a-1) )) >> a) : (x << (-a));
}

static inline unsigned int rshift_rnd_us(unsigned int x, unsigned int a)
{
  return (a > 0) ? ((x + (1 << (a-1))) >> a) : x;
}

static inline int rshift_rnd_sf(int x, int a)
{
  return ((x + (1 << (a-1) )) >> a);
}

static inline unsigned int rshift_rnd_us_sf(unsigned int x, unsigned int a)
{
  return ((x + (1 << (a-1))) >> a);
}

static inline int iClip1(int high, int x)
{
  x = imax(x, 0);
  x = imin(x, high);

  return x;
}

static inline int iClip3(int low, int high, int x)
{
  x = imax(x, low);
  x = imin(x, high);

  return x;
}

static inline double dClip3(double low, double high, double x)
{
  x = dmax(x, low);
  x = dmin(x, high);

  return x;
}

static inline int RSD(int x)
{
 return ((x&2)?(x|1):(x&(~1)));
}

# else

#  define imin(a, b)                  (((a) < (b)) ? (a) : (b))
#  define imax(a, b)                  (((a) > (b)) ? (a) : (b))
#  define dmin(a, b)                  (((a) < (b)) ? (a) : (b))
#  define dmax(a, b)                  (((a) > (b)) ? (a) : (b))
#  define i64min(a, b)                (((a) < (b)) ? (a) : (b))
#  define i64max(a, b)                (((a) > (b)) ? (a) : (b))
#  define iabs(x)                     (((x) < 0)   ? -(x) : (x))
#  define dabs(x)                     (((x) < 0)   ? -(x) : (x))
#  define isign(x)                    (((x) < 0)   ? -1 : 1)
#  define isignab(a, b)               (((b) < 0)   ? -iabs(a) : iabs(a))
#  define rshift_rnd(x, a)            (((a) > 0)   ? (((x) + (1 << ((a)-1))) >> (a)) : ((x) << (-(a)))
#  define rshift_rnd_us(x, a)         (((a) > 0)   ? (((x) + (1 << ((a)-1))) >> (a)) : (x))
#  define rshift_rnd_sf(x, a)         (((x) + (1 << ((a)-1))) >> (a))
#  define rshift_rnd_us_sf(x, a)      (((x) + (1 << ((a)-1))) >> (a))
#  define iClip1(high, x)             (imax( imin(x, high), 0))
#  define iClip3(low, high, x)        (imax( imin(x, high), low))
#  define dClip3(low, high, x)        (dmax( dmin(x, high), low))
#  define RSD(x)                      (((x)&2)?((x)|1):((x)&(~1)))

# endif
#endif

