/*******************************************************************************
********************************************************************************
**                                                                            **
**                     INTERRUPT HANDLING                                     **
**                                                                            **
********************************************************************************
*******************************************************************************/

unsigned char serial_in_buffer[16];
unsigned char serial_in_get      = 0;
unsigned char serial_in_put      = 0;
unsigned char serial_in_length   = 0;
unsigned char serial_in_overflow = 0;

void rx_interrupt()
{
char c = ASM(" IN   (IN_RX_DATA), RU");

   if (serial_in_length < sizeof(serial_in_buffer))
      {
        serial_in_buffer[serial_in_put] = c;
        serial_in_put = ++serial_in_put & 15;
        ++serial_in_length;
      }
   else
      {
        serial_in_overflow = 0xFF;
      }
}
//-----------------------------------------------------------------------------

unsigned char serial_out_buffer[16];
unsigned char serial_out_get      = 0;
unsigned char serial_out_put      = 0;
unsigned char serial_out_length   = 0;

void tx_interrupt()
{
   if (serial_out_length)
      {
        serial_out_buffer[serial_out_get];
        ASM(" OUT  R, (OUT_TX_DATA)");
        serial_out_get = ++serial_out_get & 15;
        --serial_out_length;
      }
   else
      {
        ASM(" MOVE #0x05, RR");            // RxInt and TimerInt
        ASM(" OUT  R, (OUT_INT_MASK)");
      }
}

//-----------------------------------------------------------------------------

unsigned int  milliseconds    = 0;
unsigned int  seconds_low     = 0;
unsigned int  seconds_mid     = 0;
unsigned int  seconds_high    = 0;
unsigned char seconds_changed = 0;

void timer_interrupt()
{
   ASM(" OUT  R, (OUT_RESET_TIMER)");
   if (++milliseconds == 1000)
      {
         milliseconds = 0;
         seconds_changed = 0xFF;
         if (++seconds_low == 0)
            {
              if (++seconds_mid == 0)   ++seconds_high;
            }
      }
}
//-----------------------------------------------------------------------------
void interrupt()
{
   ASM(" MOVE RR, -(SP)");
   ASM(" MOVE LL, RR");
   ASM(" MOVE RR, -(SP)");

   if (ASM(" IN   (IN_STATUS), RU") & 0x10)   rx_interrupt();
   if (ASM(" IN   (IN_STATUS), RU") & 0x20)   tx_interrupt();
   if (ASM(" IN   (IN_STATUS), RU") & 0x40)   timer_interrupt();

   ASM(" MOVE (SP)+, RR");
   ASM(" MOVE RR, LL");
   ASM(" MOVE (SP)+, RR");
   ASM(" RETI");
}
/*******************************************************************************
********************************************************************************
**                                                                            **
**                     UTILITY FUNCTIONS                                      **
**                                                                            **
********************************************************************************
*******************************************************************************/

int strlen(const char * buffer)
{
const char * from = buffer;

    while (*buffer)   buffer++;

   return buffer - from;
}
/*******************************************************************************
********************************************************************************
**                                                                            **
**                     SERIAL OUTPUT                                          **
**                                                                            **
********************************************************************************
*******************************************************************************/

