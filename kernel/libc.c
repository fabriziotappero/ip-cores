/*--------------------------------------------------------------------
 * TITLE: ANSI C Library
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 12/17/05
 * FILENAME: libc.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Subset of the ANSI C library
 *--------------------------------------------------------------------*/
#define NO_ELLIPSIS
#include "rtos.h"

char *strcpy(char *dst, const char *src)
{
   char *dstSave=dst;
   int c;
   do
   {
      c = *dst++ = *src++;
   } while(c);
   return dstSave;
}


char *strncpy(char *dst, const char *src, int count)
{
   int c=1;
   char *dstSave=dst;
   while(count-- > 0 && c)
      c = *dst++ = *src++;
   *dst = 0;
   return dstSave;
}


char *strcat(char *dst, const char *src)
{
   int c;
   char *dstSave=dst;
   while(*dst)
      ++dst;
   do
   {
      c = *dst++ = *src++;
   } while(c);
   return dstSave;
}


char *strncat(char *dst, const char *src, int count)
{
   int c=1;
   char *dstSave=dst;
   while(*dst)
      ++dst;
   while(--count >= 0 && c)
      c = *dst++ = *src++;
   *dst = 0;
   return dstSave;
}

#ifdef STRNCAT_SIZE
char *strncat_size(char *dst, const char *src, int sizeDst)
{
   int c=1;
   char *dstSave=dst;
   while(*dst)
      ++dst;
   sizeDst -= dst - dstSave;
   while(--sizeDst > 0 && c)
      c = *dst++ = *src++;
   *dst = 0;
   return dstSave;
}
#endif

int strcmp(const char *string1, const char *string2)
{
   int diff, c;
   for(;;)
   {
      diff = *string1++ - (c = *string2++);
      if(diff)
         return diff;
      if(c == 0)
         return 0;
   }
}


int strncmp(const char *string1, const char *string2, int count)
{
   int diff, c;
   while(count-- > 0)
   {
      diff = *string1++ - (c = *string2++);
      if(diff)
         return diff;
      if(c == 0)
         return 0;
   }
   return 0;
}


char *strstr(const char *string, const char *find)
{
   int i;
   for(;;)
   {
      for(i = 0; string[i] == find[i] && find[i]; ++i) ;
      if(find[i] == 0)
         return (char*)string;
      if(*string++ == 0)
         return NULL;
   }
}


int strlen(const char *string)
{
   const char *base=string;
   while(*string++) ;
   return string - base - 1;
}


void *memcpy(void *dst, const void *src, unsigned long bytes)
{
   if(((uint32)dst | (uint32)src | bytes) & 3)
   {
      uint8 *Dst = (uint8*)dst, *Src = (uint8*)src;
      while((int)bytes-- > 0)
         *Dst++ = *Src++;
   }
   else
   {
      uint32 *Dst32 = (uint32*)dst, *Src32 = (uint32*)src;
      bytes >>= 2;
      while((int)bytes-- > 0)
         *Dst32++ = *Src32++;
   }
   return dst;
}


void *memmove(void *dst, const void *src, unsigned long bytes)
{
   uint8 *Dst = (uint8*)dst;
   uint8 *Src = (uint8*)src;
   if(Dst < Src)
   {
      while((int)bytes-- > 0)
         *Dst++ = *Src++;
   }
   else
   {
      Dst += bytes;
      Src += bytes;
      while((int)bytes-- > 0)
         *--Dst = *--Src;
   }
   return dst;
}


int memcmp(const void *cs, const void *ct, unsigned long bytes)
{
   uint8 *Dst = (uint8*)cs;
   uint8 *Src = (uint8*)ct;
   int diff;
   while((int)bytes-- > 0)
   {
      diff = *Dst++ - *Src++;
      if(diff)
         return diff;
   }
   return 0;
}


void *memset(void *dst, int c, unsigned long bytes)
{
   uint8 *Dst = (uint8*)dst;
   while((int)bytes-- > 0)
      *Dst++ = (uint8)c;
   return dst;
}


int abs(int n)
{
   return n>=0 ? n : -n;
}


static uint32 Rand1=0x1f2bcda3;
int rand(void)
{
   Rand1 = 1664525 * Rand1 + 1013904223;  //from D.E. Knuth and H.W. Lewis
   return Rand1 << 16 | Rand1 >> 16;
}


