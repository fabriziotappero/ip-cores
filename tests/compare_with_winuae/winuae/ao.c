/* 
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "ao.h"
#include "readcpu.h"

/* changes in WinUAE sources:
 * BCHG,BSET,BCLR,BTST: changes in table68k
 * RTD/illegal command: changes in table68k
 */

uae_u32 get_wordi(uaecptr addr);
uae_u8 *get_real_address(uaecptr addr);
uae_u32 get_long(uaecptr addr);
uae_u32 get_word(uaecptr addr);
uae_u32 get_byte(uaecptr addr);
void put_byte(uaecptr addr, uae_u32 b);
void put_word(uaecptr addr, uae_u32 w);
void put_long(uaecptr addr, uae_u32 l);

void exception3 (uae_u32 opcode, uaecptr addr, uaecptr fault);
void exception3i (uae_u32 opcode, uaecptr addr, uaecptr fault);
void exception3write(uae_u32 opcode, uaecptr addr, uaecptr fault);
void REGPARAM2 MakeSR (void);


struct regstruct regs;

const int areg_byteinc[] = { 1, 1, 1, 1, 1, 1, 1, 2 };
const int imm8_table[] = { 8, 1, 2, 3, 4, 5, 6, 7 };

int movem_index1[256];
int movem_index2[256];
int movem_next[256];

struct flag_struct regflags;


//newcpu.h start
uaecptr m68k_getpc (void)
{
	return (uaecptr)(regs.pc + ((uae_u8*)regs.pc_p - (uae_u8*)regs.pc_oldp));
}
void m68k_setpc(uaecptr newpc)
{
	regs.pc_p = regs.pc_oldp = get_real_address (newpc);
	//AOregs.fault_pc = regs.pc = newpc;
	regs.pc = newpc;
}

void m68k_do_bsr (uaecptr oldpc, uae_s32 offset, uae_u32 opcode)
{
	//AO extra
	uaecptr spa = m68k_areg (regs, 7) - 4;
	if (spa & 1) {
		exception3write(opcode, m68k_getpc () + offset, spa);
		return;
	}
	//AO extra end
	
	m68k_areg (regs, 7) -= 4;
	put_long (m68k_areg (regs, 7), oldpc);
	m68k_incpc (offset);
}
void m68k_do_rts (void)
{
	//AO extra
	uaecptr pca = m68k_areg (regs, 7);
	if (pca & 1) {
		exception3 (0x4e75, m68k_getpc () + 2, pca);
		return;
	}
	uae_s32 pc = get_long (pca);
	m68k_areg (regs, 7) += 4;
	if (pc & 1)
		exception3i(0x4e75, m68k_getpc () + 2, pc);
	else
	m68k_setpc (pc);
	
	//m68k_setpc (get_long (m68k_areg (regs, 7)));
	//m68k_areg (regs, 7) += 4;
}
//newcpu.h end

//cpu_prefetch.c - start
uae_u32 get_word_prefetch (int o)
{
	uae_u32 v = regs.irc;
	regs.irc = get_wordi (m68k_getpc () + o);
	return v;
}
uae_u32 get_long_prefetch (int o)
{
	uae_u32 v = get_word_prefetch (o) << 16;
	v |= get_word_prefetch (o + 2);
	return v;
}
//cpu_prefetch.c - end

void cpureset(void)
{
}

void uae_reset(int hardreset) {
	printf("processor blocked: yes\n");
}

void m68k_setstopped(void)
{
	regs.stopped = 1;
	/* A traced STOP instruction drops through immediately without
	actually stopping.  */
}

//------------------------------------------------------------------- newcpu.c start

/* Opcode of faulting instruction */
static uae_u16 last_op_for_exception_3;
/* PC at fault time */
static uaecptr last_addr_for_exception_3;
/* Address that generated the exception */
static uaecptr last_fault_for_exception_3;
/* read (0) or write (1) access */
static int last_writeaccess_for_exception_3;
/* instruction (1) or data (0) access */
static int last_instructionaccess_for_exception_3;
/* instruction (0) or not instruction (1) */
static int last_wasgroup0or1_for_exception_3;

