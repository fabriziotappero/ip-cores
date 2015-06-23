/*------------------------------------------------------------------------------
* slite.c -- MIPS-I simulator based on Steve Rhoad's "mlite"
*
* This is a heavily modified version of Steve Rhoad's "mlite" simulator, which
* is part of his PLASMA project (original date: 1/31/01).
*
*-------------------------------------------------------------------------------
* Usage:
*     slite [options]
*
* See function 'usage' for a very brief explaination of the available options.
*
* Generally, upon startup the program will allocate some RAM for the simulated
* system and initialize it with the contents of one or more plain binary,
* big-endian object files. Then it will simulate a cpu reset and start the
* simulation, in interactive or batch mode.
*
* A simulation log file will be dumped to file "sw_sim_log.txt". This log can be
* used to compare with an equivalent log dumped by the hardware simulation, as
* a simple way to validate the hardware for a given program. See the project
* readme files for details.
*
*-------------------------------------------------------------------------------
* This program simulates the CPU connected to a certain memory map (chosen from
* a set of predefined options) and to a UART.
* The UART is hardcoded at a fixed address and is not configurable in runtime.
* The simulated UART includes the real UART status bits, hardcoded to 'always
* ready' so that software and hardware simulations can be made identical with
* more ease (no need to simulate the actual cycle count of TX/RX, etc.).
*-------------------------------------------------------------------------------
* KNOWN BUGS:
*
*-------------------------------------------------------------------------------
* @date 2011-jan-16
*
*-------------------------------------------------------------------------------
* COPYRIGHT:    Software placed into the public domain by the author.
*               Software 'as is' without warranty.  Author liable for nothing.
*
* IMPORTANT: Assumes host is little endian and target is big endian.
*-----------------------------------------------------------------------------*/

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>

/** CPU identification code (contents of register CP0[15], PRId */
#define R3000_ID (0x00000200)

/** Number of hardware interrupt inputs (irq0 is NMI) */
#define NUM_HW_IRQS (8)

/** Set to !=0 to disable file logging (much faster simulation) */
/* alternately you can just set an unreachable log trigger address */
#define FILE_LOGGING_DISABLED (0)
/** Define to enable cache simulation (unimplemented) */
//#define ENABLE_CACHE
/** Set to !=0 to display a fancier listing of register values */
#define FANCY_REGISTER_DISPLAY (1)


/*---- Definition of simulated system parameters -----------------------------*/

#define VECTOR_RESET (0xbfc00000)
#define VECTOR_TRAP  (0xbfc00180)

/** Definition of a memory block */
typedef struct s_block {
    uint32_t start;
    uint32_t size;
    uint32_t mask;
    uint32_t read_only;
    uint8_t  *mem;
    char     *area_name;
} t_block;

#define NUM_MEM_BLOCKS      (4)
#define NUM_MEM_MAPS        (4)

/** Definition of a memory map */
/* FIXME i/o addresses missing, hardcoded */
typedef struct s_map {
    t_block blocks[NUM_MEM_BLOCKS];
} t_map;



/*  Here's where we define the memory areas (blocks) of the system.

    The blocks should be defined in this order: BRAM, XRAM, FLASH

    BRAM is FPGA block ram initialized with bootstrap code
    XRAM is external SRAM
    FLASH is external flash

    Give any area a size of 0x0 to leave it unused.

    When a binary file is specified in the cmd line for one of these areas, it
    will be used to initialize it, checking bounds.

    Memory decoding is done in the order the blocks are defined; the address
    is anded with field .mask and then compared to field .start. If they match
    the address modulo the field .size is used to index the memory block, giving
    a 'mirror' effect. All of this simulates how the actual hardware works.
    Make sure the blocks don't overlap or the scheme will fail.
*/

#define MAP_DEFAULT         (0)
#define MAP_UCLINUX_BRAM    (1)  /* debug only */
#define MAP_SMALL           (2)
#define MAP_UCLINUX         (3)

t_map memory_maps[NUM_MEM_MAPS] = {
    {/* Experimental memory map (default) */
        {/* Bootstrap BRAM, read only */
        {VECTOR_RESET,  0x00008000, 0xf8000000, 1, NULL, "Boot BRAM"},
        /* main external ram block  */
        {0x00000000,    0x00080000, 0xf8000000, 0, NULL, "XRAM0"},
        /* main external ram block  */
        {0x80000000,    0x00080000, 0xf8000000, 0, NULL, "XRAM1"},
        /* external flash block */
        {0xb0000000,    0x00040000, 0xf8000000, 0, NULL, "Flash"},
        }
    },

    {/* uClinux memory map with bootstrap BRAM, debug only, to be removed */
        {/* Bootstrap BRAM, read only */
        {VECTOR_RESET,  0x00008000, 0xf8000000, 1, NULL, "Boot BRAM"},
        /* main external ram block  */
        {0x80000000,    0x00800000, 0xf8000000, 0, NULL, "XRAM0"},
        {0x00000000,    0x00800000, 0xf8000000, 0, NULL, "XRAM1"},
        /* external flash block */
        {0xb0000000,    0x00100000, 0xf8000000, 0, NULL, "Flash"},
        }
    },

    {/* Experimental memory map with small XRAM */
        {/* Bootstrap BRAM, read only */
        {VECTOR_RESET,  0x00008000, 0xf8000000, 1, NULL, "Boot BRAM"},
        /* main external ram block  */
        {0x00000000,    0x00001000, 0xf8000000, 0, NULL, "XRAM0"},
        /* main external ram block  */
        {0x80000000,    0x00001000, 0xf8000000, 0, NULL, "XRAM1"},
        /* external flash block */
        {0xb0000000,    0x00040000, 0xf8000000, 0, NULL, "Flash"},
        }
    },

    {/* uClinux memory map with FLASH and XRAM */
        {/* Flash mapped at two different addresses is actually meant to be
            a single chip (note they have the same size). */
         /* E.g. put the bootloader at 0xbfc00000 and the romfs at 0xb0020000;
            chip offsets will be 0x0 and 0x20000. */
         /* Don't forget there's no address translation here. */
        {0xbfc00000,    0x00400000, 0xf8000000, 1, NULL, "Flash (bootloader)"},
        {0xb0000000,    0x00400000, 0xf8000000, 1, NULL, "Flash (romfs)"},
        /* main external ram block (kernal & user areas ) */
        {0x80000000,    0x00200000, 0xf8000000, 0, NULL, "XRAM (kernel)"},
        {0x00000000,    0x00400000, 0xf8000000, 0, NULL, "XRAM (user)"},
        }
    },
};


/*---- end of system parameters ----------------------------------------------*/


/** Values for the command line arguments */
typedef struct s_args {
    /** !=0 to trap on unimplemented opcodes, 0 to print warning and NOP */
    uint32_t trap_on_reserved;
    /** !=0 to emulate some common mips32 opcodes */
    uint32_t emulate_some_mips32;
    /** Prescale value used for the timer/counter */
    uint32_t timer_prescaler;
    /** address to start execution from (by default, reset vector) */
    uint32_t start_addr;
    /** memory map to be used */
    uint32_t memory_map;
    /** implement unaligned load/stores (don't just trap them) */
    uint32_t do_unaligned;
    /** start simulation without showing monitor prompt and quit on
        end condition -- useful for batch runs */
    uint32_t no_prompt;
    /** breakpoint address (0xffffffff if unused) */
    uint32_t breakpoint;
    /** a code fetch from this address starts logging */
    uint32_t log_trigger_address;
    /** full name of log file */
    char *log_file_name;
    /** bin file to load to each area or null */
    char *bin_filename[NUM_MEM_BLOCKS];
    /** map file to be used for function call tracing, if any */
    char *map_filename;
    /** offset into area (in bytes) where bin will be loaded */
    /* only used when loading a linux kernel image */
    uint32_t offset[NUM_MEM_BLOCKS];
} t_args;
/** Parse cmd line args globally accessible */
t_args cmd_line_args;


/*---- Endianess conversion macros -------------------------------------------*/

#define ntohs(A) ( ((A)>>8) | (((A)&0xff)<<8) )
#define htons(A) ntohs(A)
#define ntohl(A) ( ((A)>>24) | (((A)&0xff0000)>>8) | (((A)&0xff00)<<8) | ((A)<<24) )
#define htonl(A) ntohl(A)

/*---- OS-dependent support functions and definitions ------------------------*/
#ifndef WIN32
//Support for Linux
#define putch putchar
#include <termios.h>
#include <unistd.h>

void slite_sleep(unsigned int value){
    usleep(value * 1000);
}

int kbhit(void){
    struct termios oldt, newt;
    struct timeval tv;
    fd_set read_fd;

    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    tv.tv_sec=0;
    tv.tv_usec=0;
    FD_ZERO(&read_fd);
    FD_SET(0,&read_fd);
    if(select(1, &read_fd, NULL, NULL, &tv) == -1){
        return 0;
    }
    //tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    if(FD_ISSET(0,&read_fd)){
        return 1;
    }
    return 0;
}

int getch(void){
    struct termios oldt, newt;
    int ch;

    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    ch = getchar();
    //tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    return ch;
}
#else
//Support for Windows
#include <conio.h>
extern void __stdcall Sleep(unsigned long value);

void slite_sleep(unsigned int value){
    Sleep(value);
}

#endif
/*---- End of OS-dependent support functions and definitions -----------------*/

/*---- Hardware system parameters --------------------------------------------*/

/* Much of this is a remnant from Plasma's mlite and is  no longer used. */
/* FIXME Refactor HW system params */

#define DBG_REGS          (0x20010000)
#define UART_WRITE        (0x20000000)
#define UART_READ         (0x20000000)
#define UART_STATUS       (0x20000004)
#define TIMER_READ        (0x20000100)

#define DEFAULT_TIMER_PRESCALER (50)

