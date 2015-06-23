/*
 * This file is subject to the terms and conditions of the GPL License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "shared_mem.h"
#include "vmips_emulator.h"

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

//------------------------------------------------------------------------------ cpzero.cc

static uint32 read_masks[] = {
    Index_MASK, Random_MASK, EntryLo_MASK, 0, Context_MASK,
    PageMask_MASK, Wired_MASK, Error_MASK, BadVAddr_MASK, Count_MASK,
    EntryHi_MASK, Compare_MASK, Status_MASK, Cause_MASK, EPC_MASK,
    PRId_MASK, Config_MASK, LLAddr_MASK, WatchLo_MASK, WatchHi_MASK,
    0, 0, 0, 0, 0, 0, ECC_MASK, CacheErr_MASK, TagLo_MASK, TagHi_MASK,
    ErrorEPC_MASK, 0
};

static uint32 write_masks[] = {
    Index_MASK, 0, EntryLo_MASK, 0, Context_MASK & ~Context_BadVPN_MASK,
    PageMask_MASK, Wired_MASK, Error_MASK, 0, Count_MASK,
    EntryHi_MASK, Compare_MASK, Status_MASK,
    Cause_MASK & ~Cause_IP_Ext_MASK, 0, 0, Config_MASK, LLAddr_MASK,
    WatchLo_MASK, WatchHi_MASK, 0, 0, 0, 0, 0, 0, ECC_MASK,
    CacheErr_MASK, TagLo_MASK, TagHi_MASK, ErrorEPC_MASK, 0
};

CPZero::CPZero(CPU *m) : cpu (m) { }

/* Reset (warm or cold) */
void
CPZero::reset(void)
{
    int r;
    for (r = 0; r < 16; r++) {
        reg[r] = 0;
    }
    /* Turn off any randomly-set pending-interrupt bits, as these
     * can impact correctness. */
    reg[Cause] &= ~Cause_IP_MASK;
    /* Reset Random register to upper bound (8<=Random<=63) */
    reg[Random] = Random_UPPER_BOUND << 8;
    /* Reset Status register: clear KUc, IEc, SwC (i.e., caches are not
     * switched), TS (TLB shutdown has not occurred), and set
     * BEV (Bootstrap exception vectors ARE in effect).
     */
    reg[Status] = (reg[Status] | Status_DS_BEV_MASK) &
        ~(Status_KUc_MASK | Status_IEc_MASK | Status_DS_SwC_MASK |
          Status_DS_TS_MASK);
    reg[PRId] = 0x00000230; /* MIPS R3000A */
}

/* Yow!! Are we in KERNEL MODE yet?? ...Read the Status register. */
bool
CPZero::kernel_mode(void) const
{
    return !(reg[Status] & Status_KUc_MASK);
}

/* Request for address translation (possibly using the TLB). */
uint32
CPZero::address_trans(uint32 vaddr, int mode, bool *cacheable, bool *cache_isolated)
{
    (*cache_isolated) = caches_isolated();
    
    if (kernel_mode()) {
        switch(vaddr & KSEG_SELECT_MASK) {
        case KSEG0:
            *cacheable = true;
            return vaddr - KSEG0_CONST_TRANSLATION;
        case KSEG1:
            *cacheable = false;
            return vaddr - KSEG1_CONST_TRANSLATION;
        case KSEG2:
        case KSEG2_top:
            return tlb_translate(KSEG2, vaddr, mode, cacheable);
        default: /* KUSEG */
            return tlb_translate(KUSEG, vaddr, mode, cacheable);
        }
    }
    
    /* user mode */
    if (vaddr & KERNEL_SPACE_MASK) {
        /* Can't go there. */
        cpu->exception(mode == DATASTORE ? AdES : AdEL, mode);
        return 0xffffffff;
    } else /* user space address */ {
        return tlb_translate(KUSEG, vaddr, mode, cacheable);
    }
}

void
CPZero::load_addr_trans_excp_info(uint32 va, uint32 vpn, TLBEntry *match)
{
    reg[BadVAddr] = va;
    reg[Context] = (reg[Context] & ~Context_BadVPN_MASK) | ((va & 0x7ffff000) >> 10);
    reg[EntryHi] = (va & EntryHi_VPN_MASK) | (reg[EntryHi] & ~EntryHi_VPN_MASK);
}

int
CPZero::find_matching_tlb_entry(uint32 vpn, uint32 asid)
{
    for (uint16 x = 0; x < TLB_ENTRIES; x++)
        if (tlb[x].vpn() == vpn && (tlb[x].global() || tlb[x].asid() == asid))
            return x;
    return -1;
}

uint32
CPZero::tlb_translate(uint32 seg, uint32 vaddr, int mode, bool *cacheable)
{
    uint32 asid = reg[EntryHi] & EntryHi_ASID_MASK;
    uint32 vpn = vaddr & EntryHi_VPN_MASK;
    int index = find_matching_tlb_entry(vpn, asid);
    TLBEntry *match = (index == -1) ? 0 : &tlb[index];
    tlb_miss_user = false;
    if (match && match->valid()) {
        if (mode == DATASTORE && !match->dirty()) {
            /* TLB Mod exception - write to page not marked "dirty" */
            load_addr_trans_excp_info(vaddr,vpn,match);
            cpu->exception(Mod, DATASTORE);
            return 0xffffffff;
        } else {
            /* We have a matching TLB entry which is valid. */
            *cacheable = !match->noncacheable();
            return match->pfn() | (vaddr & ~EntryHi_VPN_MASK);
        }
    }
    // If we got here, then there was no matching tlb entry, or it wasn't valid.
    // Use special refill handler vector for user TLB miss.
    tlb_miss_user = (seg == KUSEG && !match);
    load_addr_trans_excp_info(vaddr,vpn,match);
    //fprintf(stderr, "TLB: Miss for vaddr=%x (vpn=%x)\n", vaddr, (vaddr>>12));
    cpu->exception(mode == DATASTORE ? TLBS : TLBL, mode);
    return 0xffffffff;
}