int putchr(char c)
{
   while (serial_out_length == sizeof(serial_out_buffer))   /* wait */ ;

   serial_out_buffer[serial_out_put] = c;
   serial_out_put = ++serial_out_put & 15;
   ASM(" DI");   ++serial_out_length;   ASM(" EI");
   ASM(" MOVE #0x07, RR");            // RxInt and TxInt and TimerInt
   ASM(" OUT  R, (OUT_INT_MASK)");
   1;
}
//-----------------------------------------------------------------------------
void print_string(const char * buffer)
{
    while (*buffer)   putchr(*buffer++);
}
//-----------------------------------------------------------------------------
void print_hex(char * dest, unsigned int value, const char * hex)
{
   if (value >= 0x1000)   *dest++ = hex[(value >> 12) & 0x0F];
   if (value >=  0x100)   *dest++ = hex[(value >>  8) & 0x0F];
   if (value >=   0x10)   *dest++ = hex[(value >>  4) & 0x0F];
   *dest++ = hex[value  & 0x0F];
   *dest = 0;
}
//-----------------------------------------------------------------------------
void print_unsigned(char * dest, unsigned int value)
{
   if (value >= 10000)   { *dest++ = '0' + value / 10000;   value %= 10000; }
   if (value >=  1000)   { *dest++ = '0' + value /  1000;   value %=  1000; }
   if (value >=   100)   { *dest++ = '0' + value /   100;   value %=   100; }
   if (value >=    10)   { *dest++ = '0' + value /    10;   value %=    10; }
   *dest++ = '0' + value;
   *dest = 0;
}
//-----------------------------------------------------------------------------
int print_item(const char * buffer, char flags, char sign, char pad,
               const char * alt, int field_w, int min_w, char min_p)
{
   // [fill] [sign] [alt] [pad] [buffer] [fill]
   //        ----------- len ----------- 
int filllen = 0;
int signlen = 0;
int altlen  = 0;
int padlen  = 0;
int buflen  = strlen(buffer);
int len;
int i;

   if (min_w > buflen)          padlen = min_w - buflen;
   if (sign)                    signlen = 1;
   if (alt && (flags & 0x01))   altlen = strlen(alt);

   len = signlen + altlen + padlen + buflen;

   if (0x02 & ~flags)   // right align
      {
        for (i = len; i < field_w; i++)   putchr(pad);
      }

   if (sign)   putchr(sign);
   if (alt)
      {
        if (flags & 0x01)   print_string(alt);
      }

   for (i = 0; i < padlen; i++)   putchr(min_p);
   print_string(buffer);

   if (0x02 & flags)   // left align
      {
        for (i = len; i < field_w; i++)   putchr(pad);
      }

   return len;
}
//-----------------------------------------------------------------------------
int printf(const char * format, ...)
{
const char **  args = 1 + &format;
int            len = 0;
char           c;
char           flags;
char           sign;
char           pad;
const char *   alt;
int            field_w;
int            min_w;
unsigned int * which_w;
char           buffer[12];

   while (c = *format++)
       {
         if (c != '%')   { len +=putchr(c);   continue; }

         flags   = 0;
         sign    = 0;
         pad     = ' ';
         field_w = 0;
         min_w   = 0;
         which_w = &field_w;
         for (;;)
             {
               switch(c = *format++)
                  {
                    case 'X': print_hex(buffer, (unsigned int)*args++,
                                        "0123456789ABCDEF");
                              len += print_item(buffer, flags, sign, pad,
                                                "0X", field_w, min_w, '0');
                              break;

                    case 'd': if (((int)*args) < 0)
                                 {
                                   sign = '-';
                                   *args = (char *)(- ((int)*args));
                                 }
                              print_unsigned(buffer, (unsigned int)*args++);
                              len += print_item(buffer, flags, sign, pad,
                                                "", field_w, min_w, '0');
                              break;

                    case 's': len += print_item(*args++, flags & 0x02, 0, ' ',
                                                "", field_w, min_w, ' ');
                              break;

                    case 'u': print_unsigned(buffer, (unsigned int)*args++);
                              len += print_item(buffer, flags, sign, pad,
                                                "", field_w, min_w, '0');
                              break;

                    case 'x': print_hex(buffer, (unsigned int)*args++,
                                        "0123456789abcdef");
                              len += print_item(buffer, flags, sign, pad,
                                                "0x", field_w, min_w, '0');
                              break;

                    case 'c': len += putchr((int)*args++);    break;

                    case '#': flags |= 0x01;                  continue;
                    case '-': flags |= 0x02;                  continue;
                    case ' ': if (!sign)  sign = ' ';         continue;
                    case '+': sign = '+';                     continue;
                    case '.': which_w = &min_w;               continue;

                    case '0': if (*which_w)   *which_w *= 10;
                              else            pad = '0';
                              continue;

                    case '1': *which_w = 10 * *which_w + 1;   continue;
                    case '2': *which_w = 10 * *which_w + 2;   continue;
                    case '3': *which_w = 10 * *which_w + 3;   continue;
                    case '4': *which_w = 10 * *which_w + 4;   continue;
                    case '5': *which_w = 10 * *which_w + 5;   continue;
                    case '6': *which_w = 10 * *which_w + 6;   continue;
                    case '7': *which_w = 10 * *which_w + 7;   continue;
                    case '8': *which_w = 10 * *which_w + 8;   continue;
                    case '9': *which_w = 10 * *which_w + 9;   continue;
                    case '*': *which_w = (int)*args++;        continue;

                    case 0:   format--;   // premature end of format
                              break;

                    default:  len += putchr(c);
                              break;
                  }
                break;
             }
       }
   return len;
}
/*******************************************************************************
********************************************************************************
**                                                                            **
**                     SERIAL INPUT                                           **
**                                                                            **
********************************************************************************
*******************************************************************************/

