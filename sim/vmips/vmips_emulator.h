/*
 * This file is subject to the terms and conditions of the GPL License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#ifndef __VMIPS_EMULATOR_H

#define __VMIPS_EMULATOR_H

//------------------------------------------------------------------------------

uint32 ao_interrupts        ();
uint8  ao_fetch_byte        (uint32 addr, bool cacheable, bool isolated);
uint16 ao_fetch_halfword    (uint32 addr, bool cacheable, bool isolated);
uint32 ao_fetch_word        (uint32 addr, int32 mode, bool cacheable, bool isolated);
void   ao_store_byte        (uint32 addr, uint8 data, bool cacheable, bool isolated);
void   ao_store_halfword    (uint32 addr, uint16 data, bool cacheable, bool isolated);
void   ao_store_word        (uint32 addr, uint32 data, bool cacheable, bool isolated, uint32 byteenable = 0xF);

void fatal_error(const char *error, ...);

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------ Code from vmips-1.4.1 project under the GPL license
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

/* MIPS R3000 CPU emulation.
   Copyright 2001, 2002, 2003, 2004 Brian R. Gaeke.

This file is part of VMIPS.

VMIPS is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.

VMIPS is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with VMIPS; if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */

//------------------------------------------------------------------------------ excnames.h

/* Exceptions - Cause register ExcCode field */
#define Int 0       /* Interrupt */
#define Mod 1       /* TLB modification exception */
#define TLBL 2      /* TLB exception (load or instruction fetch) */
#define TLBS 3      /* TLB exception (store) */
#define AdEL 4      /* Address error exception (load or instruction fetch) */
#define AdES 5      /* Address error exception (store) */
#define IBE 6       /* Instruction bus error */
#define DBE 7       /* Data (load or store) bus error */
#define Sys 8       /* SYSCALL exception */
#define Bp 9        /* Breakpoint exception (BREAK instruction) */
#define RI 10       /* Reserved instruction exception */
#define CpU 11      /* Coprocessor Unusable */
#define Ov 12       /* Arithmetic Overflow */
#define Tr 13       /* Trap (R4k/R6k only) */
#define NCD 14      /* LDCz or SDCz to uncached address (R6k) */
#define VCEI 14     /* Virtual Coherency Exception (instruction) (R4k) */
#define MV 15       /* Machine check exception (R6k) */
#define FPE 15      /* Floating-point exception (R4k) */
/* 16-22 - reserved */
#define WATCH 23    /* Reference to WatchHi/WatchLo address detected (R4k) */
/* 24-30 - reserved */
#define VCED 31     /* Virtual Coherency Exception (data) (R4k) */

//------------------------------------------------------------------------------ accesstypes.h

/* Three kinds of memory accesses are possible.
 * There are two kinds of load and one kind of store:
 * INSTFETCH is a memory access due to an instruction fetch.
 * DATALOAD is a memory access due to a load instruction,
 * e.g., lw, lh, lb.
 * DATASTORE is a memory access due to a store instruction,
 * e.g., sw, sh, sb.
 *
 * ANY is a catch-all used in exception prioritizing which
 * implies that none of the kinds of memory accesses applies,
 * or that the type of memory access otherwise doesn't matter.
 */
#define INSTFETCH 0
#define DATALOAD 1
#define DATASTORE 2
#define ANY 3

/* add_core_mapping and friends maintain a set of protection
 * bits which define allowable access to memory. These do
 * not have anything to do with the virtual memory privilege
 * bits that a kernel would maintain; they are used to
 * distinguish between, for example, ROM and RAM, and between
 * readable and unreadable words of a memory-mapped device.
 */
#define MEM_READ       0x01
#define MEM_WRITE      0x02
#define MEM_READ_WRITE 0x03

//------------------------------------------------------------------------------ cpzeroreg.h

/* Constants for virtual address translation.
 *
 * Some of these are used as masks and some are used as constant
 * translations (i.e., the address of something is the address of
 * something else plus or minus a translation). The desired effect is
 * to reduce the number of random "magic numbers" floating around...
 */