uint32 CPZero::read_reg(const uint16 r) {
    // This ensures that non-existent CP0 registers read as zero.
    return reg[r] & read_masks[r];
}

void CPZero::write_reg(const uint16 r, const uint32 data) {
    // This preserves the bits which are readable but not writable, and writes
    // the bits which are writable with new data, thus making it suitable
    // for mtc0-type operations.  If you want to write all the bits which
    // are _connected_, use: reg[r] = new_data & write_masks[r]; .
    reg[r] = (reg[r] & (read_masks[r] & ~write_masks[r]))
             | (data & write_masks[r]);
}

void
CPZero::mfc0_emulate(uint32 instr, uint32 pc)
{
    cpu->put_reg (CPU::rt (instr), read_reg (CPU::rd (instr)));
}

void
CPZero::mtc0_emulate(uint32 instr, uint32 pc)
{
    write_reg (CPU::rd (instr), cpu->get_reg (CPU::rt (instr)));
}

void
CPZero::bc0x_emulate(uint32 instr, uint32 pc)
{
    uint16 condition = CPU::rt (instr);
    switch (condition) {
    case 0: /* bc0f */ if (! cpCond ()) { cpu->branch (instr, pc); } break;
    case 1: /* bc0t */ if (cpCond ()) { cpu->branch (instr, pc); } break;
    case 2: /* bc0fl - not valid, but not reserved(A-17, H&K) - no-op. */ break;
    case 3: /* bc0tl - not valid, but not reserved(A-21, H&K) - no-op. */ break;
    default: cpu->exception (RI); break; /* reserved */
    }
}

void
CPZero::tlbr_emulate(uint32 instr, uint32 pc)
{
    reg[EntryHi] = (tlb[(reg[Index] & Index_Index_MASK) >> 8].entryHi) &
        write_masks[EntryHi];
    reg[EntryLo] = (tlb[(reg[Index] & Index_Index_MASK) >> 8].entryLo) &
        write_masks[EntryLo];
}

void
CPZero::tlb_write(unsigned index)
{
    tlb[index].entryHi = read_reg(EntryHi);
    tlb[index].entryLo = read_reg(EntryLo);
}

void
CPZero::tlbwi_emulate(uint32 instr, uint32 pc)
{
    tlb_write ((reg[Index] & Index_Index_MASK) >> 8);
}

void
CPZero::tlbwr_emulate(uint32 instr, uint32 pc)
{
    tlb_write ((reg[Random] & Random_Random_MASK) >> 8);
    
    adjust_random();
}

void
CPZero::tlbp_emulate(uint32 instr, uint32 pc)
{
    uint32 vpn = reg[EntryHi] & EntryHi_VPN_MASK;
    uint32 asid = reg[EntryHi] & EntryHi_ASID_MASK;
    int idx = find_matching_tlb_entry (vpn, asid);
    if (idx != -1)
      reg[Index] = (idx << 8);
    else
      reg[Index] = (1 << 31);
}

void
CPZero::rfe_emulate(uint32 instr, uint32 pc)
{
    reg[Status] = (reg[Status] & 0xfffffff0) | ((reg[Status] >> 2) & 0x0f);
}

void
CPZero::cpzero_emulate(uint32 instr, uint32 pc)
{
    uint16 rs = CPU::rs (instr);
    if (CPU::rs (instr) > 15) {
        switch (CPU::funct (instr)) {
        case 1: tlbr_emulate (instr, pc); break;
        case 2: tlbwi_emulate (instr, pc); break;
        case 6: tlbwr_emulate (instr, pc); break;
        case 8: tlbp_emulate (instr, pc); break;
        case 16: rfe_emulate (instr, pc); break;
        default: cpu->exception (RI, ANY, 0); break;
        }
    } else {
        switch (rs) {
        case 0: mfc0_emulate (instr, pc); break;
        case 2: cpu->exception (RI, ANY, 0); break; /* cfc0 - reserved */
        case 4: mtc0_emulate (instr, pc); break;
        case 6: cpu->exception (RI, ANY, 0); break; /* ctc0 - reserved */
        case 8: bc0x_emulate (instr,pc); break;
        default: cpu->exception (RI, ANY, 0); break;
        }
    }
}

void
CPZero::adjust_random(void)
{
//ao modified
    int32 r = (int32) (reg[Random] >> 8);
    if(r <= 8) r = 63; else r--;
    reg[Random] = (uint32) (r << 8);
}

uint32
CPZero::getIP(void)
{
    return (reg[Cause] & Cause_IP_SW_MASK) | ao_interrupts();
}

void
CPZero::enter_exception(uint32 pc, uint32 excCode, uint32 ce, bool dly)
{
    /* Save exception PC in EPC. */
    reg[EPC] = pc;
    /* Disable interrupts and enter Kernel mode. */
    reg[Status] = (reg[Status] & ~Status_KU_IE_MASK) |
        ((reg[Status] & Status_KU_IE_MASK) << 2);
    /* Clear Cause register BD, CE, and ExcCode fields. */
    reg[Cause] &= ~(Cause_BD_MASK|Cause_CE_MASK|Cause_ExcCode_MASK);
    /* Set Cause register CE field if this is a Coprocessor
     * Unusable exception. (If we are passed ce=-1 we don't want
     * to toggle bits in Cause.) */
    if (excCode == CpU) {
        reg[Cause] |= ((ce & 0x3) << 28);
    }
    /* Update IP, BD, ExcCode fields of Cause register. */
    reg[Cause] &= ~Cause_IP_MASK;
    reg[Cause] |= getIP () | (dly << 31) | (excCode << 2);
}

bool
CPZero::use_boot_excp_address(void)
{
    return (reg[Status] & Status_DS_BEV_MASK);
}

bool
CPZero::caches_isolated(void)
{
    return (reg[Status] & Status_DS_IsC_MASK);
}

