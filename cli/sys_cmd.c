#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sys_cmd.h"


/*-----------------------------------------------------------*/
static char func_help( const unsigned char argc, const char *argv[] )
{
  unsigned int i;

  iprintf( "Usage: cmd <arg1> <arg2> <arg3> ...\r\n" );
  iprintf( "\r\n" );
  iprintf( "Commands:\r\n" );

  for( i = 0; i < NO_OF_COMMANDS; i++ )
    puts( cli_commands[i].help_string );

  return EXIT_SUCCESS;
}


/*-----------------------------------------------------------*/
static char func_peek( const unsigned char argc, const char *argv[] )
{
  volatile unsigned int *address = (volatile unsigned int *)( strtoul( argv[1], (char **)NULL, 16 ) );

  iprintf( "peek: %s => 0x%08x \r\n", argv[1], *address  );

  return EXIT_SUCCESS;
}


/*-----------------------------------------------------------*/
static char func_poke( const unsigned char argc, const char *argv[] )
{
  volatile unsigned int *address  = (volatile unsigned int *)( strtoul( argv[1], (char **)NULL, 16 ) );
  unsigned int value              = strtoul( argv[2], (char **)NULL, 16 );

  *((volatile unsigned int *)address) = value;

  iprintf( "poke: %s <= %s \r\n", argv[1], argv[2]  );

  return EXIT_SUCCESS;
}


/*-----------------------------------------------------------*/
#include "memtest.h"

static char func_memtest( const unsigned char argc, const char *argv[] )
{
  datum *address        = (datum *)( strtoul( argv[1], (char **)NULL, 16 ) );
  unsigned long nBytes  = strtoul( argv[2], (char **)NULL, 16 );

  if( argc != 3 || address == NULL || nBytes == 0 )
  {
    iprintf( "memtest:  bad args \r\n" );
    return( EXIT_FAILURE );
  }

  iprintf( "running memTestDataBus() ...   " );

  if( memTestDataBus( address ) )
    iprintf( "FAILED!!!\r\n" );
  else
    iprintf( "PASSED\r\n" );


  iprintf( "running memTestAddressBus() ...   " );

  if( memTestAddressBus( address, nBytes ) )
    iprintf( "FAILED!!!\r\n" );
  else
    iprintf( "PASSED\r\n" );


  iprintf( "running memTestDevice() ...   " );

  if( memTestDevice( address, nBytes ) )
    iprintf( "FAILED!!!\r\n" );
  else
    iprintf( "PASSED\r\n" );

    return EXIT_SUCCESS;
}


/*-----------------------------------------------------------*/
struct cli_cmd_tab_t cli_commands[NO_OF_COMMANDS] =
{
  { "help",       func_help,        "\t help\t\t print this help message\r" },
  { "memtest",    func_memtest,     "\t memtest\t memtest 0x<base_address> 0x<size>\r" },
  { "peek",       func_peek,        "\t peek\t\t peek <address>\r"  },
  { "poke",       func_poke,        "\t poke\t\t poke <address> <value> \r" },
  { "ssp0",       func_ssp0,        "\t ssp0\t\t ssp0 <command> \r" },
};