#define KSEG_SELECT_MASK 0xe0000000 /* bits of address which determine seg. */
#define KUSEG 0            /* not really a mask, but user space begins here */
#define KERNEL_SPACE_MASK 0x80000000           /* beginning of kernel space */
#define KSEG0 0x80000000     /* beginning of unmapped cached kernel segment */
#define KSEG0_CONST_TRANSLATION 0x80000000 /* kseg0 v->p address difference */
#define KSEG1 0xa0000000   /* beginning of unmapped uncached kernel segment */
#define KSEG1_CONST_TRANSLATION 0xa0000000 /* kseg1 v->p address difference */
#define KSEG2 0xc0000000       /* beginning of mapped cached kernel segment */
#define KSEG2_top 0xe0000000    /* 2nd half of mapped cached kernel segment */

/* CP0 register names and masks
 *
 * A table of names for CP0's registers follows. After that follow a
 * series of masks by which fields of these registers can be isolated.
 * The masks are convenient for Boolean flags but are slightly less so
 * for numbers being extracted from the middle of a word because they
 * still need to be shifted. At least, it makes clear which field is
 * being accessed, and the bit numbers are clearly indicated in every mask
 * below.  The naming convention is as follows: Mumble is the name of some
 * CP0 register, Mumble_MASK is the bit mask which controls reading and
 * writing of the register (0 -> bit is always zero and ignores writes,
 * 1 -> normal read/write) and Mumble_Field_MASK is the mask used to
 * access the "Field" portion of register Mumble. For more information
 * on these fields consult "MIPS RISC Architecture", chapters 4 and 6.
 */

#define Index 0     /* selects TLB entry for r/w ops & shows probe success */ 
#define Random 1    /* continuously decrementing number (range 8..63) */
#define EntryLo 2   /* low word of a TLB entry */
#define EntryLo0 2  /* R4k uses this for even-numbered virtual pages */
#define EntryLo1 3  /* R4k uses this for odd-numbered virtual pages */
#define Context 4   /* TLB refill handler's kernel PTE entry pointer */
#define PageMask 5  /* R4k page number bit mask (impl. variable page sizes) */
#define Wired 6     /* R4k lower bnd for Random (controls randomness of TLB) */
#define Error 7     /* R6k status/control register for parity checking */
#define BadVAddr 8  /* "bad" virt. addr (VA of last failed v->p translation) */
#define Count 9     /* R4k r/w reg - continuously incrementing counter */
#define EntryHi 10  /* High word of a TLB entry */
#define ASID 10     /* R6k uses this to store the ASID (only) */
#define Compare 11  /* R4k traps when this register equals Count */
#define Status 12   /* Kernel/User mode, interrupt enb., & diagnostic states */
#define Cause 13    /* Cause of last exception */
#define EPC 14      /* Address to return to after processing this exception */
#define PRId 15     /* Processor revision identifier */
#define Config 16   /* R4k config options for caches, etc. */
#define LLAdr 17    /* R4k last instruction read by a Load Linked */
#define LLAddr 17   /* Inconsistencies in naming... sigh. */
#define WatchLo 18  /* R4k hardware watchpoint data */
#define WatchHi 19  /* R4k hardware watchpoint data */
/* 20-25 - reserved */
#define ECC 26      /* R4k cache Error Correction Code */
#define CacheErr 27 /* R4k read-only cache error codes */
#define TagLo 28    /* R4k primary or secondary cache tag and parity */
#define TagHi 29    /* R4k primary or secondary cache tag and parity */
#define ErrorEPC 30 /* R4k cache error EPC */
/* 31 - reserved */

/* (0) Index fields */
#define Index_P_MASK 0x80000000         /* Last TLB Probe instr failed (31) */
#define Index_Index_MASK 0x00003f00  /* TLB entry to read/write next (13-8) */
#define Index_MASK 0x80003f00

/* (1) Random fields */
#define Random_Random_MASK 0x00003f00   /* TLB entry to replace next (13-8) */
#define Random_MASK 0x00003f00
/* Random register upper and lower bounds (R3000) */
#define Random_UPPER_BOUND 63
#define Random_LOWER_BOUND 8

/* (2) EntryLo fields */
#define EntryLo_PFN_MASK 0xfffff000            /* Page frame number (31-12) */
#define EntryLo_N_MASK 0x00000800                      /* Noncacheable (11) */
#define EntryLo_D_MASK 0x00000400                             /* Dirty (10) */
#define EntryLo_V_MASK 0x00000200                              /* Valid (9) */
#define EntryLo_G_MASK 0x00000100                             /* Global (8) */
#define EntryLo_MASK 0xffffff00