/* FIXME The following addresses are remnants of Plasma to be removed */
#define IRQ_MASK          0x20000010
#define IRQ_STATUS        0x20000020
#define CONFIG_REG        0x20000070
#define MMU_PROCESS_ID    0x20000080
#define MMU_FAULT_ADDR    0x20000090
#define MMU_TLB           0x200000a0

#define IRQ_UART_READ_AVAILABLE  0x002
#define IRQ_UART_WRITE_AVAILABLE 0x001
#define IRQ_COUNTER18_NOT        0x004
#define IRQ_COUNTER18            0x008
#define IRQ_MMU                  0x200

/*----------------------------------------------------------------------------*/

/* These are flags that will be used to notify the main cycle function of any
   failed assertions in its subfunctions. */
#define ASRT_UNALIGNED_READ         (1<<0)
#define ASRT_UNALIGNED_WRITE        (1<<1)

char *assertion_messages[2] = {
   "Unaligned read",
   "Unaligned write"
};


/** Length of debugging jump target queue */
#define TRACE_BUFFER_SIZE (32)

/** Assorted debug & trace info */
typedef struct s_trace {
   unsigned int buf[TRACE_BUFFER_SIZE];   /**< queue of last jump targets */
   unsigned int next;                     /**< internal queue head pointer */
   FILE *log;                             /**< text log file or NULL */
   int log_triggered;                     /**< !=0 if log has been triggered */
   uint32_t log_trigger_address;          /**< */
   int pr[32];                            /**< last value of register bank */
   int hi, lo, epc, status;               /**< last value of internal regs */
   int disasm_ptr;                        /**< disassembly pointer */
   /** Instruction cycles remaining to trigger irq[i], or -1 if irq inactive */
   int32_t irq_trigger_countdown[NUM_HW_IRQS];  /**< (in instructions) */
} t_trace;

typedef struct s_state {
   unsigned failed_assertions;            /**< assertion bitmap */
   unsigned faulty_address;               /**< addr that failed assertion */
   uint32_t do_unaligned;                 /**< !=0 to enable unaligned L/S */
   uint32_t breakpoint;                   /**< BP address of 0xffffffff */

   int delay_slot;              /**< !=0 if prev. instruction was a branch */
   uint32_t instruction_ctr;    /**< # of instructions executed since reset */
   uint32_t inst_ctr_prescaler; /**< Prescaler counter for instruction ctr. */
   uint32_t debug_regs[16];     /**< Rd/wr debug registers */

   int r[32];
   int opcode;
   int pc, pc_next, epc;
   uint32_t op_addr;            /**< address of opcode being simulated */
   unsigned int hi;
   unsigned int lo;
   int status;
   int32_t trap_cause;          /**< temporary trap code or <0 if no trap */
   unsigned cp0_cause;
   int userMode;                /**< DEPRECATED, to be removed */
   int processId;               /**< DEPRECATED, to be removed */
   int faultAddr;               /**< DEPRECATED, to be removed */
   int irqStatus;               /**< DEPRECATED, to be removed */
   int skip;
   t_trace t;
   t_block blocks[NUM_MEM_BLOCKS];
   int wakeup;
   int big_endian;
} t_state;

static char *reg_names[]={
    "zero","at","v0","v1","a0","a1","a2","a3",
    "t0","t1","t2","t3","t4","t5","t6","t7",
    "s0","s1","s2","s3","s4","s5","s6","s7",
    "t8","t9","k0","k1","gp","sp","s8","ra"
};

static char *opcode_string[]={
   "0SPECIAL","0REGIMM","1J","1JAL","2BEQ","2BNE","3BLEZ","3BGTZ",
   "5ADDI","5ADDIU","5SLTI","5SLTIU","5ANDI","5ORI","5XORI","6LUI",
   "cCOP0","cCOP1","cCOP2","cCOP3","2BEQL","2BNEL","3BLEZL","3BGTZL",
   "0?","0?","0?","0?","0SPECIAL2","0?","0?","0SPECIAL3",
   "8LB","8LH","8LWL","8LW","8LBU","8LHU","8LWR","0?",
   "8SB","8SH","8SWL","8SW","0?","0?","8SWR","0CACHE",
   "0LL","0LWC1","0LWC2","0LWC3","?","0LDC1","0LDC2","0LDC3"
   "0SC","0SWC1","0SWC2","0SWC3","?","0SDC1","0SDC2","0SDC3"
};

static char *special_string[]={
   "4SLL","0?","4SRL","4SRA","bSLLV","0?","bSRLV","bSRAV",
   "aJR","aJALR","0MOVZ","0MOVN","0SYSCALL","0BREAK","0?","0SYNC",
   "0MFHI","0MTHI","0MFLO","0MTLO","0?","0?","0?","0?",
   "0MULT","0MULTU","0DIV","0DIVU","0?","0?","0?","0?",
   "7ADD","7ADDU","7SUB","7SUBU","7AND","7OR","7XOR","7NOR",
   "0?","0?","7SLT","7SLTU","0?","0DADDU","0?","0?",
   "7TGE","7TGEU","7TLT","7TLTU","7TEQ","0?","7TNE","0?",
   "0?","0?","0?","0?","0?","0?","0?","0?"
};

static char *regimm_string[]={
   "9BLTZ","9BGEZ","9BLTZL","9BGEZL","0?","0?","0?","0?",
   "0TGEI","0TGEIU","0TLTI","0TLTIU","0TEQI","0?","0TNEI","0?",
   "9BLTZAL","9BEQZAL","9BLTZALL","9BGEZALL","0?","0?","0?","0?",
   "0?","0?","0?","0?","0?","0?","0?","0?"
};
/*
static char *special2_string[]={
    "0MADD","0MADDU","0MUL","0?",  "0?","0?","0?","0?",
    "0?","0?","0?","0?",  "0?","0?","0?","0?",
    "0?","0?","0?","0?",  "0?","0?","0?","0?",
    "0?","0?","0?","0?",  "0?","0?","0?","0?",

    "0CLZ","0CLO","0?","0?",  "0?","0?","0?","0?",
    "0?","0?","0?","0?",  "0?","0?","0?","0?",
    "0?","0?","0?","0?",  "0?","0?","0?","0?",
    "0?","0?","0?","0?",  "0?","0?","0?","0?",
};
*/

/** local memory used by the console simulation code */
static unsigned int HWMemory[8];

#define MAP_MAX_FUNCTIONS  (400)
#define MAP_MAX_NAME_LEN   (80)

/** Information extracted from the map file, if any */
typedef struct {
    uint32_t num_functions;         /**< number of functions in the table */
    FILE *log;                      /**< text log file or stdout */
    char *log_filename;             /**< name of log file or NULL */
    uint32_t fn_address[MAP_MAX_FUNCTIONS];
    char fn_name[MAP_MAX_FUNCTIONS][MAP_MAX_NAME_LEN];
} t_map_info;

t_map_info map_info;

/*---- Local function prototypes ---------------------------------------------*/

/* Debug and logging */
void init_trace_buffer(t_state *s, t_args *args);
void close_trace_buffer(t_state *s);
void dump_trace_buffer(t_state *s);
uint32_t log_cycle(t_state *s);
void log_read(t_state *s, int full_address, int word_value, int size, int log);
void log_failed_assertions(t_state *s);
uint32_t log_enabled(t_state *s);
void trigger_log(t_state *s);
void print_opcode_fields(uint32_t opcode);
void reserved_opcode(uint32_t pc, uint32_t opcode, t_state* s);
int32_t read_map_file(char *filename, t_map_info* map);
void log_call(uint32_t to, uint32_t from);
void log_ret(uint32_t to, uint32_t from);
int32_t function_index(uint32_t address);

int32_t parse_cmd_line(uint32_t argc, char **argv, t_args *args);
void usage(void);

/* CPU model */
void free_cpu(t_state *s);
int init_cpu(t_state *s, t_args *args);
void reset_cpu(t_state *s);
void unimplemented(t_state *s, const char *txt);
void reverse_endianess(uint8_t *data, uint32_t bytes);

/* Hardware simulation */
int mem_read(t_state *s, int size, unsigned int address, int log);
void mem_write(t_state *s, int size, unsigned address, unsigned value, int log);
void debug_reg_write(t_state *s, uint32_t address, uint32_t data);
int debug_reg_read(t_state *s, int size, unsigned int address);
void start_load(t_state *s, uint32_t addr, int rt, int data);
uint32_t simulate_hw_irqs(t_state *s);


/*---- Local functions -------------------------------------------------------*/

/*---- Call & ret tracing (EARLY DRAFT) --------------------------------------*/

static uint32_t call_depth = 0;

void log_ret(uint32_t to, uint32_t from){
    int32_t i,j;

    /* If no map file has been loaded, skip trace */
    if((!map_info.num_functions) || (!map_info.log)) return;

    if(call_depth>0){
        fprintf(map_info.log, "[%08x]  ", from);
        for(j=0;j<call_depth;j++){
            fprintf(map_info.log, ". ");
        }
        fprintf(map_info.log, "}\n");
        call_depth--;
    }
    else{
        i = function_index(to);
        if(i>=0){
            fprintf(map_info.log, "[%08x]  %s\n", from, map_info.fn_name[i]);
        }
        else{
            fprintf(map_info.log, "[%08x]  %08x\n", from, to);
        }
    }
}

/** */
void log_call(uint32_t to, uint32_t from){
    int32_t i,j;

    /* If no map file has been loaded, skip trace */
    if((!map_info.num_functions) || (!map_info.log)) return;

    i = function_index(to);
    if(i>=0){
        call_depth++;
        fprintf(map_info.log, "[%08x]  ", from);
        for(j=0;j<call_depth;j++){
            fprintf(map_info.log, ". ");
        }
        fprintf(map_info.log, "%s{\n", map_info.fn_name[i]);
    }
}

int32_t function_index(uint32_t address){
    uint32_t i;

    for(i=0;i<map_info.num_functions;i++){
        if(address==map_info.fn_address[i]){
            return i;
        }
    }
    return -1;
}

