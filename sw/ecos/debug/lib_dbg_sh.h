//
//
//


#include <pkgconf/hal.h>
#include <cyg/hal/hal_if.h>
#include <cyg/hal/hal_tables.h>


// CLI support functions
// externC bool parse_num(char *s, unsigned long *val, char **es, char *delim);
// externC bool parse_bool(char *s, bool *val);

typedef void cmd_fun(int argc, char *argv[]);
struct cmd {
    char    *str;
    char    *help;
    char    *usage;
    cmd_fun *fun;
    struct cmd *sub_cmds, *sub_cmds_end;
} CYG_HAL_TABLE_TYPE;
// externC struct cmd *cmd_search(struct cmd *tab, struct cmd *tabend, char *arg);
// externC void        cmd_usage(struct cmd *tab, struct cmd *tabend, char *prefix);
#define RedBoot_cmd(_s_,_h_,_u_,_f_) cmd_entry(_s_,_h_,_u_,_f_,0,0,RedBoot_commands)
#define RedBoot_nested_cmd(_s_,_h_,_u_,_f_,_subs_,_sube_) cmd_entry(_s_,_h_,_u_,_f_,_subs_,_sube_,RedBoot_commands)
#define _cmd_entry(_s_,_h_,_u_,_f_,_subs_,_sube_,_n_)                                   \
cmd_fun _f_;                                                      \
struct cmd _cmd_tab_##_f_ CYG_HAL_TABLE_QUALIFIED_ENTRY(_n_,_f_) = {_s_, _h_, _u_, _f_, _subs_, _sube_};
#define cmd_entry(_s_,_h_,_u_,_f_,_subs_,_sube_,_n_)                                   \
extern _cmd_entry(_s_,_h_,_u_,_f_,_subs_,_sube_,_n_)
#define local_cmd_entry(_s_,_h_,_u_,_f_,_n_)                             \
static _cmd_entry(_s_,_h_,_u_,_f_,0,0,_n_)

#define CYGBLD_REDBOOT_MAX_MEM_SEGMENTS 1
#define CYGNUM_REDBOOT_CMD_LINE_EDITING 16

#define MAX_ARGV 16

// Option processing support

struct option_info {
    char flag;
    bool takes_arg;
    int  arg_type;
    void *arg;
    bool *arg_set;
    char *name;
};

#define NUM_ELEMS(s) (sizeof(s)/sizeof(s[0]))

#define OPTION_ARG_TYPE_NUM 0    // Numeric data
#define OPTION_ARG_TYPE_STR 1    // Generic string
#define OPTION_ARG_TYPE_FLG 2    // Flag only


// Command line parsing
externC struct cmd *parse(char **line, int *argc, char **argv);

externC void init_opts(struct option_info *opts, char flag, bool takes_arg, 
                       int arg_type, void *arg, bool *arg_set, char *name);
externC bool scan_opts(int argc, char *argv[], int first, 
                       struct option_info *opts, int num_opts, 
                       void *def_arg, int def_arg_type, char *def_descr);


// RedBoot_cmd(
//   "iopeek",
//   "Read I/O location",
//   "[-b <location>] [-1|2|4]",
//   do_iopeek
// );

// RedBoot_cmd(
//   "iopoke",
//   "Write I/O location",
//   "[-b <location>] [-1|2|4] -v <value>",
//   do_iopoke
// );


// static void do_memtest (int argc, char *argv[]);
//     
// RedBoot_cmd(
//   "memtest", 
//   "Manage do_memtest", 
//   "-b <location> -l <length>", 
//   do_memtest
// );

    