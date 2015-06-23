/*count.c*/
int putchar(int value);
int puts(const char *string);

char *name[] = {
   "", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
   "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen",
   "sixteen", "seventeen", "eighteen", "nineteen",
   "", "ten", "twenty", "thirty", "forty", "fifty", "sixty", "seventy",
   "eighty", "ninety"
};

char *xtoa(unsigned long num)
{
   static char buf[12];
   int i, digit;
   buf[8] = 0;
   for (i = 7; i >= 0; --i)
   {
      digit = num & 0xf;
      buf[i] = digit + (digit < 10 ? '0' : 'A' - 10);
      num >>= 4;
   }
   return buf;
}

char *itoa10(unsigned long num)
{
   static char buf[12];
   int i;
   buf[10] = 0;
   for (i = 9; i >= 0; --i)
   {
      buf[i] = (char)((num % 10) + '0');
      num /= 10;
   }
   return buf;
}

void number_text(unsigned long number)
{
   int digit;
   puts(itoa10(number));
   puts(": ");
   if(number >= 1000000000)
   {
      digit = number / 1000000000;
      puts(name[digit]);
      puts(" billion ");
      number %= 1000000000;
   }
   if(number >= 100000000)
   {
      digit = number / 100000000;
      puts(name[digit]);
      puts(" hundred ");
      number %= 100000000;
      if(number < 1000000)
      {
         puts("million ");
      }
   }
   if(number >= 20000000)
   {
      digit = number / 10000000;
      puts(name[digit + 20]);
      putchar(' ');
      number %= 10000000;
      if(number < 1000000)
      {
         puts("million ");
      }
   }
   if(number >= 1000000)
   {
      digit = number / 1000000;
      puts(name[digit]);
      puts(" million ");
      number %= 1000000;
   }
   if(number >= 100000)
   {
      digit = number / 100000;
      puts(name[digit]);
      puts(" hundred ");
      number %= 100000;
      if(number < 1000)
      {
         puts("thousand ");
      }
   }
   if(number >= 20000)
   {
      digit = number / 10000;
      puts(name[digit + 20]);
      putchar(' ');
      number %= 10000;
      if(number < 1000)
      {
         puts("thousand ");
      }
   }
   if(number >= 1000)
   {
      digit = number / 1000;
      puts(name[digit]);
      puts(" thousand ");
      number %= 1000;
   }
   if(number >= 100)
   {
      digit = number / 100;
      puts(name[digit]);
      puts(" hundred ");
      number %= 100;
   }
   if(number >= 20)
   {
      digit = number / 10;
      puts(name[digit + 20]);
      putchar(' ');
      number %= 10;
   }
   puts(name[number]);
   putchar ('\r');
   putchar ('\n');
}


int main()
{
   unsigned long number, i=0;

   number = 3;
   for(i = 0;; ++i)
   {
      number_text(number);
      number *= 3;
      //++number;
   }
}