/*---- Execution log ---------------------------------------------------------*/

/** Log to file a memory read operation (not including target reg change) */
void log_read(t_state *s, int full_address, int word_value, int size, int log){
    /* if bit CP0.16==1, this is a D-Cache line invalidation access and
           the HW will not read any actual data, so skip the log (@note1) */
    if(log_enabled(s) && log!=0 && !(s->status & 0x00010000)){
        fprintf(s->t.log, "(%08X) [%08X] <**>=%08X RD\n",
              s->op_addr, full_address, word_value);
    }
}

/** Read memory, optionally logging */
int mem_read(t_state *s, int size, unsigned int address, int log){
    unsigned int value=0, word_value=0, i, ptr;
    unsigned int full_address = address;

    /* Handle access to debug register block */
    if((address&0xffff0000)==(DBG_REGS&0xffff0000)){
        return debug_reg_read(s, size, address);
    }

    s->irqStatus |= IRQ_UART_WRITE_AVAILABLE;
    switch(address){
    case UART_READ:
        /* FIXME Take input from text file */
        /* Wait for incoming character */
        while(!kbhit());
        HWMemory[0] = getch();
        //s->irqStatus &= ~IRQ_UART_READ_AVAILABLE; //clear bit
        printf("%c", HWMemory[0]);
        return HWMemory[0];
    case UART_STATUS:
        /* Hardcoded status bits: tx and rx available */
        return IRQ_UART_WRITE_AVAILABLE | IRQ_UART_READ_AVAILABLE;
    case TIMER_READ:
        printf("TIMER = %10d\n", s->instruction_ctr);
        return s->instruction_ctr;
        break;
    case IRQ_MASK:
       return HWMemory[1];
    case IRQ_MASK + 4:
       slite_sleep(10);
       return 0;
    case IRQ_STATUS:
       /*if(kbhit())
          s->irqStatus |= IRQ_UART_READ_AVAILABLE;
       return s->irqStatus;
       */
       /* FIXME Optionally simulate UART TX delay */
       word_value = 0x00000003; /* Ready to TX and RX */
       //log_read(s, full_address, word_value, size, log);
       return word_value;
    case MMU_PROCESS_ID:
       return s->processId;
    case MMU_FAULT_ADDR:
       return s->faultAddr;
    }

    /* point ptr to the byte in the block, or NULL is the address is unmapped */
    ptr = 0;
    for(i=0;i<NUM_MEM_BLOCKS;i++){
        if((address & s->blocks[i].mask) ==
           (s->blocks[i].start & s->blocks[i].mask)){
            ptr = (unsigned)(s->blocks[i].mem) +
                  ((address - s->blocks[i].start) % s->blocks[i].size);
            break;
        }
    }
    if(!ptr){
        /* address out of mapped blocks: log and return zero */
        /* if bit CP0.16==1, this is a D-Cache line invalidation access and
           the HW will not read any actual data, so skip the log (@note1) */
        printf("MEM RD ERROR @ 0x%08x [0x%08x]\n", s->pc, full_address);
        if(log_enabled(s) && log!=0 && !(s->status & (1<<16))){
            fprintf(s->t.log, "(%08X) [%08X] <**>=%08X RD UNMAPPED\n",
                s->pc, full_address, 0);
        }
        return 0;
    }

    /* get the whole word */
    word_value = *(int*)(ptr&0xfffffffc);
    if(s->big_endian){
        word_value = ntohl(word_value);
    }

    switch(size){
    case 4:
        if(address & 3){
            printf("Unaligned access PC=0x%x address=0x%x\n",
                (int)s->pc, (int)address);
        }
        if((address & 3) != 0){
            /* unaligned word, log fault */
            s->failed_assertions |= ASRT_UNALIGNED_READ;
            s->faulty_address = address;
            address = address & 0xfffffffc;
        }
        value = *(int*)ptr;
        if(s->big_endian){
            value = ntohl(value);
        }
        break;
    case 2:
        if((address & 1) != 0){
            /* unaligned halfword, log fault */
            s->failed_assertions |= ASRT_UNALIGNED_READ;
            s->faulty_address = address;
            address = address & 0xfffffffe;
        }
        value = *(unsigned short*)ptr;
        if(s->big_endian){
            value = ntohs((unsigned short)value);
        }
        break;
    case 1:
        value = *(unsigned char*)ptr;
        break;
    default:
        /* This is a bug, display warning */
        printf("\n\n**** BUG: wrong memory read size at 0x%08x\n\n", s->pc);
    }

    //log_read(s, full_address, value, size, log);
    return(value);
}

int debug_reg_read(t_state *s, int size, unsigned int address){
    /* FIXME should mirror debug registers 0..3 */
    return s->debug_regs[(address >> 2)&0x0f];
}


/** Write to debug register */
void debug_reg_write(t_state *s, uint32_t address, uint32_t data){

    if((address>= 0x0000f000) && (address < 0x0000f008)){
        /* HW interrupt trigger register */
        s->t.irq_trigger_countdown[address-0x0000f000] = data;
        printf("DEBUG REG[%04x]=%08x\n", address & 0xffff, data);
    }
    else{
        /* all other registers are used for display (like LEDs) */
        printf("DEBUG REG[%04x]=%08x\n", address & 0xffff, data);
        s->debug_regs[(address >> 2)&0x0f] = data;
    }
}

/** Write to memory, including simulated i/o */
void mem_write(t_state *s, int size, unsigned address, unsigned value, int log){
    unsigned int i, ptr, mask, dvalue, b0, b1, b2, b3;

    if(log_enabled(s)){
        b0 = value & 0x000000ff;
        b1 = value & 0x0000ff00;
        b2 = value & 0x00ff0000;
        b3 = value & 0xff000000;

        switch(size){
        case 4:  mask = 0x0f;
            dvalue = value;
            break;
        case 2:
            if((address&0x2)==0){
                mask = 0xc;
                dvalue = b1<<16 | b0<<16;
            }
            else{
               mask = 0x3;
               dvalue = b1 | b0;
            }
            break;
        case 1:
            switch(address%4){
            case 0 : mask = 0x8;
                dvalue = b0<<24;
                break;
            case 1 : mask = 0x4;
                dvalue = b0<<16;
                break;
            case 2 : mask = 0x2;
                dvalue = b0<<8;
                break;
            case 3 : mask = 0x1;
                dvalue = b0;
                break;
            }
            break;
        default:
            printf("BUG: mem write size invalid (%08x)\n", s->pc);
            exit(2);
        }

        fprintf(s->t.log, "(%08X) [%08X] |%02X|=%08X WR\n",
                //s->op_addr, address&0xfffffffc, mask, dvalue);
                s->op_addr, address, mask, dvalue);
    }

    /* Print anything that's written to a debug register, otherwise ignore it */
    if((address&0xffff0000)==(DBG_REGS&0xffff0000)){
        debug_reg_write(s, address, value);
        return;
    }

    switch(address){
    case UART_WRITE:
        putch(value);
        fflush(stdout);
        return;
    case IRQ_MASK:
        HWMemory[1] = value;
        return;
    case IRQ_STATUS:
        s->irqStatus = value;
        return;
    case CONFIG_REG:
        return;
    case MMU_PROCESS_ID:
        //printf("processId=%d\n", value);
        s->processId = value;
        return;
    }

    ptr = 0;
    for(i=0;i<NUM_MEM_BLOCKS;i++){
        if((address & s->blocks[i].mask) ==
                  (s->blocks[i].start & s->blocks[i].mask)){
            ptr = (unsigned)(s->blocks[i].mem) +
                            ((address - s->blocks[i].start) % s->blocks[i].size);

            if(s->blocks[i].read_only){
                if(log_enabled(s) && log!=0){
                    fprintf(s->t.log, "(%08X) [%08X] |%02X|=%08X WR READ ONLY\n",
                    s->op_addr, address, mask, dvalue);
                    return;
                }
            }
            break;
        }
    }
    if(!ptr){
        /* address out of mapped blocks: log and return zero */
        printf("MEM WR ERROR @ 0x%08x [0x%08x]\n", s->pc, address);
        if(log_enabled(s) && log!=0){
            fprintf(s->t.log, "(%08X) [%08X] |%02X|=%08X WR UNMAPPED\n",
                s->op_addr, address, mask, dvalue);
        }
        return;
    }

    switch(size){
    case 4:
        if((address & 3) != 0){
            /* unaligned word, log fault */
            s->failed_assertions |= ASRT_UNALIGNED_WRITE;
            s->faulty_address = address;
            address = address & (~0x03);
        }
        if(s->big_endian){
            value = htonl(value);
        }
        *(int*)ptr = value;
        break;
    case 2:
        if((address & 1) != 0){
            /* unaligned halfword, log fault */
            s->failed_assertions |= ASRT_UNALIGNED_WRITE;
            s->faulty_address = address;
            address = address & (~0x01);
        }
        if(s->big_endian){
            value = htons((unsigned short)value);
        }
        *(short*)ptr = (unsigned short)value;
        break;
    case 1:
        *(char*)ptr = (unsigned char)value;
        break;
    default:
        /* This is a bug, display warning */
        printf("\n\n**** BUG: wrong memory write size at 0x%08x\n\n", s->pc);
    }
}

/*-- unaligned store and load instructions -----------------------------------*/
/*
 These are meant to be left unimplemented and trapped. These functions simulate
 the unaligned r/w instructions until proper trap handlers are written.
*/

void mem_swl(t_state *s, uint32_t address, uint32_t value, uint32_t log){
    uint32_t data, offset;

    if(!s->do_unaligned) return unimplemented(s, "SWL");

    offset = (address & 0x03);
    address = (address & (~0x03));
    data = value;

    while(offset<4){
        mem_write(s,1,address+offset,(data>>24) & 0xff,0);
        data = data << 8;
        offset++;
    }
}

