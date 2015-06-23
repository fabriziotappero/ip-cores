
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

#include "b51_cpu.h"
#include "b51_mcu.h"
#include "b51_log.h"
#include "util/ihex.h"


/*-- Local data types & macros -----------------------------------------------*/

typedef enum cpu_op_e {
    add, addc, subb,
    alu_mul, alu_div,
    da,
    rrc, rlc, rr, rl,
    setb_c, clr_c, anl_c, orl_c,
    cjne
} cpu_op_t;

/** Cycle count information for an opcode. */
typedef struct {
    int min;    /**< Minimum number of cycles. */
    int max;    /**< Maximum number of cycles. */
} cycle_count_t;

/** Cycle count table for light52 core. */
cycle_count_t cycle_count[256] = {
    { 2, 2}, { 5, 5}, { 6, 6}, { 3, 3}, { 3, 3}, { 5, 5}, { 7, 7}, { 7, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 7, 8}, { 7, 7}, { 8, 8}, { 3, 3}, { 3, 3}, { 5, 5}, { 7, 7}, { 7, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 6, 7}, { 5, 5}, { 7, 7}, { 3, 3}, { 4, 4}, { 5, 5}, { 7, 7}, { 7, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 6, 7}, { 7, 7}, { 7, 7}, { 3, 3}, { 4, 4}, { 5, 5}, { 7, 7}, { 7, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 3, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 4, 4}, { 5, 5}, { 7, 7}, { 7, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 3, 5}, { 7, 7}, { 5, 5}, { 5, 5}, { 4, 4}, { 5, 5}, { 7, 7}, { 7, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 3, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 4, 4}, { 5, 5}, { 7, 7}, { 7, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 3, 5}, { 7, 7}, { 5, 5}, { 4, 4}, { 4, 4}, { 5, 5}, { 5, 5}, { 5, 5},
    { 4, 4}, { 4, 4}, { 4, 4}, { 4, 4}, { 4, 4}, { 4, 4}, { 4, 4}, { 4, 4},
    { 5, 5}, { 5, 5}, { 5, 5}, { 4, 4}, {10,10}, { 5, 5}, { 7, 7}, { 7, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 5, 5}, { 7, 7}, { 5, 5}, { 4, 4}, { 4, 4}, { 5, 5}, { 7, 7}, { 7, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 5, 5}, { 5, 5}, { 5, 5}, { 3, 3}, { 3, 3}, { 2, 2}, { 6, 6}, { 6, 6},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 5, 5}, { 7, 7}, { 5, 5}, { 3, 3}, { 5, 6}, { 6, 7}, { 8, 9}, { 8, 9},
    { 6, 7}, { 6, 7}, { 6, 7}, { 6, 7}, { 6, 7}, { 6, 7}, { 6, 7}, { 6, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 3, 3}, { 3, 3}, { 6, 6}, { 7, 7}, { 7, 7},
    { 6, 6}, { 6, 6}, { 6, 6}, { 6, 6}, { 6, 6}, { 6, 6}, { 6, 6}, { 6, 6},
    { 5, 5}, { 7, 7}, { 5, 5}, { 3, 3}, { 2, 2}, { 7, 8}, { 2, 2}, { 2, 2},
    { 7, 8}, { 7, 8}, { 7, 8}, { 7, 8}, { 7, 8}, { 7, 8}, { 7, 8}, { 7, 8},
    { 3, 3}, { 5, 5}, { 6, 6}, { 6, 6}, { 3, 3}, { 5, 5}, { 7, 7}, { 7, 7},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    { 3, 3}, { 7, 7}, { 5, 5}, { 5, 5}, { 3, 3}, { 4, 4}, { 5, 5}, { 5, 5},
    { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5}, { 5, 5},
    };




/*-- Local function prototypes -----------------------------------------------*/


static uint8_t cpu_fetch(cpu51_t *cpu);
static uint16_t cpu_fetch16(cpu51_t *cpu);
static uint16_t cpu_fetch11(cpu51_t *cpu, uint8_t opcode);
static uint8_t cpu_xcode_read(cpu51_t *cpu, uint16_t addr);
static uint8_t cpu_xdata_read(cpu51_t *cpu, uint16_t addr);
static void cpu_xdata_write(cpu51_t *cpu, uint16_t addr, uint8_t value);
static void cpu_set_rn(cpu51_t *cpu, uint8_t n, uint8_t value);
static void cpu_set_a(cpu51_t *cpu, uint8_t value);
static uint8_t cpu_update_flags(cpu51_t *cpu, uint8_t x, uint8_t y, cpu_op_t op);
static uint8_t cpu_compute_ac(cpu51_t *cpu, uint8_t x, uint8_t y, cpu_op_t op);
static void cpu_set_dir(cpu51_t *cpu, uint8_t dir, uint8_t value);
static void cpu_set_idata(cpu51_t *cpu, uint8_t dir, uint8_t value);
static uint8_t cpu_get_dir(cpu51_t *cpu, uint8_t dir);
static uint8_t cpu_get_idata(cpu51_t *cpu, uint8_t dir);
static bool cpu_rel_jump(cpu51_t *cpu, uint8_t rel);
static void cpu_set_sfr(cpu51_t *cpu, uint8_t dir, uint8_t value);
static uint8_t cpu_get_sfr(cpu51_t *cpu, uint8_t dir);
static uint8_t cpu_get_bit_address(cpu51_t *cpu, uint8_t bit);
static uint8_t cpu_get_bit(cpu51_t *cpu, uint8_t bit);
static void cpu_set_bit(cpu51_t *cpu, uint8_t bit, uint8_t value);

static bool cpu_exec_rn(cpu51_t *cpu, uint8_t opcode);
static bool cpu_exec_upper_half(cpu51_t *cpu, uint8_t opcode);


/*-- Public functions --------------------------------------------------------*/