/* (4) Context fields */
#define Context_PTEBase_MASK 0xffe00000          /* Page Table Base (31-21) */
#define Context_BadVPN_MASK 0x001ffffc      /* Bad Virtual Page num. (20-2) */
#define Context_MASK 0xfffffffc

/* (5) PageMask is only on the R4k */
#define PageMask_MASK 0x00000000

/* (6) Wired is only on the R4k */
#define Wired_MASK 0x00000000

/* (7) Error is only on the R6k */
#define Error_MASK 0x00000000

/* (8) BadVAddr has only one field */
#define BadVAddr_MASK 0xffffffff

/* (9) Count is only on the R4k */
#define Count_MASK 0x00000000

/* (10) EntryHi fields */
#define EntryHi_VPN_MASK 0xfffff000             /* Virtual page no. (31-12) */
#define EntryHi_ASID_MASK 0x00000fc0                 /* Current ASID (11-6) */
#define EntryHi_MASK 0xffffffc0

/* (11) Compare is only on the R4k */
#define Compare_MASK 0x00000000

/* (12) Status fields */
#define Status_CU_MASK 0xf0000000      /* Coprocessor (3..0) Usable (31-28) */
#define Status_CU3_MASK 0x80000000             /* Coprocessor 3 Usable (31) */
#define Status_CU2_MASK 0x40000000             /* Coprocessor 2 Usable (30) */
#define Status_CU1_MASK 0x20000000             /* Coprocessor 1 Usable (29) */
#define Status_CU0_MASK 0x10000000             /* Coprocessor 0 Usable (28) */
#define Status_RE_MASK 0x02000000     /* Reverse Endian (R3000A/R6000) (25) */
#define Status_DS_MASK 0x01ff0000              /* Diagnostic Status (24-16) */
#define Status_DS_BEV_MASK 0x00400000    /* Bootstrap Exception Vector (22) */
#define Status_DS_TS_MASK 0x00200000                   /* TLB Shutdown (21) */
#define Status_DS_PE_MASK 0x00100000             /* Cache Parity Error (20) */
#define Status_DS_CM_MASK 0x00080000                     /* Cache miss (19) */
#define Status_DS_PZ_MASK 0x00040000    /* Cache parity forced to zero (18) */
#define Status_DS_SwC_MASK 0x00020000      /* Data/Inst cache switched (17) */
#define Status_DS_IsC_MASK 0x00010000                /* Cache isolated (16) */
#define Status_IM_MASK 0x0000ff00                  /* Interrupt Mask (15-8) */
#define Status_IM_Ext_MASK 0x0000fc00 /* Extrn. (HW) Interrupt Mask (15-10) */
#define Status_IM_SW_MASK 0x00000300       /* Software Interrupt Mask (9-8) */
#define Status_KU_IE_MASK 0x0000003f /* Kernel/User & Int Enable bits (5-0) */
#define Status_KUo_MASK 0x00000020            /* Old Kernel/User status (5) */
#define Status_IEo_MASK 0x00000010       /* Old Interrupt Enable status (4) */
#define Status_KUp_MASK 0x00000008       /* Previous Kernel/User status (3) */
#define Status_IEp_MASK 0x00000004  /* Previous Interrupt Enable status (2) */
#define Status_KUc_MASK 0x00000002        /* Current Kernel/User status (1) */
#define Status_IEc_MASK 0x00000001   /* Current Interrupt Enable status (0) */
#define Status_MASK 0xf27fff3f

/* (13) Cause fields */
#define Cause_BD_MASK 0x80000000                       /* Branch Delay (31) */
#define Cause_CE_MASK 0x30000000               /* Coprocessor Error (29-28) */
#define Cause_IP_MASK 0x0000ff00                /* Interrupt Pending (15-8) */
#define Cause_IP_Ext_MASK 0x0000fc00  /* External (HW) ints IP(7-2) (15-10) */
#define Cause_IP_SW_MASK 0x00000300          /* Software ints IP(1-0) (9-8) */
#define Cause_ExcCode_MASK 0x0000007c               /* Exception Code (6-2) */
#define Cause_MASK 0xb000ff7c

/* (14) EPC has only one field */
#define EPC_MASK 0xffffffff

