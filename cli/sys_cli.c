/*-----------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "sys_cmd.h"
#include "sys_drivers.h"
#include "sys_error.h"

#define ASCII_ESC '\x1b'


/*-----------------------------------------------------------*/
static int cmd_cmp( const void *e1, const void *e2 )
{
  struct cli_cmd_tab_t *p_cmd_1 = (struct cli_cmd_tab_t *)e1;
  struct cli_cmd_tab_t *p_cmd_2 = (struct cli_cmd_tab_t *)e2;

  return strncmp( p_cmd_1->cmd, p_cmd_2->cmd, MAX_CMD_LENGTH );
}


/*-----------------------------------------------------------*/
static void send_csi( char c )
{
  putchar( ASCII_ESC );
  putchar( '[' );
  putchar( c );
}


/*-----------------------------------------------------------*/
static char *cli_edit_buffer( char *in_buffer, char *out_buffer, unsigned int line_length )
{
  static char *out_ptr;
  static char *begin_ptr;
  static char *end_ptr;
  static char prev_char;
  static unsigned int csi;

  unsigned int i;

  if( out_buffer != NULL )
  {
    out_ptr   = out_buffer;
    begin_ptr = out_buffer;
    end_ptr   = out_buffer + INPUT_LINE_LENGTH;

    prev_char = 0;
    csi = 0;
  }

  for( i = 0 ; i < line_length ; i++ )
  {

    if( out_ptr >= end_ptr )
    {
      *end_ptr = '\0';
      return( NULL );
    }
    
    if( out_ptr < begin_ptr )
      sys_error_fatal( FATAL_ERROR_CLI );

    switch( in_buffer[i] )
    {
      case '\0':
        return( NULL );
        break;

      case '\n':
        break;

      case '\r':
        *out_ptr = '\0';
        return( NULL );
        break;

      case '\b':
        if( out_ptr != begin_ptr )
        {
          send_csi( 'P' );
          out_ptr--;
        } else
        {
          putchar( ' ' );
          send_csi( '\a' );
        }          
        
        break;

      case ASCII_ESC:
        break;

      case '[':
        if( prev_char == ASCII_ESC )
        {
          csi = 1;
        } else 
        {           
          *out_ptr = in_buffer[i];
          out_ptr++;
        }
        break;

      case 'A':
        if( csi )
        {
          send_csi( 'B' );
          send_csi( '\a' );

          csi = 0;
        } else
        {
          *out_ptr = in_buffer[i];
          out_ptr++;
        }
        break;

      case 'B':
        if( csi == 0 )
        {
          *out_ptr = in_buffer[i];
          out_ptr++;
        }
        break;

      case 'C':
        if( csi )
        {
          send_csi( 'D' );
          send_csi( '\a' );

          csi = 0;
        } else
        {
          *out_ptr = in_buffer[i];
          out_ptr++;
        }
        break;

      case 'D':
        if( csi )
        {
          send_csi( 'C' );
          send_csi( '\a' );

          csi = 0;
        } else
        {
          *out_ptr = in_buffer[i];
          out_ptr++;
        }
        break;

      default:
        *out_ptr = in_buffer[i];
        out_ptr++;
        break;
    }

    prev_char = in_buffer[i];
  }

  return( out_ptr );
}


/*-----------------------------------------------------------*/
void sys_cli_task( void *pvParameters )
{
  char last_return_value = EXIT_SUCCESS;
  char in_buffer[16];
  char out_buffer[INPUT_LINE_LENGTH];
  char *cli_ptr;
  struct cli_cmd_tab_t cmd_to_check = { "", NULL };
  unsigned char cli_argc;
  char *cli_argv[MAX_CLI_ARGC];
  struct cli_cmd_tab_t *cli_cmd;
  unsigned int bytes_read;
  
  iprintf( "\r\n" );

  for( ;; )
  {
   iprintf( "%d > ", last_return_value );
    iprintf( "# " );

    cli_argc = 0;
    last_return_value = EXIT_SUCCESS;

    bytes_read = (unsigned int)read( FD_UART_2, (void *)in_buffer, sizeof(in_buffer) );
    cli_ptr = cli_edit_buffer( in_buffer, out_buffer, bytes_read );

    while( cli_ptr != NULL )
    {
      bytes_read = (unsigned int)read( FD_UART_2, (void *)in_buffer, sizeof(in_buffer) );
      cli_ptr = cli_edit_buffer( in_buffer, NULL, bytes_read );
    }

    if( out_buffer[0] == '\0' )
    {
      iprintf( "\r\n NULL String! Command ignored\r\n" );
      last_return_value = EXIT_FAILURE;
    }

    while( last_return_value != EXIT_FAILURE )
    {
      cli_ptr = strtok( out_buffer, " \t" );

      strncpy( cmd_to_check.cmd, out_buffer, MAX_CMD_LENGTH );
      cli_cmd = (struct cli_cmd_tab_t *) bsearch( &cmd_to_check, cli_commands, NO_OF_COMMANDS, sizeof(struct cli_cmd_tab_t), cmd_cmp );

      if ( cli_cmd == NULL )
      {
        iprintf( "\r\nCommand not found!\r\n" );
        last_return_value = EXIT_FAILURE;
        break;
      }

      if( cli_ptr == NULL )
      {
        cli_argv[cli_argc] = out_buffer;
        cli_argc++;
      } else
      {
        while( cli_ptr != NULL )
        {
          cli_argv[cli_argc] = cli_ptr;
          cli_argc++;

          cli_ptr = strtok( NULL, " \t" );
        }
      }

      last_return_value = cli_cmd->func( cli_argc, (const char **)cli_argv );
      break;
    }

  }
}

