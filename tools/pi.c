/*Calculate the value of PI.  Takes a long time!*/
#ifndef WIN32
int putchar(char ch)
{
   *(int*)0x20000000 = ch;
   return 0;
}

void OS_InterruptServiceRoutine(unsigned int status)
{
   (void)status;
}
#endif

void print_num(unsigned long num)
{
   unsigned long digit,offset;
   for(offset=1000;offset;offset/=10) {
      digit=num/offset;
      putchar(digit+'0');
      num-=digit*offset;
   }
}

long a=10000,b,c=56,d,e,f[57],g;
int main()
{
   long a5=a/5;
   for(;b-c;) f[b++]=a5;
   for(;d=0,g=c*2;c-=14,print_num(e+d/a),e=d%a)for(b=c;d+=f[b]*a,
     f[b]=d%--g,d/=g--,--b;d*=b);
   putchar('\n');
   return 0;
}