/* (15) PRId fields */
#define PRId_Imp_MASK 0x0000ff00                   /* Implementation (15-8) */
#define PRId_Rev_MASK 0x000000ff                          /* Revision (7-0) */
#define PRId_MASK 0x0000ffff

/* (16) Config is only on the R4k */
#define Config_MASK 0x00000000

/* (17) LLAddr is only on the R4k */
#define LLAddr_MASK 0x00000000

/* (18) WatchLo is only on the R4k */
#define WatchLo_MASK 0x00000000

/* (19) WatchHi is only on the R4k */
#define WatchHi_MASK 0x00000000

/* (20-25) reserved */

/* (26) ECC is only on the R4k */
#define ECC_MASK 0x00000000

/* (27) CacheErr is only on the R4k */
#define CacheErr_MASK 0x00000000

/* (28) TagLo is only on the R4k */
#define TagLo_MASK 0x00000000

/* (29) TagHi is only on the R4k */
#define TagHi_MASK 0x00000000

/* (30) ErrorEPC is only on the R4k */
#define ErrorEPC_MASK 0x00000000

/* (31) reserved */

//------------------------------------------------------------------------------ tlbentry.h

class TLBEntry {
public:
    uint32 entryHi;
    uint32 entryLo;
    TLBEntry () {
    }
    uint32 vpn() const { return (entryHi & EntryHi_VPN_MASK); }
    uint16 asid() const { return (entryHi & EntryHi_ASID_MASK); }
    uint32 pfn() const { return (entryLo & EntryLo_PFN_MASK); }
    bool noncacheable() const { return (entryLo & EntryLo_N_MASK); }
    bool dirty() const { return (entryLo & EntryLo_D_MASK); }
    bool valid() const { return (entryLo & EntryLo_V_MASK); }
    bool global() const { return (entryLo & EntryLo_G_MASK); }
};

//------------------------------------------------------------------------------ cpzero.h

class CPU;

#define TLB_ENTRIES 64

class CPZero
{
    TLBEntry tlb[TLB_ENTRIES];
    uint32 reg[32];
    CPU *cpu;

    // Return TRUE if interrupts are enabled, FALSE otherwise.
    bool interrupts_enabled(void) const;

    // Return TRUE if the cpu is running in kernel mode, FALSE otherwise.
    bool kernel_mode(void) const;

    // Return the currently pending interrupts.
    uint32 getIP(void);

    void mfc0_emulate(uint32 instr, uint32 pc);
    void mtc0_emulate(uint32 instr, uint32 pc);
    void bc0x_emulate(uint32 instr, uint32 pc);
    void tlbr_emulate(uint32 instr, uint32 pc);
    void tlbwi_emulate(uint32 instr, uint32 pc);
    void tlbwr_emulate(uint32 instr, uint32 pc);
    void tlbp_emulate(uint32 instr, uint32 pc);
    void rfe_emulate(uint32 instr, uint32 pc);
    void load_addr_trans_excp_info(uint32 va, uint32 vpn, TLBEntry *match);
    int find_matching_tlb_entry(uint32 vpn, uint32 asid);
    uint32 tlb_translate(uint32 seg, uint32 vaddr, int mode, bool *cacheable);

public:
    bool tlb_miss_user;

    // Write TLB entry number INDEX with the contents of the EntryHi
    // and EntryLo registers.
    void tlb_write(unsigned index);

    // Return the contents of the readable bits of register REG.
    uint32 read_reg(const uint16 regno);

    // Change the contents of the writable bits of register REG to NEW_DATA.
    void write_reg(const uint16 regno, const uint32 new_data);

    /* Convention says that CP0's condition is TRUE if the memory
       write-back buffer is empty. Because memory writes are fast as far
       as the emulation is concerned, the write buffer is always empty
       for CP0. */
    bool cpCond() const { return true; }

    CPZero(CPU *m);
    void reset(void);
    
    //initialize from shared memory
    void initialize();
    //report to shared memory
    void report();
    
    /* Request to translate virtual address VADDR, while the processor is
       in mode MODE to a physical address. CLIENT is the entity that will
       recieve any interrupts generated by the attempted translation. On
       return CACHEABLE will be set to TRUE if the returned address is
       cacheable, it will be set to FALSE otherwise. Returns the physical
       address corresponding to VADDR if such a translation is possible,
       otherwise an interrupt is raised with CLIENT and the return value
       is undefined. */
    uint32 address_trans(uint32 vaddr, int mode, bool *cacheable, bool *cache_isolated);