bool
CPZero::caches_swapped(void)
{
    return (reg[Status] & Status_DS_SwC_MASK);
}

bool
CPZero::cop_usable(int coprocno)
{
    switch (coprocno) {
    case 3: return (reg[Status] & Status_CU3_MASK);
    case 2: return (reg[Status] & Status_CU2_MASK);
    case 1: return (reg[Status] & Status_CU1_MASK);
    case 0: return (reg[Status] & Status_CU0_MASK);
    default: fatal_error ("Bad coprocno passed to CPZero::cop_usable()");
    };
}

bool
CPZero::interrupts_enabled(void) const
{
    return (reg[Status] & Status_IEc_MASK);
}

bool
CPZero::interrupt_pending(void)
{
    if (! interrupts_enabled())
        return false;   /* Can't very well argue with IEc == 0... */
    /* Mask IP with the interrupt mask, and return true if nonzero: */
    return ((getIP () & (reg[Status] & Status_IM_MASK)) != 0);
}

//------------------------------------------------------------------------------ cpu.cc

/* certain fixed register numbers which are handy to know */
static const int reg_zero = 0;  /* always zero */
static const int reg_sp = 29;   /* stack pointer */
static const int reg_ra = 31;   /* return address */

/* pointer to CPU method returning void and taking two uint32's */
typedef void (CPU::*emulate_funptr)(uint32, uint32);

CPU::CPU () : last_epc (0), last_prio (0),
             cpzero (new CPZero (this)), delay_state (NORMAL)
{
    reg[reg_zero] = 0;
}

CPU::~CPU() {
}

void CPU::reset () {
    reg[reg_zero] = 0;
    pc = 0xbfc00000;
    cpzero->reset();
}

int
CPU::exception_priority(uint16 excCode, int mode) const
{
    /* See doc/excprio for an explanation of this table. */
    static const struct excPriority prio[] = {
        {1, AdEL, INSTFETCH},
        {2, TLBL, INSTFETCH}, {2, TLBS, INSTFETCH},
        {3, IBE, ANY},
        {4, Ov, ANY}, {4, Tr, ANY}, {4, Sys, ANY},
        {4, Bp, ANY}, {4, RI, ANY}, {4, CpU, ANY},
        {5, AdEL, DATALOAD}, {5, AdES, ANY},
        {6, TLBL, DATALOAD}, {6, TLBS, DATALOAD},
        {6, TLBL, DATASTORE}, {6, TLBS, DATASTORE},
        {7, Mod, ANY},
        {8, DBE, ANY},
        {9, Int, ANY},
        {0, ANY, ANY} /* catch-all */
    };
    const struct excPriority *p;

    for (p = prio; p->priority != 0; p++) {
        if (excCode == p->excCode || p->excCode == ANY) {
            if (mode == p->mode || p->mode == ANY) {
                return p->priority;
            }
        }
    }
    return 0;
}

void
CPU::exception(uint16 excCode, int mode /* = ANY */, int coprocno /* = -1 */)
{
printf("Exception: code: 0x%x, mode: %x, coprocno: %x\n", (uint32)excCode, mode, coprocno);
    int prio;
    uint32 base, vector, epc;
    bool delaying = (delay_state == DELAYSLOT);

    /* step() ensures that next_epc will always contain the correct
     * EPC whenever exception() is called.
     */
    epc = next_epc;

    /* Prioritize exception -- if the last exception to occur _also_ was
     * caused by this EPC, only report this exception if it has a higher
     * priority.  Otherwise, exception handling terminates here,
     * because only one exception will be reported per instruction
     * (as per MIPS RISC Architecture, p. 6-35). Note that this only
     * applies IFF the previous exception was caught during the current
     * _execution_ of the instruction at this EPC, so we check that
     * EXCEPTION_PENDING is true before aborting exception handling.
     * (This flag is reset by each call to step().)
     */
    prio = exception_priority(excCode, mode);
    if (epc == last_epc) {
        if (prio <= last_prio && exception_pending) {
            return;
        } else {
            last_prio = prio;
        }
    }
    last_epc = epc;

    /* Set processor to Kernel mode, disable interrupts, and save 
     * exception PC.
     */
    cpzero->enter_exception(epc,excCode,coprocno,delaying);

    /* Calculate the exception handler address; this is of the form BASE +
     * VECTOR. The BASE is determined by whether we're using boot-time
     * exception vectors, according to the BEV bit in the CP0 Status register.
     */
    if (cpzero->use_boot_excp_address()) {
        base = 0xbfc00100;
    } else {
        base = 0x80000000;
    }

    /* Do we have a User TLB Miss exception? If so, jump to the
     * User TLB Miss exception vector, otherwise jump to the
     * common exception vector.
     */
    if ((excCode == TLBL || excCode == TLBS) && (cpzero->tlb_miss_user)) {
        vector = 0x000;
    } else {
        vector = 0x080;
    }

    pc = base + vector;
    exception_pending = true;
}

/* emulation of instructions */
void
CPU::cpzero_emulate(uint32 instr, uint32 pc)
{
    cpzero->cpzero_emulate(instr, pc);
}

/* Called when the program wants to use coprocessor COPROCNO, and there
 * isn't any implementation for that coprocessor.
 * Results in a Coprocessor Unusable exception, along with an error
 * message being printed if the coprocessor is marked usable in the
 * CP0 Status register.
 */
void
CPU::cop_unimpl (int coprocno, uint32 instr, uint32 pc)
{
    exception (CpU, ANY, coprocno);
}

void
CPU::cpone_emulate(uint32 instr, uint32 pc)
{
    /* If it's a cfc1 <reg>, $0 then we copy 0 into reg,
        * which is supposed to mean there is NO cp1... 
        * for now, though, ANYTHING else asked of cp1 results
        * in the default "unimplemented" behavior. */
    if (cpzero->cop_usable (1) && rs (instr) == 2
                && rd (instr) == 0) {
        reg[rt (instr)] = 0; /* No cp1. */
    } else {
        cop_unimpl (1, instr, pc);
    }
}

