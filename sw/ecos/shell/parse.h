//
//
//


// Command line parsing
externC struct cmd *parse(char **line, int *argc, char **argv);

externC void init_opts(struct option_info *opts, char flag, bool takes_arg, 
                       int arg_type, void *arg, bool *arg_set, char *name);
externC bool scan_opts(int argc, char *argv[], int first, 
                       struct option_info *opts, int num_opts, 
                       void *def_arg, int def_arg_type, char *def_descr);