    void enter_exception(uint32 pc, uint32 excCode, uint32 ce, bool dly);
    bool use_boot_excp_address(void);
    bool caches_isolated(void);

    /* Return TRUE if the instruction and data caches are swapped,
       FALSE otherwise. */
    bool caches_swapped(void);

    bool cop_usable (int coprocno);
    void cpzero_emulate(uint32 instr, uint32 pc);

    /* Change the CP0 random register after an instruction step. */
    void adjust_random(void);

    /* Return TRUE if there is an interrupt which should be handled
       at the next available opportunity, FALSE otherwise. */
    bool interrupt_pending(void);
};

//------------------------------------------------------------------------------ cpu.h

/* states of the delay-slot state machine -- see CPU::step() */
static const int NORMAL = 0, DELAYING = 1, DELAYSLOT = 2;

/* Exception priority information -- see exception_priority(). */
struct excPriority {
    int priority;
    int excCode;
    int mode;
};

class CPU {
    
    // Important registers:
    uint32 pc;      // Program counter
    uint32 reg[32]; // General-purpose registers
    uint32 instr;   // The current instruction
    uint32 hi, lo;  // Division and multiplication results

    // Exception bookkeeping data.
    uint32 last_epc;
    int last_prio;
    uint32 next_epc;

    // Other components of the VMIPS machine.
    CPZero *cpzero;

    // Delay slot handling.
    int delay_state;
    uint32 delay_pc;

    // Miscellaneous shared code. 
    void control_transfer(uint32 new_pc);
    void jump(uint32 instr, uint32 pc);
    uint32 calc_jump_target(uint32 instr, uint32 pc);
    uint32 calc_branch_target(uint32 instr, uint32 pc);
    void mult64(uint32 *hi, uint32 *lo, uint32 n, uint32 m);
    void mult64s(uint32 *hi, uint32 *lo, int32 n, int32 m);
    void cop_unimpl (int coprocno, uint32 instr, uint32 pc);

    // Unaligned load/store support.
    uint32 lwr(uint32 regval, uint32 memval, uint8 offset);
    uint32 lwl(uint32 regval, uint32 memval, uint8 offset);
    uint32 swl(uint32 regval, uint32 memval, uint8 offset);
    uint32 swr(uint32 regval, uint32 memval, uint8 offset);