void
CPU::cptwo_emulate(uint32 instr, uint32 pc)
{
    cop_unimpl (2, instr, pc);
}

void
CPU::cpthree_emulate(uint32 instr, uint32 pc)
{
    cop_unimpl (3, instr, pc);
}

void
CPU::control_transfer (uint32 new_pc)
{
    delay_state = DELAYING;
    delay_pc = new_pc;
}

/// calc_jump_target - Calculate the address to jump to as a result of
/// the J-format (jump) instruction INSTR at address PC.  (PC is the address
/// of the jump instruction, and INSTR is the jump instruction word.)
///
uint32
CPU::calc_jump_target (uint32 instr, uint32 pc)
{
    // Must use address of delay slot (pc + 4) to calculate.
    return ((pc + 4) & 0xf0000000) | (jumptarg(instr) << 2);
}

void
CPU::jump(uint32 instr, uint32 pc)
{
    control_transfer (calc_jump_target (instr, pc));
}

void
CPU::j_emulate(uint32 instr, uint32 pc)
{
    jump (instr, pc);
}

void
CPU::jal_emulate(uint32 instr, uint32 pc)
{
    jump (instr, pc);
    // RA gets addr of instr after delay slot (2 words after this one).
    reg[reg_ra] = pc + 8;
}

/// calc_branch_target - Calculate the address to jump to for the
/// PC-relative branch for which the offset is specified by the immediate field
/// of the branch instruction word INSTR, with the program counter equal to PC.
/// 
uint32
CPU::calc_branch_target(uint32 instr, uint32 pc)
{
    return (pc + 4) + (s_immed(instr) << 2);
}

void
CPU::branch(uint32 instr, uint32 pc)
{
    control_transfer (calc_branch_target (instr, pc));
}

void
CPU::beq_emulate(uint32 instr, uint32 pc)
{
    if (reg[rs(instr)] == reg[rt(instr)])
        branch (instr, pc);
}

void
CPU::bne_emulate(uint32 instr, uint32 pc)
{
    if (reg[rs(instr)] != reg[rt(instr)])
        branch (instr, pc);
}

void
CPU::blez_emulate(uint32 instr, uint32 pc)
{
    if (rt(instr) != 0) {
        exception(RI);
        return;
    }
    if (reg[rs(instr)] == 0 || (reg[rs(instr)] & 0x80000000))
        branch(instr, pc);
}

void
CPU::bgtz_emulate(uint32 instr, uint32 pc)
{
    if (rt(instr) != 0) {
        exception(RI);
        return;
    }
    if (reg[rs(instr)] != 0 && (reg[rs(instr)] & 0x80000000) == 0)
        branch(instr, pc);
}

void
CPU::addi_emulate(uint32 instr, uint32 pc)
{
    int32 a, b, sum;

    a = (int32)reg[rs(instr)];
    b = s_immed(instr);
    sum = a + b;
    if ((a < 0 && b < 0 && !(sum < 0)) || (a >= 0 && b >= 0 && !(sum >= 0))) {
        exception(Ov);
        return;
    } else {
        reg[rt(instr)] = (uint32)sum;
    }
}

void
CPU::addiu_emulate(uint32 instr, uint32 pc)
{
    int32 a, b, sum;

    a = (int32)reg[rs(instr)];
    b = s_immed(instr);
    sum = a + b;
    reg[rt(instr)] = (uint32)sum;
}

void
CPU::slti_emulate(uint32 instr, uint32 pc)
{
    int32 s_rs = reg[rs(instr)];

    if (s_rs < s_immed(instr)) {
        reg[rt(instr)] = 1;
    } else {
        reg[rt(instr)] = 0;
    }
}

void
CPU::sltiu_emulate(uint32 instr, uint32 pc)
{
    if (reg[rs(instr)] < (uint32)(int32)s_immed(instr)) {
        reg[rt(instr)] = 1;
    } else {
        reg[rt(instr)] = 0;
    }
}

void
CPU::andi_emulate(uint32 instr, uint32 pc)
{
    reg[rt(instr)] = (reg[rs(instr)] & 0x0ffff) & immed(instr);
}

void
CPU::ori_emulate(uint32 instr, uint32 pc)
{
    reg[rt(instr)] = reg[rs(instr)] | immed(instr);
}

void
CPU::xori_emulate(uint32 instr, uint32 pc)
{
    reg[rt(instr)] = reg[rs(instr)] ^ immed(instr);
}

void
CPU::lui_emulate(uint32 instr, uint32 pc)
{
    reg[rt(instr)] = immed(instr) << 16;
}

void
CPU::lb_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, base;
    int8 byte;
    int32 offset;
    bool cacheable, isolated;
    
    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(virt, DATALOAD, &cacheable, &isolated);
    if (exception_pending) return;

    /* Fetch byte.
     * Because it is assigned to a signed variable (int32 byte)
     * it will be sign-extended.
     */
    byte = ao_fetch_byte(phys, cacheable, isolated);
    if (exception_pending) return;

    /* Load target register with data. */
    reg[rt(instr)] = byte;
}

void
CPU::lh_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, base;
    int16 halfword;
    int32 offset;
    bool cacheable, isolated;

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;

    /* This virtual address must be halfword-aligned. */
    if (virt % 2 != 0) {
        exception(AdEL,DATALOAD);
        return;
    }

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(virt, DATALOAD, &cacheable, &isolated);
    if (exception_pending) return;

    /* Fetch halfword.
     * Because it is assigned to a signed variable (int32 halfword)
     * it will be sign-extended.
     */
    halfword = ao_fetch_halfword(phys, cacheable, isolated);
    if (exception_pending) return;

    /* Load target register with data. */
    reg[rt(instr)] = halfword;
}

/* The lwr and lwl algorithms here are taken from SPIM 6.0,
 * since I didn't manage to come up with a better way to write them.
 * Improvements are welcome.
 */