void mem_swr(t_state *s, uint32_t address, uint32_t value, uint32_t log){
    uint32_t data, offset;

    if(!s->do_unaligned) return unimplemented(s, "SWR");

    offset = (address & 0x03);
    address = (address & (~0x03));
    data = value;

    while(offset>=0){
        mem_write(s,1,address+offset,data & 0xff,0);
        data = data >> 8;
        offset--;
    }
}

void mem_lwr(t_state *s, uint32_t address, uint32_t reg_index, uint32_t log){
    uint32_t offset, data;
    uint32_t disp[4] = {24,         16,         8,          0};
    uint32_t mask[4] = {0x000000ff, 0x0000ffff, 0x00ffffff, 0xffffffff};

    if(!s->do_unaligned) return unimplemented(s, "LWR");

    offset = (address & 0x03);
    address = (address & (~0x03));

    data = mem_read(s, 4, address, 0);
    data = (data >> disp[offset]) & mask[offset];

    s->r[reg_index] = (s->r[reg_index] & (~mask[offset])) | data;
}

void mem_lwl(t_state *s, uint32_t address, uint32_t reg_index, uint32_t log){
    uint32_t offset, data;
    uint32_t disp[4] = {0,          8,          16,         24};
    uint32_t mask[4] = {0xffffffff, 0xffffff00, 0xffff0000, 0xff000000};

    if(!s->do_unaligned) return unimplemented(s, "LWL");

    offset = (address & 0x03);
    address = (address & (~0x03));

    data = mem_read(s, 4, address, 0);
    data = (data << disp[offset]) & mask[offset];

    s->r[reg_index] = (s->r[reg_index] & (~mask[offset])) | data;
}

/*---- Optional MIPS32 opcodes -----------------------------------------------*/

uint32_t count_leading(uint32_t lead, uint32_t src){
    uint32_t mask, bit_val, i;

    mask = 0x80000000;
    bit_val = lead? 0xffffffff : 0x00000000;

    for(i=0;i<32;i++){
        if((src & mask) != (bit_val & mask)){
            return i;
        }
        mask = mask >> 1;
    }

    return i;
}

uint32_t mult_gpr(uint32_t m1, uint32_t m2){
    uint32_t temp;

    temp = m1 * m2;
    return temp;
}

uint32_t ext_bitfield(uint32_t src, uint32_t opcode){
    uint32_t pos, size, mask, value;

    pos = (opcode>>6) & 0x1f;
    size = ((opcode>>11) & 0x1f) + 1;
    mask = (1 << size)-1;
    mask = mask << pos;

    value = (src & mask) >> pos;
    return value;
}

uint32_t ins_bitfield(uint32_t target, uint32_t src, uint32_t opcode){
    uint32_t pos, size, mask, value;

    pos = (opcode>>6) & 0x1f;
    size = ((opcode>>11) & 0x1f) + 1;
    mask = (1 << size)-1;
    mask = mask << pos;

    value = target & (~mask);
    value |= ((src << pos) & mask);
    return value;
}

/*---- Optional MMU and cache implementation ---------------------------------*/

/*
   The actual core does not have a cache so all of the original Plasma mlite.c
   code for cache simulation has been removed.
*/

/*---- End optional cache implementation -------------------------------------*/


/** Simulates MIPS-I multiplier unsigned behavior*/
void mult_big(unsigned int a,
              unsigned int b,
              unsigned int *hi,
              unsigned int *lo){
    unsigned int ahi, alo, bhi, blo;
    unsigned int c0, c1, c2;
    unsigned int c1_a, c1_b;

    ahi = a >> 16;
    alo = a & 0xffff;
    bhi = b >> 16;
    blo = b & 0xffff;

    c0 = alo * blo;
    c1_a = ahi * blo;
    c1_b = alo * bhi;
    c2 = ahi * bhi;

    c2 += (c1_a >> 16) + (c1_b >> 16);
    c1 = (c1_a & 0xffff) + (c1_b & 0xffff) + (c0 >> 16);
    c2 += (c1 >> 16);
    c0 = (c1 << 16) + (c0 & 0xffff);
    *hi = c2;
    *lo = c0;
}

/** Simulates MIPS-I multiplier signed behavior*/
void mult_big_signed(int a,
                     int b,
                     unsigned int *hi,
                     unsigned int *lo){
    int64_t xa, xb, xr, temp;
    int32_t rh, rl;

    xa = a;
    xb = b;
    xr = xa * xb;

    temp = (xr >> 32) & 0xffffffff;
    rh = temp;
    temp = (xr >> 0) & 0xffffffff;
    rl = temp;

    *hi = rh;
    *lo = rl;
}

/** Load data from memory (used to simulate load delay slots) */
void start_load(t_state *s, uint32_t addr, int rt, int data){
    /* load delay slot not simulated */
    log_read(s, addr, data, 1, 1);
    s->r[rt] = data;
}

void process_traps(t_state *s, uint32_t epc, uint32_t rSave, uint32_t rt){
    int32_t i, cause= -1;

    if(s->trap_cause>=0){
        /* If there is a software-triggered trap pending, deal with it */
        cause = s->trap_cause;
    }
    else{
        /* If there's any hardware interrupt pending, deal with it */
        for(i=0;i<NUM_HW_IRQS;i++){
            if(s->t.irq_trigger_countdown[i]==0){
                /* trigger interrupt i IF it is not masked */
                if(s->status & (1 << (8 + i))){
                    cause = 0; /* cause = hardware interrupt */
                }
                s->t.irq_trigger_countdown[i]--;
            }
            else if (s->t.irq_trigger_countdown[i]>0){
                s->t.irq_trigger_countdown[i]--;
            }
        }
    }

    /* Now, whatever the cause was, do the trap handling */
    if(cause >= 0){
        s->trap_cause = cause;
        s->r[rt] = rSave; /* 'undo' current instruction (?) */
        /* set cause field ... */
        s->cp0_cause = (s->delay_slot & 0x1) << 31 | (s->trap_cause & 0x1f) << 2;
        /* ...save previous KU/IE flags in SR... */
        s->status = (s->status & 0xffffffc3) | ((s->status & 0x0f) << 2);
        /* ...and raise KU(EXL) kernel mode flag */
        s->status |= 0x02;
        /* adjust epc if we (i.e. the victim instruction) are in a delay slot */
        if(s->delay_slot){
            epc = epc - 4;
        }
        s->epc = epc;
        s->pc_next = VECTOR_TRAP;
        s->skip = 1;
        s->userMode = 0;
    }
}