cpuop_func *cpufunctbl[65536];

/* 68000 slow but compatible.  */
extern const struct cputbl op_smalltbl_11_ff[];

void Exception (int nr, uaecptr oldpc);

unsigned long REGPARAM2 op_illg (uae_u32 opcode)
{	
	if ((opcode & 0xF000) == 0xF000) {
		Exception (0xB, 0);
		return 4;
	}
	if ((opcode & 0xF000) == 0xA000) {
		Exception (0xA, 0);
		return 4;
	}

	Exception (4, 0);
	return 4;
}

void fill_prefetch_slow (void)
{
	regs.ir = get_word (m68k_getpc ());
	regs.irc = get_word (m68k_getpc () + 2);
}

// exception start

//was Exception_normal(int nr, uaecptr oldpc)
void Exception(int nr, uaecptr oldpc)
{
	// illegal, line 1111, line 1010, privilege, trace
	// left: interrupt
	if(nr == 4 || nr == 0xA || nr == 0xB || nr == 8 || nr == 9) {
		last_wasgroup0or1_for_exception_3 = 1;
	}

	uae_u32 currpc = m68k_getpc (), newpc;
	int sv = regs.s;

	if (nr >= 24 && nr < 24 + 8)
		nr = get_byte(0x00fffff1 | (nr << 1));

	MakeSR();

	if (!regs.s) {
		regs.usp = m68k_areg (regs, 7);
		m68k_areg (regs, 7) = regs.isp;
		regs.s = 1;
	}
	//AO extra
	regs.t1 = 0;
		
	//AO extra
	if (m68k_areg(regs, 7) & 1) {
		if (nr == 2 || nr == 3)
	    	m68k_setpc(last_addr_for_exception_3);
		uae_reset(1); /* there  is nothing else we can do.. */
		return;
	}
    if (nr == 2 || nr == 3) {
		uae_u16 mode = (sv ? 4 : 0) | (last_instructionaccess_for_exception_3 ? 2 : 1);
		mode |= last_writeaccess_for_exception_3 ? 0 : 16;
		//AO extra
		mode |= last_wasgroup0or1_for_exception_3 ? 8 : 0;
		m68k_areg (regs, 7) -= 14;
		
		put_word (m68k_areg (regs, 7) + 0, mode);
		put_long (m68k_areg (regs, 7) + 2, last_fault_for_exception_3);
		put_word (m68k_areg (regs, 7) + 6, last_op_for_exception_3);
		put_word (m68k_areg (regs, 7) + 8, regs.sr);
		put_long (m68k_areg (regs, 7) + 10, last_addr_for_exception_3);
		
		last_wasgroup0or1_for_exception_3 = 1;
		goto kludge_me_do;
	}
	m68k_areg (regs, 7) -= 4;
	put_long (m68k_areg (regs, 7), currpc);
	m68k_areg (regs, 7) -= 2;
	put_word (m68k_areg (regs, 7), regs.sr);

kludge_me_do:
	newpc = get_long (regs.vbr + 4 * nr);
	if (newpc & 1) {
		if (nr == 2 || nr == 3) {
			//AO extra
			m68k_setpc(last_addr_for_exception_3);
			uae_reset (1); /* there is nothing else we can do.. */
		}
		else
			exception3i(regs.ir, m68k_getpc (), newpc);
		return;
	}
	m68k_setpc (newpc);
	fill_prefetch_slow ();
	
	last_wasgroup0or1_for_exception_3 = 0;
	//AOexception_trace (nr);
}

// exception end


//exception3 start

static void exception3f(uae_u32 opcode, uaecptr addr, uaecptr fault, int writeaccess, int instructionaccess)
{
	last_addr_for_exception_3 = addr;
	last_fault_for_exception_3 = fault;
	last_op_for_exception_3 = opcode;
	last_writeaccess_for_exception_3 = writeaccess;
	last_instructionaccess_for_exception_3 = instructionaccess;
	Exception(3, fault);
}

