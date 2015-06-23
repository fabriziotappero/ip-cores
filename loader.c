// LOADER
//-----------------------------------------------------------------------------
int getchr()
{
   while (! (ASM(" IN   (IN_STATUS), RU") & 0x01))   /* wait */ ;
   ASM("IN   (IN_RX_DATA), RU");
}
//-----------------------------------------------------------------------------
void putchr(char c)
{
   while (ASM(" IN (IN_STATUS), RU") & 0x02)   /* wait */ ;
   ASM(" MOVE 2(SP), RU");
   ASM(" OUT  R, (OUT_TX_DATA)");
}
//-----------------------------------------------------------------------------
void print_string(const char * buffer)
{
    while (*buffer)   putchr(*buffer++);
}
//-----------------------------------------------------------------------------
unsigned char get_nibble()
{
unsigned char c  = getchr();

   if (c <  '0') return 0xFF;
   if (c <= '9') return  c - '0';
   if (c <  'A') return 0xFF;
   if (c <= 'F') return  c - 0x37;
   if (c <  'a') return 0xFF;
   if (c <= 'f') return  c - 0x57;
   return 0xFF;
}
//-----------------------------------------------------------------------------
int get_byte()
{
unsigned char hi = get_nibble();
unsigned char lo;

   if (hi != 0xFF)
      {
        lo = get_nibble();
        if (lo != 0xFF)   return (hi << 4) | lo;
      }

   print_string("\r\nERROR: not hex\r\n");
   ASM(" HALT");
}
//-----------------------------------------------------------------------------
int main(int argc, char * argv[])
{
unsigned char record_length;
unsigned int  address;
unsigned char record_type;
unsigned char check_sum;
unsigned char  i;
unsigned char c;

   for (;;)
       {
         print_string("\r\nLOAD > ");
         for (;;)
            {
              // wait for start of record...
              while ((c = getchr()) != ':')   ;
              check_sum = 0;

              c = get_byte();   check_sum += c;   record_length = c;
              c = get_byte();   check_sum += c;   address       = c << 8;
              c = get_byte();   check_sum += c;   address      |= c;
              c = get_byte();   check_sum += c;   record_type   = c;

              for (i = 0; i < record_length; i++)
                  {
                    c = get_byte();
                    ((char *)address)[i] = c;
                    check_sum += c;
                  }

              c = get_byte();   check_sum += c;
	      if (check_sum)   break;
	      putchr('.');

              if (record_type == 1)
                 {
                   print_string("\r\nDONE.\r\n");
                   ((void (*)())address)();
                 }
            }

         print_string("\r\nCHECKSUM ERROR.");
       }
}
//-----------------------------------------------------------------------------
