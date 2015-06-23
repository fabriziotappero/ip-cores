/*-----------------------------------------------------------*/

 typedef enum
{
  FATAL_ERROR_CLI = 0,
  FATAL_ERROR_FD_SSP0_0,
} sys_error_fatal_type;


/*-----------------------------------------------------------*/
void sys_error_fatal( unsigned int error );

