#include "mem_map.h"
#include "serial.h"

//-----------------------------------------------------------------
// Defines
//-----------------------------------------------------------------
#define UART_RX_AVAIL    (1<<0)
#define UART_TX_BUSY     (1<<3)

//-------------------------------------------------------------
// serial_init: 
//-------------------------------------------------------------
void serial_init (void)
{      
    // Not required
}
//-------------------------------------------------------------
// serial_putchar: Write character to UART Tx buffer
//-------------------------------------------------------------
int serial_putchar(char ch)   
{   
    if (ch == '\n')
        serial_putchar('\r');
    
    // Print in simulator via l.nop instruction
    {
        register char  t1 asm ("r3") = ch;
        asm volatile ("\tl.nop\t%0" : : "K" (0x0004), "r" (t1));
    }

    // Write to Tx buffer
    UART_UDR = ch;

    // Wait for Tx to complete
    while (UART_USR & UART_TX_BUSY);

    return 0;
}
//-------------------------------------------------------------
// serial_getchar: Read character from UART Rx buffer
//-------------------------------------------------------------
int serial_getchar (void)
{
    if (serial_haschar())
        return UART_UDR;
    else
        return -1;
}
//-------------------------------------------------------------
// serial_haschar: Is a character waiting in Rx buffer
//-------------------------------------------------------------
int serial_haschar()
{
    return (UART_USR & UART_RX_AVAIL);
}
//-------------------------------------------------------------
// serial_putstr: Send a string to UART
//-------------------------------------------------------------
void serial_putstr(char *str)
{
    while (*str)
        serial_putchar(*str++);
}