void exception3 (uae_u32 opcode, uaecptr addr, uaecptr fault)
{
	exception3f(opcode, addr, fault, 0, 0);
}
void exception3i (uae_u32 opcode, uaecptr addr, uaecptr fault)
{
	exception3f(opcode, addr, fault, 0, 1);
}
void exception3write(uae_u32 opcode, uaecptr addr, uaecptr fault)
{
	exception3f(opcode, addr, fault, 1, 0);
}
//exception3 end

void REGPARAM2 MakeSR (void)
{
	regs.sr = ((regs.t1 << 15) | (regs.t0 << 14)
		| (regs.s << 13) | (regs.m << 12) | (regs.intmask << 8)
		| (GET_XFLG () << 4) | (GET_NFLG () << 3)
		| (GET_ZFLG () << 2) | (GET_VFLG () << 1)
		|  GET_CFLG ());
}

void REGPARAM2 MakeFromSR (void)
{
	int oldm = regs.m;
	int olds = regs.s;

	SET_XFLG ((regs.sr >> 4) & 1);
	SET_NFLG ((regs.sr >> 3) & 1);
	SET_ZFLG ((regs.sr >> 2) & 1);
	SET_VFLG ((regs.sr >> 1) & 1);
	SET_CFLG (regs.sr & 1);
	if (regs.t1 == ((regs.sr >> 15) & 1) &&
		regs.t0 == ((regs.sr >> 14) & 1) &&
		regs.s  == ((regs.sr >> 13) & 1) &&
		regs.m  == ((regs.sr >> 12) & 1) &&
		regs.intmask == ((regs.sr >> 8) & 7))
		return;
	regs.t1 = (regs.sr >> 15) & 1;
	regs.t0 = (regs.sr >> 14) & 1;
	regs.s  = (regs.sr >> 13) & 1;
	regs.m  = (regs.sr >> 12) & 1;
	regs.intmask = (regs.sr >> 8) & 7;
	
	//code fragment for: currprefs.cpu_model < 68020
	regs.t0 = regs.m = 0;
	if (olds != regs.s) {
		if (olds) {
			regs.isp = m68k_areg (regs, 7);
			m68k_areg (regs, 7) = regs.usp;
		} else {
			regs.usp = m68k_areg (regs, 7);
			m68k_areg (regs, 7) = regs.isp;
		}
	}
	
	// doint()
	
	// if(regs.t1 || regs.t0)
	//    set_special (SPCFLAG_TRACE);
	// else
		/* Keep SPCFLAG_DOTRACE, we still want a trace exception for
		   SR-modifying instructions (including STOP).  */
	//    unset_special (SPCFLAG_TRACE);
}

uae_u32 REGPARAM3 get_disp_ea_000 (uae_u32 base, uae_u32 dp) REGPARAM
{
	int reg = (dp >> 12) & 15;
	uae_s32 regd = regs.regs[reg];

	if ((dp & 0x800) == 0)
		regd = (uae_s32)(uae_s16)regd;
	return base + (uae_s8)dp + regd;
}

//------------------------------------------------------------------- newcpu.c end

//------------------------------------------------------------------- test start

char **global_argv;
int global_argc;

unsigned int get_arg(const char *name) {
	int i;
	char buf[64];

	for(i=1; i<global_argc; i++) {
		unsigned int ret = snprintf(buf, sizeof(buf), "+%s=%%08x", name);
		if(ret != (strlen(name) + 6)) {
			printf("Internal error while reading argument: %s\n", name);
			exit(-1);
		}

		unsigned int result;
		ret = sscanf(global_argv[i], buf, &result);
		if(ret != 1) continue;
		else return result;
	}
	printf("Error reading argument: %s\n", name);
	exit(-2);
}


