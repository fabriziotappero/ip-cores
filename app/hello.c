#include "stdint.h"
#include "avr/io.h"
#include "avr/pgmspace.h"

#undef F_CPU
#define F_CPU 25000000UL
#include "util/delay.h"


     //----------------------------------------------------------------------//
    //                                                                      //
   //   print char cc on UART.                                             //
  //    return number of chars printed (i.e. 1).                          //
 //                                                                      //
//----------------------------------------------------------------------//
uint8_t
uart_putc(uint8_t cc)
{
    while ((UCSRA & (1 << UDRE)) == 0)      ;
    UDR = cc;
    return 1;
}

     //----------------------------------------------------------------------//
    //                                                                      //
   //   print char cc on 7 segment display.                                //
  //    return number of chars printed (i.e. 1).                          //
 //                                                                      //
//----------------------------------------------------------------------//
// The segments of the display are encoded like this:
//
//
//      segment     PORT B
//      name        Bit number
//      ----A----   ----0----
//      |       |   |       |
//      F       B   5       1
//      |       |   |       |
//      ----G----   ----6----
//      |       |   |       |
//      E       C   4       2
//      |       |   |       |
//      ----D----   ----3----
//
//-----------------------------------------------------------------------------

#define SEG7(G, F, E, D, C, B, A)   (~(G<<6|F<<5|E<<4|D<<3|C<<2|B<<1|A))

uint8_t
seg7_putc(uint8_t cc)
{
uint16_t t;

    switch(cc)
    {                   //   G F E D C B A
    case ' ':   PORTB = SEG7(0,0,0,0,0,0,0);        break;
    case 'E':   PORTB = SEG7(1,1,1,1,0,0,1);        break;
    case 'H':   PORTB = SEG7(1,1,1,0,1,1,0);        break;
    case 'L':   PORTB = SEG7(0,1,1,1,0,0,0);        break;
    case 'O':   PORTB = SEG7(0,1,1,1,1,1,1);        break;
    default:    PORTB = SEG7(1,0,0,1,0,0,1);        break;
    }

    // wait 800 + 200 ms. This can be quite boring in simulations,
    // so we wait only if DIP switch 6 is closed.
    //
    if (!(PINB & 0x20))     for (t = 0; t < 800; ++t)   _delay_ms(1);
    PORTB = SEG7(0,0,0,0,0,0,0);
    if (!(PINB & 0x20))     for (t = 0; t < 200; ++t)   _delay_ms(1);

    return 1;
}

     //----------------------------------------------------------------------//
    //                                                                      //
   //   print string s on UART.                                            //
  //    return number of chars printed.                                   //
 //                                                                      //
//----------------------------------------------------------------------//
uint16_t
uart_puts(const char * s)
{
const char * from = s;
uint8_t cc;
    while ((cc = pgm_read_byte(s++)))   uart_putc(cc);
    return s - from - 1;
}

     //----------------------------------------------------------------------//
    //                                                                      //
   //   print string s on 7 segment display.                               //
  //    return number of chars printed.                                   //
 //                                                                      //
//----------------------------------------------------------------------//
uint16_t
seg7_puts(const char * s)
{
const char * from = s;
uint8_t cc;
    while ((cc = pgm_read_byte(s++)))   seg7_putc(cc);
    return s - from - 1;
}

//-----------------------------------------------------------------------------
int
main(int argc, char * argv[])
{
    for (;;)
    {
        if (PINB & 0x40)    // DIP switch 7 open.
            {
                // print 'Hello world' on UART.
                uart_puts(PSTR("Hello, World!\r\n"));
            }
        else                // DIP switch 7 closed.
            {
                // print 'HELLO' on 7-segment display
                seg7_puts(PSTR("HELLO "));
            }
    }
}
//-----------------------------------------------------------------------------