/** Execute one cycle of the CPU (including any interlock stall cycles) */
void cycle(t_state *s, int show_mode){
    unsigned int opcode;
    int delay_slot = 0; /* 1 of this instruction is a branch */
    unsigned int op, rs, rt, rd, re, func, imm, target;
    int imm_shift, branch=0, lbranch=2, skip2=0;
    int link=0; /* !=0 if this is a 'branch-and-link' opcode */
    int *r=s->r;
    unsigned int *u=(unsigned int*)s->r;
    unsigned int ptr, epc, rSave;
    char format;
    uint32_t aux;
    uint32_t target_offset16;
    uint32_t target_long;

    /* Update cycle counter (we implement an instruction counter actually )*/
    s->inst_ctr_prescaler++;
    if(s->inst_ctr_prescaler == (cmd_line_args.timer_prescaler-1)){
        s->inst_ctr_prescaler = 0;
        s->instruction_ctr++;
    }
    /* No traps pending for this instruction (yet) */
    s->trap_cause = -1;

    /* fetch and decode instruction */
    opcode = mem_read(s, 4, s->pc, 0);

    op = (opcode >> 26) & 0x3f;
    rs = (opcode >> 21) & 0x1f;
    rt = (opcode >> 16) & 0x1f;
    rd = (opcode >> 11) & 0x1f;
    re = (opcode >> 6) & 0x1f;
    func = opcode & 0x3f;
    imm = opcode & 0xffff;
    imm_shift = (((int)(short)imm) << 2) - 4;
    target = (opcode << 6) >> 4;
    ptr = (short)imm + r[rs];
    r[0] = 0;
    target_offset16 = opcode & 0xffff;
    if(target_offset16 & 0x8000){
        target_offset16 |= 0xffff0000;
    }
    target_long = (opcode & 0x03ffffff)<<2;
    target_long |= (s->pc & 0xf0000000);

    /* Trigger log if we fetch from trigger address */
    if(s->pc == s->t.log_trigger_address){
        trigger_log(s);
    }

    /* if we are priting state to console, do it now */
    if(show_mode){
        printf("%8.8x %8.8x ", s->pc, opcode);
        if(op == 0){
            printf("  %-6s ", &(special_string[func][1]));
            format = special_string[func][0];
        }
        else if(op == 1){
            printf("  %-6s ", &(regimm_string[rt][1]));
            format = regimm_string[rt][0];
        }
        else{
            format = opcode_string[op][0];
            if(format!='c'){
                printf("  %-6s ", &(opcode_string[op][1]));
            }
            else{
                aux = op&0x03;
                switch(rs){
                    case 16:
                        /* FIXME partial decoding of some COP0 opcodes */
                        printf("  RFE      "); format = ' '; break;
                    case 4:
                        printf("  MTC%1d   ", aux); break;
                    case 0:
                        printf("  MFC%1d   ", aux); break;
                    default:
                        printf("  ???      "); break;
                        format = '?';
                }
            }
        }

        switch(format){
            case '1':
                printf("0x%08x", target_long);
                break;
            case '2':
                printf("%s,%s,0x%08x",
                       reg_names[rt], reg_names[rs],
                       (target_offset16*4)+s->pc+4);
                break;
            case '3':
                printf("%s,0x%08x", reg_names[rt], (target_offset16*4)+s->pc+4);
                break;
            case '4':
                printf("%s,%s,%d", reg_names[rd], reg_names[rt], re);
                break;
            case '5':
                printf("%s,%s,0x%04x",
                       reg_names[rt], reg_names[rs],
                       target_offset16&0xffff);
                break;
            case '6':
                printf("%s,0x%04x",
                       reg_names[rt],
                       target_offset16&0xffff);
                break;
            case '7':
                printf("%s,%s,%s", reg_names[rd], reg_names[rs], reg_names[rt]);
                break;
            case '8':
                printf("%s,%d(%s)", reg_names[rt],
                       (target_offset16), reg_names[rs]);
                break;
            case '9':
                printf("%s,0x%08x", reg_names[rt], (target_offset16*4)+s->pc+4);
                break;
            case 'a':
                printf("%s", reg_names[rs]);
                break;
            case 'b':
                printf("%s,%s,%s", reg_names[rd], reg_names[rt], reg_names[rs]);
                break;
            case 'c':
                printf("%s,$%d", reg_names[rt], rd);
                break;
            case '0':
                printf("$%2.2d $%2.2d $%2.2d $%2.2d ", rs, rt, rd, re);
                printf("%4.4x", imm);
                break;
            default:;
        }


        if(show_mode == 1){
            printf(" r[%2.2d]=%8.8x r[%2.2d]=%8.8x", rs, r[rs], rt, r[rt]);
        }
        printf("\n");
    }

    /* if we're just showing state to console, quit and don't run instruction */
    if(show_mode > 5){
        return;
    }

    /* epc will point to the victim instruction, i.e. THIS instruction */
    epc = s->pc;

    /* If we catch a jump instruction jumping to itself, assume we hit the
       and of the program and quit. */
    if(s->pc == s->pc_next+4){
        printf("\n\nEndless loop at 0x%08x\n\n", s->pc-4);
        s->wakeup = 1;
    }
    s->op_addr = s->pc;
    s->pc = s->pc_next;
    s->pc_next = s->pc_next + 4;
    if(s->skip){
        s->skip = 0;
        return;
    }
    rSave = r[rt];

    switch(op){
    case 0x00:/*SPECIAL*/
        switch(func){
        case 0x00:/*SLL*/  r[rd]=r[rt]<<re;          break;
        case 0x02:/*SRL*/  r[rd]=u[rt]>>re;          break;
        case 0x03:/*SRA*/  r[rd]=r[rt]>>re;          break;
        case 0x04:/*SLLV*/ r[rd]=r[rt]<<r[rs];       break;
        case 0x06:/*SRLV*/ r[rd]=u[rt]>>r[rs];       break;
        case 0x07:/*SRAV*/ r[rd]=r[rt]>>r[rs];       break;
        case 0x08:/*JR*/   if(rs==31) log_ret(r[rs],epc);
                           delay_slot=1;
                           s->pc_next=r[rs];         break;
        case 0x09:/*JALR*/ delay_slot=1;
                           r[rd]=s->pc_next;
                           s->pc_next=r[rs];
                           log_call(s->pc_next, epc); break;
        case 0x0a:/*MOVZ*/  if(cmd_line_args.emulate_some_mips32){   /*IV*/
                                if(!r[rt]) r[rd]=r[rs];
                            };
                            break;
        case 0x0b:/*MOVN*/  if(cmd_line_args.emulate_some_mips32){    /*IV*/
                                if(r[rt]) r[rd]=r[rs];
                            };
                            break;
        case 0x0c:/*SYSCALL*/ s->trap_cause = 8;
                              /*
                              //FIXME enable when running uClinux
                              printf("SYSCALL (%08x)\n", s->pc);
                              */
                              break;
        case 0x0d:/*BREAK*/   s->trap_cause = 9;
                              /*
                              FIXME enable when running uClinux
                              printf("BREAK (%08x)\n", s->pc);
                              */
                              break;
        case 0x0f:/*SYNC*/ s->wakeup=1;              break;
        case 0x10:/*MFHI*/ r[rd]=s->hi;              break;
        case 0x11:/*FTHI*/ s->hi=r[rs];              break;
        case 0x12:/*MFLO*/ r[rd]=s->lo;              break;
        case 0x13:/*MTLO*/ s->lo=r[rs];              break;
        case 0x18:/*MULT*/ mult_big_signed(r[rs],r[rt],&s->hi,&s->lo); break;
        case 0x19:/*MULTU*/ mult_big(r[rs],r[rt],&s->hi,&s->lo); break;
        case 0x1a:/*DIV*/  s->lo=r[rs]/r[rt]; s->hi=r[rs]%r[rt]; break;
        case 0x1b:/*DIVU*/ s->lo=u[rs]/u[rt]; s->hi=u[rs]%u[rt]; break;
        case 0x20:/*ADD*/  r[rd]=r[rs]+r[rt];        break;
        case 0x21:/*ADDU*/ r[rd]=r[rs]+r[rt];        break;
        case 0x22:/*SUB*/  r[rd]=r[rs]-r[rt];        break;
        case 0x23:/*SUBU*/ r[rd]=r[rs]-r[rt];        break;
        case 0x24:/*AND*/  r[rd]=r[rs]&r[rt];        break;
        case 0x25:/*OR*/   r[rd]=r[rs]|r[rt];        break;
        case 0x26:/*XOR*/  r[rd]=r[rs]^r[rt];        break;
        case 0x27:/*NOR*/  r[rd]=~(r[rs]|r[rt]);     break;
        case 0x2a:/*SLT*/  r[rd]=r[rs]<r[rt];        break;
        case 0x2b:/*SLTU*/ r[rd]=u[rs]<u[rt];        break;
        case 0x2d:/*DADDU*/r[rd]=r[rs]+u[rt];        break;
        case 0x31:/*TGEU*/ break;
        case 0x32:/*TLT*/  break;
        case 0x33:/*TLTU*/ break;
        case 0x34:/*TEQ*/  break;
        case 0x36:/*TNE*/  break;
        default:
            reserved_opcode(epc, opcode, s);
        }
        break;
    case 0x01:/*REGIMM*/
        switch(rt){
            case 0x10:/*BLTZAL*/ r[31]=s->pc_next; link=1;
            case 0x00:/*BLTZ*/   branch=r[rs]<0;    break;
            case 0x11:/*BGEZAL*/ r[31]=s->pc_next; link=1;
            case 0x01:/*BGEZ*/   branch=r[rs]>=0;   break;
            case 0x12:/*BLTZALL*/r[31]=s->pc_next; link=1;
            case 0x02:/*BLTZL*/  lbranch=r[rs]<0;   break;
            case 0x13:/*BGEZALL*/r[31]=s->pc_next; link=1;
            case 0x03:/*BGEZL*/  lbranch=r[rs]>=0;  break;
            default: printf("ERROR1\n"); s->wakeup=1;
        }
        break;
    case 0x03:/*JAL*/    r[31]=s->pc_next; log_call(((s->pc&0xf0000000)|target), epc);
    case 0x02:/*J*/      delay_slot=1;
                       s->pc_next=(s->pc&0xf0000000)|target; break;
    case 0x04:/*BEQ*/    branch=r[rs]==r[rt];     break;
    case 0x05:/*BNE*/    branch=r[rs]!=r[rt];     break;
    case 0x06:/*BLEZ*/   branch=r[rs]<=0;         break;
    case 0x07:/*BGTZ*/   branch=r[rs]>0;          break;
    case 0x08:/*ADDI*/   r[rt]=r[rs]+(short)imm;  break;
    case 0x09:/*ADDIU*/  u[rt]=u[rs]+(short)imm;  break;
    case 0x0a:/*SLTI*/   r[rt]=r[rs]<(short)imm;  break;
    case 0x0b:/*SLTIU*/  u[rt]=u[rs]<(unsigned int)(short)imm; break;
    case 0x0c:/*ANDI*/   r[rt]=r[rs]&imm;         break;
    case 0x0d:/*ORI*/    r[rt]=r[rs]|imm;         break;
    case 0x0e:/*XORI*/   r[rt]=r[rs]^imm;         break;
    case 0x0f:/*LUI*/    r[rt]=(imm<<16);         break;
    case 0x10:/*COP0*/
        if(s->status & 0x02){ /* kernel mode? */
            if(opcode==0x42000010){  // rfe
                /* restore ('pop') the KU/IE flag values */
                s-> status = (s->status & 0xfffffff0) |
                             ((s->status & 0x03c) >> 2);
            }
            else if((opcode & (1<<23)) == 0){  //move from CP0 (mfc0)
                //printf("mfc0: [%02d]=0x%08x @ [0x%08x]\n", rd, s->status, epc);
                switch(rd){
                    case 12: r[rt]=s->status & 0x0000ff3f; break;
                    case 13: r[rt]=s->cp0_cause; break;
                    case 14: r[rt]=s->epc; break;
                    case 15: r[rt]=R3000_ID; break;
                    default:
                        /* FIXME log access to unimplemented CP0 register */
                        printf("mfc0 [%02d]->%02d @ [0x%08x]\n", rd, rt,s->pc);
                        break;
                }
            }
            else{                         //move to CP0 (mtc0)
                /* FIXME check CF= reg address */
                if(rd==12){
                    s->status=r[rt] & 0x0003ff3f; /* mask W/O bits */
                    //printf("mtc0: [SR]=0x%08x @ [0x%08x]\n", s->status, epc);
                }
                else{
                    /* Move to unimplemented COP0 register: display warning */
                    /* FIXME should log ignored move */
                    printf("mtc0 [%2d]=0x%08x @ [0x%08x] IGNORED\n",
                           rd, r[rt], epc);
                }
            }
        }
        else{
            /* tried to execute mtc* or mfc* in user mode: trap */
            printf("COP0 UNAVAILABLE [0x%08x] = 0x%x %c -- ",
                   epc, opcode, (s->delay_slot? 'D':' '));
            print_opcode_fields(opcode);
            printf("\n");

            s->trap_cause = 11; /* unavailable coprocessor */
        }
        break;
    case 0x11:/*COP1*/  unimplemented(s,"COP1");
                        break;
//      case 0x12:/*COP2*/ break;
//      case 0x13:/*COP3*/ break;
    case 0x14:/*BEQL*/  lbranch=r[rs]==r[rt];    break;
    case 0x15:/*BNEL*/  lbranch=r[rs]!=r[rt];    break;
    case 0x16:/*BLEZL*/ lbranch=r[rs]<=0;        break;
    case 0x17:/*BGTZL*/ lbranch=r[rs]>0;         break;
    case 0x1c:/*SPECIAL2*/
        /* MIPS32 opcodes, some of which may be emulated */
        if(cmd_line_args.emulate_some_mips32){
            switch(func){
                case 0x20: /* CLZ */ r[rt] = count_leading(0, r[rs]); break;
                case 0x21: /* CLO */ r[rt] = count_leading(1, r[rs]); break;
                case 0x02: /* MUL */ r[rd] = mult_gpr(r[rs], r[rt]); break;
                default:
                    reserved_opcode(epc, opcode, s);
            }
        }
        else{
            reserved_opcode(epc, opcode, s);
        }
        break;
    case 0x1f: /* SPECIAL3 */
        if(cmd_line_args.emulate_some_mips32){
            switch(func){
                case 0x00: /* EXT */ r[rt] = ext_bitfield(r[rs], opcode); break;
                case 0x04: /* INS */ r[rt] = ins_bitfield(r[rt], r[rs], opcode); break;
                default:
                    reserved_opcode(epc, opcode, s);
            }
        }
        else{
            reserved_opcode(epc, opcode, s);
        }
        break;
    case 0x20:/*LB*/    //r[rt]=(signed char)mem_read(s,1,ptr,1);  break;
                        start_load(s, ptr, rt,(signed char)mem_read(s,1,ptr,1));
                        break;

    case 0x21:/*LH*/    //r[rt]=(signed short)mem_read(s,2,ptr,1); break;
                        start_load(s, ptr, rt, (signed short)mem_read(s,2,ptr,1));
                        break;
    case 0x22:/*LWL*/   mem_lwl(s, ptr, rt, 1);
                        //printf("LWL\n");
                        break;
    case 0x23:/*LW*/    //r[rt]=mem_read(s,4,ptr,1);   break;
                        start_load(s, ptr, rt, mem_read(s,4,ptr,1));
                        break;
    case 0x24:/*LBU*/   //r[rt]=(unsigned char)mem_read(s,1,ptr,1); break;
                        start_load(s, ptr, rt, (unsigned char)mem_read(s,1,ptr,1));
                        break;
    case 0x25:/*LHU*/   //r[rt]= (unsigned short)mem_read(s,2,ptr,1);
                        start_load(s, ptr, rt, (unsigned short)mem_read(s,2,ptr,1));
                        break;
    case 0x26:/*LWR*/   mem_lwr(s, ptr, rt, 1);
                        //printf("LWR\n");
                        break;
    case 0x28:/*SB*/    mem_write(s,1,ptr,r[rt],1);  break;
    case 0x29:/*SH*/    mem_write(s,2,ptr,r[rt],1);  break;
    case 0x2a:/*SWL*/   mem_swl(s, ptr, r[rt], 1);
                        //printf("SWL\n");
                        break;
    case 0x2b:/*SW*/    mem_write(s,4,ptr,r[rt],1);  break;
    case 0x2e:/*SWR*/   mem_swr(s, ptr, r[rt], 1);
                        //printf("SWR\n");
                        break;
    case 0x2f:/*CACHE*/ unimplemented(s,"CACHE");
                        break;
    case 0x30:/*LL*/    //unimplemented(s,"LL");
                        start_load(s, ptr, rt, mem_read(s,4,ptr,1));
                        break;
//      case 0x31:/*LWC1*/ break;
//      case 0x32:/*LWC2*/ break;
//      case 0x33:/*LWC3*/ break;
//      case 0x35:/*LDC1*/ break;
//      case 0x36:/*LDC2*/ break;
//      case 0x37:/*LDC3*/ break;
//      case 0x38:/*SC*/     *(int*)ptr=r[rt]; r[rt]=1; break;
    case 0x38:/*SC*/    mem_write(s,4,ptr,r[rt],1); r[rt]=1; break;
//      case 0x39:/*SWC1*/ break;
//      case 0x3a:/*SWC2*/ break;
//      case 0x3b:/*SWC3*/ break;
//      case 0x3d:/*SDC1*/ break;
//      case 0x3e:/*SDC2*/ break;
//      case 0x3f:/*SDC3*/ break;
    default:  /* unimplemented opcode */
        reserved_opcode(epc, opcode, s);
    }

    /* */
    if((branch || lbranch == 1) && link){
        log_call(s->pc_next + imm_shift, epc);
    }

    /* adjust next PC if this was a a jump instruction */
    s->pc_next += (branch || lbranch == 1) ? imm_shift : 0;
    s->pc_next &= ~3;
    s->skip = (lbranch == 0) | skip2;

    /* If there was trouble (failed assertions), log it */
    if(s->failed_assertions!=0){
        log_failed_assertions(s);
        s->failed_assertions=0;
    }

    /* if there's a delayed load pending, do it now: load reg with memory data*/
    /* load delay slots not simulated */

    /* Handle exceptions, software and hardware */
    /* Software-triggered traps have priority over HW interrupts, IIF they
       trigger in the same clock cycle. */
    process_traps(s, epc, rSave, rt);

    /* if we're NOT showing output to console, log state of CPU to file */
    if(!show_mode){
        s->wakeup |= log_cycle(s);
    }

    /* if this instruction was any kind of branch that actually jumped, then
       the next instruction will be in a delay slot. Remember it. */
    delay_slot = ((lbranch==1) || branch || delay_slot);
    s->delay_slot = delay_slot;
}