void load_state() {
	m68k_dreg(regs, 0) = get_arg("D0");
	m68k_dreg(regs, 1) = get_arg("D1");
	m68k_dreg(regs, 2) = get_arg("D2");
	m68k_dreg(regs, 3) = get_arg("D3");
	m68k_dreg(regs, 4) = get_arg("D4");
	m68k_dreg(regs, 5) = get_arg("D5");
	m68k_dreg(regs, 6) = get_arg("D6");
	m68k_dreg(regs, 7) = get_arg("D7");

	m68k_setpc(get_arg("PC"));

	SET_CFLG(get_arg("C"));
	SET_VFLG(get_arg("V"));
	SET_ZFLG(get_arg("Z"));
	SET_NFLG(get_arg("N"));
	SET_XFLG(get_arg("X"));

	regs.intmask = get_arg("IPM");
	regs.s = get_arg("S");
	regs.t1 = get_arg("T");
	regs.m = 0;

	m68k_areg(regs, 0) = get_arg("A0");
	m68k_areg(regs, 1) = get_arg("A1");
	m68k_areg(regs, 2) = get_arg("A2");
	m68k_areg(regs, 3) = get_arg("A3");
	m68k_areg(regs, 4) = get_arg("A4");
	m68k_areg(regs, 5) = get_arg("A5");
	m68k_areg(regs, 6) = get_arg("A6");
	regs.usp = get_arg("USP");
	regs.isp = get_arg("SSP");
	if(regs.s == 0) m68k_areg(regs, 7) = regs.usp;
	else m68k_areg(regs, 7) = regs.isp;
}

void save_state() {
	printf("A0: %08x\n", m68k_areg(regs, 0));
	printf("A1: %08x\n", m68k_areg(regs, 1));
	printf("A2: %08x\n", m68k_areg(regs, 2));
	printf("A3: %08x\n", m68k_areg(regs, 3));
	printf("A4: %08x\n", m68k_areg(regs, 4));
	printf("A5: %08x\n", m68k_areg(regs, 5));
	printf("A6: %08x\n", m68k_areg(regs, 6));
	printf("SSP: %08x\n", (regs.s == 1)? m68k_areg(regs, 7) : regs.isp);
	printf("USP: %08x\n", (regs.s == 0)? m68k_areg(regs, 7) : regs.usp);

	printf("D0: %08x\n", m68k_dreg(regs, 0));
	printf("D1: %08x\n", m68k_dreg(regs, 1));
	printf("D2: %08x\n", m68k_dreg(regs, 2));
	printf("D3: %08x\n", m68k_dreg(regs, 3));
	printf("D4: %08x\n", m68k_dreg(regs, 4));
	printf("D5: %08x\n", m68k_dreg(regs, 5));
	printf("D6: %08x\n", m68k_dreg(regs, 6));
	printf("D7: %08x\n", m68k_dreg(regs, 7));

	printf("PC: %08x\n", m68k_getpc());

	printf("C: %d\n", GET_CFLG());
	printf("V: %d\n", GET_VFLG());
	printf("Z: %d\n", GET_ZFLG());
	printf("N: %d\n", GET_NFLG());
	printf("X: %d\n", GET_XFLG());
	printf("IPM: %d\n", regs.intmask);
	printf("S: %d\n", regs.s);
	printf("T: %d\n", regs.t1);
}