extern uint16_t cpu_load_code(cpu51_t *cpu, const char *hex_filename){
    FILE *fp;
    IHexRecord irec;
    uint16_t i, target, bytes_read=0;

    fp = fopen(hex_filename, "r");
    if (fp == NULL) {
        perror("Error opening file");
        return 0;
    }

    while (Read_IHexRecord(&irec, fp) == IHEX_OK) {
        /* Debug: print read record */
        #if 0
        Print_IHexRecord(&irec);
        printf("\n");
        #endif
        /* Move data from record to XCODE space, no questions asked */
        /* FIXME XCODE size hardcoded here */
        target = irec.address;
        for(i=0; i < irec.dataLen && (target+i)<65536; i++){
            cpu->mcu.xcode[target + i] = irec.data[i];
        }
        bytes_read += irec.dataLen;
    }

    fclose(fp);

    if(bytes_read > 0){
        printf("Read %d code bytes from '%s'\n", bytes_read, hex_filename);
    }

    return bytes_read;
}

extern void cpu_init(cpu51_t *cpu){
    /* Not much to init in the CPU so far */
    cpu->breakpoint = 0xffff; /* FIXME implementation of BP is flimsy */
    cpu->log.executed_instructions = 0;
    /* Set the core implementation options to their default value */
    cpu->options.bcd = false;
    /* now init the MCU model -- peripherals */
    mcu_init(&cpu->mcu);
}

extern void cpu_reset(cpu51_t *cpu){
    /* Give CPU registers their reset value, if any */
    cpu->sfr.dph = 0x00;
    cpu->sfr.dpl = 0x00;
    cpu->sfr.sp = 0x07;
    cpu->sfr.psw = 0x00;
    cpu->pc = 0x0000;
    cpu->cycles = 0;
    /* FIXME reset interrupt level */
    /* Now reset the MCU model -- peripherals */
    mcu_reset(&cpu->mcu);
}

extern bool cpu_add_breakpoint(cpu51_t *cpu, uint16_t address){
    cpu->breakpoint = address;
    return true;
}

extern uint32_t cpu_exec(cpu51_t *cpu, uint32_t num_inst){
    uint8_t opcode;
    uint32_t i;
    bool ok;
    uint32_t cycles;

    for(i=0;i<num_inst;i++){
        log_baseline(&(cpu->log), cpu->pc, cpu->sfr.sp, cpu->a, cpu->sfr.psw);

        if(cpu->pc == cpu->breakpoint){
            printf("BREAKPOINT hit at %04Xh\n", cpu->breakpoint);
            return 2;
        }

        opcode = cpu_fetch(cpu);
        cpu->max_cycle_count = false;
        cpu->implemented_as_nop = false;

        if((opcode & 0x08)!=0){
            /* bottom half of decoding table */
            ok = cpu_exec_rn(cpu, opcode);
        }
        else{
            /* top half of decoding table */
            ok = cpu_exec_upper_half(cpu, opcode);
        }

        /* Update cycle counter... */
        if(cpu->implemented_as_nop){
            /* Instruction is not implemented as per command line parameters;
               it was executed as NOP so its cycle count is that of NOP.*/
            cycles = cycle_count[0].min;
        }
        else{
            if(cpu->max_cycle_count){
                cycles = cycle_count[opcode].max;
            }
            else{
                cycles = cycle_count[opcode].min;
            }
        }
        cpu->cycles += cycles;

        mcu_update(&cpu->mcu, cycles);
        log_status(&(cpu->log), cpu->sfr.sp, cpu->a, cpu->sfr.psw);

        cpu->log.executed_instructions++;

        /* Break execution on any kind of trouble */
        /* FIXME handle execution faults */
        if(!ok) {
            return 1;
            break;
        }
    }

    return 0;
}

/*-- Local functions ---------------------------------------------------------*/

/**
    Get the byte pointed to by PC, increment PC.

    This function and cpu_xcode_read encapsulate code space addressing.

    @arg CPU object.
    @return Opcode at PC.
    @sideeffect CPU state updated accordingly.
*/
static uint8_t cpu_fetch(cpu51_t *cpu){
    return cpu_xcode_read(cpu, cpu->pc++);
}

static uint16_t cpu_fetch16(cpu51_t *cpu){
    uint8_t hi, lo;
    uint16_t word;

    hi = cpu_fetch(cpu);
    lo = cpu_fetch(cpu);
    word = ((uint16_t)hi << 8) + (uint16_t)lo;
    return word;
}

static uint16_t cpu_fetch11(cpu51_t *cpu, uint8_t opcode){
    uint8_t hi, lo, tmp;
    uint16_t word;

    lo = cpu_fetch(cpu);
    hi = (opcode >> 5) & 0x07;
    tmp = (cpu->pc >> 8) & 0xf8;
    hi |= tmp;
    word = ((uint16_t)hi << 8) + (uint16_t)lo;
    return word;
}


static uint8_t cpu_xcode_read(cpu51_t *cpu, uint16_t addr){
    return cpu->mcu.xcode[addr];
}


static uint8_t cpu_xdata_read(cpu51_t *cpu, uint16_t addr){
    return cpu->mcu.xdata[addr];
}

static void cpu_xdata_write(cpu51_t *cpu, uint16_t addr, uint8_t value){
    /*if(cpu->mcu.xdata[addr]!=value){*/
        log_xdata(&(cpu->log), addr, value);
    /*}*/
    cpu->mcu.xdata[addr] = value;
}


static uint8_t cpu_get_rn(cpu51_t *cpu, uint8_t n){
    uint8_t idata_address;

    idata_address = (cpu->sfr.psw & 0x18) + (n & 0x07);
    return cpu->idata[idata_address];
}

static void cpu_set_rn(cpu51_t *cpu, uint8_t n, uint8_t value){
    uint8_t idata_address;

    idata_address = (cpu->sfr.psw & 0x18) + (n & 0x07);
    cpu_set_idata(cpu, idata_address, value);
}

static void cpu_set_a(cpu51_t *cpu, uint8_t value){
    uint8_t p, t, i;

    cpu->a = value;

    /* Update P flag */
    t = cpu->a;
    p = 0;
    for(i=0;i<8;i++){
        p = p ^ (t & 0x01);
        t = t >> 1;
    }
    cpu->sfr.psw &= 0x0fe;
    cpu->sfr.psw |= (p & 0x01);
}


