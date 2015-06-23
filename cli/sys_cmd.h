/*-----------------------------------------------------------*/


#ifndef _QAZ_SYS_CMD_H_
#define _QAZ_SYS_CMD_H_

#define INPUT_LINE_LENGTH   40
#define MAX_CMD_LENGTH      11
#define MAX_CLI_ARGC        6
#define NO_OF_COMMANDS      5


typedef char (*cli_cmd_func)( const unsigned char argc, const char * argv[] );

struct cli_cmd_tab_t
{
  char          cmd[MAX_CMD_LENGTH];
  cli_cmd_func  func;
  const char    *help_string;
};

extern struct cli_cmd_tab_t cli_commands[NO_OF_COMMANDS];


/*-----------------------------------------------------------*/
extern char func_ssp0( const unsigned char argc, const char *argv[] );


#endif  //  _QAZ_SYS_CMD_H_
