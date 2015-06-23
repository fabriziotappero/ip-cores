//
//
//


extern void init_serial( void );
extern int puts(const char *s);


int main (void)
{
   unsigned int temp_buf;
   
   // test flash
  temp_buf = *((volatile unsigned int *)(0x20000100));
  temp_buf = *((volatile unsigned int *)(0x20000104));
  temp_buf = *((volatile unsigned int *)(0x20000108));
  
  temp_buf = *((volatile unsigned int *)(0x20000040));
  temp_buf = *((volatile unsigned int *)(0x20000044));
  temp_buf = *((volatile unsigned int *)(0x20000048));
  
   // test on chip ram
	*((volatile unsigned int *)(0x30000000)) = 0xab1122ef;
  temp_buf = *((volatile unsigned int *)(0x30000000));
	
	*((volatile unsigned char *)(0x30000001)) = 0xba;
	*((volatile unsigned char *)(0x30000002)) = 0xbe;

  temp_buf = *((volatile unsigned int *)(0x30000000));
  
  // test gpio 
  temp_buf = *((volatile unsigned int *)(0x60000000));
	*((volatile unsigned int *)(0x60000008)) = 0x000000ff;
	*((volatile unsigned int *)(0x60000014)) = 0x000000ff;
  temp_buf = *((volatile unsigned int *)(0x60000000));
  
  temp_buf = *((volatile unsigned int *)(0x61000000));
	*((volatile unsigned int *)(0x61000014)) = 0xffffffff;
	*((volatile unsigned int *)(0x61000008)) = 0xffffffff;
  temp_buf = *((volatile unsigned int *)(0x61000000));
  
  temp_buf = *((volatile unsigned int *)(0x66000000));
  
  temp_buf = *((volatile unsigned int *)(0x60000028));
  temp_buf = *((volatile unsigned int *)(0x6000002c));
  temp_buf = *((volatile unsigned int *)(0x60000040));
  temp_buf = *((volatile unsigned int *)(0x60400000));
  temp_buf = *((volatile unsigned int *)(0x6f000000));

	*((volatile unsigned int *)(0x5ffffffc)) = 0xcea5e0ff;
	
	// test serial port
  init_serial();
  
  NS16550_putc( 'q' );  
  NS16550_putc( 'a' );  
  NS16550_putc( 'z' );  
  NS16550_putc( '\n' ); 
  NS16550_putc( '\r' ); 

  puts( "arrg! arrg!!\n\r" );  

  
	*((volatile unsigned int *)(0x5ffffffc)) = 0xcea5e0ff;
	
  while(1) {};
            
  return 0;
}

