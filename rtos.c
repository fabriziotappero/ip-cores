/*******************************************************************************
********************************************************************************
**                                                                            **
**                     TASK SWITCHING                                         **
**                                                                            **
********************************************************************************
*******************************************************************************/

enum
{
   TASK_RUNNING   = 0x00,
   TASK_BLOCKED   = 0x01,
   TASK_SLEEPING  = 0x02,
   TASK_SUSPENDED = 0x04
};

typedef struct _task Task;
typedef struct _semaphore Semaphore;
struct _task
{
   // members required at initialization...
   // 
   Task        * next_task;
   int         * stack_pointer;
   char          status;
   unsigned char priority;
   const char *  name;
   char *        stack_bottom;
   char *        stack_top;

   // members used later on
   //
   char          sema_ret;
   unsigned char saved_priority;
   Semaphore  *  waiting_for;
   Task *        next_waiting_task;
   int           sleep_count;
};

extern Task * current_task;
extern Task task_idle;

struct _semaphore
{
   int          counter;
   Task *       next_waiting;
   Task *       last_waiting;
   const char * name;
};
Semaphore rx_sema =    { 0, 0, 0, "rx_semaphore"   };
Semaphore t2_control = { 0, 0, 0, "task 2 control" };
Semaphore t3_control = { 0, 0, 0, "task 3 control" };
Semaphore serial_out = { 1, 0, 0, "serial out"     };
Semaphore tx_sema =    { 16, 0, 0, "tx_semaphore"  };