int get_mem_arg(uae_u32 *vals, int vals_count, uaecptr addr) {
	if((vals_count != 1 && vals_count != 2) || vals == NULL) {
		printf("Illegal get_mem_arg arguments: %p, %d\n", vals, vals_count);
		exit(-1);
	}
	char buf[1+3+8+1 +1];
	if(snprintf(buf, sizeof(buf), "+MEM%08x=", addr>>2) != sizeof(buf)-1) {
		printf("Internal error while preparing +MEM argument: %08x (%08x)\n", addr>>2, addr);
		exit(-2);
	}
	uae_u32 temp = 0;
	int i;
	for(i=0; i<global_argc; i++) {
		if(strncmp(global_argv[i], buf, sizeof(buf)-1) == 0) {
			if(sscanf(global_argv[i], "+MEM%08x=%x", &temp, &(vals[0])) != 2) {
				printf("Error parsing argument: %s\n", global_argv[i]);
				exit(-3);
			}
			else break;
		}
	}
	if(i==global_argc) {
		printf("Missing argument: MEM%08x\n", addr>>2);
		exit(-4);
	}
	if(vals_count == 1) return 1;

	if(snprintf(buf, sizeof(buf), "+MEM%08x=", (addr>>2)+1) != sizeof(buf)-1) {
		printf("Internal error while preparing +MEM argument: %08x (%08x)\n", (addr>>2)+1, addr+4);
		exit(-5);
	}

	for(i=0; i<global_argc; i++) {
		if(strncmp(global_argv[i], buf, sizeof(buf)-1) == 0) {
			if(sscanf(global_argv[i], "+MEM%08x=%x", &temp, &(vals[1])) != 2) {
				printf("Error parsing argument: %s\n", global_argv[i]);
				exit(-6);
			}
			else break;
		}
	}
	if(i==global_argc) return 1;
	return 2;
}

//memory.h start

uae_u8 *get_real_address(uaecptr addr)
{   
    return (uae_u8 *)addr;
}
uae_u32 get_long(uaecptr ptr)
{
	printf("memory read: address=%08x, select=%x\n", ptr>>2, 0xf);

	uae_u32 vals[2];
	int res = get_mem_arg(vals, 2, ptr);

	if( (ptr % 4) > 0 && (res == 1) ) {
		printf("Missing argument: MEM%08x\n", (ptr>>2)+1);
		exit(-1);
	}
	else if((ptr % 4) == 0) return vals[0];
	else if((ptr % 4) == 2) return (vals[0] << 16) | (vals[1] >> 16);
	else if((ptr % 2) == 1) {
	  printf("memory read on odd address: long, ptr=%p\n", ptr);
	  exit(-1);
	  //return (vals[0] << 8) | (vals[1] >> 24);
	  //return 0;
	}
}
uae_u32 get_word(uaecptr ptr)
{
	printf("memory read: address=%08x, select=%x\n", ptr>>2, 0xf);

	uae_u32 vals[2];
	int res = get_mem_arg(vals, 2, ptr);

	if( (ptr % 4) == 3 && (res == 1) ) {
		printf("Missing argument: MEM%08x\n", (ptr>>2)+1);
		exit(-1);
	}
	else if((ptr % 4) == 0) return (vals[0] >> 16) & 0xFFFF;
	else if((ptr % 4) == 2) return (vals[0]) & 0xFFFF;
	else if((ptr % 2) == 1) {
	  printf("memory read on odd address: word, ptr=%p\n", ptr);
	  exit(-1);
	  //return (vals[0] >> 8) & 0xFFFF;
	  //return 0;
	}
	
}
uae_u32 get_byte(uaecptr ptr)
{
	printf("memory read: address=%08x, select=%x\n", ptr>>2, 0xf);
	uae_u32 vals[1];
	get_mem_arg(vals, 1, ptr);

	if((ptr % 4) == 0) return (vals[0] >> 24) & 0xFF;
	else if((ptr % 4) == 1) return (vals[0] >> 16) & 0xFF;
	else if((ptr % 4) == 2) return (vals[0] >> 8) & 0xFF;
	else if((ptr % 4) == 3) return (vals[0]) & 0xFF;
}