uint32
CPU::lwr(uint32 regval, uint32 memval, uint8 offset)
{
    switch (offset)
    {
        /* The SPIM source claims that "The description of the
            * little-endian case in Kane is totally wrong." The fact
            * that I ripped off the LWR algorithm from them could be
            * viewed as a sort of passive assumption that their claim
            * is correct.
            */
        case 0: /* 3 in book */
            return memval;
        case 1: /* 0 in book */
            return (regval & 0xff000000) | ((memval & 0xffffff00) >> 8);
        case 2: /* 1 in book */
            return (regval & 0xffff0000) | ((memval & 0xffff0000) >> 16);
        case 3: /* 2 in book */
            return (regval & 0xffffff00) | ((memval & 0xff000000) >> 24);
    }
    fatal_error("Invalid offset %x passed to lwr\n", offset);
}

uint32
CPU::lwl(uint32 regval, uint32 memval, uint8 offset)
{
    switch (offset)
    {
        case 0: return (memval & 0xff) << 24 | (regval & 0xffffff);
        case 1: return (memval & 0xffff) << 16 | (regval & 0xffff);
        case 2: return (memval & 0xffffff) << 8 | (regval & 0xff);
        case 3: return memval;
    }
    fatal_error("Invalid offset %x passed to lwl\n", offset);
}

void
CPU::lwl_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, wordvirt, base, memword;
    uint8 which_byte;
    int32 offset;
    bool cacheable, isolated;

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;
    /* We request the word containing the byte-address requested. */
    wordvirt = virt & ~0x03UL;

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(wordvirt, DATALOAD, &cacheable, &isolated);
    if (exception_pending) return;

    /* Fetch word. */
    memword = ao_fetch_word(phys, DATALOAD, cacheable, isolated);
    if (exception_pending) return;
    
    /* Insert bytes into the left side of the register. */
    which_byte = virt & 0x03;
    reg[rt(instr)] = lwl(reg[rt(instr)], memword, which_byte);
}

void
CPU::lw_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, base, word;
    int32 offset;
    bool cacheable, isolated;

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;

    /* This virtual address must be word-aligned. */
    if (virt % 4 != 0) {
        exception(AdEL,DATALOAD);
        return;
    }

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(virt, DATALOAD, &cacheable, &isolated);
    if (exception_pending) return;

    /* Fetch word. */
    word = ao_fetch_word(phys, DATALOAD, cacheable, isolated);
    if (exception_pending) return;

    /* Load target register with data. */
    reg[rt(instr)] = word;
}

void
CPU::lbu_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, base, byte;
    int32 offset;
    bool cacheable, isolated;

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(virt, DATALOAD, &cacheable, &isolated);
    if (exception_pending) return;

    /* Fetch byte.  */
    byte = ao_fetch_byte(phys, cacheable, isolated) & 0x000000ff;
    if (exception_pending) return;

    /* Load target register with data. */
    reg[rt(instr)] = byte;
}

void
CPU::lhu_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, base, halfword;
    int32 offset;
    bool cacheable, isolated;

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;

    /* This virtual address must be halfword-aligned. */
    if (virt % 2 != 0) {
        exception(AdEL,DATALOAD);
        return;
    }

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(virt, DATALOAD, &cacheable, &isolated);
    if (exception_pending) return;

    /* Fetch halfword.  */
    halfword = ao_fetch_halfword(phys, cacheable, isolated) & 0x0000ffff;
    if (exception_pending) return;

    /* Load target register with data. */
    reg[rt(instr)] = halfword;
}

void
CPU::lwr_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, wordvirt, base, memword;
    uint8 which_byte;
    int32 offset;
    bool cacheable, isolated;

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;
    /* We request the word containing the byte-address requested. */
    wordvirt = virt & ~0x03UL;

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(wordvirt, DATALOAD, &cacheable, &isolated);
    if (exception_pending) return;

    /* Fetch word. */
    memword = ao_fetch_word(phys, DATALOAD, cacheable, isolated);
    if (exception_pending) return;
    
    /* Insert bytes into the left side of the register. */
    which_byte = virt & 0x03;
    reg[rt(instr)] = lwr(reg[rt(instr)], memword, which_byte);
}

void
CPU::sb_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, base;
    uint8 data;
    int32 offset;
    bool cacheable, isolated;

    /* Load data from register. */
    data = reg[rt(instr)] & 0x0ff;

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(virt, DATASTORE, &cacheable, &isolated);
    if (exception_pending) return;

    /* Store byte. */
    ao_store_byte(phys, data, cacheable, isolated);
}

void
CPU::sh_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, base;
    uint16 data;
    int32 offset;
    bool cacheable, isolated;

    /* Load data from register. */
    data = reg[rt(instr)] & 0x0ffff;

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;

    /* This virtual address must be halfword-aligned. */
    if (virt % 2 != 0) {
        exception(AdES,DATASTORE);
        return;
    }

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(virt, DATASTORE, &cacheable, &isolated);
    if (exception_pending) return;

    /* Store halfword. */
    ao_store_halfword(phys, data, cacheable, isolated);
}

uint32
CPU::swl(uint32 regval, uint32 memval, uint8 offset)
{
    switch (offset) {
        case 0: return (memval & 0xffffff00) | (regval >> 24 & 0xff); 
        case 1: return (memval & 0xffff0000) | (regval >> 16 & 0xffff); 
        case 2: return (memval & 0xff000000) | (regval >> 8 & 0xffffff); 
        case 3: return regval; 
    }
    fatal_error("Invalid offset %x passed to swl\n", offset);
}

uint32
CPU::swr(uint32 regval, uint32 memval, uint8 offset)
{
    switch (offset) {
        case 0: return regval; 
        case 1: return ((regval << 8) & 0xffffff00) | (memval & 0xff); 
        case 2: return ((regval << 16) & 0xffff0000) | (memval & 0xffff); 
        case 3: return ((regval << 24) & 0xff000000) | (memval & 0xffffff); 
    }
    fatal_error("Invalid offset %x passed to swr\n", offset);
}