static uint8_t set_bit(uint8_t target, uint8_t index, uint8_t value){
    index &= 0x07;
    target &= ~(1 << index);
    value &= 0x01;
    target |= (value << index);
    return target;
}

static uint8_t cpu_compute_ac(cpu51_t *cpu, uint8_t x, uint8_t y, cpu_op_t op){

  if(op==subb){
    x = x & 0x0f;
    y = y & 0x0f;
    if((cpu->sfr.psw)&0x80){
      y++;
    }
    return (x<y)?1:0;
  }
  else{
    x = x & 0x0f;
    y = y & 0x0f;
    if((cpu->sfr.psw)&0x80){
      y++;
    }
    return ((x+y)>0x0f)?1:0;
  }
}

static uint8_t cpu_update_flags(cpu51_t *cpu, uint8_t s, uint8_t d, cpu_op_t op){
    uint16_t res, x, y, res_half, rem;
    uint16_t cy=0, ov=0, ac=0;

    x = (uint16_t)s;
    y = (uint16_t)d;

    switch(op){
    case add:
        res = x + y;
        res_half = (x & 0x0f) + (y & 0x0f);
        cy = (res & 0x0100)? 1 : 0;
        ac = (res_half & 0x0010)? 1 : 0;
        if((x < 0x80) && (y < 0x80)){
            ov = (res & 0x0080)? 1 : 0;
        }
        else if((x >= 0x80) && (y >= 0x80)){
            ov = (~(res & 0x0080))? 1 : 0;
        }
        else{
            ov = 0;
        }
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, cy);
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 6, ac);
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 2, ov);
        break;
    case subb:
        ac = cpu_compute_ac(cpu, x, y, subb);
        y ^= 0xffff;
        y += 1;
        res = x + y;
        if(cpu->sfr.psw & 0x80){
            res--;
        }
        cy = (res & 0x0100)? 1 : 0;

        if((x < 0x80) && (y >= 0x80)){
            /* positive - negative = positive, otherwise OV */
            ov = (res & 0x0080)? 1 : 0;
        }
        else if((x >= 0x80) && (y < 0x80)){
            /* negative - positive = negative, otherwise OV */
            ov = (~(res & 0x0080))? 1 : 0;
        }
        else{
            ov = 0;
        }

        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, cy);
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 6, ac);
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 2, ov);
        break;
    case addc:
        res = x + y;
        res_half = (x & 0x0f) + (y & 0x0f);
        if(cpu->sfr.psw & 0x80){
            res++;
            res_half++;
        }
        cy = (res & 0x0100)? 1 : 0;
        ac = (res_half & 0x0010)? 1 : 0;
        if((x < 0x80) && (y < 0x80)){
            ov = (res & 0x0080)? 1 : 0;
        }
        else if((x >= 0x80) && (y >= 0x80)){
            ov = (~(res & 0x0080))? 1 : 0;
        }
        else{
            ov = 0;
        }
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, cy);
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 6, ac);
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 2, ov);
        break;
    case alu_mul:
        res = x * y;
        ov = (res & 0xff00)? 1 : 0;
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, 0);
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 2, ov);
        /* special case: update B right here */
        cpu->sfr.b = (res>>8)&0xff;
        res = res & 0xff;
        break;
    case alu_div:
        if(y != 0){
            res = x / y;
            rem = x % y;
            cy = 0;
            ov = 0;
            /* special case: update B right here */
            cpu->sfr.b = rem;
        }
        else{
            ov = 1;
            cy = 0;
            /* Quotient and remainder are undefined in Intel specs; we'll use
               light52 actual values for consistency of the SW/HW simulations */
            res = 0xff;
            rem = 0x00;
        }
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, cy);
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 2, ov);
        break;
    case da:
        x = s & 0x0f;
        y = s;
        if((x > 9) || ((cpu->sfr.psw&0x40)!=0)){
            y += 0x06;
        }
        x = (y >> 4) & 0x1f;
        if((x > 9) || ((cpu->sfr.psw&0x80)!=0)){
            y += 0x60;
        }
        res = y & 0x0ff;
        /* DA can SET C but can't clear it if it's set */
        if(y > 0x0ff){
            cpu->sfr.psw |= 0x80;
        }
        break;
    case rlc:
        res = (s << 1) | (cpu->sfr.psw >> 7);
        cy = (s >> 7) & 0x01;
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, cy);
        break;
    case rl:
        res = (s << 1) | ((s >> 7) & 0x01);
        break;
    case rrc:
        cy = (s & 0x01)? 1 : 0;
        res = ((s >> 1) & 0x7f) | (cpu->sfr.psw & 0x80);
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, cy);
        break;
    case rr:
        res = ((s >> 1) & 0x7f) | ((s << 7) & 0x80);
        break;
    case setb_c:
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, 1);
        res = 0; /* unused ret value */
        break;
    case clr_c:
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, 0);
        res = 0; /* unused ret value */
        break;
    case anl_c:
        s = (cpu->sfr.psw >> 7);
        cy = s & d;
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, cy);
        break;
    case orl_c:
        s = (cpu->sfr.psw >> 7);
        cy = s | d;
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, cy);
        break;
    case cjne:
        if(x < y){
            cpu->sfr.psw |= 0x80;
        }
        else{
            cpu->sfr.psw &= ~0x80;
        }
        res = 0;
        break;
    }

    return res;
}