void srand(unsigned int seed)
{
   Rand1 = seed;
}


long strtol(const char *s, char **end, int base)
{
   int i;
   unsigned long ch, value=0, neg=0;

   if(s[0] == '-')
   {
      neg = 1;
      ++s;
   }
   if(s[0] == '0' && s[1] == 'x')
   {
      base = 16;
      s += 2;
   }
   for(i = 0; i <= 8; ++i)
   {
      ch = *s++;
      if('0' <= ch && ch <= '9')
         ch -= '0';
      else if('A' <= ch && ch < base - 10 + 'A')
         ch = ch - 'A' + 10;
      else if('a' <= ch && ch < base - 10 + 'a')
         ch = ch - 'a' + 10;
      else
         break;
      value = value * base + ch;
   }
   if(end)
      *end = (char*)s - 1;
   if(neg)
      value = -(int)value;
   return value;
}


int atoi(const char *s)
{
   return strtol(s, NULL, 10);
}


char *itoa(int num, char *dst, int base)
{
   int digit, negate=0, place;
   char c, text[20];

   if(base == 10 && num < 0)
   {
      num = -num;
      negate = 1;
   }
   text[16] = 0;
   for(place = 15; place > 0; --place)
   {
      digit = (unsigned int)num % (unsigned int)base;
      if(num == 0 && place < 15 && base == 10 && negate)
      {
         c = '-';
         negate = 0;
      }
      else if(digit < 10)
         c = (char)('0' + digit);
      else
         c = (char)('a' + digit - 10);
      text[place] = c;
      num = (unsigned int)num / (unsigned int)base;
      if(num == 0 && negate == 0)
         break;
   }
   strcpy(dst, text + place);
   return dst;
}


int sprintf(char *s, const char *format, 
            int arg0, int arg1, int arg2, int arg3,
            int arg4, int arg5, int arg6, int arg7)
{
   int argv[8];
   int argc=0, width, length;
   char f=0, prev, text[20], fill;

   argv[0] = arg0; argv[1] = arg1; argv[2] = arg2; argv[3] = arg3;
   argv[4] = arg4; argv[5] = arg5; argv[6] = arg6; argv[7] = arg7;

   for(;;)
   {
      prev = f;
      f = *format++;
      if(f == 0)
         return argc;
      else if(f == '%')
      {
         width = 0;
         fill = ' ';
         f = *format++;
         while('0' <= f && f <= '9')
         {
            width = width * 10 + f - '0';
            f = *format++;
         }
         if(f == '.')
         {
            fill = '0';
            f = *format++;
         }
         if(f == 0)
            return argc;

         if(f == 'd')
         {
            memset(s, fill, width);
            itoa(argv[argc++], text, 10);
            length = (int)strlen(text);
            if(width < length)
               width = length;
            strcpy(s + width - length, text);
         }
         else if(f == 'x' || f == 'f')
         {
            memset(s, '0', width);
            itoa(argv[argc++], text, 16);
            length = (int)strlen(text);
            if(width < length)
               width = length;
            strcpy(s + width - length, text);
         }
         else if(f == 'c')
         {
            *s++ = (char)argv[argc++];
            *s = 0;
         }
         else if(f == 's')
         {
            length = strlen((char*)argv[argc]);
            if(width > length)
            {
               memset(s, ' ', width - length);
               s += width - length;
            }
            strcpy(s, (char*)argv[argc++]);
         }
         s += strlen(s);
      }
      else
      {
         if(f == '\n' && prev != '\r')
            *s++ = '\r';
         *s++ = f;
      }
      *s = 0;
   }
}


int sscanf(const char *s, const char *format,
           int arg0, int arg1, int arg2, int arg3,
           int arg4, int arg5, int arg6, int arg7)
{
   int argv[8];
   int argc=0;
   char f, *ptr;

   argv[0] = arg0; argv[1] = arg1; argv[2] = arg2; argv[3] = arg3;
   argv[4] = arg4; argv[5] = arg5; argv[6] = arg6; argv[7] = arg7;

   for(;;)
   {
      if(*s == 0)
         return argc;
      f = *format++;
      if(f == 0)
         return argc;
      else if(f == '%')
      {
         while(isspace(*s))
            ++s;
         f = *format++;
         if(f == 0)
            return argc;
         if(f == 'd')
            *(int*)argv[argc++] = strtol(s, (char**)&s, 10);
         else if(f == 'x')
            *(int*)argv[argc++] = strtol(s, (char**)&s, 16);
         else if(f == 'c')
            *(char*)argv[argc++] = *s++;
         else if(f == 's')
         {
            ptr = (char*)argv[argc++];
            while(!isspace(*s))
               *ptr++ = *s++;
            *ptr = 0;
         }
      }
      else 
      {
         while(*s && *s != f)
            ++s;
         if(*s)
            ++s;
      }
   }
}