void
CPU::swl_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, wordvirt, base, regdata, memdata;
    int32 offset;
    uint8 which_byte;
    bool cacheable, isolated;

    /* Load data from register. */
    regdata = reg[rt(instr)];

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;
    /* We request the word containing the byte-address requested. */
    wordvirt = virt & ~0x03UL;

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(wordvirt, DATASTORE, &cacheable, &isolated);
    if (exception_pending) return;

    /* Read data from memory. */
    //memdata = ao_fetch_word(phys, DATASTORE, cacheable);
    //if (exception_pending) return;

    /* Write back the left side of the register. */
    which_byte = virt & 0x03UL;
    //ao_store_word(phys, swl(regdata, memdata, which_byte), cacheable);
    uint32 store_value =
        (which_byte == 0)?  (regdata >> 24 & 0xff) :
        (which_byte == 1)?  (regdata >> 16 & 0xffff) :
        (which_byte == 2)?  (regdata >> 8 & 0xffffff) :
                            regdata;
    uint32 store_byteena =
        (which_byte == 0)?  0b0001 :
        (which_byte == 1)?  0b0011 :
        (which_byte == 2)?  0b0111 :
                            0b1111;
    ao_store_word(phys, store_value, cacheable, isolated, store_byteena);
}

void
CPU::sw_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, base, data;
    int32 offset;
    bool cacheable, isolated;

    /* Load data from register. */
    data = reg[rt(instr)];

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;

    /* This virtual address must be word-aligned. */
    if (virt % 4 != 0) {
        exception(AdES,DATASTORE);
        return;
    }

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(virt, DATASTORE, &cacheable, &isolated);
    if (exception_pending) return;

    /* Store word. */
    ao_store_word(phys, data, cacheable, isolated);
}

void
CPU::swr_emulate(uint32 instr, uint32 pc)
{
    uint32 phys, virt, wordvirt, base, regdata, memdata;
    int32 offset;
    uint8 which_byte;
    bool cacheable, isolated;

    /* Load data from register. */
    regdata = reg[rt(instr)];

    /* Calculate virtual address. */
    base = reg[rs(instr)];
    offset = s_immed(instr);
    virt = base + offset;
    /* We request the word containing the byte-address requested. */
    wordvirt = virt & ~0x03UL;

    /* Translate virtual address to physical address. */
    phys = cpzero->address_trans(wordvirt, DATASTORE, &cacheable, &isolated);
    if (exception_pending) return;

    /* Read data from memory. */
    //memdata = ao_fetch_word(phys, DATASTORE, cacheable);
    //if (exception_pending) return;

    /* Write back the right side of the register. */
    which_byte = virt & 0x03UL;
    //ao_store_word(phys, swr(regdata, memdata, which_byte), cacheable);
    
    uint32 store_value =
        (which_byte == 0)?  regdata :
        (which_byte == 1)?  ((regdata << 8) & 0xffffff00) :
        (which_byte == 2)?  ((regdata << 16) & 0xffff0000) :
                            ((regdata << 24) & 0xff000000);
    uint32 store_byteena =
        (which_byte == 0)?  0b1111 :
        (which_byte == 1)?  0b1110 :
        (which_byte == 2)?  0b1100 :
                            0b1000;
    ao_store_word(phys, store_value, cacheable, isolated, store_byteena);
}

void
CPU::lwc1_emulate(uint32 instr, uint32 pc)
{
    cop_unimpl (1, instr, pc);
}

void
CPU::lwc2_emulate(uint32 instr, uint32 pc)
{
    cop_unimpl (2, instr, pc);
}

void
CPU::lwc3_emulate(uint32 instr, uint32 pc)
{
    cop_unimpl (3, instr, pc);
}

void
CPU::swc1_emulate(uint32 instr, uint32 pc)
{
    cop_unimpl (1, instr, pc);
}

void
CPU::swc2_emulate(uint32 instr, uint32 pc)
{
    cop_unimpl (2, instr, pc);
}

void
CPU::swc3_emulate(uint32 instr, uint32 pc)
{
    cop_unimpl (3, instr, pc);
}

void
CPU::sll_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = reg[rt(instr)] << shamt(instr);
}

int32
srl(int32 a, int32 b)
{
    if (b == 0) {
        return a;
    } else if (b == 32) {
        return 0;
    } else {
        return (a >> b) & ((1 << (32 - b)) - 1);
    }
}

int32
sra(int32 a, int32 b)
{
    if (b == 0) {
        return a;
    } else {
        return (a >> b) | (((a >> 31) & 0x01) * (((1 << b) - 1) << (32 - b)));
    }
}

void
CPU::srl_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = srl(reg[rt(instr)], shamt(instr));
}

void
CPU::sra_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = sra(reg[rt(instr)], shamt(instr));
}

void
CPU::sllv_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = reg[rt(instr)] << (reg[rs(instr)] & 0x01f);
}

void
CPU::srlv_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = srl(reg[rt(instr)], reg[rs(instr)] & 0x01f);
}

void
CPU::srav_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = sra(reg[rt(instr)], reg[rs(instr)] & 0x01f);
}

void
CPU::jr_emulate(uint32 instr, uint32 pc)
{
    if (reg[rd(instr)] != 0) {
        exception(RI);
        return;
    }
    control_transfer (reg[rs(instr)]);
}

void
CPU::jalr_emulate(uint32 instr, uint32 pc)
{
    control_transfer (reg[rs(instr)]);
    /* RA gets addr of instr after delay slot (2 words after this one). */
    reg[rd(instr)] = pc + 8;
}

void
CPU::syscall_emulate(uint32 instr, uint32 pc)
{
    exception(Sys);
}

void
CPU::break_emulate(uint32 instr, uint32 pc)
{
    exception(Bp);
}

void
CPU::mfhi_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = hi;
}

void
CPU::mthi_emulate(uint32 instr, uint32 pc)
{
    if (rd(instr) != 0) {
        exception(RI);
        return;
    }
    hi = reg[rs(instr)];
}