static void cpu_set_sfr(cpu51_t *cpu, uint8_t dir, uint8_t value){
    uint16_t undefined_sfr=0;

    if(dir < 0x80) return;

    switch(dir){
    case 0xe0:  /* ACC */
        cpu_set_a(cpu, value);
        break;
    case 0xf0:  /* B */
        cpu->sfr.b = value;
        break;
    case 0x83:  /* DPH */
        cpu->sfr.dph = value;
        break;
    case 0x82:  /* DPL */
        cpu->sfr.dpl = value;
        break;
    case 0xa8:  /* IE */
        cpu->sfr.ie = value;
        break;
    case 0xb8:  /* IP */
        cpu->sfr.ip = value;
        break;
    case 0x0d0: /* PSW */
        /* The P flag can't be overwritten */
        cpu->sfr.psw = (value & 0xfe) | (cpu->sfr.psw & 0x01);
        break;
    case 0x081: /* SP */
        cpu->sfr.sp = value;
        break;
    default:
        undefined_sfr = mcu_set_sfr(&cpu->mcu, dir, value);
        if(undefined_sfr){
            /* TODO unimplemented SFR addr message should be optional */
            printf("(%04X) UNIMPLEMENTED SFR %02X\n", cpu->log.pc, dir);
        }
    }
    log_sfr(&(cpu->log), dir, value);
}

static uint8_t cpu_get_sfr(cpu51_t *cpu, uint8_t dir){
    uint16_t sfr_value;

    /* TODO this is a bug and some fault flag should be raised */
    if(dir < 0x80) return 0;

    switch(dir){
    case 0xe0:  /* ACC */
        return cpu->a;
        break;
    case 0xf0:  /* B */
        return cpu->sfr.b;
        break;
    case 0x83:  /* DPH */
        return cpu->sfr.dph;
        break;
    case 0x82:  /* DPL */
        return cpu->sfr.dpl;
        break;
    case 0xa8:  /* IE */
        return cpu->sfr.ie;
        break;
    case 0xb8:  /* IP */
        return cpu->sfr.ip;
        break;
    case 0x0d0: /* PSW */
        return cpu->sfr.psw;
        break;
    case 0x081: /* SP */
        return cpu->sfr.sp;
        break;
    default:
        sfr_value = mcu_get_sfr(&cpu->mcu, dir);
        if(sfr_value==0xffff){
            /* TODO unimplemented SFR addr message should be optional */
            printf("(%04X) UNIMPLEMENTED SFR %02X\n", cpu->log.pc, dir);
        }
        else{
            return (uint8_t)sfr_value;
        }
    }

    /* Control will never actually reach here */
    return 0;
}

static void cpu_set_idata(cpu51_t *cpu, uint8_t dir, uint8_t value){
    /* FIXME check bounds */
    cpu->idata[dir] = value;
    log_idata(&(cpu->log), dir, value);
}

static void cpu_set_dir(cpu51_t *cpu, uint8_t dir, uint8_t value){
    /* Direct addressing mode is special; can access both idata and sfr */
    if(dir > 0x07f){
        /* In direct addressing mode, 0x80 to 0xff is actually an SFR address */
        cpu_set_sfr(cpu, dir, value);
    }
    else{
        /* From 0x00 to 0x7f, we're addressing regular idata RAM */
        cpu->idata[dir] = value;
        log_idata(&(cpu->log), dir, value);
    }
}

static uint8_t cpu_get_dir(cpu51_t *cpu, uint8_t dir){
    /* Direct addressing mode is special; can access both idata and sfr */
    if(dir > 0x07f){
        /* In direct addressing mode, 0x80 to 0xff is actually an SFR address */
        return cpu_get_sfr(cpu, dir);
    }
    else{
        /* From 0x00 to 0x7f, we're addressing regular idata RAM */
        return cpu->idata[dir];
    }
}

static uint8_t cpu_get_idata(cpu51_t *cpu, uint8_t dir){
    /* FIXME check bounds */
    return cpu->idata[dir];
}


static bool cpu_rel_jump(cpu51_t *cpu, uint8_t rel){
    int16_t target, offset;

    target = (int16_t)cpu->pc;
    offset = (int16_t)((int8_t)rel);
    target += offset;
    cpu->pc = (uint16_t)target;
    return log_jump(&(cpu->log), cpu->pc);
}


static uint8_t cpu_get_bit_address(cpu51_t *cpu, uint8_t bit){
    uint8_t addr;

    if(bit > 0x7f){
        addr = bit & 0xf8;
    }
    else{
        addr = 0x20 + (bit >> 3);
    }

    return addr;
}


static uint8_t cpu_get_bit(cpu51_t *cpu, uint8_t bit){
    uint8_t dir, res, value;

    dir = cpu_get_bit_address(cpu, bit);
    res = cpu_get_dir(cpu, dir);
    value = (res & (1 << (bit & 0x07)))? 1 : 0;

    return value;
}


static void cpu_set_bit(cpu51_t *cpu, uint8_t bit, uint8_t value){
    uint8_t dir, res;

    dir = cpu_get_bit_address(cpu, bit);
    res = cpu_get_dir(cpu, dir);
    res = set_bit(res, bit, value);
    cpu_set_dir(cpu, dir, res);
}