#ifdef INCLUDE_DUMP
/*********************** dump ***********************/
void dump(const unsigned char *data, int length)
{
   int i, index=0, value;
   char string[80];
   memset(string, 0, sizeof(string));
   for(i = 0; i < length; ++i)
   {
      if((i & 15) == 0)
      {
         if(strlen(string))
            printf("%s\n", string);
         printf("%4x ", i);
         memset(string, 0, sizeof(string));
         index = 0;
      }
      value = data[i];
      printf("%2x ", value);
      if(isprint(value))
         string[index] = (char)value;
      else
         string[index] = '.';
      ++index;
   }
   for(; index < 16; ++index)
      printf("   ");
   printf("%s\n", string);
}
#endif //INCLUDE_DUMP


#ifdef INCLUDE_QSORT
/*********************** qsort ***********************/
static void QsortSwap(char *base, long left, long right, long size)
{
   int temp, i;
   char *ptrLeft, *ptrRight;
   ptrLeft = base + left * size;
   ptrRight = base + right * size;
   for(i = 0; i < size; ++i)
   {
      temp = ptrLeft[i];
      ptrLeft[i] = ptrRight[i];
      ptrRight[i] = (char)temp;
   }
}


//Modified from K&R
static void qsort2(void *base, long left, long right, long size,
      int (*cmp)(const void *,const void *))
{
   int i, last;
   char *base2=(char*)base, *pivot;
   if(left >= right) 
      return;
   QsortSwap(base2, left, (left + right)/2, size);
   last = left;
   pivot = &base2[left*size];
   for(i = left + 1; i <= right; ++i) 
   {
      if(cmp(&base2[i*size], pivot) < 0) 
         QsortSwap(base2, ++last, i, size);
   }
   QsortSwap(base2, left, last, size);
   qsort2(base, left, last-1, size, cmp);
   qsort2(base, last+1, right, size, cmp);
}


void qsort(void *base, 
           long n, 
           long size, 
           int (*cmp)(const void *,const void *))
{ 
   qsort2(base, 0, n-1, size, cmp); 
}


void *bsearch(const void *key,
              const void *base,
              long n,
              long size,
              int (*cmp)(const void *,const void *))
{
   long cond, low=0, high=n-1, mid;
   char *base2=(char*)base;
   while(low <= high) 
   {
      mid = (low + high)/2;
      cond = cmp(key, &base2[mid*size]);
      if(cond < 0) 
         high = mid - 1;
      else if(cond > 0) 
         low = mid + 1;
      else 
         return &base2[mid * size];
   }
   return NULL;
}
#endif //INCLUDE_QSORT


#ifdef INCLUDE_TIMELIB
/************************* time.h ***********************/
#define SEC_PER_YEAR (365L*24*60*60)
#define SEC_PER_DAY (24L*60*60)
//typedef unsigned long time_t;  //start at 1/1/80
//struct tm {
//   int tm_sec;      //(0,59)
//   int tm_min;      //(0,59)
//   int tm_hour;     //(0,23)
//   int tm_mday;     //(1,31)
//   int tm_mon;      //(0,11)
//   int tm_year;     //(0,n) from 1900
//   int tm_wday;     //(0,6)     calculated
//   int tm_yday;     //(0,365)   calculated
//   int tm_isdst;    //hour adjusted for day light savings
//};
static const unsigned short DaysUntilMonth[]=
   {0,31,59,90,120,151,181,212,243,273,304,334,365}; 
static const unsigned short DaysInMonth[]=
   {31,28,31,30,31,30,31,31,30,31,30,31};
static time_t DstTimeIn, DstTimeOut;


/* Leap year if divisible by 4.  Centenary years should only be 
   leap-years if they were divisible by 400. */