void
CPU::mflo_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = lo;
}

void
CPU::mtlo_emulate(uint32 instr, uint32 pc)
{
    if (rd(instr) != 0) {
        exception(RI);
        return;
    }
    lo = reg[rs(instr)];
}

void
CPU::mult_emulate(uint32 instr, uint32 pc)
{
    if (rd(instr) != 0) {
        exception(RI);
        return;
    }
    mult64s(&hi, &lo, reg[rs(instr)], reg[rt(instr)]);
}

void
CPU::mult64(uint32 *hi, uint32 *lo, uint32 n, uint32 m)
{
    uint64 result;
    result = ((uint64)n) * ((uint64)m);
    *hi = (uint32) (result >> 32);
    *lo = (uint32) result;
}

void
CPU::mult64s(uint32 *hi, uint32 *lo, int32 n, int32 m)
{
    int64 result;
    result = ((int64)n) * ((int64)m);
    *hi = (uint32) (result >> 32);
    *lo = (uint32) result;
}

void
CPU::multu_emulate(uint32 instr, uint32 pc)
{
    if (rd(instr) != 0) {
        exception(RI);
        return;
    }
    mult64(&hi, &lo, reg[rs(instr)], reg[rt(instr)]);
}

void
CPU::div_emulate(uint32 instr, uint32 pc)
{
    int32 signed_rs = (int32)reg[rs(instr)];
    int32 signed_rt = (int32)reg[rt(instr)];
    
    if(signed_rt == 0) {
        lo = (signed_rs >= 0)? 0xFFFFFFFF : 0x00000001;
        hi = signed_rs;
    }
    else {
        lo = signed_rs / signed_rt;
        hi = signed_rs % signed_rt;
    }
}

void
CPU::divu_emulate(uint32 instr, uint32 pc)
{
    if(reg[rt(instr)] == 0) {
        lo = 0xFFFFFFFF;
        hi = reg[rs(instr)];
    }
    else {
        lo = reg[rs(instr)] / reg[rt(instr)];
        hi = reg[rs(instr)] % reg[rt(instr)];
    }
}

void
CPU::add_emulate(uint32 instr, uint32 pc)
{
    int32 a, b, sum;
    a = (int32)reg[rs(instr)];
    b = (int32)reg[rt(instr)];
    sum = a + b;
    if ((a < 0 && b < 0 && !(sum < 0)) || (a >= 0 && b >= 0 && !(sum >= 0))) {
        exception(Ov);
        return;
    } else {
        reg[rd(instr)] = (uint32)sum;
    }
}

void
CPU::addu_emulate(uint32 instr, uint32 pc)
{
    int32 a, b, sum;
    a = (int32)reg[rs(instr)];
    b = (int32)reg[rt(instr)];
    sum = a + b;
    reg[rd(instr)] = (uint32)sum;
}

void
CPU::sub_emulate(uint32 instr, uint32 pc)
{
    int32 a, b, diff;
    a = (int32)reg[rs(instr)];
    b = (int32)reg[rt(instr)];
    diff = a - b;
    if ((a < 0 && !(b < 0) && !(diff < 0)) || (!(a < 0) && b < 0 && diff < 0)) {
        exception(Ov);
        return;
    } else {
        reg[rd(instr)] = (uint32)diff;
    }
}

void
CPU::subu_emulate(uint32 instr, uint32 pc)
{
    int32 a, b, diff;
    a = (int32)reg[rs(instr)];
    b = (int32)reg[rt(instr)];
    diff = a - b;
    reg[rd(instr)] = (uint32)diff;
}

void
CPU::and_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = reg[rs(instr)] & reg[rt(instr)];
}

void
CPU::or_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = reg[rs(instr)] | reg[rt(instr)];
}

void
CPU::xor_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = reg[rs(instr)] ^ reg[rt(instr)];
}

void
CPU::nor_emulate(uint32 instr, uint32 pc)
{
    reg[rd(instr)] = ~(reg[rs(instr)] | reg[rt(instr)]);
}

void
CPU::slt_emulate(uint32 instr, uint32 pc)
{
    int32 s_rs = (int32)reg[rs(instr)];
    int32 s_rt = (int32)reg[rt(instr)];
    if (s_rs < s_rt) {
        reg[rd(instr)] = 1;
    } else {
        reg[rd(instr)] = 0;
    }
}

void
CPU::sltu_emulate(uint32 instr, uint32 pc)
{
    if (reg[rs(instr)] < reg[rt(instr)]) {
        reg[rd(instr)] = 1;
    } else {
        reg[rd(instr)] = 0;
    }
}

void
CPU::bltz_emulate(uint32 instr, uint32 pc)
{
    if ((int32)reg[rs(instr)] < 0)
        branch(instr, pc);
}

void
CPU::bgez_emulate(uint32 instr, uint32 pc)
{
    if ((int32)reg[rs(instr)] >= 0)
        branch(instr, pc);
}

/* As with JAL, BLTZAL and BGEZAL cause RA to get the address of the
 * instruction two words after the current one (pc + 8).
 */
void
CPU::bltzal_emulate(uint32 instr, uint32 pc)
{
    reg[reg_ra] = pc + 8;
    if ((int32)reg[rs(instr)] < 0)
        branch(instr, pc);
}

void
CPU::bgezal_emulate(uint32 instr, uint32 pc)
{
    reg[reg_ra] = pc + 8;
    if ((int32)reg[rs(instr)] >= 0)
        branch(instr, pc);
}

/* reserved instruction */
void
CPU::RI_emulate(uint32 instr, uint32 pc)
{
    exception(RI);
}

