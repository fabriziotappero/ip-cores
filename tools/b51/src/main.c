/**
    @file main.c
    @brief Entry point to b51 simulator.

    So farm this program is inly useful for the cosimulation of the light52 test
    bench. It does not simulate any peripheral hardware. Besides, this main
    program is just a stub: no argument parsing, for starters.

*/

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "b51_mcu.h"
#include "b51_cpu.h"
#include "b51_log.h"

/*-- Local file data ---------------------------------------------------------*/

/** Value of command line parameters */
static struct {
    char *hex_file_name;
    char *trace_logfile_name;
    char *console_logfile_name;
    uint32_t num_instructions;
    bool implement_bcd;
} args;



/*-- Local function prototypes -----------------------------------------------*/

static bool parse_command_line(int argc, char **argv);
static void usage(void);


/*-- Entry point -------------------------------------------------------------*/

int main(int argc, char **argv){
    cpu51_t cpu;
    int32_t retval;

    cpu_init(&cpu);

    /* Parse command line... */
    if(!parse_command_line(argc, argv)){
        exit(2);
    }
    /* ...and pass options to CPU model */
    cpu.options.bcd = args.implement_bcd;

    if(!cpu_load_code(&cpu, args.hex_file_name)){
        exit(1);
    }

    log_init(args.trace_logfile_name, args.console_logfile_name);
    printf("\n\n");

    //cpu_add_breakpoint(&cpu, 0x0003);
    cpu_reset(&cpu);
    retval = cpu_exec(&cpu, args.num_instructions);

    printf("\n\nExecution finished after %u instructions and %u cycles.\n",
           cpu.log.executed_instructions, cpu.cycles);

    switch(retval){
    case 1 :
        printf("Execution interrupted, cause unknown.\n");
        break;
    case 2 :
        printf("Execution hit a breakpoint.\n");
        break;
    default :
        printf("Execution loop returned invalid code %d\n", retval);
        break;
    }

    log_close();

    return 0;
}

/*-- local functions ---------------------------------------------------------*/

static bool parse_command_line(int argc, char **argv){
    uint32_t i;

    /* Fill command line arguments with default values */
    args.console_logfile_name = NULL; /* "console_log.txt"; */
    args.trace_logfile_name = "sw_log.txt";
    args.hex_file_name = NULL;
    args.num_instructions = 9e8;
    args.implement_bcd = false;

    for(i=1;i<argc;i++){
        if(strcmp(argv[i],"--nologs")==0){
            /* disable logging */
            args.console_logfile_name = NULL;
            args.trace_logfile_name = NULL;
        }
        else if(strncmp(argv[i],"--hex=", strlen("--hex="))==0){
            args.hex_file_name = &(argv[i][strlen("--hex=")]);
        }
        else if(strncmp(argv[i],"--log_con=", strlen("--log_con="))==0){
            args.console_logfile_name = &(argv[i][strlen("--log_con=")]);
        }
        else if(strncmp(argv[i],"--log=", strlen("--log="))==0){
            args.trace_logfile_name = &(argv[i][strlen("--log_con=")]);
        }
        else if(strncmp(argv[i],"--ninst=", strlen("--ninst="))==0){
            /* Number of instructions as decimal integer */
            if(sscanf(&(argv[i][strlen("--ninst=")]), "%u",
                      &(args.num_instructions))==0){
                printf("Error: expected decimal integer as argument of --ninst\n\n");
                return false;
            }
        }
        else if(strncmp(argv[i],"--bcd", strlen("--bcd"))==0){
            printf("Simulating BCD instructions.\n");
            args.implement_bcd = true;
        }
        else{
            printf("unknown argument '%s'\n\n",argv[i]);
            usage();
            return false;
        }
    }

    if(args.hex_file_name==NULL){
        printf("Error: Missing mandatory '--hex=' argument.\n");
        usage();
        return false;
    }

    return true;
}


static void usage(void){
    printf("B51: Batch-mode simulator for MCS51 architecture.\n\n");
    printf("Usage: b51 [options]\n\n");
    printf("Options:\n\n");
    printf("  --hex=<filename>       -"
           " (mandatory) Name of Intel HEX object code file.\n");
    printf("  --nint=<dec. number>   -"
           " No. of instructions to run. Defaults to a gazillion.\n");
    printf("  --nologs               -"
           " Disable console and execution logging.\n");
    printf("\n");
    printf("The program will load the object file, reset the CPU and execute "
           "the specified\nnumber of instructions, then quit.\n");
    printf("Simulation will only stop after <nint> instructions, when the CPU "
           "enters a\nsingle-instruction endless loop or on an error "
           "condition.\n\n");
}