/** Print opcode fields for easier debugging */
void print_opcode_fields(uint32_t opcode){
    uint32_t field;

    field = (opcode >> 26)&0x3f;
    printf("%02x:", field);
    field = (opcode >> 21)&0x1f;
    printf("%02x:", field);
    field = (opcode >> 16)&0x1f;
    printf("%02x:", field);
    field = (opcode >> 11)&0x1f;
    printf("%02x:", field);
    field = (opcode >>  6)&0x1f;
    printf("%02x:", field);
    field = (opcode >>  0)&0x3f;
    printf("%02x",  field);
}

/** Deal with reserved, unimplemented opcodes. Updates s->trap_cause. */
void reserved_opcode(uint32_t pc, uint32_t opcode, t_state* s){
    if(cmd_line_args.trap_on_reserved){
        s->trap_cause = 10; /* reserved instruction */
    }
    else{
        printf("RESERVED OPCODE [0x%08x] = 0x%08x %c -- ",
                pc, opcode, (s->delay_slot? 'D':' '));
        print_opcode_fields(opcode);
        printf("\n");
    }
}


/** Dump CPU state to console */
void show_state(t_state *s){
    int i,j;
    printf("pid=%d userMode=%d, epc=0x%x\n", s->processId, s->userMode, s->epc);
    printf("hi=0x%08x lo=0x%08x\n", s->hi, s->lo);

    /* print register values */
    #if FANCY_REGISTER_DISPLAY
    printf(" v = [%08x %08x]  ", s->r[2], s->r[3]);
    printf("           a = [");
    for(i=4;i<8;i++){
        printf("%08x ", s->r[i]);
    }
    printf("]\n");
    printf(" s = [");
    for(i=16;i<24;i++){
        printf("%08x ", s->r[i]);
    }
    printf("]\n");
    printf(" t = [");
    for(i=8;i<16;i++){
        printf("%08x ", s->r[i]);
    }
    printf("-\n");
    printf("      %08x %08x]  ", s->r[24], s->r[25]);
    printf("                          ");
    printf("  k = [ %08x %08x ]\n", s->r[26], s->r[27]);
    printf(" gp = %08x     sp = %08x    ", s->r[28], s->r[29]);
    printf(" fp = %08x     ra = %08x ", s->r[30], s->r[31]);
    printf("\n\n");
    #else
    for(i = 0; i < 4; ++i){
        printf("%2.2d ", i * 8);
        for(j = 0; j < 8; ++j){
            printf("%8.8x ", s->r[i*8+j]);
        }
        printf("\n");
    }
    #endif

    j = s->pc; /* save pc value (it's altered by the 'cycle' function) */
    for(i = -4; i <= 8; ++i){
        printf("%c", i==0 ? '*' : ' ');
        s->pc = j + i * 4;
        cycle(s, 10);
    }
    s->t.disasm_ptr = s->pc; /* executing code updates the disasm pointer */
    s->pc = j; /* restore pc value */
}