/* dispatching */
int
CPU::step(bool debug)
{
    // Table of emulation functions.
    static const emulate_funptr opcodeJumpTable[] = {
        &CPU::funct_emulate, &CPU::regimm_emulate,  &CPU::j_emulate,
        &CPU::jal_emulate,   &CPU::beq_emulate,     &CPU::bne_emulate,
        &CPU::blez_emulate,  &CPU::bgtz_emulate,    &CPU::addi_emulate,
        &CPU::addiu_emulate, &CPU::slti_emulate,    &CPU::sltiu_emulate,
        &CPU::andi_emulate,  &CPU::ori_emulate,     &CPU::xori_emulate,
        &CPU::lui_emulate,   &CPU::cpzero_emulate,  &CPU::cpone_emulate,
        &CPU::cptwo_emulate, &CPU::cpthree_emulate, &CPU::RI_emulate,
        &CPU::RI_emulate,    &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,    &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,    &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,    &CPU::RI_emulate,      &CPU::lb_emulate,
        &CPU::lh_emulate,    &CPU::lwl_emulate,     &CPU::lw_emulate,
        &CPU::lbu_emulate,   &CPU::lhu_emulate,     &CPU::lwr_emulate,
        &CPU::RI_emulate,    &CPU::sb_emulate,      &CPU::sh_emulate,
        &CPU::swl_emulate,   &CPU::sw_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,    &CPU::swr_emulate,     &CPU::RI_emulate,
        &CPU::RI_emulate,    &CPU::lwc1_emulate,    &CPU::lwc2_emulate,
        &CPU::lwc3_emulate,  &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,    &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::swc1_emulate,  &CPU::swc2_emulate,    &CPU::swc3_emulate,
        &CPU::RI_emulate,    &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate
    };

    // Clear exception_pending flag if it was set by a prior instruction.
    exception_pending = false;

    // Decrement Random register every clock cycle.
    //changed only after tlbwr
    //cpzero->adjust_random();

    // Save address of instruction responsible for exceptions which may occur.
    if (delay_state != DELAYSLOT)
        next_epc = pc;
    
    bool cacheable, isolated;
    uint32 real_pc;
    
    //AdE
    if (pc % 4 != 0) {
        exception(AdEL,INSTFETCH);
        goto out;
    }
    
    // Get physical address of next instruction.
    real_pc = cpzero->address_trans(pc,INSTFETCH,&cacheable,&isolated);
    if (exception_pending) {
        goto out;
    }

    // Fetch next instruction.
    instr = ao_fetch_word(real_pc,INSTFETCH,cacheable,isolated);
    if (exception_pending) {
        goto out;
    }

    //interrupt check moved below

    // Emulate the instruction by jumping to the appropriate emulation method.

static uint32 instr_cnt = 0;
if(debug) {
    printf("[%d] table: %d instr: %08x pc: %08x\n", instr_cnt, opcode(instr), instr, pc);
    for(int i=1; i<32; i++) printf("%08x ", reg[i]); printf("\n");
}
instr_cnt++;

    (this->*opcodeJumpTable[opcode(instr)])(instr, pc);

out:
    // Force register zero to contain zero.
    reg[reg_zero] = 0;

    // If an exception is pending, then the PC has already been changed to
    // contain the exception vector.  Return now, so that we don't clobber it.
    if (exception_pending) {
        // Instruction at beginning of exception handler is NOT in delay slot,
        // no matter what the last instruction was.
        delay_state = NORMAL;
        return 1;
    }

    // Recall the delay_state values: 0=NORMAL, 1=DELAYING, 2=DELAYSLOT.
    // This is what the delay_state values mean (at this point in the code):
    // DELAYING: The last instruction caused a branch to be taken.
    //  The next instruction is in the delay slot.
    //  The next instruction EPC will be PC - 4.
    // DELAYSLOT: The last instruction was executed in a delay slot.
    //  The next instruction is on the other end of the branch.
    //  The next instruction EPC will be PC.
    // NORMAL: No branch was executed; next instruction is at PC + 4.
    //  Next instruction EPC is PC.

    // Update the pc and delay_state values.
    pc += 4;
    was_delayed_transfer = false;
    if (delay_state == DELAYSLOT) {
        was_delayed_transfer = true;
        was_delayed_pc = pc;
        
        pc = delay_pc;
    }
    delay_state = (delay_state << 1) & 0x03; // 0->0, 1->2, 2->0
    
    // Check for a (hardware or software) interrupt.
    if (cpzero->interrupt_pending()) {
        if(delay_state != DELAYSLOT) next_epc = pc;
        
        exception(Int);
        delay_state = NORMAL;
        return 2;
    }
    
    return 0;
}

void
CPU::funct_emulate(uint32 instr, uint32 pc)
{
    static const emulate_funptr functJumpTable[] = {
        &CPU::sll_emulate,     &CPU::RI_emulate,
        &CPU::srl_emulate,     &CPU::sra_emulate,
        &CPU::sllv_emulate,    &CPU::RI_emulate,
        &CPU::srlv_emulate,    &CPU::srav_emulate,
        &CPU::jr_emulate,      &CPU::jalr_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::syscall_emulate, &CPU::break_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::mfhi_emulate,    &CPU::mthi_emulate,
        &CPU::mflo_emulate,    &CPU::mtlo_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::mult_emulate,    &CPU::multu_emulate,
        &CPU::div_emulate,     &CPU::divu_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::add_emulate,     &CPU::addu_emulate,
        &CPU::sub_emulate,     &CPU::subu_emulate,
        &CPU::and_emulate,     &CPU::or_emulate,
        &CPU::xor_emulate,     &CPU::nor_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::slt_emulate,     &CPU::sltu_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate,
        &CPU::RI_emulate,      &CPU::RI_emulate
    };
    (this->*functJumpTable[funct(instr)])(instr, pc);
}

void
CPU::regimm_emulate(uint32 instr, uint32 pc)
{
    switch(rt(instr))
    {
        case 0: bltz_emulate(instr, pc); break;
        case 1: bgez_emulate(instr, pc); break;
        case 16: bltzal_emulate(instr, pc); break;
        case 17: bgezal_emulate(instr, pc); break;
        default: exception(RI); break; /* reserved instruction */
    }
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
