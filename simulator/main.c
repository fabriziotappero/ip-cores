#include <stdio.h>
#include <unistd.h>
#include <getopt.h>
#include <stdlib.h>
#include <err.h>
#include <string.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <signal.h>
#include <ctype.h>

#include "regs.h"
#include "instructions.h"
#include "memory.h"
#include "microcode.h"
#include "object.h"
#include "machine.h"
#include "debug.h"
#include "breakpoint.h"
#include "print.h"
#include "io.h"
#include "profiler.h"
//globals considered harmful
int sim_autorun;
char* sim_name;


void
usage(void)
{
	errx(1, "[-m memory file] [-s memory size] [-c microprogram file]");
}

void
dump_microcode_to_file(FILE *f)
{
	int i;
	for (i = 0; i < microcode_size(); i++) {
		print_instruction_to_file(f, i);
	}
}

void
dump_microcode(void)
{
	dump_microcode_to_file(stdout);
}

// Set this to 0 to jump out of the run loop
int stop_execution;

void
cmd_run(char *cmd)
{
	reg_t to_addr, nxt;
	int with_to_addr = 0;

	if (strlen(cmd) > 2) {
		sscanf(&cmd[2], "%X", &to_addr);
		with_to_addr = 1;
	}

	stop_execution = 0;
	while (machine_up()) {
		if (stop_execution)
			break;
		do_next_instruction();
		nxt = next_instr_addr();
		if (with_to_addr && nxt == to_addr) {
			printf("reached destination: ");
			print_instruction(nxt);
			return;
		}
		if (breakpoint_at(nxt)) {
			printf("breakpoint: ");
			print_instruction(nxt);
			return;
		}
	}
}

void
cmd_step(char *cmd)
{
	int n, i;

	if (strlen(cmd) > 2) {
		sscanf(&cmd[2], "%X", &n);
	} else {
		n = 1;
	}

	if (machine_up()) {
		for (i = 0; i < n; i++)
			do_next_instruction();
	} else {
		printf("cannot step instruction: machine down\n");
	}
}

void
cmd_print(char *cmd)
{
	char what;
	uint32_t start_addr;
	uint32_t end_addr;
	uint32_t addr;
	reg_t val = 0;

	if (strlen(cmd) < 4) {
		printf("what do you want me to print?\n");
		return;
	}

	what = cmd[2];
#if 0
	if (islower(what) && sscanf(&cmd[3], "%X", &addr) != 1) {
		fprintf(stderr, "an address, please\n");
		return;
	}
#endif

	if (what=='r') {
		int n;
		struct di_const *c;

		if (cmd[3] == ' ') {
			val = debug_get_key(&cmd[4], "reg");
			if (val == 0xdeadbeef) {
				printf("Unknown register: %s\n", &cmd[3]);
			} else {
				printf("Dumping register: 0x%X\n", val);
				val = reg_get(val);
				object_dump(val);
			}
		} else if((n = sscanf(&cmd[3], "%X-r%X", &start_addr,
		    &end_addr)) == 1) {
			c = debug_get1_filter(start_addr, "reg");
			if (c != NULL)
				printf("Named register: %s\n", c->name);
			if (start_addr < 0 || start_addr >= N_REGS) {
				printf("That is not a register!\n");
				return;
			}
			val=reg_get(start_addr);
			object_dump(val);
		} else if (n == 2) {
			for(uint32_t i=start_addr; i<=end_addr; i++)
			{
				c = debug_get1_filter(i, "reg");
				printf("r%X (%s):\n", i, c == NULL? "" : c->name);
				val=reg_get(i);
				object_dump(val);
			}
		} else {
			printf("Unknown print format\n");
		}
	} else if (what=='m') {
		struct di_const *c;

		if (sscanf(&cmd[3], "%X", &addr) != 1) {
			fprintf(stderr, "an address, please\n");
			return;
		}

		if (sscanf(&cmd[3], "%X-m%X", &addr, &end_addr)==1)
		        end_addr=addr;
		for(uint32_t i=addr; i<=end_addr; i++) {
		        c = debug_get1_filter(i, "memory");
			if (c != NULL)
			        printf("Named memory: %s (0x%X)\n", c->name, i);
			else if (addr < end_addr)
			        printf("Memory location 0x%X:\n",i);
  		        val = memory_get(i);
		        object_dump(val);
		}
	} else if (what=='s') {
		if (sscanf(&cmd[3], "%X", &addr) != 1) {
			fprintf(stderr, "an address, please\n");
			return;
		}
		print(addr);
		printf("\n");
	} else {
		printf("what is '%c'?\n", what);
		return;
	}
}