/** Show debug monitor prompt and execute user command */
void do_debug(t_state *s, uint32_t no_prompt){
    int ch;
    int i, j=0, watch=0, addr;
    j = s->breakpoint;
    s->pc_next = s->pc + 4;
    s->skip = 0;
    s->wakeup = 0;

    printf("Starting simulation.\n");

    if(no_prompt){
        ch = '5'; /* 'go' command */
        printf("\n\n");
    }
    else{
        show_state(s);
        ch = ' ';
    }

    for(;;){
        if(ch != 'n' && !no_prompt){
            if(watch){
                printf("0x%8.8x=0x%8.8x\n", watch, mem_read(s, 4, watch,0));
            }
            printf("1=Debug   2=Trace   3=Step    4=BreakPt 5=Go      ");
            printf("6=Memory  7=Watch   8=Jump\n");
            printf("9=Quit    A=Dump    L=LogTrg  C=Disasm  ");
            printf("> ");
        }
        if(ch==' ') ch = getch();
        if(ch != 'n'){
            printf("\n");
        }
        switch(ch){
        case 'a': case 'A':
            dump_trace_buffer(s); break;
        case '1': case 'd': case ' ':
            cycle(s, 0); show_state(s); break;
        case 'n':
            cycle(s, 1); break;
        case '2': case 't':
            cycle(s, 0); printf("*"); cycle(s, 10); break;
        case '3': case 's':
            printf("Count> ");
            scanf("%d", &j);
            for(i = 0; i < j; ++i){
                cycle(s, 1);
            }
            show_state(s);
            break;
        case '4': case 'b':
            printf("Line> ");
            scanf("%x", &j);
            printf("break point=0x%x\n", j);
            break;
        case '5': case 'g':
            s->wakeup = 0;
            cycle(s, 0);
            while(s->wakeup == 0){
                if(s->pc == j){
                    printf("\n\nStop: pc = 0x%08x\n\n", j);
                    break;
                }
                cycle(s, 0);
            }
            if(no_prompt) return;
            show_state(s);
            break;
        case 'G':
            s->wakeup = 0;
            cycle(s, 1);
            while(s->wakeup == 0){
                if(s->pc == j){
                    break;
                }
                cycle(s, 1);
            }
            show_state(s);
            break;
        case '6': case 'm':
            printf("Memory> ");
            scanf("%x", &j);
            for(i = 0; i < 8; ++i){
                printf("%8.8x ", mem_read(s, 4, j+i*4, 0));
            }
            printf("\n");
            break;
        case '7': case 'w':
            printf("Watch> ");
            scanf("%x", &watch);
            break;
        case '8': case 'j':
            printf("Jump> ");
            scanf("%x", &addr);
            s->pc = addr;
            s->pc_next = addr + 4;
            show_state(s);
            break;
        case '9': case 'q':
            return;
        case 'l':
            printf("Address> ");
            scanf("%x", &(s->t.log_trigger_address));
            printf("Log trigger address=0x%x\n", s->t.log_trigger_address);
            break;
        case 'c': case 'C':
            j = s->pc;
            for(i = 1; i <= 16; ++i){
                printf("%c", i==0 ? '*' : ' ');
                s->pc = s->t.disasm_ptr + i * 4;
                cycle(s, 10);
            }
            s->t.disasm_ptr = s->pc;
            s->pc = j;
        }
        ch = ' ';
    }
}

/** Read binary code and data files */
int read_binary_files(t_state *s, t_args *args){
    FILE *in;
    uint8_t *target;
    uint32_t bytes=0, i, files_read=0;

    /* read map file if requested */
    if(args->map_filename!=NULL){
        if(read_map_file(args->map_filename, &map_info)<0){
            printf("Trouble reading map file '%s', quitting!\n",
                   args->map_filename);
            return 0;
        }
        printf("Read %d functions from the map file; call trace enabled.\n\n",
               map_info.num_functions);
    }

    /* read object code binaries */
    for(i=0;i<NUM_MEM_BLOCKS;i++){
        bytes = 0;
        if(args->bin_filename[i]!=NULL){

            in = fopen(args->bin_filename[i], "rb");
            if(in == NULL){
                free_cpu(s);
                printf("Can't open file %s, quitting!\n",args->bin_filename[i]);
                return(0);
            }

            /* FIXME load offset 0x2000 for linux kernel hardcoded! */
            //bytes = fread((s->blocks[i].mem + 0x2000), 1, s->blocks[i].size, in);
            target = (uint8_t *)(s->blocks[i].mem + args->offset[i]);
            while(!feof(in) &&
                  ((bytes+1024+args->offset[i]) < (s->blocks[i].size))){
                bytes += fread(&(target[bytes]), 1, 1024, in);
                if(errno!=0){
                    printf("ERROR: file load failed with code %d ('%s')\n",
                        errno, strerror(errno));
                    free_cpu(s);
                    return 0;
                }
            }

            fclose(in);

            /* Now reverse the endianness of the data we just read, if it's
             necessary. */
             /* FIXME handle little-endian stuff (?) */
            //reverse_endianess(target, bytes);

            files_read++;
        }
        printf("%-16s [size= %6dKB, start= 0x%08x] loaded %d bytes.\n",
                s->blocks[i].area_name,
                s->blocks[i].size/1024,
                s->blocks[i].start,
                bytes);
    }

    if(!files_read){
        free_cpu(s);
        printf("No binary object files read, quitting\n");
        return 0;
    }

    return files_read;
}

void reverse_endianess(uint8_t *data, uint32_t bytes){
    uint8_t w[4];
    uint32_t i, j;

    for(i=0;i<bytes;i=i+4){
        for(j=0;j<4;j++){
            w[3-j] = data[i+j];
        }
        for(j=0;j<4;j++){
            data[i+j] = w[j];
        }
    }
}


/*----------------------------------------------------------------------------*/

int main(int argc,char *argv[]){
    t_state state, *s=&state;



    /* Parse command line and pass any relevant arguments to CPU record */
    if(parse_cmd_line(argc,argv, &cmd_line_args)==0){
        return 0;
    }

    printf("MIPS-I emulator (" __DATE__ ")\n\n");
    if(!init_cpu(s, &cmd_line_args)){
        printf("Trouble allocating memory, quitting!\n");
        return 1;
    };

    /* Read binary object files into memory*/
    if(!read_binary_files(s, &cmd_line_args)){
        return 2;
    }
    printf("\n\n");

    init_trace_buffer(s, &cmd_line_args);

    /* NOTE: Original mlite supported loading little-endian code, which this
      program doesn't. The endianess-conversion code has been removed.
    */

    /* Simulate a CPU reset */
    reset_cpu(s);

    /* Simulate the work of the uClinux bootloader */
    if(cmd_line_args.memory_map == MAP_UCLINUX_BRAM){
        /* FIXME this 'bootloader' is a stub, flesh it out */
        s->pc = 0x80002400;
    }

    /* Enter debug command interface; will only exit clean with user command */
    do_debug(s, cmd_line_args.no_prompt);

    /* Close and deallocate everything and quit */
    close_trace_buffer(s);
    free_cpu(s);
    return(0);
}

/*----------------------------------------------------------------------------*/


void init_trace_buffer(t_state *s, t_args *args){
    int i;

    /* setup misc info related to the monitor interface */
    s->t.disasm_ptr = VECTOR_RESET;

#if FILE_LOGGING_DISABLED
    s->t.log = NULL;
    s->t.log_triggered = 0;
    map_info.log = NULL;
    return;
#else
    /* clear trace buffer */
    for(i=0;i<TRACE_BUFFER_SIZE;i++){
        s->t.buf[i]=0xffffffff;
    }
    s->t.next = 0;

    /* if file logging is enabled, open log file */
    if(args->log_file_name!=NULL){
        s->t.log = fopen(args->log_file_name, "w");
        if(s->t.log==NULL){
            printf("Error opening log file '%s', file logging disabled\n",
                    args->log_file_name);
        }
    }
    else{
        s->t.log = NULL;
    }

    /* Setup log trigger */
    s->t.log_triggered = 0;
    s->t.log_trigger_address = args->log_trigger_address;

    /* if file logging of function calls is enabled, open log file */
    if(map_info.log_filename!=NULL){
        map_info.log = fopen(map_info.log_filename, "w");
        if(map_info.log==NULL){
            printf("Error opening log file '%s', file logging disabled\n",
                    map_info.log_filename);
        }
    }
#endif
}

/** Dumps last jump targets as a chunk of hex numbers (older is left top) */
void dump_trace_buffer(t_state *s){
    int i, col;

    for(i=0, col=0;i<TRACE_BUFFER_SIZE;i++, col++){
        printf("%08x ", s->t.buf[s->t.next + i]);
        if((col % 8)==7){
            printf("\n");
        }
    }
}

/** Logs last cycle's activity (changes in state and/or loads/stores) */
uint32_t log_cycle(t_state *s){
    static unsigned int last_pc = 0;
    int i;
    uint32_t log_pc;

    /* store PC in trace buffer only if there was a jump */
    if(s->pc != (last_pc+4)){
        s->t.buf[s->t.next] = s->pc;
        s->t.next = (s->t.next + 1) % TRACE_BUFFER_SIZE;
    }
    last_pc = s->pc;
    log_pc = s->op_addr;


    /* if file logging is enabled, dump a trace log to file */
    if(log_enabled(s)){

        /* skip register zero which does not change */
        for(i=1;i<32;i++){
            if(s->t.pr[i] != s->r[i]){
                fprintf(s->t.log, "(%08X) [%02X]=%08X\n", log_pc, i, s->r[i]);
            }
            s->t.pr[i] = s->r[i];
        }
        if(s->lo != s->t.lo){
            //fprintf(s->t.log, "(%08X) [LO]=%08X\n", log_pc, s->lo);
        }
        s->t.lo = s->lo;

        if(s->hi != s->t.hi){
            //fprintf(s->t.log, "(%08X) [HI]=%08X\n", log_pc, s->hi);
        }
        s->t.hi = s->hi;

        /* Catch changes in EPC by direct write (mtc0) and by exception */
        if(s->epc != s->t.epc){
            fprintf(s->t.log, "(%08X) [EP]=%08X\n", log_pc, s->epc);
        }
        s->t.epc = s->epc;

        if(s->status != s->t.status){
            fprintf(s->t.log, "(%08X) [SR]=%08X\n", log_pc, s->status);
        }
        s->t.status = s->status;
    }

#if 0
    /* FIXME Try to detect a code crash by looking at SP */
    if(1){
            if((s->r[29]&0xffff0000) == 0xffff00000){
                printf("SP derailed! @ 0x%08x [0x%08x]\n", log_pc, s->r[29]);
                return 1;
            }
    }
#endif

    return 0;
}

/** Frees debug buffers and closes log file */
void close_trace_buffer(t_state *s){
    if(s->t.log){
        fclose(s->t.log);
    }
    if(map_info.log){
        fclose(map_info.log);
    }
}