static bool cpu_exec_upper_half(cpu51_t *cpu, uint8_t opcode){
    uint8_t imm, dir, dir2, bit, res, rel, val;
    uint8_t hi, lo;
    uint16_t address;
    bool ok = true, endless_loop = false;


    switch(opcode){
    /*-- ROW 0 ---------------------------------------------------------------*/
    case 0x00:  /* NOP */
        break;
    case 0x10: /* Jcc bit, rel */
    case 0x20:
    case 0x30:
        bit = cpu_fetch(cpu);
        rel = cpu_fetch(cpu);
        dir = cpu_get_bit_address(cpu, bit);
        res = cpu_get_dir(cpu, dir);
        switch(opcode){
        case 0x10:  /* JBC bit, rel */
            val = res & (1 << (bit & 0x07));
            res &= ~(1 << (bit & 0x07));
            cpu_set_dir(cpu, dir, res);
            if(val){
                cpu_rel_jump(cpu, rel);
                cpu->max_cycle_count = true;
            }
            break;
        case 0x20:  /* JB bit, rel */
            if(res & (1 << (bit & 0x07))){
                cpu_rel_jump(cpu, rel);
                cpu->max_cycle_count = true;
            }
            break;
        case 0x30:  /* JC bit, rel */
            if((res & (1 << (bit & 0x07))) ==0){
                cpu_rel_jump(cpu, rel);
                cpu->max_cycle_count = true;
            }
            break;
        }
        break;
    case 0x40:  /* JC rel */
        rel = cpu_fetch(cpu);
        if(cpu->sfr.psw & 0x80){
            cpu_rel_jump(cpu, rel);
            cpu->max_cycle_count = true;
        }
        break;
    case 0x50:  /* JNC rel */
        rel = cpu_fetch(cpu);
        if(!(cpu->sfr.psw & 0x80)){
            cpu_rel_jump(cpu, rel);
            cpu->max_cycle_count = true;
        }
        break;
    case 0x60:  /* JZ rel */
        rel = cpu_fetch(cpu);
        if(cpu->a == 0){
            cpu_rel_jump(cpu, rel);
            cpu->max_cycle_count = true;
        }
        break;
    case 0x70:  /* JNZ rel */
        rel = cpu_fetch(cpu);
        if(cpu->a != 0){
            cpu_rel_jump(cpu, rel);
            cpu->max_cycle_count = true;
        }
        break;
    case 0x80:  /* SJMP rel */
        rel = cpu_fetch(cpu);
        endless_loop = cpu_rel_jump(cpu, rel);
        break;
    case 0x90:  /* MOV DPTR, #addr16 */
        hi = cpu_fetch(cpu);
        lo = cpu_fetch(cpu);
        cpu->sfr.dph = hi;
        cpu->sfr.dpl = lo;
        log_sfr(&(cpu->log), 0x83, hi);
        log_sfr(&(cpu->log), 0x82, lo);
        break;
    case 0xa0:  /* ORL C, /bit */
        bit = cpu_fetch(cpu);
        res = 1 - cpu_get_bit(cpu, bit);
        cpu->sfr.psw  |= (res << 7);
        break;
    case 0xb0:  /* ANL C, /bit */
        bit = cpu_fetch(cpu);
        res = 1 - cpu_get_bit(cpu, bit);
        cpu->sfr.psw  &= (res << 7);
        break;
    case 0xc0:  /* PUSH dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        cpu->sfr.sp++;
        cpu_set_idata(cpu, cpu->sfr.sp, res);
        break;
    case 0xd0:  /* POP dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_idata(cpu, cpu->sfr.sp--);
        cpu_set_dir(cpu, dir, res);
        break;
    case 0xe0:  /* MOVX A, @DPTR */
        address = (((uint16_t)cpu->sfr.dph) << 8) + (uint16_t)cpu->sfr.dpl;
        res = cpu_xdata_read(cpu, address);
        cpu_set_a(cpu, res);
        break;
    case 0xf0:  /* MOVX @DPTR, A */
        address = (((uint16_t)cpu->sfr.dph) << 8) + (uint16_t)cpu->sfr.dpl;
        cpu_xdata_write(cpu, address, cpu->a);
        break;
    /*-- ROW 1 ---------------------------------------------------------------*/
    case 0x01: case 0x21: case 0x41: case 0x61: /* AJMP addr11 */
    case 0x81: case 0xa1: case 0xc1: case 0xe1:
        address = cpu_fetch11(cpu, opcode);
        cpu->pc = address;
        endless_loop = log_jump(&(cpu->log), address);
        break;
    case 0x11: case 0x31: case 0x51: case 0x71: /* ACALL addr11 */
    case 0x91: case 0xb1: case 0xd1: case 0xf1:
        address = cpu_fetch11(cpu, opcode);
        hi = (uint8_t)(cpu->pc >> 8);
        lo = (uint8_t)(cpu->pc >> 0);
        cpu->sfr.sp++;
        cpu_set_idata(cpu, cpu->sfr.sp, lo);
        cpu->sfr.sp++;
        cpu_set_idata(cpu, cpu->sfr.sp, hi);
        cpu->pc = address;
        endless_loop = log_jump(&(cpu->log), address);
        break;
    /*-- ROW 2 ---------------------------------------------------------------*/
    case 0x02:  /* LJMP addr16 */
        address = cpu_fetch16(cpu);
        cpu->pc = address;
        endless_loop = log_jump(&(cpu->log), address);
        break;
    case 0x12:  /* LCALL addr16 */
        address = cpu_fetch16(cpu);
        hi = (uint8_t)(cpu->pc >> 8);
        lo = (uint8_t)(cpu->pc >> 0);
        cpu->sfr.sp++;
        cpu_set_idata(cpu, cpu->sfr.sp, lo);
        cpu->sfr.sp++;
        cpu_set_idata(cpu, cpu->sfr.sp, hi);
        cpu->pc = address;
        endless_loop = log_jump(&(cpu->log), address);
        break;
    case 0x22:  /* RET */
        hi = cpu_get_idata(cpu, cpu->sfr.sp--);
        lo = cpu_get_idata(cpu, cpu->sfr.sp--);
        address = ((uint16_t)hi << 8) + (uint16_t)lo;
        cpu->pc = address;
        endless_loop = log_jump(&(cpu->log), address);
        break;
    case 0x32:  /* RET */
        /* FIXME interrupts unimplemented / RETI */
        hi = cpu_get_idata(cpu, cpu->sfr.sp--);
        lo = cpu_get_idata(cpu, cpu->sfr.sp--);
        address = ((uint16_t)hi << 8) + (uint16_t)lo;
        cpu->pc = address;
        endless_loop = log_jump(&(cpu->log), address);
        break;
    case 0x42:  /* ORL dir, A */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res | cpu->a;
        cpu_set_dir(cpu, dir, res);
        break;
    case 0x52:  /* ANL dir, A */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res & cpu->a;
        cpu_set_dir(cpu, dir, res);
        break;
    case 0x62:  /* XRL dir, A */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res ^ cpu->a;
        cpu_set_dir(cpu, dir, res);
        break;
    case 0x72:  /* ORL C, bit */
        bit = cpu_fetch(cpu);
        res = cpu_get_bit(cpu, bit);
        cpu->sfr.psw  |= (res << 7);
        break;
    case 0x82:  /* ANL C, bit */
        bit = cpu_fetch(cpu);
        res = cpu_get_bit(cpu, bit);
        cpu->sfr.psw &= (res << 7);
        break;
    case 0x92:  /* MOV bit, C */
        bit = cpu_fetch(cpu);
        cpu_set_bit(cpu, bit, (cpu->sfr.psw >> 7));
        break;
    case 0xa2:  /* MOV C, bit */
        bit = cpu_fetch(cpu);
        res = cpu_get_bit(cpu, bit);
        cpu->sfr.psw = set_bit(cpu->sfr.psw, 7, res);
        break;
    case 0xb2:  /* CPL bit */
        bit = cpu_fetch(cpu);
        dir = cpu_get_bit_address(cpu, bit);
        res = cpu_get_dir(cpu, dir);
        res ^= (1 << (bit & 0x07));
        cpu_set_dir(cpu, dir, res);
        break;
    case 0xc2:  /* CLR bit */
        bit = cpu_fetch(cpu);
        dir = cpu_get_bit_address(cpu, bit);
        res = cpu_get_dir(cpu, dir);
        res &= ~(1 << (bit & 0x07));
        cpu_set_dir(cpu, dir, res);
        break;
    case 0xd2:  /* SETB bit */
        bit = cpu_fetch(cpu);
        dir = cpu_get_bit_address(cpu, bit);
        res = cpu_get_dir(cpu, dir);
        res |= (1 << (bit & 0x07));
        cpu_set_dir(cpu, dir, res);
        break;
    case 0xe2:  /* MOVX A, @R0 */
        /* TODO MOVX @Ri upper address byte hardcoded to zero */
        address = ((uint16_t)cpu_get_rn(cpu, 0)) & 0x00ff;
        res = cpu_xdata_read(cpu, address);
        cpu_set_a(cpu, res);
        break;
    case 0xf2:  /* MOVX @R0, A */
        /* TODO MOVX @Ri upper address byte hardcoded to zero */
        address = ((uint16_t)cpu_get_rn(cpu, 0)) & 0x00ff;
        cpu_xdata_write(cpu, address, cpu->a);
        break;
    /*-- ROW 3 ---------------------------------------------------------------*/
    case 0x03:  /* RR A */
        val = cpu_update_flags(cpu, cpu->a, 0, rr);
        cpu_set_a(cpu, val);
        break;
    case 0x13:  /* RRC A */
        val = cpu_update_flags(cpu, cpu->a, 0, rrc);
        cpu_set_a(cpu, val);
        break;
    case 0x23:  /* RL A */
        val = cpu_update_flags(cpu, cpu->a, 0, rl);
        cpu_set_a(cpu, val);
        break;
    case 0x33:  /* RLC A */
        val = cpu_update_flags(cpu, cpu->a, 0, rlc);
        cpu_set_a(cpu, val);
        break;
    case 0x43:  /* ORL dir, #data */
        dir = cpu_fetch(cpu);
        imm = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res | imm;
        cpu_set_dir(cpu, dir, res);
        break;
    case 0x53:  /* ANL dir, #data */
        dir = cpu_fetch(cpu);
        imm = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res & imm;
        cpu_set_dir(cpu, dir, res);
        break;
    case 0x63:  /* XRL dir, #data */
        dir = cpu_fetch(cpu);
        imm = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res ^ imm;
        cpu_set_dir(cpu, dir, res);
        break;
    case 0x73:  /* JMP @A + DPTR */
        address = (((uint16_t)cpu->sfr.dph) << 8) + (uint16_t)cpu->sfr.dpl;
        address += (uint16_t)(cpu->a);
        cpu->pc = address;
        endless_loop = log_jump(&(cpu->log), address);
        break;
    case 0x83:  /* MOVC A, @A + PC */
        /* Base is PC of NEXT instruction == cpu->pc */
        address = cpu->pc + (uint16_t)(cpu->a);
        res = cpu_xcode_read(cpu, address);
        cpu_set_a(cpu, res);
        break;
    case 0x93:  /* MOVC A, @A + DPTR */
        address = (((uint16_t)cpu->sfr.dph) << 8) + (uint16_t)cpu->sfr.dpl;
        address += (uint16_t)(cpu->a);
        res = cpu_xcode_read(cpu, address);
        cpu_set_a(cpu, res);
        break;
    case 0xa3:  /* INC DPTR */
        address = (((uint16_t)cpu->sfr.dph) << 8) + (uint16_t)cpu->sfr.dpl;
        address++;
        cpu->sfr.dph = (uint8_t)(address >> 8);
        cpu->sfr.dpl = (uint8_t)(address >> 0);
        log_reg16(&(cpu->log), "DPTR", address);
        break;
    case 0xb3:  /* CPL C */
        cpu->sfr.psw ^= 0x80;
        break;
    case 0xc3:  /* CLR C */
        cpu->sfr.psw &= ~0x80;
        break;
    case 0xd3:  /* SETB C */
        cpu->sfr.psw |= 0x80;
        break;
    case 0xe3:  /* MOVX A, @R0 */
        /* TODO MOVX @Ri upper address byte hardcoded to zero */
        address = ((uint16_t)cpu_get_rn(cpu, 1)) & 0x00ff;
        res = cpu_xdata_read(cpu, address);
        cpu_set_a(cpu, res);
        break;
    case 0xf3:  /* MOVX @R0, A */
        /* TODO MOVX @Ri upper address byte hardcoded to zero */
        address = ((uint16_t)cpu_get_rn(cpu, 1)) & 0x00ff;
        cpu_xdata_write(cpu, address, cpu->a);
        break;
    /*-- ROW 4 ---------------------------------------------------------------*/
    case 0x04:  /* INC a */
        cpu_set_a(cpu, cpu->a + 1);
        break;
    case 0x14:  /* DEC a */
        cpu_set_a(cpu, cpu->a - 1);
        break;
    case 0x24:  /* ADD A, #imm */
        imm = cpu_fetch(cpu);
        res = cpu_update_flags(cpu, cpu->a, imm, add);
        cpu_set_a(cpu, res);
        break;
    case 0x34:  /* ADDC A, #imm */
        imm = cpu_fetch(cpu);
        res = cpu_update_flags(cpu, cpu->a, imm, addc);
        cpu_set_a(cpu, res);
        break;
    case 0x44:  /* ORL A, #imm */
        imm = cpu_fetch(cpu);
        res = cpu->a | imm;
        cpu_set_a(cpu, res);
        break;
    case 0x54:  /* ANL A, #imm */
        imm = cpu_fetch(cpu);
        res = cpu->a & imm;
        cpu_set_a(cpu, res);
        break;
    case 0x64:  /* XRL A, #imm */
        imm = cpu_fetch(cpu);
        res = cpu->a ^ imm;
        cpu_set_a(cpu, res);
        break;
    case 0x74:  /* MOV A, #data */
        imm = cpu_fetch(cpu);
        cpu_set_a(cpu, imm);
        break;
    case 0x84:  /* DIV AB */
        res = cpu_update_flags(cpu, cpu->a, cpu->sfr.b, alu_div);
        cpu_set_a(cpu, res);
        break;
    case 0x94:  /* SUBB A, #data */
        imm = cpu_fetch(cpu);
        res = cpu_update_flags(cpu, cpu->a, imm, subb);
        cpu_set_a(cpu, res);
        break;
    case 0xa4:  /* MUL AB */
        res = cpu_update_flags(cpu, cpu->a, cpu->sfr.b, alu_mul);
        cpu_set_a(cpu, res);
        break;
    case 0xb4:  /* CJNE A, #data, rel */
        imm = cpu_fetch(cpu);
        rel = cpu_fetch(cpu);
        cpu_update_flags(cpu, cpu->a, imm, cjne);
        if(imm != cpu->a){
            cpu_rel_jump(cpu, rel);
            cpu->max_cycle_count = true;
        }
        break;
    case 0xc4:  /* SWAP A */
        res = (cpu->a >> 4) & 0x0f;
        res = res | ((cpu->a << 4) & 0x0f0);
        cpu_set_a(cpu, res);
        break;
    case 0xd4:  /* DA A */
        if(cpu->options.bcd){
            val = cpu_update_flags(cpu, cpu->a, 0, da);
            cpu_set_a(cpu, val);
        }
        else{
            /* DA unimplemented, execute as NOP */
            cpu->implemented_as_nop = true;
        }
        break;
    case 0xe4:  /* CLR A */
        cpu_set_a(cpu, 0);
        break;
    case 0xf4:  /* CPL A */
        cpu_set_a(cpu, ~(cpu->a));
        break;
    /*-- ROW 5 ---------------------------------------------------------------*/
    case 0x05:  /* INC dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res + 1;
        cpu_set_dir(cpu, dir, res);
        break;
    case 0x15:  /* DEC dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res - 1;
        cpu_set_dir(cpu, dir, res);
        break;
    case 0x25:  /* ADD A, dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = cpu_update_flags(cpu, cpu->a, res, add);
        cpu_set_a(cpu, res);
        break;
    case 0x35:  /* ADDC A, dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = cpu_update_flags(cpu, cpu->a, res, addc);
        cpu_set_a(cpu, res);
        break;
    case 0x45:  /* ORL A, dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res | cpu->a;
        cpu_set_a(cpu, res);
        break;
    case 0x55:  /* ANL A, dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res & cpu->a;
        cpu_set_a(cpu, res);
        break;
    case 0x65:  /* XRL A, dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res ^ cpu->a;
        cpu_set_a(cpu, res);
        break;
    case 0x75:  /* MOV dir, #imm */
        dir = cpu_fetch(cpu);
        imm = cpu_fetch(cpu);
        cpu_set_dir(cpu, dir, imm);
        break;
    case 0x85:  /* MOV dir1, dir2 */
        dir = cpu_fetch(cpu);
        dir2 = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        cpu_set_dir(cpu, dir2, res);
        break;
    case 0x95:  /* SUBB A, dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = cpu_update_flags(cpu, cpu->a, res, subb);
        cpu_set_a(cpu, res);
        break;
    case 0xa5:  /* RESERVED A5h opcode : implemented as NOP */
        cpu->implemented_as_nop = true;
        break;
    case 0xb5:  /* CJNE A, dir, rel */
        dir = cpu_fetch(cpu);
        rel = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        cpu_update_flags(cpu, cpu->a, res, cjne);
        if(res != cpu->a){
            cpu_rel_jump(cpu, rel);
            cpu->max_cycle_count = true;
        }
        break;
    case 0xc5:  /* XCH A,dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        cpu_set_dir(cpu, dir, cpu->a);
        cpu_set_a(cpu, res);
        break;
    case 0xd5:  /* DJNZ dir, rel */
        dir = cpu_fetch(cpu);
        rel = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        res = res - 1;
        cpu_set_dir(cpu, dir, res);
        if(res != 0){
            cpu_rel_jump(cpu, rel);
            cpu->max_cycle_count = true;
        }
        break;
    case 0xe5:  /* MOV a, dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        cpu_set_a(cpu, res);
        break;
    case 0xf5:  /* MOV dir, a */
        dir = cpu_fetch(cpu);
        cpu_set_dir(cpu, dir, cpu->a);
        break;
    /*-- ROW 6 & ROW 7 -------------------------------------------------------*/
    /*  IMPORTANT:
        All the cases in the x6 & x7 groups are PAIRED. The 'case fallthrough'
        is intentional.
        TODO label fallthrough case for lint tool.
    */
    case 0x06:  /* INC @Ri */
    case 0x07:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        cpu_set_idata(cpu, dir, res + 1);
        break;
    case 0x16:  /* DEC @Ri */
    case 0x17:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        cpu_set_idata(cpu, dir, res - 1);
        break;
    case 0x26:  /* ADD A, @Ri */
    case 0x27:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        res = cpu_update_flags(cpu, cpu->a, res, add);
        cpu_set_a(cpu, res);
        break;
    case 0x36:  /* ADDC A, @Ri */
    case 0x37:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        res = cpu_update_flags(cpu, cpu->a, res, addc);
        cpu_set_a(cpu, res);
        break;
    case 0x46:  /* ORL A, @Ri */
    case 0x47:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        res = res | cpu->a;
        cpu_set_a(cpu, res);
        break;
    case 0x56:  /* ANL A, @Ri */
    case 0x57:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        res = res & cpu->a;
        cpu_set_a(cpu, res);
        break;
    case 0x66:  /* XRL A, @Ri */
    case 0x67:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        res = res ^ cpu->a;
        cpu_set_a(cpu, res);
        break;
    case 0x76:  /* MOV @Ri, imm */
    case 0x77:
        imm = cpu_fetch(cpu);
        dir = cpu_get_rn(cpu, opcode & 0x01);
        cpu_set_idata(cpu, dir, imm);
        break;
    case 0x86:  /* MOV dir, @Ri */
    case 0x87:
        dir = cpu_fetch(cpu);
        imm = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, imm);
        cpu_set_dir(cpu, dir, res);
        break;
    case 0x96:  /* SUBB A, @Ri */
    case 0x97:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        res = cpu_update_flags(cpu, cpu->a, res, subb);
        cpu_set_a(cpu, res);
        break;
    case 0xa6:  /* MOV @Ri, dir */
    case 0xa7:
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        dir = cpu_get_rn(cpu, opcode & 0x01);
        cpu_set_idata(cpu, dir, res);
        break;
    case 0xb6:  /* CJNE @Ri, #imm, rel */
    case 0xb7:
        imm = cpu_fetch(cpu);
        rel = cpu_fetch(cpu);
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        cpu_update_flags(cpu, res, imm, cjne);
        if(imm != res){
            cpu_rel_jump(cpu, rel);
            cpu->max_cycle_count = true;
        }
        break;
    case 0xc6:  /* XCH A,@Ri */
    case 0xc7:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        cpu_set_idata(cpu, dir, cpu->a);
        cpu_set_a(cpu, res);
        break;
    case 0xd6:  /* XCHD A,@Ri */
    case 0xd7:
        if(cpu->options.bcd){
            dir = cpu_get_rn(cpu, opcode & 0x01);
            res = cpu_get_idata(cpu, dir);
            imm = (res & 0x0f0) | (cpu->a & 0x00f);
            cpu_set_a(cpu, ((cpu->a & 0x0f0) | (res & 0x00f)));
            cpu_set_idata(cpu, dir, imm);
        }
        else{
            /* Implemented as NOP */
            cpu->implemented_as_nop = true;
        }
        break;
    case 0xe6:  /* MOV A, @Ri */
    case 0xe7:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        res = cpu_get_idata(cpu, dir);
        cpu_set_a(cpu, res);
        break;
    case 0xf6:  /* MOV @Ri, A */
    case 0xf7:
        dir = cpu_get_rn(cpu, opcode & 0x01);
        cpu_set_idata(cpu, dir, cpu->a);
        break;
    default:    /* unimplemented opcode */
        log_unimplemented(&(cpu->log), opcode);
        ok = false;
    }

    if(endless_loop){
        return false;
    }
    else{
        return ok;
    }
}