void
compact_print(reg_t object)
{
  	struct di_const *c;
	char *type;

	c = debug_get1_filter(OBJECT_TYPE(object), "type");
	if (c == NULL)
		type = "unknown";
	else
		type = c->name;
	printf("%-9s %d 0x%X\n",type, OBJECT_GC(object), OBJECT_DATUM(object));
}

void
cmd_compact_print(char *cmd)
{
        uint32_t start_addr;
	uint32_t end_addr;
	uint32_t n;
	char what;
	char a1[80],a2[80];
	reg_t val;
       
	if (strlen(cmd) < 4) {
	        printf("what do you want me to print?\n");
		return;
	}
	if (strlen(cmd) > 75) {
	        printf("too long command line, i refuse to parse.\n");
		return;
	}
	what = cmd[2];
	n = sscanf (cmd,"c %[rm]%X-%[rm]%X", a1, &start_addr, a2, &end_addr);
	if (n!= 4 || a1[0]!=a2[0]) {
	        printf("you didn't adhere to the correct syntax format.\n");
		return;
	}
	if (what == 'r') {
	        if (start_addr < 0 || end_addr >= N_REGS) {
		        printf("please enter a legal register range.\n");
			return;
		}
		for(uint32_t i=start_addr; i<=end_addr; i++) {
		        val = reg_get(i);
		        printf("r%X: ",i);
			compact_print(val);
		}
		
	} else if (what == 'm') {
	  /* TODO find out memory size */
	        if (start_addr < 0 /* || end_addr >= ?? */) {
		        printf("please enter a legal memory address range.\n");
			return;
		}
		for(uint32_t i=start_addr; i<=end_addr; i++) {
		        val = memory_get(i);
		        printf("m%X: ",i);
			compact_print(val);
		}
	}
	return;
}

void
cmd_breakpoint(char *cmd)
{
	int len = strlen(cmd);
	int arg;

	if (len == 1) {
		breakpoint_list();
		return;
	}
	if (len < 4) {
		printf("invalid b syntax\n");
		return;
	}

	arg = debug_get_key(&cmd[3], "label");
	if (arg == 0xdeadbeef) {
		if (sscanf(&cmd[3], "%X", &arg) != 1) {
			printf("No thingy\n");
			return;
		}
	}

	switch (cmd[1]) {
	case 's':
		breakpoint_set(arg);
		break;
	case 'd':
		breakpoint_del(arg);
		break;
	default:
		printf("invalid b syntax\n");
		return;
	}
}

void
cmd_toggle_instr_print(char *cmd)
{
	print_instructions = 1-print_instructions;
	printf("Instruction printing turned %s\n",
	       print_instructions ? "on" : "off");
}

void
cmd_help(char *cmd)
{
	printf("%s",
	       "commands:\n"
	       "r [ADDR] -- run to ADDR (if given) or breakpoint or halt\n"
	       "         (whichever occurs first)\n" "s [N]    -- step N (default 1) instructions\n"
	       "p rN     -- print register N\n"
	       "p rN-rM  -- print registers from N to M\n"
	       "p r name -- print register with that name\n"
	       "p mN     -- print memory cell N\n"
	       "p mN-mM  -- print memory cells from N to M\n"
	       "p sN     -- print S-expression starting at memory location N\n"
	       "c rN-rM  -- print registers from N to M in compact form\n"
	       "c mN-mM  -- print memory cells from N to M in compact form\n"
	       "b        -- list breakpoints\n"
	       "bs ADDR  -- set breakpoint\n"
	       "bd ADDR  -- delete breakpoint\n"
	       "d        -- dump microcode\n"
	       "i        -- turn instruction printing on/off\n"
	       "q        -- quit\n"
	       "h        -- help\n"
	       "(all numerical arguments are written hexadecimally)\n");
}

void
cmd_dump(char *cmd)
{
	printf("Microprogram listing:\n");
	dump_microcode();
	printf("\n");
}