/** Logs a message for each failed assertion, each in a line */
void log_failed_assertions(t_state *s){
    unsigned bitmap = s->failed_assertions;
    int i = 0;

    /* This loop will crash the program if the message table is too short...*/
    if(s->t.log != NULL){
        for(i=0;i<32;i++){
            if(bitmap & 0x1){
                fprintf(s->t.log, "ASSERTION FAILED: [%08x] %s\n",
                        s->faulty_address,
                        assertion_messages[i]);
            }
            bitmap = bitmap >> 1;
        }
    }
}

uint32_t log_enabled(t_state *s){
    return ((s->t.log != NULL) && (s->t.log_triggered!=0));
}

void trigger_log(t_state *s){
    uint32_t i;

    s->t.log_triggered = 1;

    for(i=0;i<32;i++){
        s->t.pr[i] = s->r[i];
    }

    s->t.lo = s->lo;
    s->t.hi = s->hi;
    s->t.epc = s->epc;
}

int32_t read_map_file(char *filename, t_map_info* map){
    FILE *f;
    uint32_t address, i;
    uint32_t segment_text = 0;
    char line[256];
    char name[256];

    f = fopen (filename, "rt");  /* open the file for reading */

    if(!f){
        return -1;
    }

   while(fgets(line, sizeof(line)-1, f) != NULL){
       if(!strncmp(line, ".text", 5)){
           segment_text = 1;
       }
       else if(line[0]==' ' && segment_text){
            /* may be a function address */
            for(i=0;(i<sizeof(line)-1) && (line[i]==' '); i++);
            if(line[i]=='0'){
                sscanf(line, "%*[ \n\t]%x%*[ \n\t]%s", &address, &(name[0]));

                strncpy(map->fn_name[map->num_functions],
                        name, MAP_MAX_NAME_LEN-1);
                map->fn_address[map->num_functions] = address;
                map->num_functions++;
                if(map->num_functions >= MAP_MAX_FUNCTIONS){
                    printf("WARNING: too many functions in map file!\n");
                    return map->num_functions;
                }
            }
       }
       else if(line[0]=='.' && segment_text){
           break;
       }
    }
    fclose(f);

#if 0
    for(i=0;i<map->num_functions;i++){
        printf("--> %08x %s\n", map->fn_address[i], map->fn_name[i]);
    }
#endif

    return map->num_functions;
}


void free_cpu(t_state *s){
    int i;

    for(i=0;i<NUM_MEM_BLOCKS;i++){
        free(s->blocks[i].mem);
        s->blocks[i].mem = NULL;
    }
}

void reset_cpu(t_state *s){
    uint32_t i;

    s->pc = cmd_line_args.start_addr; /* reset start vector or cmd line address */
    s->delay_slot = 0;
    s->failed_assertions = 0; /* no failed assertions pending */
    s->status = 0x02; /* kernel mode, interrupts disabled */
    s->instruction_ctr = 0;
    s->inst_ctr_prescaler = 0;
    for(i=0;i<NUM_HW_IRQS;i++){
        s->t.irq_trigger_countdown[i] = -1;
    }
    /* init trace struct to prevent spurious logs */
    s->t.status = s->status;
}

/* FIXME redundant function, merge with reserved_opcode */
void unimplemented(t_state *s, const char *txt){
    printf("UNIMPLEMENTED: %s\n", txt);
}

int init_cpu(t_state *s, t_args *args){
    int i, j;
    uint32_t k = args->memory_map;

    memset(s, 0, sizeof(t_state));
    s->big_endian = 1;

    s->do_unaligned = args->do_unaligned;
    s->breakpoint = args->breakpoint;

    /* Initialize memory map */
    for(i=0;i<NUM_MEM_BLOCKS;i++){
        s->blocks[i].start =        memory_maps[k].blocks[i].start;
        s->blocks[i].size =         memory_maps[k].blocks[i].size;
        s->blocks[i].area_name =    memory_maps[k].blocks[i].area_name;
        s->blocks[i].mask =         memory_maps[k].blocks[i].mask;
        s->blocks[i].read_only =    memory_maps[k].blocks[i].read_only;

        s->blocks[i].mem = (unsigned char*)malloc(s->blocks[i].size);

        if(s->blocks[i].mem == NULL){
            for(j=0;j<i;j++){
                free(s->blocks[j].mem);
            }
            return 0;
        }
        memset(s->blocks[i].mem, 0, s->blocks[i].size);
    }
    return NUM_MEM_BLOCKS;
}

int32_t parse_cmd_line(uint32_t argc, char **argv, t_args *args){
    uint32_t i;

    /* Initialize logging parameters */
    map_info.num_functions = 0;
    map_info.log_filename = NULL;
    map_info.log = stdout;

    /* fill cmd line args with default values */
    args->memory_map = MAP_DEFAULT;
    args->trap_on_reserved = 1;
    args->emulate_some_mips32 = 1;
    args->timer_prescaler = DEFAULT_TIMER_PRESCALER;
    args->start_addr = VECTOR_RESET;
    args->do_unaligned = 0;
    args->no_prompt = 0;
    args->breakpoint = 0xffffffff;
    args->log_file_name = "sw_sim_log.txt";
    args->log_trigger_address = VECTOR_RESET;
    args->map_filename = NULL;
    for(i=0;i<NUM_MEM_BLOCKS;i++){
        args->bin_filename[i] = NULL;
        args->offset[i] = 0;
    }

    /* parse actual cmd line args */
    for(i=1;i<argc;i++){
        if(strcmp(argv[i],"--plasma")==0){
            /* plasma simulation not supported, error*/
            printf("Error: program compiled for compatibility to MIPS-I\n");
            return 0;
        }
        else if(strcmp(argv[i],"--uclinux")==0){
            args->memory_map = MAP_UCLINUX_BRAM;
            /* FIXME selecting uClinux enables unaligned L/S emulation */
            args->do_unaligned = 1;
        }
        else if(strcmp(argv[i],"--small")==0){
            args->memory_map = MAP_SMALL;
        }
        else if(strcmp(argv[i],"--unaligned")==0){
            args->do_unaligned = 1;
        }
        else if(strcmp(argv[i],"--noprompt")==0){
            args->no_prompt = 1;
        }
        else if(strcmp(argv[i],"--notrap10")==0){
            args->trap_on_reserved = 0;
        }
        else if(strcmp(argv[i],"--nomips32")==0){
            args->emulate_some_mips32 = 0;
        }
        else if(strncmp(argv[i],"--bram=", strlen("--bram="))==0){
            args->bin_filename[0] = &(argv[i][strlen("--bram=")]);
        }
        else if(strncmp(argv[i],"--flash=", strlen("--flash="))==0){
            args->bin_filename[3] = &(argv[i][strlen("--flash=")]);
        }
        else if(strncmp(argv[i],"--xram=", strlen("--xram="))==0){
            args->bin_filename[1] = &(argv[i][strlen("--xram=")]);
        }
        else if(strncmp(argv[i],"--map=", strlen("--map="))==0){
            args->map_filename = &(argv[i][strlen("--map=")]);
        }
        else if(strncmp(argv[i],"--trace_log=", strlen("--trace_log="))==0){
            map_info.log_filename = &(argv[i][strlen("--trace_log=")]);
        }
        else if(strncmp(argv[i],"--start=", strlen("--start="))==0){
            sscanf(&(argv[i][strlen("--start=")]), "%x", &(args->start_addr));
        }
        else if(strncmp(argv[i],"--kernel=", strlen("--kernel="))==0){
            args->bin_filename[1] = &(argv[i][strlen("--kernel=")]);
            /* FIXME uClinux kernel 'offset' hardcoded */
            args->offset[1] = 0x2000;
        }
        else if(strncmp(argv[i],"--trigger=", strlen("--trigger="))==0){
            sscanf(&(argv[i][strlen("--trigger=")]), "%x", &(args->log_trigger_address));
        }
        else if(strncmp(argv[i],"--break=", strlen("--break="))==0){
            sscanf(&(argv[i][strlen("--break=")]), "%x", &(args->breakpoint));
        }
        else if(strncmp(argv[i],"--breakpoint=", strlen("--breakpoint="))==0){
            sscanf(&(argv[i][strlen("--breakpoint=")]), "%x", &(args->breakpoint));
        }
        else if((strcmp(argv[i],"--help")==0)||(strcmp(argv[i],"-h")==0)){
            usage();
            return 0;
        }
        else{
            printf("unknown argument '%s'\n\n",argv[i]);
            usage();
            return 0;
        }
    }

    return 1;
}

void usage(void){
    printf("Usage:");
    printf("    slite file.exe [arguments]\n");
    printf("Arguments:\n");
    printf("--bram=<file name>      : BRAM initialization file\n");
    printf("--xram=<file name>      : XRAM initialization file\n");
    printf("--kernel=<file name>    : XRAM initialization file for uClinux kernel\n");
    printf("                          (loads at block offset 0x2000)\n");
    printf("--flash=<file name>     : FLASH initialization file\n");
    printf("--map=<file name>       : Map file to be used for tracing, if any\n");
    printf("--trace_log=<file name> : Log file used for tracing, if any\n");
    printf("--trigger=<hex number>  : Log trigger address\n");
    printf("--break=<hex number>    : Breakpoint address\n");
    printf("--start=<hex number>    : Start here instead of at reset vector\n");
    printf("--notrap10              : Reserverd opcodes are NOPs and don't trap\n");
    printf("--nomips32              : Do not emulate any mips32 opcodes\n");
    printf("--plasma                : Simulate Plasma instead of MIPS-I\n");
    printf("--uclinux               : Use memory map tailored to uClinux\n");
    printf("--unaligned             : Implement unaligned load/store instructions\n");
    printf("--noprompt              : Run in batch mode\n");
    printf("--stop_at_zero          : Stop simulation when fetching from address 0x0\n");
    printf("--help, -h              : Show this usage text\n");
}

