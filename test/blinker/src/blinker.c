/**
    @file blinker.c
    @brief LED blinker demo for light52 core.
        
    Does nothing but send a greeting string to the console and do a binary count
    on port P0.
    Should fit in 4K of ROM and use no XRAM.
    This demo may come in handy to try the core on boards with no RS232 port or
    display.
*/
#include <stdio.h>
#include "../../include/light52.h"
#include "../../common/soc.h"


/*-- Local function prototypes -----------------------------------------------*/




/*-- Public functions --------------------------------------------------------*/

void main(void){
    uint32_t msecs, secs;
    
    /* Initialize the support code: timer0 set to count seconds. */
    /* The UART is left in its default reset state: 19200-8-N-1 */
    soc_init();

    /* Send a banner to the serial port, in case it is connected. */
    printf("\n\r");
    printf("Light52 project -- " __DATE__ "\n\n\r");
    printf("LED blinker test.\n\r");

    while(1){
        msecs = soc_get_msecs();
        secs = msecs/1000;
        P1 = (uint8_t)(secs & 0xff);
        P0 = (uint8_t)((secs>>8) & 0xff);
    }
}

/*-- Local functions ---------------------------------------------------------*/