int getchr()
{
char c;

   while (! serial_in_length)   /* wait */ ;
   c = serial_in_buffer[serial_in_get];
   serial_in_get = ++serial_in_get & 15;
   ASM(" DI");   --serial_in_length;   ASM(" EI");
   return c;
}
//-----------------------------------------------------------------------------
int peekchr()
{
   while (! serial_in_length)   /* wait */ ;
   return serial_in_buffer[serial_in_get];
}
//-----------------------------------------------------------------------------
char getnibble(char echo)
{
char c  = peekchr();
int ret = -1;

   if      ((c >= '0') && (c <= '9'))   ret = c - '0';
   else if ((c >= 'A') && (c <= 'F'))   ret = c - 0x37;
   else if ((c >= 'a') && (c <= 'f'))   ret = c - 0x57;

   if (ret != -1)   // valid hex char
      {
        getchr();
        if (echo)   putchr(c);
      }
   return ret;
}
//-----------------------------------------------------------------------------
int gethex(char echo)
{
int  ret = 0;
char c;

   while ((c = getnibble(echo)) != -1)   ret = (ret << 4) | c;
   return ret;
}
/*******************************************************************************
********************************************************************************
**                                                                            **
**                     main and its helpers                                   **
**                                                                            **
********************************************************************************
*******************************************************************************/

void show_time()
{
unsigned int sl;
unsigned int sm;
unsigned int sh;

   do {
        seconds_changed = 0;
        sl = seconds_low;
        sm = seconds_mid;
        sh = seconds_high;
      } while (seconds_changed);

   printf("Uptime is %4.4X%4.4X%4.4X seconds\r\n", sh, sm, sl);
}
//-----------------------------------------------------------------------------
void display_memory(unsigned char * address)
{
char c;
int  row;
int  col;

   for (row = 0; row < 16; row++)
       {
         printf("%4.4X:", address);
         for (col = 0; col < 16; col++)   printf(" %2.2X", *address++);
         address -= 16;
         printf(" - ");
         for (col = 0; col < 16; col++)
             {
               c = *address++;
               if (c < ' ')         putchr('.');
               else if (c < 0x7F)   putchr(c);
               else                 putchr('.');
             }
         printf("\r\n");
       }
}
//-----------------------------------------------------------------------------
int main(int argc, char * argv[])
{
char            c;
char            noprompt;
char            last_c;
unsigned char * address;

   ASM(" MOVE #0x05, RR");            // RxInterrupt enable bit
   ASM(" OUT  R, (OUT_INT_MASK)");
   for (;;)
      {
        last_c = c;
        if (!noprompt)   printf("-> ");
        noprompt = 0;
	switch(c = getchr())
           {
             case '\r':
             case '\n':
                  if (last_c == 'd')
                     {
                       address += 0x100;
                       printf("\b\b\b\b");
                       display_memory(address);
                       c = 'd';
                     }
                  noprompt = 1;
                  break;

             case 'C':
             case 'c':
                  show_time();
                  break;

             case 'D':
             case 'd':
                  last_c = 'd';
                  printf("Display ");
                  address = (unsigned char *)gethex(1); 
                  printf("\r\n");
                  getchr();
                  display_memory(address);
                  break;

             case 'E':
             case 'e':
                  printf("LEDs ");
                  gethex(1);    ASM(" OUT R, (OUT_LEDS)");
                  printf("\r\n");
                  getchr();
                  break;

             case 'M':
             case 'm':
                  printf("Memory ");
                  address = (unsigned char *)gethex(1); 
                  printf(" Value ");
                  getchr(); 
		  *address = gethex(1);  
                  getchr(); 
                  printf("\r\n");
                  break;

             case 'S':
             case 's':
                  printf("DIP switch is 0x%X\r\n",
                         ASM(" IN (IN_DIP_SWITCH), RU"));
                  break;

             case 'T':
             case 't':
                  printf("Temperature is %d degrees Celsius\r\n",
                         ASM(" IN (IN_TEMPERAT), RU"));
                  break;

             case 'Q':
             case 'q':
             case 'X':
             case 'x': printf("Halted.\r\n");
                       while (serial_out_length)   /* wait */ ;
                       ASM(" DI");
                       ASM(" HALT");
                  break;

             default:
                  printf("\r\n"
                         "C - show time\r\n"
                         "D - display memory\r\n"
                         "E - set LEDs\r\n"
                         "M - modify memory\r\n"
                         "S - read DIP switch\r\n"
                         "T - read temperature\r\n"
                         "Q - quit\r\n"
                         "X - exit\r\n"
                         "\r\n");
           }
      }
}
//-----------------------------------------------------------------------------