void
command_loop(void)
{
	char lastcmd[512];

	lastcmd[0] = '\0';
	lastcmd[sizeof(lastcmd)-1] = '\0';
	for (;;) {
		char *cmd = readline("hwemu> ");
		if (cmd == NULL)
			cmd = "q"; //EOF
		if (cmd[0] == '\0' && lastcmd[0] != '\0')
			cmd = lastcmd;
		else
			strncpy(lastcmd, cmd, sizeof(lastcmd)-1);

		switch (cmd[0]) {
		case 'r':
			cmd_run(cmd);
			break;
		case 's':
			cmd_step(cmd);
			break;
		case 'p':
			cmd_print(cmd);
			break;
		case 'b':
			cmd_breakpoint(cmd);
			break;
		case 'q':
			printf("happy happy joy joy\n");
			return;
		case 'h':
			cmd_help(cmd);
			break;
		case 'd':
			cmd_dump(cmd);
			break;
		case 'i':
			cmd_toggle_instr_print(cmd);
			break;
		case 'c':
		  cmd_compact_print(cmd);
			break;
		case 'z': 
			profiler_dump_program(sim_name);
			profiler_new();
			break;
		default:
			printf("?\n");
		}
		if (cmd != lastcmd)
			free(cmd);
	}
}

/*
 * Signal handlers
 */
void
sig_stop_execution(int sig)
{
	stop_execution = 1;
	signal(SIGINT, sig_stop_execution);
}

extern int verify_written_memory;
int
main(int argc, char **argv)
{
	int opt;
	unsigned int availmem;
	char *microcodepath, *memorypath, *regpath;
	int cache_size = 0;
	unsigned int branch_buffer_size = 0;
	char* branch_pred_scheme = NULL;
	sim_autorun = 0;

	io_init();

	availmem = DEFAULT_MEMORY_SIZE;
	microcodepath = "/tmp/microcode";
	memorypath = NULL; //"memory.bin";
	regpath = NULL;
	verify_written_memory = 0;
	while ((opt = getopt(argc, argv, "t:h:a:s:c:m:r:f:Mz:")) != -1) {
		switch (opt) {
		case 't':
			branch_pred_scheme = strdup(optarg);
			break;
		case 'h':
			branch_buffer_size = atoi(optarg);
			printf("Branch buffer size: %u\n", branch_buffer_size);
			break;
		case 'a':
			printf("Cache size: %s\n",optarg);
			cache_size = atoi(optarg);
			break;
		case 'c':
			microcodepath = optarg;
			break;
		case 's':
			availmem = atoi(optarg);
			printf("Size of memory: %x\n", availmem);
			break;
		case 'm':
			memorypath = optarg;
			break;
		case 'r':
			regpath = optarg;
			break;
		case 'f':
			if (strlen(optarg) < 3 || optarg[1] != ':') {
				printf("invalid -f argument '%s'\n", optarg);
				usage();
			}
			switch (optarg[0]) {
			case 'b': io_set_file(DEV_BOOT, &optarg[2]); break;
			case 'k': io_set_files(DEV_TERMINAL, &optarg[2], NULL); break;
			case 's': io_set_files(DEV_TERMINAL, NULL, &optarg[2]); break;
			case 'i': io_set_files(DEV_SERIAL, &optarg[2], NULL); break;
			case 'o': io_set_files(DEV_SERIAL, NULL, &optarg[2]); break;
			case 'f': io_set_file(DEV_STORAGE, &optarg[2]); break;
			}
			break;
		case 'M':
			verify_written_memory = 1;
			break;
		case 'z':
			printf("simulation name: %s\n", optarg);
			sim_name = strdup(optarg);
			sim_autorun = 1;
			break;
		default:
			usage();
		}
	}


	signal(SIGINT, sig_stop_execution);
	debug_init(microcodepath);
	machine_init(microcodepath, memorypath, availmem, regpath, cache_size);
	machine_shutup();
	if(sim_autorun == 1){
		sim_init(sim_name, microcode_size(), cache_size, availmem, branch_buffer_size, branch_pred_scheme);
	}
//	else 
//		sim_init(NULL, "gurba", microcode_size(), 512, availmem, branch_buffer_size);

	/*
	printf("Microprogram listing:\n");
	dump_microcode();
	printf("\n");
	*/

	//FILE *mcdumpfile = fopen("mcdump.txt", "w");
	//dump_microcode_to_file(mcdumpfile);
	//fclose(mcdumpfile);

	printf("Starting execution\n");
	if(sim_autorun == 1){
		printf("Starting simulation autorun.\n");
		cmd_run("");
		printf("Done with simulation. Going to write file now...\n");
		profiler_dump_program(sim_name);
	} else {
		command_loop();
	}

//	FILE *profilingfile = fopen("profiling.txt", "w");
//	profiler_dump_program(profilingfile);
//	fclose(profilingfile);

	return 0;
}