static int IsLeapYear(int year)
{
   return(((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0));
}

time_t mktime(struct tm *tp)
{
   time_t seconds;
   unsigned long days, y, year;

   days = tp->tm_mday - 1 + DaysUntilMonth[tp->tm_mon] + 
      365 * (tp->tm_year - 80);
   seconds = (unsigned long)tp->tm_sec + 60L * (tp->tm_min + 
      60L * (tp->tm_hour + 24L * days));
   if(tp->tm_isdst)
      seconds -= 60 * 60;
   year = 1900 + tp->tm_year - (tp->tm_mon < 2);
   for(y = 1980; y <= year; y += 4)
   {
      if(y % 100 != 0 || y % 400 == 0)
         seconds += SEC_PER_DAY;
   }
   return seconds;
}


void gmtime_r(const time_t *tp, struct tm *out)
{
   time_t seconds, delta, secondsIn=*tp;
   int isLeapYear; 
   unsigned long year, month;

   out->tm_isdst = 0;
   if(DstTimeIn <= secondsIn && secondsIn < DstTimeOut)
   {
      secondsIn += 60 * 60;
      out->tm_isdst = 1;
   }
   seconds = secondsIn;
   for(year = 0; ; ++year) 
   {
      delta = SEC_PER_YEAR + IsLeapYear(1980 + year) * SEC_PER_DAY;
      if(seconds >= delta) 
         seconds -= delta;
      else 
         break;
   }
   out->tm_year = year + 80;
   out->tm_yday = seconds / SEC_PER_DAY;
   isLeapYear = IsLeapYear(1980 + year);
   for(month = 0; ; ++month) 
   {
      delta = SEC_PER_DAY * (DaysInMonth[month] + (isLeapYear && (month == 1)));
      if(seconds >= delta) 
         seconds -= delta;
      else 
         break;
   }
   out->tm_mon = month;
   out->tm_mday = seconds / SEC_PER_DAY;
   seconds -= out->tm_mday * SEC_PER_DAY;
   ++out->tm_mday;
   out->tm_hour = seconds / (60 * 60);
   seconds -= out->tm_hour * (60 * 60);
   out->tm_min = seconds / 60;
   seconds -= out->tm_min * 60;
   out->tm_sec = seconds;
   seconds = secondsIn % (SEC_PER_DAY * 7);
   out->tm_wday = (seconds / SEC_PER_DAY + 2) % 7; /* 1/1/80 is a Tue */
   //printf("%4.d/%2.d/%2.d:%2.d:%2.d:%2.d\n", 
   //         out->tm_year+1900, out->tm_mon+1, out->tm_mday,
   //         out->tm_hour, out->tm_min, out->tm_sec);
}


void gmtimeDst(time_t dstTimeIn, time_t dstTimeOut)
{
   DstTimeIn = dstTimeIn;
   DstTimeOut = dstTimeOut;
}


//DST from 2am on the second Sunday in March to 2am first Sunday in November
void gmtimeDstSet(time_t *tp, time_t *dstTimeIn, time_t *dstTimeOut)
{
   time_t seconds, timeIn, timeOut;
   struct tm tmDate;
   int year, days;

   DstTimeIn = 0;
   DstTimeOut = 0;
   gmtime_r(tp, &tmDate);
   year = tmDate.tm_year;

   //March 1, year, 2AM -> second Sunday
   tmDate.tm_year = year;
   tmDate.tm_mon = 2;
   tmDate.tm_mday = 1;
   tmDate.tm_hour = 2;
   tmDate.tm_min = 0;
   tmDate.tm_sec = 0;
   seconds = mktime(&tmDate);
   gmtime_r(&seconds, &tmDate);
   days = 7 - tmDate.tm_wday + 7;
   *dstTimeIn = timeIn = seconds + days * SEC_PER_DAY;

   //November 1, year, 2AM -> first Sunday
   tmDate.tm_year = year;
   tmDate.tm_mon = 10;
   tmDate.tm_mday = 1;
   tmDate.tm_hour = 2;
   tmDate.tm_min = 0;
   tmDate.tm_sec = 0;
   seconds = mktime(&tmDate);
   gmtime_r(&seconds, &tmDate);
   days = 7 - tmDate.tm_wday;
   *dstTimeOut = timeOut = seconds + days * SEC_PER_DAY;

   DstTimeIn = timeIn;
   DstTimeOut = timeOut;
}
#endif //INCLUDE_TIMELIB