void switch_tasks()   // interrupts disabled !
{
Task * next = 0;
Task * t = current_task;

   /* for performance reasons, we hand-code the following:
 
   do { if (  !(t = t->next_task)->status       // t is running and
           && (!next                            // no next found so far,
              || t->priority > next->priority   // or t has higher priority
              )
           )  next = t;
      } while (t != current_task);
   */

   ASM("
st_loop:
	MOVE	0(SP), RR		; RR = t
	MOVE	(RR), RR		; RR = t->next_task
	MOVE	RR, 0(SP)		; t  = t->next_task
	ADD	RR, #4			; RR = & t->status
	MOVE	(RR), RS		; RR = t->status
	JMP	RRNZ, st_next_task	; jump if (status != 0)
					;
	MOVE	2(SP), RR		; RR = next
	JMP	RRZ, st_accept		; jump if (next == 0)
					;
	ADD	RR, #5			; RR = & next->priority
	MOVE	(RR), RS		; RR = next->priority
	MOVE	RR, LL			; LL = next->priority
	MOVE	0(SP), RR		; RR = t
	ADD	RR, #5			; RR = & t->priority
	MOVE	(RR), RS		; RR = t->priority
	SGE	LL, RR			; RR = (next->priority >= t->priority)
	JMP	RRNZ, st_next_task	; jump if (next->priority > t->priority)
st_accept:				;
	MOVE	0(SP), RR		; RR = t
	MOVE	RR, 2(SP)		; next = t
st_next_task:				;
	MOVE	0(SP), RR		; RR = t
	MOVE	(Ccurrent_task), LL	; LL = current_task
	SNE	LL, RR			; RR = (t != current_task)
	JMP	RRNZ, st_loop		;
	");

   if (current_task != next)
      {
        current_task->stack_pointer = (int *)ASM(" LEA  0(SP), RR");
        current_task = next;
        current_task->stack_pointer;  ASM(" MOVE RR, SP");
      }
}
//-----------------------------------------------------------------------------
void P(Semaphore * sema)
{
   ASM(" DI");

   if (--sema->counter < 0)
      {
        // this task blocks
        //
        current_task->waiting_for = sema;
        current_task->next_waiting_task = 0;
        current_task->status |= TASK_BLOCKED;

        if (sema->next_waiting)   // some tasks blocked already on sema
           sema->last_waiting->next_waiting_task = current_task;
        else                      // first task blocked on sema
           sema->next_waiting = current_task;

        sema->last_waiting = current_task;
        switch_tasks();
      }

   ASM(" RETI");
}
//-----------------------------------------------------------------------------
//
// return non-zero if timeout occured
//
char P_timed(Semaphore * sema, unsigned int ticks)
{
char ret = 0;

   ASM(" DI");

   if (--sema->counter < 0)
      {
        // this task blocks
        //
        current_task->waiting_for = sema;
        current_task->sleep_count = ticks;
        current_task->next_waiting_task = 0;
        current_task->status |= TASK_BLOCKED | TASK_SLEEPING;
        current_task->sema_ret = 0;

        if (sema->next_waiting)   // some tasks blocked already on sema
           sema->last_waiting->next_waiting_task = current_task;
        else                      // first task blocked on sema
           sema->next_waiting = current_task;


        switch_tasks();
        ret = current_task->sema_ret;
      }

   ASM(" EI");
   return ret;
}
//-----------------------------------------------------------------------------
//
// return non-zero if task switch required
//
char Vint(Semaphore * sema)   // interrupts disabled !
{
Task * next = sema->next_waiting;

   ++sema->counter;

   if (next)   // waiting queue not empty: remove first waiting
      {
        next->status &= ~(TASK_BLOCKED | TASK_SLEEPING);

        sema->next_waiting = next->next_waiting_task;
        if (!sema->next_waiting)   sema->last_waiting = 0;

        return next->priority > current_task->priority;
      }

   return 0;
}
//-----------------------------------------------------------------------------
void V(Semaphore * sema)
{
   ASM(" DI");
   if (Vint(sema))   switch_tasks();
   ASM(" RETI");
}
/*******************************************************************************
********************************************************************************
**                                                                            **
**                     INTERRUPT HANDLERS                                     **
**                                                                            **
********************************************************************************
*******************************************************************************/

unsigned char serial_in_buffer[16];
unsigned char serial_in_get       = 0;
unsigned char serial_in_put       = 0;
unsigned int  serial_in_overflows = 0;

char rx_interrupt()
{
char c = ASM(" IN   (IN_RX_DATA), RU");

   if (rx_sema.counter < sizeof(serial_in_buffer))
      {
        serial_in_buffer[serial_in_put] = c;
        if (++serial_in_put >= sizeof(serial_in_buffer))   serial_in_put = 0;
        return Vint(&rx_sema);
      }
   else
      {
        ++serial_in_overflows;
        return 0;
      }
}
//-----------------------------------------------------------------------------

unsigned char serial_out_buffer[16];
unsigned char serial_out_get = 0;
unsigned char serial_out_put = 0;

char tx_interrupt()
{
   if (tx_sema.counter < sizeof(serial_out_buffer))
      {
        serial_out_buffer[serial_out_get];
        ASM(" OUT  R, (OUT_TX_DATA)");
        if (++serial_out_get >= sizeof(serial_out_buffer))   serial_out_get = 0;
        return Vint(&tx_sema);
      }
   else
      {
        ASM(" MOVE #0x05, RR");            // RxInt and TimerInt
        ASM(" OUT  R, (OUT_INT_MASK)");
        return 0;
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
Task * t = current_task;
Semaphore * s;
Task * ts;

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

   do {
        if (!--(t->sleep_count) && (t->status & TASK_SLEEPING))
           {
             t->status &= ~TASK_SLEEPING;
             if (t->status & TASK_BLOCKED)   // timed P
                {
                  t->status &= ~TASK_BLOCKED;
                  t->sema_ret = -1;
                  s = t->waiting_for;
                  ++s->counter;
                  ts = s->next_waiting;
                  if (t == ts)                    // t is first waiting
                     {
                       if (t == s->last_waiting)
                          { // t is also last (thus, the only) waiting
                            s->next_waiting = 0;
                            s->last_waiting = 0;
                          }
                       else
                          { // t is first of several waiting (thus, not last)
                            s->next_waiting = t->next_waiting_task;
                          }
                     }
                  else                            // t is subsequent waiting
                     {
                       while (t != ts->next_waiting_task)
                             ts = ts->next_waiting_task;
                       ts->next_waiting_task = t->next_waiting_task;
                       if (t == s->last_waiting)   // t is last waiting
                          s->last_waiting = ts;    // now ts is last waiting
                     }
                }
           }
      } while (current_task != (t = t->next_task));
}
//-----------------------------------------------------------------------------
void interrupt()
{
char ts_1 = 0;
char ts_2 = 0;

   ASM(" MOVE RR, -(SP)");
   ASM(" MOVE LL, RR");
   ASM(" MOVE RR, -(SP)");

   if (ASM(" IN   (IN_STATUS), RU") & 0x10)   ts_1  = rx_interrupt();
   if (ASM(" IN   (IN_STATUS), RU") & 0x20)   ts_2  = tx_interrupt();
   if (ASM(" IN   (IN_STATUS), RU") & 0x40)
      { timer_interrupt();   ts_1 = -1; }

   if (ts_1 | ts_2)   switch_tasks();

   ASM(" MOVE (SP)+, RR");
   ASM(" MOVE RR, LL");
   ASM(" MOVE (SP)+, RR");
   ASM(" ADD  SP, #2");
   ASM(" RETI");
}
//-----------------------------------------------------------------------------
void sleep(int millisecs)
{
   ASM(" DI");
   current_task->sleep_count = millisecs;
   current_task->status      = TASK_SLEEPING;
   switch_tasks();
   ASM(" RETI");
}
//-----------------------------------------------------------------------------
void deschedule()
{
   ASM(" DI");
   switch_tasks();
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
   P(&tx_sema);   // get free position

   serial_out_buffer[serial_out_put] = c;
   if (++serial_out_put >= sizeof(serial_out_buffer))   serial_out_put = 0;
   ASM(" MOVE #0x07, RR");            // RxInt and TxInt and TimerInt
   ASM(" OUT  R, (OUT_INT_MASK)");
   1;
}
//-----------------------------------------------------------------------------
void print_n(char c, int count)
{
    for (; count > 0; --count)   putchr(c);
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
   if (value >= 10000)    *dest++ = '0' + (value / 10000);
   if (value >=  1000)    *dest++ = '0' + (value /  1000) % 10;
   if (value >=   100)    *dest++ = '0' + (value /   100) % 10;
   if (value >=    10)    *dest++ = '0' + (value /    10) % 10;
   *dest++ = '0' + value % 10;
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

   if (0x02 & ~flags)   print_n(pad, field_w - len);   // right align

   if (sign)   putchr(sign);
   if (alt)
      {
        if (flags & 0x01)   print_string(alt);
      }

   for (i = 0; i < padlen; i++)   putchr(min_p);
   print_string(buffer);

   if (0x02 & flags)   print_n(pad, field_w - len);   // left align

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
                              print_unsigned(buffer, ((int)*args++));
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

   P(&rx_sema);

   c = serial_in_buffer[serial_in_get];
   if (++serial_in_get >= sizeof(serial_in_buffer))   serial_in_get = 0;
   return c;
}
//-----------------------------------------------------------------------------
int getchr_timed(unsigned int ticks)
{
char c;

   c = P_timed(&rx_sema, ticks);
   if (c)   return -1;   // if rx_sema timed out

   c = serial_in_buffer[serial_in_get];
   if (++serial_in_get >= sizeof(serial_in_buffer))   serial_in_get = 0;
   return c;
}
//-----------------------------------------------------------------------------
char peekchr()
{
char ret;

   P(&rx_sema);
   ret = serial_in_buffer[serial_in_get];
   V(&rx_sema);

   return ret;
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

//-----------------------------------------------------------------------------
void init_stack()
{
char * bottom = current_task->stack_bottom;

   while (bottom < (char *)ASM(" LEA 0(SP), RR"))   *bottom++ = 'S';
}
//-----------------------------------------------------------------------------

extern char * end_text;

void init_unused()   // must ONLY be called by idle task
{
char * cp = current_task->stack_bottom;

   while (--cp >= (char *)&end_text)   *cp = ' ';
}
//-----------------------------------------------------------------------------
int stack_used(Task * t)
{
char * bottom = t->stack_bottom;

   while (*bottom == 'S')   bottom++;
   return t->stack_top - bottom;
}
//-----------------------------------------------------------------------------
void show_sema(Semaphore * s)
{
Task * t;

   printf("%-20s %4d ", s->name, s->counter);
   if (s->counter < 0)
      {
        for (t = s->next_waiting; t; t = t->next_waiting_task)
            {
              printf("%s -> ", t->name);
              if (t == s->last_waiting)   printf("0");
            }
      }
   else
      {
        printf("none.");
      }
   printf("\r\n");
}
//-----------------------------------------------------------------------------

unsigned char loader[] =
{
//  0xF8, 0x18, 0x00, 0x4F, 0xFC, 0x00, 0xA0, 0x08, 
//  0x6E, 0x0E, 0x24, 0x1A, 0x00, 0x03, 0x07, 0x00, 
//  0xF8, 0x32, 0x9E, 0x4F, 0x05, 0xF0, 0x9E, 0x00, 
//  0xE8, 0x01,

                0x2E, 0x01, 0x11, 0x01, 0x3D, 0x03, 
    0x32, 0x1E, 0x2E, 0x00, 0x07, 0x2E, 0x01, 0x11, 
    0x02, 0x03, 0x3D, 0x1E, 0x65, 0x02, 0x2F, 0x00, 
    0x07, 0x02, 0x59, 0x1E, 0x61, 0x02, 0xA1, 0x5D, 
    0x02, 0xB1, 0x47, 0x0F, 0x05, 0x3D, 0x1E, 0x2B, 
    0x01, 0x61, 0x02, 0x47, 0x03, 0x4C, 0x1E, 0x07, 
    0x05, 0x32, 0x1E, 0x0F, 0x65, 0x00, 0x29, 0x30, 
    0x04, 0x71, 0x1E, 0xF8, 0xFF, 0x00, 0x02, 0xBB, 
    0x1E, 0x65, 0x00, 0x27, 0x39, 0x04, 0x7F, 0x1E, 
    0x65, 0x00, 0xF7, 0x30, 0x02, 0xBB, 0x1E, 0x65, 
    0x00, 0x29, 0x41, 0x04, 0x8C, 0x1E, 0xF8, 0xFF, 
    0x00, 0x02, 0xBB, 0x1E, 0x65, 0x00, 0x27, 0x46, 
    0x04, 0x9A, 0x1E, 0x65, 0x00, 0xF7, 0x37, 0x02, 
    0xBB, 0x1E, 0x65, 0x00, 0x29, 0x61, 0x04, 0xA7, 
    0x1E, 0xF8, 0xFF, 0x00, 0x02, 0xBB, 0x1E, 0x65, 
    0x00, 0x27, 0x66, 0x04, 0xB5, 0x1E, 0x65, 0x00, 
    0xF7, 0x57, 0x02, 0xBB, 0x1E, 0xF8, 0xFF, 0x00, 
    0x02, 0xBB, 0x1E, 0x2B, 0x01, 0x07, 0x05, 0x60, 
    0x1E, 0x0F, 0x2D, 0x65, 0x01, 0x18, 0xFF, 0x00, 
    0x04, 0xE3, 0x1E, 0x05, 0x60, 0x1E, 0x5F, 0x00, 
    0x65, 0x00, 0x18, 0xFF, 0x00, 0x04, 0xE3, 0x1E, 
    0x65, 0x01, 0x52, 0x04, 0x43, 0x65, 0x00, 0x31, 
    0x02, 0xED, 0x1E, 0xF8, 0xC7, 0x1F, 0x0E, 0x05, 
    0x49, 0x1E, 0x2B, 0x02, 0x00, 0x2B, 0x02, 0x07, 
    0x2D, 0x2C, 0x2D, 0x2D, 0x2D, 0x2D, 0xF8, 0xDA, 
    0x1F, 0x0E, 0x05, 0x49, 0x1E, 0x2B, 0x02, 0x05, 
    0x32, 0x1E, 0x5F, 0x00, 0x19, 0x3A, 0x03, 0xFF, 
    0x1E, 0xC0, 0x5F, 0x02, 0x05, 0xBE, 0x1E, 0x5F, 
    0x00, 0x65, 0x02, 0x43, 0x65, 0x00, 0x58, 0x5F, 
    0x02, 0x65, 0x00, 0x5F, 0x06, 0x05, 0xBE, 0x1E, 
    0x5F, 0x00, 0x65, 0x02, 0x43, 0x65, 0x00, 0x58, 
    0x5F, 0x02, 0x65, 0x00, 0x52, 0x08, 0x5D, 0x04, 
    0x05, 0xBE, 0x1E, 0x5F, 0x00, 0x65, 0x02, 0x43, 
    0x65, 0x00, 0x58, 0x5F, 0x02, 0x61, 0x04, 0x43, 
    0x65, 0x00, 0x31, 0x5D, 0x04, 0x05, 0xBE, 0x1E, 
    0x5F, 0x00, 0x65, 0x02, 0x43, 0x65, 0x00, 0x58, 
    0x5F, 0x02, 0x65, 0x00, 0x5F, 0x03, 0xC0, 0x5F, 
    0x01, 0x02, 0x7C, 0x1F, 0x05, 0xBE, 0x1E, 0x5F, 
    0x00, 0x65, 0x00, 0x0F, 0x65, 0x02, 0x0E, 0x61, 
    0x07, 0x0B, 0x58, 0x43, 0x09, 0x45, 0x65, 0x02, 
    0x43, 0x65, 0x00, 0x58, 0x5F, 0x02, 0x65, 0x01, 
    0xA1, 0x5F, 0x01, 0xB1, 0x65, 0x01, 0x43, 0x65, 
    0x06, 0x3C, 0x03, 0x5C, 0x1F, 0x05, 0xBE, 0x1E, 
    0x5F, 0x00, 0x65, 0x02, 0x43, 0x65, 0x00, 0x58, 
    0x5F, 0x02, 0x65, 0x02, 0x04, 0x9A, 0x1F, 0x02, 
    0xB8, 0x1F, 0xF9, 0x2E, 0x0F, 0x05, 0x3D, 0x1E, 
    0x2B, 0x01, 0x65, 0x03, 0x17, 0x01, 0x04, 0xB5, 
    0x1F, 0xF8, 0xE4, 0x1F, 0x0E, 0x05, 0x49, 0x1E, 
    0x2B, 0x02, 0x61, 0x04, 0x06, 0x02, 0xFF, 0x1E, 
    0xF8, 0xEE, 0x1F, 0x0E, 0x05, 0x49, 0x1E, 0x2B, 
    0x02, 0x02, 0xF6, 0x1E, 0x2B, 0x07, 0x07, 0x0D, 
    0x0A, 0x45, 0x52, 0x52, 0x4F, 0x52, 0x3A, 0x20, 
    0x6E, 0x6F, 0x74, 0x20, 0x68, 0x65, 0x78, 0x0D, 
    0x0A, 0x00, 0x0D, 0x0A, 0x4C, 0x4F, 0x41, 0x44, 
    0x20, 0x3E, 0x20, 0x00, 0x0D, 0x0A, 0x44, 0x4F, 
    0x4E, 0x45, 0x2E, 0x0D, 0x0A, 0x00, 0x0D, 0x0A, 
    0x43, 0x48, 0x45, 0x43, 0x4B, 0x53, 0x55, 0x4D, 
    0x20, 0x45, 0x52, 0x52, 0x4F, 0x52, 0x2E, 0x00, 
};

void load_image()
{
unsigned char * from = (unsigned char *)&loader;
unsigned char * to   = (unsigned char *)0x2000 - sizeof(loader);
int len              = sizeof(loader);

   printf("Loading image...\r\n");
   while (tx_sema.counter < sizeof(serial_out_buffer)) ;
   ASM(" DI");
   ASM(" MOVE #0x00, RR");            // disable ints
   ASM(" OUT  R, (OUT_INT_MASK)");    // disable int sources
   for (; len; --len)   *to++ = *from++;
   to;   ASM(" MOVE  RR, SP");
   ASM(" JMP  0x1EF0\t\t; &main");
}
//-----------------------------------------------------------------------------
void show_semas()
{
   printf("\r\nSemaphore           Count Waiting tasks\r\n");
   print_n('-', 79);   printf("\r\n");
   show_sema(&serial_out);
   show_sema(&rx_sema);
   show_sema(&tx_sema);
   show_sema(&t2_control);
   show_sema(&t3_control);
   print_n('=', 79);   printf("\r\n");

   if (serial_in_overflows)
      printf("\r\n\r\nSerial Overflows: %u\r\n\r\n", serial_in_overflows);
}
//-----------------------------------------------------------------------------
void show_tasks()
{
Task * t = &task_idle;

   printf("\r\nTask name        Prio   PC Stack  Size  Used "
          "Next waiting     Status\r\n");
   print_n('-', 79);   printf("\r\n");

   do {
        printf("%-16s %4d  %4X %4X %5d %5d ",
               t->name, t->priority, t->stack_pointer[2], t->stack_pointer,
               t->stack_top - t->stack_bottom, stack_used(t));
        if (t->next_waiting_task)   printf("%-16s ", t->next_waiting_task);
        else                        printf("none.            ");
        if (t->status == 0)               printf("RUN ");
        if (t->status & TASK_SUSPENDED)   printf("SUSP ");
        if (t->status & TASK_SLEEPING)    printf("SLEEP %d ms ",
                                                 t->sleep_count);
        if (t->status & TASK_BLOCKED )    printf("BLKD on %s ",
                                                 t->waiting_for->name);
        printf("\r\n");

        t = t->next_task;
      } while (t != &task_idle);

   print_n('=', 79);   printf("\r\n");
}
//-----------------------------------------------------------------------------

void show_time()
{
unsigned int sl;
unsigned int sm;
unsigned int sh;

   do { seconds_changed = 0;
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
//
//   main() is the idle task. main() MUST NOT BLOCK, but could do
//   some non-blocking background jobs. It is safer, though, to do
//   nothing in main()'s for() loop.
//
int main()
{
int i;

   init_unused();
   init_stack();

   ASM(" MOVE #0x00, RR");            // disable all interrupt sources
   ASM(" OUT  R, (OUT_INT_MASK)");

   // we dont know the value of the interrupt disable counter,
   // so we force it to zero (i.e. interrupts enabled)
   //
   for (i = 0; i < 16; ++i)   ASM(" EI");   // decrement int disable counter

   ASM(" MOVE #0x05, RR");            // enable Rx and timer interrupts
   ASM(" OUT  R, (OUT_INT_MASK)");

   deschedule();

   for (;;)   ASM(" HALT");
}
//-----------------------------------------------------------------------------
int main_1(int argc, char * argv[])
{
int             c;
char            last_c;
unsigned char * address;
int             value;

   ASM(" EI");

   init_stack();

   for (;;)
      {
        P(&serial_out);
        printf("READY\r");
        V(&serial_out);

        last_c = c;
	c = getchr_timed(60000);
        if (c == -1)   // time out
           {
             P(&serial_out);
             printf("%s is bored.\r\n", current_task->name);
             V(&serial_out);
             continue;
           }

        P(&serial_out);
	switch(c)
           {
             case '\r':
             case '\n':
                  if (last_c == 'd')
                     {
                       address += 0x100;
                       putchr('\r');
                       display_memory(address);
                       c = 'd';
                     }
                  break;

             case '2':
                  V(&t2_control);
                  printf("Task 2 kicked\r\n");
                  break;

             case '3':
                  V(&t3_control);
                  sleep(100);
                  P(&t3_control);
                  printf("Task 3 enabled for 100 ms\r\n");
                  break;

             case 'b':
                  0;   ASM(" OUT  R, (OUT_START_CLK_CTR)");
		  deschedule();
                  ASM(" OUT  R, (OUT_STOP_CLK_CTR)");
                  value = (ASM(" IN   (IN_CLK_CTR_HIGH), RU") << 8)
                        |  ASM(" IN   (IN_CLK_CTR_LOW), RU");
                  printf("deschedule took %d CLKs = %d us\r\n",
                         value, (value + 10)/20);
                  break;

             case 'c':
                  show_time();
                  break;

             case 'd':
                  last_c = 'd';
                  printf("Display ");
                  address = (unsigned char *)gethex(1); 
                  printf("\r\n");
                  getchr();
                  display_memory(address);
                  break;

             case 'e':
                  printf("LEDs ");
                  gethex(1);    ASM(" OUT R, (OUT_LEDS)");
                  printf("\r\n");
                  getchr();
                  break;

             case 'm':
                  printf("Memory ");
                  address = (unsigned char *)gethex(1); 
                  printf(" Value ");
                  getchr(); 
		  *address = gethex(1);  
                  getchr(); 
                  printf("\r\n");
                  break;

             case 's':
                  printf("DIP switch is 0x%X\r\n",
                         ASM(" IN (IN_DIP_SWITCH), RU"));
                  break;

             case 't':
                  printf("Temperature is %d degrees Celsius\r\n",
                         ASM(" IN (IN_TEMPERAT), RU"));
                  break;

             case 'H': printf("Halted.\r\n");
                       while (tx_sema.counter < sizeof(serial_out_buffer)) ;
                       ASM(" DI");
                       ASM(" HALT");
                  break;

             case 'I':
                  load_image();
                  break;

             case 'S':
                  show_semas();
                  break;

             case 'T':
                  show_tasks();
                  break;

             default:
                  printf("Help:  \r\n"
                         "2 - kick task 2\r\n"
                         "3 - kick task 3\r\n"
                         "I - load image\r\n"
                         "S - show semaphores\r\n"
                         "T - show tasks\r\n"
                         "b - measure task switch (deschedule)\r\n"
                         "c - show time\r\n"
                         "d - display memory\r\n"
                         "e - set LEDs\r\n"
                         "m - modify memory\r\n"
                         "s - read DIP switch\r\n"
                         "t - read temperature\r\n"
                         "H - HALT (forever)\r\n"
                         "\r\n");
           }
        V(&serial_out);
      }
}
//-----------------------------------------------------------------------------
void main_2()
{
unsigned int all_value;
unsigned int halt_value;
unsigned int all_total;
unsigned int halt_total;
int n;
int idle;

   ASM(" EI");

   init_stack();

   for (;;)
       {
         P(&t2_control);

         all_value  = 0;
         halt_value = 0;
         all_total  = 0;
         halt_total = 0;

         P(&serial_out);
         printf("Measuring...\r\n");
         V(&serial_out);

         V(&t3_control);
         for (n = 0; n < 100; n++)
             {
               sleep(1);
               0;   ASM(" OUT  R, (OUT_START_CLK_CTR)");
               sleep(1);
               ASM(" OUT  R, (OUT_STOP_CLK_CTR)");
               all_value += (ASM(" IN   (IN_CLK_CTR_HIGH), RU") << 8)
                     |  ASM(" IN   (IN_CLK_CTR_LOW), RU");

               all_total += all_value >> 8;
               all_value &= 0x00FF;

               sleep(1);
               3;   ASM(" OUT  R, (OUT_START_CLK_CTR)");
               sleep(1);
               ASM(" OUT  R, (OUT_STOP_CLK_CTR)");

               halt_value += (ASM(" IN   (IN_CLK_CTR_HIGH), RU") << 8)
                     |  ASM(" IN   (IN_CLK_CTR_LOW), RU");

               halt_total += halt_value >> 8;
               halt_value &= 0x00FF;
             }
         P(&t3_control);

         P(&serial_out);
         printf("total:  %d cycles\r\n", all_total);
         printf("halted: %d cycles\r\n", halt_total);
         idle = (100*(halt_total>> 8)) / (all_total >> 8);
         printf("idle:   %d %%\r\n", idle);
         printf("load:   %d %%\r\n", 100 - idle);
         V(&serial_out);
       }
}
//-----------------------------------------------------------------------------
void main_3()
{
char out;

   ASM(" EI");

   init_stack();

   for (;;)
       {
         P(&t3_control);
         V(&t3_control);

         P(&serial_out);
         for (out = '0'; out <= '9'; ++out)   putchr(out);
         for (out = 'A'; out <= 'Z'; ++out)   putchr(out);
         for (out = 'a'; out <= 'z'; ++out)   putchr(out);
         putchr('\r');
         putchr('\n');
         V(&serial_out);
       }
}
//-----------------------------------------------------------------------------
//
// task stacks
//
unsigned int stack_1[200], tos_1[3] = { 0, 0, (int)&main_1 }, top_1[0];
unsigned int stack_2[200], tos_2[3] = { 0, 0, (int)&main_2 }, top_2[0];
unsigned int stack_3[200], tos_3[3] = { 0, 0, (int)&main_3 }, top_3[0];

Task task_3 =    { &task_idle,         // next task
                   tos_3,              // current stack pointer
                   TASK_RUNNING,       // current state
                   30 ,                // priority
                   "Load Task ",       // task name
                   (char *)&stack_3,   // bottom of stack
                   (char *)&top_3 };   // top    of stack

Task task_2 =    { &task_3,            // next task
                   tos_2,              // current stack pointer
                   TASK_RUNNING,       // current state
                   40 ,                // priority
                   "Measurement",      // task name
                   (char *)&stack_2,   // bottom of stack
                   (char *)&top_2 };   // top    of stack

Task task_1 =    { &task_2,            // next task
                   tos_1,              // current stack pointer
                   TASK_RUNNING,       // current state
                   50,                 // priority
                   "Monitor",          // task name
                   (char *)&stack_1,   // bottom of stack
                   (char *)&top_1 };   // top    of stack

Task task_idle = { &task_1,        // next task
                   0,              // current stack pointer (N/A since running)
                   TASK_RUNNING,   // current state
                   0,              // priority
                   "Idle Task",    // task name
                   (char *)0x1F80,         // bottom of stack
                   (char *)0x2000 };       // top    of stack

Task * current_task = &task_idle;

//-----------------------------------------------------------------------------
