/*
 * helloworld.c: simple uart test application
 */

#include <stdio.h>
#include "platform.h"
#include "xparameters.h"

int main()
{
    unsigned int data;

    init_platform();

    print("Hello World\n\r");

    data = 0x000019;  // baudrate 115200Hz @ 50MHz clock
    *((volatile int *)(XPAR_UART_PLB_0_BASEADDR + 0x10)) = data;
    data = 3; // reset RX FIFO & TX FIFO
    *((volatile int *)(XPAR_UART_PLB_0_BASEADDR + 0x08)) = data;
    data = 0; // enable RX FIFO & TX FIFO
    *((volatile int *)(XPAR_UART_PLB_0_BASEADDR + 0x08)) = data;
    while(1) {
        data = *((volatile int *)(XPAR_UART_PLB_0_BASEADDR + 0x0C));
        if (data & 0x3000000)
        {
            data = *((volatile int *)(XPAR_UART_PLB_0_BASEADDR));
            *((volatile int *)(XPAR_UARTLITE_1_BASEADDR + 0x04)) = data;
        }
    }

    cleanup_platform();

    return 0;
}