    // Emulation of specific instructions.
    void funct_emulate(uint32 instr, uint32 pc);
    void regimm_emulate(uint32 instr, uint32 pc);
    void j_emulate(uint32 instr, uint32 pc);
    void jal_emulate(uint32 instr, uint32 pc);
    void beq_emulate(uint32 instr, uint32 pc);
    void bne_emulate(uint32 instr, uint32 pc);
    void blez_emulate(uint32 instr, uint32 pc);
    void bgtz_emulate(uint32 instr, uint32 pc);
    void addi_emulate(uint32 instr, uint32 pc);
    void addiu_emulate(uint32 instr, uint32 pc);
    void slti_emulate(uint32 instr, uint32 pc);
    void sltiu_emulate(uint32 instr, uint32 pc);
    void andi_emulate(uint32 instr, uint32 pc);
    void ori_emulate(uint32 instr, uint32 pc);
    void xori_emulate(uint32 instr, uint32 pc);
    void lui_emulate(uint32 instr, uint32 pc);
    void cpzero_emulate(uint32 instr, uint32 pc);
    void cpone_emulate(uint32 instr, uint32 pc);
    void cptwo_emulate(uint32 instr, uint32 pc);
    void cpthree_emulate(uint32 instr, uint32 pc);
    void lb_emulate(uint32 instr, uint32 pc);
    void lh_emulate(uint32 instr, uint32 pc);
    void lwl_emulate(uint32 instr, uint32 pc);
    void lw_emulate(uint32 instr, uint32 pc);
    void lbu_emulate(uint32 instr, uint32 pc);
    void lhu_emulate(uint32 instr, uint32 pc);
    void lwr_emulate(uint32 instr, uint32 pc);
    void sb_emulate(uint32 instr, uint32 pc);
    void sh_emulate(uint32 instr, uint32 pc);
    void swl_emulate(uint32 instr, uint32 pc);
    void sw_emulate(uint32 instr, uint32 pc);
    void swr_emulate(uint32 instr, uint32 pc);
    void lwc1_emulate(uint32 instr, uint32 pc);
    void lwc2_emulate(uint32 instr, uint32 pc);
    void lwc3_emulate(uint32 instr, uint32 pc);
    void swc1_emulate(uint32 instr, uint32 pc);
    void swc2_emulate(uint32 instr, uint32 pc);
    void swc3_emulate(uint32 instr, uint32 pc);
    void sll_emulate(uint32 instr, uint32 pc);
    void srl_emulate(uint32 instr, uint32 pc);
    void sra_emulate(uint32 instr, uint32 pc);
    void sllv_emulate(uint32 instr, uint32 pc);
    void srlv_emulate(uint32 instr, uint32 pc);
    void srav_emulate(uint32 instr, uint32 pc);
    void jr_emulate(uint32 instr, uint32 pc);
    void jalr_emulate(uint32 instr, uint32 pc);
    void syscall_emulate(uint32 instr, uint32 pc);
    void break_emulate(uint32 instr, uint32 pc);
    void mfhi_emulate(uint32 instr, uint32 pc);
    void mthi_emulate(uint32 instr, uint32 pc);
    void mflo_emulate(uint32 instr, uint32 pc);
    void mtlo_emulate(uint32 instr, uint32 pc);
    void mult_emulate(uint32 instr, uint32 pc);
    void multu_emulate(uint32 instr, uint32 pc);
    void div_emulate(uint32 instr, uint32 pc);
    void divu_emulate(uint32 instr, uint32 pc);
    void add_emulate(uint32 instr, uint32 pc);
    void addu_emulate(uint32 instr, uint32 pc);
    void sub_emulate(uint32 instr, uint32 pc);
    void subu_emulate(uint32 instr, uint32 pc);
    void and_emulate(uint32 instr, uint32 pc);
    void or_emulate(uint32 instr, uint32 pc);
    void xor_emulate(uint32 instr, uint32 pc);
    void nor_emulate(uint32 instr, uint32 pc);
    void slt_emulate(uint32 instr, uint32 pc);
    void sltu_emulate(uint32 instr, uint32 pc);
    void bltz_emulate(uint32 instr, uint32 pc);
    void bgez_emulate(uint32 instr, uint32 pc);
    void bltzal_emulate(uint32 instr, uint32 pc);
    void bgezal_emulate(uint32 instr, uint32 pc);
    void RI_emulate(uint32 instr, uint32 pc);

    // Exception prioritization.
    int exception_priority(uint16 excCode, int mode) const;

    //
    bool exception_pending;
    
public:
    // Instruction decoding.
    static uint16 opcode(const uint32 i) { return (i >> 26) & 0x03f; }
    static uint16 rs(const uint32 i) { return (i >> 21) & 0x01f; }
    static uint16 rt(const uint32 i) { return (i >> 16) & 0x01f; }
    static uint16 rd(const uint32 i) { return (i >> 11) & 0x01f; }
    static uint16 immed(const uint32 i) { return i & 0x0ffff; }
    static short s_immed(const uint32 i) { return i & 0x0ffff; }
    static uint16 shamt(const uint32 i) { return (i >> 6) & 0x01f; }
    static uint16 funct(const uint32 i) { return i & 0x03f; }
    static uint32 jumptarg(const uint32 i) { return i & 0x03ffffff; }

    // Constructor & destructor.
    CPU ();
    virtual ~CPU ();

    // Register file accessors.
    uint32 get_reg (const unsigned regno) { return reg[regno]; }
    void put_reg (const unsigned regno, const uint32 new_data) {    
        reg[regno] = new_data;  
    }
    //initialize from shared memory
    void initialize();
    //report to shared memory
    void report();
    //
    uint32 get_delay_state() { return delay_state; }
    
    bool was_delayed_transfer;
    uint32 was_delayed_pc;
    
    // Control-flow methods.
    int step (bool debug=false);
    void reset ();

    // Methods which are only for use by the CPU and its coprocessors.
    void branch (uint32 instr, uint32 pc);
    void exception (uint16 excCode, int mode = ANY, int coprocno = -1);
};

#endif //__VMIPS_EMULATOR_H
