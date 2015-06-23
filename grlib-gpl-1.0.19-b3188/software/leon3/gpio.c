#define GRGPIOADR 0x80000500;


int gpio_test(int addr) 
{
volatile int *pio = (int *) addr; 
        /*
         * pio[0] = din
         * pio[1] = dout
         * pio[2] = dir
         * pio[3] = imask
         */

        int mask;
        int width;
        
	report_device(0x0101a000);
        pio[3] = 0; 
        pio[2] = 0;
        pio[1] = 0;  
  
        pio[2] = 0xFFFFFFFF;
      
        /* determine port width and mask */
        mask = 0;
        width = 0;
        
        while( ((pio[2] >> width) & 1) && (width <= 32)) {
                mask = mask | (1 << width);
                width++;
        }
        
        pio[2] = mask;
        if( (pio[0] & mask) != 0) fail(1);  
        pio[1] = 0x89ABCDEF;
        if( (pio[0] & mask) != (0x89ABCDEF & mask)) fail(2);
        pio[2] = 0;
}