void put_byte(uaecptr ptr, uae_u32 val)
{
	if((ptr % 4) == 0) {
		printf("memory write address=%08x, select=%x: value=%08x\n", ptr>>2, 0x8, val<<24);
	}
	else if((ptr % 4) == 1) {
		printf("memory write address=%08x, select=%x: value=%08x\n", ptr>>2, 0x4, (val<<16) & 0x00FF0000);
	}
	else if((ptr % 4) == 2) {
		printf("memory write address=%08x, select=%x: value=%08x\n", ptr>>2, 0x2, (val<<8) & 0x0000FF00);
	}
	else if((ptr % 4) == 3) {
		printf("memory write address=%08x, select=%x: value=%08x\n", ptr>>2, 0x1, val & 0xFF);
	}
}
void put_word(uaecptr ptr, uae_u32 val)
{
	if((ptr % 4) == 0) {
		printf("memory write address=%08x, select=%x: value=%08x\n", ptr>>2, 0xc, val<<16);
	}
	else if((ptr % 4) == 2) {
		printf("memory write address=%08x, select=%x: value=%08x\n", ptr>>2, 0x3, val & 0xFFFF);
	}
	else if((ptr % 2) == 1) {
		printf("memory write on odd address: word, ptr=%p, val=%x\n", ptr,val);
		exit(-1);
		//return;
	}
}
void put_long(uaecptr ptr, uae_u32 val)
{
	if((ptr % 4) == 0) {
		printf("memory write address=%08x, select=%x: value=%08x\n", ptr>>2, 0xf, val);
	}
	else if((ptr % 4) == 2) {
		printf("memory write address=%08x, select=%x: value=%08x\n", ptr>>2, 0x3, val>>16);
		printf("memory write address=%08x, select=%x: value=%08x\n", (ptr>>2)+1, 0xc, val<<16);
	}
	else if((ptr % 2) == 1) {
		printf("memory write on odd address: long, ptr=%p, val=%x\n", ptr,val);
		exit(-1);
		//return;
	}
}
uae_u32 get_wordi(uaecptr addr)
{
	return get_word(addr);
}
//memory.h end

//------------------------------------------------------------------- test end

static void build_cpufunctbl(void)
{
	int i, opcnt;
	unsigned long opcode;
	const struct cputbl *tbl = 0;
	int lvl;

	lvl = 0;
	tbl = op_smalltbl_11_ff; /* prefetch */

	for (opcode = 0; opcode < 65536; opcode++)
		cpufunctbl[opcode] = op_illg;
	for (i = 0; tbl[i].handler != NULL; i++) {
		opcode = tbl[i].opcode;
		cpufunctbl[opcode] = tbl[i].handler;
	}

	opcnt = 0;
	for (opcode = 0; opcode < 65536; opcode++) {
		cpuop_func *f;

		if (table68k[opcode].mnemo == i_ILLG)
			continue;
		if (table68k[opcode].clev > lvl) {
			continue;
		}

		if (table68k[opcode].handler != -1) {
			int idx = table68k[opcode].handler;
			f = cpufunctbl[idx];
			if (f == op_illg)
				abort ();
			cpufunctbl[opcode] = f;
			opcnt++;
		}
	}
}

int main(int argc, char **argv) {
	global_argv = argv;
	global_argc = argc;
	
	//init_m68k()
	int i;

	for (i = 0 ; i < 256 ; i++) {
		int j;
		for (j = 0 ; j < 8 ; j++) {
			if (i & (1 << j)) break;
		}
		movem_index1[i] = j;
		movem_index2[i] = 7-j;
		movem_next[i] = i & (~(1 << j));
	}

	regs.address_space_mask = 0xffffffff;

	read_table68k();
	do_merges();

	build_cpufunctbl();

	//m68k_reset()
	regs.spcflags = 0;
	m68k_areg (regs, 7) = get_arg("SSP");
	m68k_setpc(get_arg("PC"));
	regs.s = 1;
	regs.m = 0;
	regs.stopped = 0;
	regs.t1 = 0;
	regs.t0 = 0;
	SET_ZFLG(0);
	SET_XFLG(0);
	SET_CFLG(0);
	SET_VFLG(0);
	SET_NFLG(0);
	regs.intmask = 7;
	regs.vbr = regs.sfc = regs.dfc = 0;
	regs.irc = 0xffff;

	regs.pcr = 0;
	
	printf("START TEST\n");
	
	load_state();
	
	MakeSR();
	fill_prefetch_slow();
	
	//m68k_go();
	//m68k_run_1();
	
	//AO	m68k_setpc (regs.pc);
	(*cpufunctbl[regs.ir])(regs.ir);
	
	
	save_state();
	
	return 0;
}

