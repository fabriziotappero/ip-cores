/*-----------------------------------------------------------*/

void sys_error_fatal( unsigned int error )
{
  (*( (volatile unsigned int *) (0x8000003c) )) = error;  // write to scratch pad reg in FPGA
  
 while(1) {}; 
}

