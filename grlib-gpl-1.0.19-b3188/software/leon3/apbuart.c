#include <stdio.h>

#define DISABLE 0x0
#define ENABLE_RX 0x1
#define ENABLE_TX 0x2
#define RX_INT 0x4
#define TX_INT 0x8
#define EVEN_PARITY 0x20
#define ODD_PARITY 0x30
#define LOOP_BACK 0x80
#define FLOW_CONTROL 0x40
#define FIFO_TX_INT 0x200
#define FIFO_RX_INT 0x400

/* 
 * uart[0] = data
 * uart[1] = status
 * uart[2] = control
 * uart[3] = scaler
 */

static inline int loadmem(int addr)
{
  int tmp;        
  asm volatile (" lda [%1]1, %0 "
      : "=r"(tmp)
      : "r"(addr)
    );
  return tmp;
}

struct uart_regs 
{
   volatile int data;
   volatile int status;
   volatile int control;
   volatile int scaler;
};

static char test[] = "40ti94a+0ygiyu05yhap5yi4h+a+iiyxhi4k59j0q905jkoyphoptjrhia4iy0+4";
static int testsize = sizeof test / sizeof test[0];

int apbuart_test(int addr) 
{
        struct uart_regs *uart = (struct uart_regs *) addr;
        int temp;
        int i;  
        int fifosize;

	if (report_device(0x0100C000)) return (0);
        /* set scaler to low value to speed up simulations */
        uart->scaler = 1;
        uart->status = 0;
        uart->data = 0;

        /* initialize receiver holding register to prevent X in gate level simulation */
        
        uart->control = 0;
        uart->control = ENABLE_TX;
        uart->data = 0;
        uart->data = 0;
        uart->control = ENABLE_TX | ENABLE_RX;// | LOOP_BACK;
        uart->control = ENABLE_TX | ENABLE_RX | LOOP_BACK;
        for (i = 0; i < 100; i++) {
          uart->data = 0;
        }
        
        for (i = 0; i < 100; i++) {
          temp = uart->data;
        }
        

        /* determine fifosize */
        uart->control = ENABLE_TX;
        while( ((loadmem((int)&uart->status) >> 2) & 0x1) != 1 ) {}
        uart->control = DISABLE;
        
        fifosize = 1;
        uart->data = 0;
        while ( ((loadmem((int)&uart->status) >> 20) & 0x3F) == fifosize ) {
          fifosize++;
          uart->data = 0;      
        }
        if (fifosize > 1) {
          fifosize--;
        }
        
        uart->control = ENABLE_RX | ENABLE_TX;
  
        /*set counters to 0, and status bits to reset values*/
        
        temp = loadmem((int)&uart->status);
        while( (temp & 1) || !(temp & 4) || !(temp & 2) ) {
                temp = loadmem((int)&uart->data);
                temp = loadmem((int)&uart->status);
        }

        temp = 0;
        uart->control = DISABLE;
        uart->status = 0;
        

        /*
         *  TRANSMITTER TEST
         */

        if(fifosize > 1) {
                if(((loadmem((int)&uart->status) & 0x80) == 1) ) {
                        /*th bit incorrect*/
                        fail( 4);
                }
        }
        

        uart->data = (int) test[0];
        
        if( (loadmem((int)&uart->status) & 4) == 1) {
                /*te bit incorrect*/
                fail( 1);
        }

        if(loadmem((int)&uart->status) & 2 == 0) {
                /*ts bit incorrect*/
                fail( 2);
        }
        
        if (fifosize > 1) {
                for(i = 1; i < fifosize; i++) {
                        uart->data = (int) test[i % testsize];
                }
        
                if(((loadmem((int)&uart->status) & 0x80) == 1) ) {
                        /*th bit incorrect*/
                        fail( 5);
                }
                
                if( ((loadmem((int)&uart->status) >> 20) & 0x3F) != fifosize ) {
                        /*tcnt error*/
                        fail( 6);
                }

                if ( loadmem((int)&uart->status) & 0x200 == 0) {
                        /*tf bit incorrect*/
                        fail( 7);
                }

                
        }
        
        /*
         *  RECEIVER TEST (WITH LOOPBACK)
         */

        uart->scaler = 1;

        if(loadmem((int)&uart->status) & 1 != 0) {
                /*dr bit incorrect*/
                fail( 7);
        }

        uart->control = ENABLE_TX | ENABLE_RX | LOOP_BACK;
//        uart->control = ENABLE_TX | ENABLE_RX ;
    
        i = 0;
        
        if (fifosize == 1) {
                while((loadmem((int)&uart->status) & 1) == 0) {}
        } else {
                while((loadmem((int)&uart->status) & 0x400) == 0) {}
        }
        
        if( (loadmem((int)&uart->status) & 1) == 0 ) {
                /*dr bit incorrect*/
                fail( 8);
        }
        
        if( fifosize > 1 ) {
                if( ((loadmem((int)&uart->status) >> 26) & 0x3F) != fifosize) {
                        /*rcnt error*/
                        fail( 9);
                }
                
                if( (loadmem((int)&uart->status) & 0x100) == 0) {
                        /*rhalffull error */
                        fail( 10);
                }
                
                if( (loadmem((int)&uart->status) & 0x400) == 0) {
                        /*rfull error */
                        fail( 11);
                }
        }
        
        for(i = 0; i < fifosize; i++) {
                temp = loadmem((int)&uart->data);
                if(temp != test[i % testsize] ) {
                        /*data error*/
                        fail( 12);
                }
        }
        
        if(fifosize > 1) {
                if( (loadmem((int)&uart->status) & 0x100) != 0 ) {
                        /*rhalffull error*/
                        fail( 13);
                }
                
                if( ((loadmem((int)&uart->status) >> 26) & 0x3F) != 0) {
                        /*rcnt error*/
                        fail( 14);
                }
                
                
                if( (loadmem((int)&uart->status) & 0x400) != 0) {
                        /*rfull error */
                        fail( 11);
                }
        }


        if( loadmem((int)&uart->status) & 1 != 0 ) {
                /*dr bit error*/
                fail( 12);
        }
        
        uart->control = DISABLE;
        return 0;
      
}