static bool cpu_exec_rn(cpu51_t *cpu, uint8_t opcode){
    uint8_t operation, rn, n, res, dir, imm, rel;
    bool ok = true;
    bool endless_loop = false;

    operation = (opcode >> 4) & 0x0f;
    n = opcode & 0x07;
    rn = cpu_get_rn(cpu, n);

    switch(operation){
    case 0x00:  /* INC Rn */
        cpu_set_rn(cpu, n, rn+1);
        break;
    case 0x01:  /* DEC Rn */
        cpu_set_rn(cpu, n, rn-1);
        break;
    case 0x02:  /* ADD A,Rn */
        res = cpu_update_flags(cpu, cpu->a, rn, add);
        cpu_set_a(cpu, res);
        break;
    case 0x03:  /* ADDC A,Rn */
        res = cpu_update_flags(cpu, cpu->a, rn, addc);
        cpu_set_a(cpu, res);
        break;
    case 0x04:  /* ORL A, Rn */
        cpu_set_a(cpu, cpu->a | rn);
        break;
    case 0x05:  /* ANL A, Rn */
        cpu_set_a(cpu, cpu->a & rn);
        break;
    case 0x06:  /* XRL A, Rn */
        cpu_set_a(cpu, cpu->a ^ rn);
        break;
    case 0x07:  /* MOV Rn, #data */
        imm = cpu_fetch(cpu);
        cpu_set_rn(cpu, n, imm);
        break;
    case 0x08:  /* MOV dir, Rn */
        dir = cpu_fetch(cpu);
        cpu_set_dir(cpu, dir, rn);
        break;
    case 0x09:  /* SUBB A, Rn */
        res = cpu_update_flags(cpu, cpu->a, rn, subb);
        cpu_set_a(cpu, res);
        break;
    case 0x0a:  /* MOV Rn, dir */
        dir = cpu_fetch(cpu);
        res = cpu_get_dir(cpu, dir);
        cpu_set_rn(cpu, n, res);
        break;
    case 0x0b:  /* CJNE Rn, #data, rel */
        imm = cpu_fetch(cpu);
        rel = cpu_fetch(cpu);
        cpu_update_flags(cpu, rn, imm, cjne);
        if(imm != rn){
            cpu_rel_jump(cpu, rel);
            cpu->max_cycle_count = true;
        }
        break;
    case 0x0c:  /* XCH A, Rn */
        res = cpu->a;
        cpu_set_a(cpu, rn);
        cpu_set_rn(cpu, n, res);
        break;
    case 0x0d:  /* DJNZ Rn, rel */
        rel = cpu_fetch(cpu);
        res = rn - 1;
        cpu_set_rn(cpu, n, res);
        if(res != 0){
            cpu_rel_jump(cpu, rel);
            cpu->max_cycle_count = true;
        }
        break;
    case 0x0e:  /* MOV A, Rn */
        cpu_set_a(cpu, rn);
        break;
    case 0x0f:  /* MOV Rn, A */
        cpu_set_rn(cpu, n, cpu->a);
        break;
    }

    if(endless_loop){
        return false;
    }
    else{
        return ok;
    }
}
