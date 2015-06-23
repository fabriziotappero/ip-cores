//
//
//

#include <stdio.h>
#include "LPC22xx.h"

#include <cyg/error/codes.h>
#include <cyg/io/io.h>
#include <cyg/io/ttyio.h>

#include "lib_dbg_sh.h"
#include "parse.h"

#include "shell_cmds.h"


//--------------------------------------------------------------------------
//
//
RedBoot_cmd("help",
            "Help about help?",
            "[<topic>]",
            do_help
    );

void
show_help(struct cmd *cmd, struct cmd *cmd_end, char *which, char *pre)
{
    bool show;
    int len = 0;

    if (which) {
        len = strlen(which);
    }
    while (cmd != cmd_end) {
        show = true;
        if (which && (strncasecmp(which, cmd->str, len) != 0)) {
            show = false;
        }
        if (show) {
            printf("%s\n  %s %s %s\n", cmd->help, pre, cmd->str, cmd->usage);
            if ((cmd->sub_cmds != (struct cmd *)0) && (which != (char *)0)) {
                show_help(cmd->sub_cmds, cmd->sub_cmds_end, 0, cmd->str);
            }
        }
        cmd++;
    }
}

void
do_help(int argc, char *argv[])
{
    struct cmd *cmd;
    char *which = (char *)0;

    if (!scan_opts(argc, argv, 1, 0, 0, (void *)&which, OPTION_ARG_TYPE_STR, "<topic>")) {
        printf("Invalid argument\n");
        return;
    }
    cmd = __RedBoot_CMD_TAB__;
    show_help(cmd, &__RedBoot_CMD_TAB_END__, which, "");
    return;
}


void dbg_sh(void)
{
  char buffer[256];

  char *command;
  struct cmd *cmd;

  int argc;
  char *argv[16];

  while(1)
  {
    printf( "dbg_sh> " );

    gets( buffer );
    command = buffer;
    
    if( strlen(command) > 0 )
    {
      if ((cmd = parse(&command, &argc, &argv[0])) != (struct cmd *)0)
      {
          (cmd->fun)(argc, argv);
      } else
      {
          printf("** Error: Illegal command: \"%s\"\n", argv[0]);
      }
    } 
  }
}


