
typedef struct _proc_state {} proc_state;
typedef struct _insn_dp_i_s_struct {
/*Data Processing immidiate shieft*/
  int (*func) (struct _insn_dp_i_s_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int op1: 5; /*Data processing opcode*/
  unsigned int dps: 2; /*Update cpsr*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int sha: 6; /*Shieft amount*/
  unsigned int sh: 3; /*Shieft direction*/
  unsigned int rm: 5; /*Register rm*/
} insn_dp_i_s_struct;
typedef struct _insn_msr_struct {
/*Move status register to register*/
  int (*func) (struct _insn_msr_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int R: 2; /*Cpsr|Spsr '1'=Spsr*/
  unsigned int SBO: 5; /**/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int SBZ: 5; /**/
  unsigned int SBZ2: 5; /**/
} insn_msr_struct;
typedef struct _insn_mrs_struct {
/*Move register to status register*/
  int (*func) (struct _insn_mrs_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int R: 2; /*Cpsr|Spsr '1'=Spsr*/
  unsigned int msk: 5; /**/
  unsigned int SBO: 5; /**/
  unsigned int SBZ: 5; /**/
  unsigned int rm: 5; /*Register rm*/
} insn_mrs_struct;
typedef struct _insn_bex_struct {
/*Branch / exchange*/
  int (*func) (struct _insn_bex_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int SBO: 13; /**/
  unsigned int rm: 5; /*Register rm*/
} insn_bex_struct;
typedef struct _insn_clz_struct {
/*Count leading zero*/
  int (*func) (struct _insn_clz_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int SBO: 5; /**/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int SBO2: 5; /**/
  unsigned int rm: 5; /*Register rm*/
} insn_clz_struct;
typedef struct _insn_blx_struct {
/*Branch and link /exchange*/
  int (*func) (struct _insn_blx_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int SBO: 13; /**/
  unsigned int rm: 5; /*Register rm*/
} insn_blx_struct;
typedef struct _insn_dsa_struct {
/*Dsp add|sub*/
  int (*func) (struct _insn_dsa_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int dsop: 3; /*Dsp operand*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int SBZ: 5; /**/
  unsigned int rm: 5; /*Register rm*/
} insn_dsa_struct;
typedef struct _insn_brk_struct {
/*Breakpoint*/
  int (*func) (struct _insn_brk_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int imm: 13; /*Breakpoint imm part1*/
  unsigned int imm2: 5; /*Breakpoint imm part2*/
} insn_brk_struct;
typedef struct _insn_dsm_struct {
/*DSP multiply*/
  int (*func) (struct _insn_dsm_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int dsop: 3; /*Dsp operand*/
  unsigned int RD: 5; /**/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rs: 5; /*Register rs*/
  unsigned int y: 2; /**/
  unsigned int x: 2; /**/
  unsigned int rm: 5; /*Register rm*/
} insn_dsm_struct;
typedef struct _insn_dp_r_s_struct {
/*Data processing register shieft*/
  int (*func) (struct _insn_dp_r_s_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int op1: 5; /*Data processing opcode*/
  unsigned int dps: 2; /*Update cpsr*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int rs: 5; /*Register rs*/
  unsigned int sh: 3; /*Shieft direction*/
  unsigned int rm: 5; /*Register rm*/
} insn_dp_r_s_struct;
typedef struct _insn_mula_struct {
/*Multiply and accumulate*/
  int (*func) (struct _insn_mula_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int MA: 2; /*Multiply accumulate*/
  unsigned int MS: 2; /*Set cpsr*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rs: 5; /*Register rs*/
  unsigned int rm: 5; /*Register rm*/
} insn_mula_struct;
typedef struct _insn_mull_struct {
/*Multiply long*/
  int (*func) (struct _insn_mull_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int MU: 2; /*Multiply unsigned*/
  unsigned int MA: 2; /*Multiply accumulate*/
  unsigned int MS: 2; /*Set cpsr*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int rdl: 5; /*Destination register long*/
  unsigned int rs: 5; /*Register rs*/
  unsigned int rm: 5; /*Register rm*/
} insn_mull_struct;
typedef struct _insn_swp_struct {
/*Swap|swap byte*/
  int (*func) (struct _insn_swp_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int SB: 2; /*Swap byte*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int sbz: 5; /**/
  unsigned int rm: 5; /*Register rm*/
} insn_swp_struct;
typedef struct _insn_ld1_struct {
/*Load|Store halfword*/
  int (*func) (struct _insn_ld1_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int LSP: 2; /*pre-indexed*/
  unsigned int LSU: 2; /*add/sub base '1'=add*/
  unsigned int LSW: 2; /*writeback*/
  unsigned int LSL: 2; /*Load|Store '1'=Load*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int sbz: 5; /**/
  unsigned int rm: 5; /*Register rm*/
} insn_ld1_struct;
typedef struct _insn_ld2_struct {
/*Load|Store halfword immidiate offset*/
  int (*func) (struct _insn_ld2_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int LSP: 2; /*pre-indexed*/
  unsigned int LSU: 2; /*add/sub base '1'=add*/
  unsigned int LSW: 2; /*writeback*/
  unsigned int LSL: 2; /*Load|Store '1'=Load*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int i81: 5; /*Immidiate8 part1*/
  unsigned int i82: 5; /*Immidiate8 part2*/
} insn_ld2_struct;
typedef struct _insn_ld3_struct {
/*Load|Store two words register offset*/
  int (*func) (struct _insn_ld3_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int LSP: 2; /*pre-indexed*/
  unsigned int LSU: 2; /*add/sub base '1'=add*/
  unsigned int LSW: 2; /*writeback*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int i81: 5; /*Immidiate8 part1*/
  unsigned int S: 2; /*Signed|Unsigned '1'=signed*/
  unsigned int i82: 5; /*Immidiate8 part2*/
} insn_ld3_struct;
typedef struct _insn_ld4_struct {
/*Load|Store signed halfword/byte register offset*/
  int (*func) (struct _insn_ld4_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int LSP: 2; /*pre-indexed*/
  unsigned int LSU: 2; /*add/sub base '1'=add*/
  unsigned int LSW: 2; /*writeback*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int i81: 5; /*Immidiate8 part1*/
  unsigned int H: 2; /*halfword|signedbyte '1'=halfword*/
  unsigned int i82: 5; /*Immidiate8 part2*/
} insn_ld4_struct;
typedef struct _insn_ld5_struct {
/*Load|Store two words register offset*/
  int (*func) (struct _insn_ld5_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int LSP: 2; /*pre-indexed*/
  unsigned int LSU: 2; /*add/sub base '1'=add*/
  unsigned int LSW: 2; /*writeback*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int i81: 5; /*Immidiate8 part1*/
  unsigned int S: 2; /*Signed|Unsigned '1'=signed*/
  unsigned int i82: 5; /*Immidiate8 part2*/
} insn_ld5_struct;
typedef struct _insn_ld6_struct {
/*Load|Store signed halfword/byte immidiate offset*/
  int (*func) (struct _insn_ld6_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int LSP: 2; /*pre-indexed*/
  unsigned int LSU: 2; /*add/sub base '1'=add*/
  unsigned int LSW: 2; /*writeback*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int i81: 5; /*Immidiate8 part1*/
  unsigned int H: 2; /*halfword|signedbyte '1'=halfword*/
  unsigned int i82: 5; /*Immidiate8 part2*/
} insn_ld6_struct;
typedef struct _insn_dp_i_struct {
/*Data processing immidiate*/
  int (*func) (struct _insn_dp_i_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int op1: 5; /*Data processing opcode*/
  unsigned int dps: 2; /*Update cpsr*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int rot: 5; /*Immidiate8 rotate*/
  unsigned int dpi: 9; /*Immidiate8*/
} insn_dp_i_struct;
typedef struct _insn_undef1_struct {
/*Undefined instruction*/
  int (*func) (struct _insn_undef1_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int X2: 2; /**/
  unsigned int X: 21; /**/
} insn_undef1_struct;
typedef struct _insn_misr_struct {
/*Move immidiate to status register*/
  int (*func) (struct _insn_misr_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int R: 2; /*Cpsr|Spsr '1'=Spsr*/
  unsigned int MSK: 5; /*move immidiate to status register mask*/
  unsigned int SBQ: 5; /**/
  unsigned int rot: 5; /*Immidiate8 rotate*/
  unsigned int dpi: 9; /*Immidiate8*/
} insn_misr_struct;
typedef struct _insn_lsio_struct {
/*Load|Store imidiate offset*/
  int (*func) (struct _insn_lsio_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int LSP: 2; /*pre-indexed*/
  unsigned int LSU: 2; /*add/sub base '1'=add*/
  unsigned int LSB: 2; /*Byte|word '1'=byte*/
  unsigned int LSW: 2; /*writeback*/
  unsigned int LSL: 2; /*Load|Store '1'=Load*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int LSI: 13; /**/
} insn_lsio_struct;
typedef struct _insn_lsro_struct {
/*Load|Store register offset*/
  int (*func) (struct _insn_lsro_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int LSP: 2; /*pre-indexed*/
  unsigned int LSU: 2; /*add/sub base '1'=add*/
  unsigned int LSB: 2; /*Byte|word '1'=byte*/
  unsigned int LSW: 2; /*writeback*/
  unsigned int LSL: 2; /*Load|Store '1'=Load*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int sha: 6; /*Shieft amount*/
  unsigned int sh: 3; /*Shieft direction*/
  unsigned int rm: 5; /*Register rm*/
} insn_lsro_struct;
typedef struct _insn_undef2_struct {
/*Undefined instruction2*/
  int (*func) (struct _insn_undef2_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int X: 21; /**/
  unsigned int X2: 5; /**/
} insn_undef2_struct;
typedef struct _insn_undef3_struct {
/*Undefined instruction3*/
  int (*func) (struct _insn_undef3_struct *s, proc_state *state);
  unsigned int X: 28; /**/
} insn_undef3_struct;
typedef struct _insn_lsm_struct {
/*Load|Store multiple*/
  int (*func) (struct _insn_lsm_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int LSP: 2; /*pre-indexed*/
  unsigned int LSU: 2; /*add/sub base '1'=add*/
  unsigned int LMS: 2; /*Set cpsr fro spsr*/
  unsigned int LSW: 2; /*writeback*/
  unsigned int LSL: 2; /*Load|Store '1'=Load*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int rgl: 17; /*register list*/
} insn_lsm_struct;
typedef struct _insn_undef4_struct {
/*Undefined instruction4*/
  int (*func) (struct _insn_undef4_struct *s, proc_state *state);
  unsigned int X: 26; /**/
} insn_undef4_struct;
typedef struct _insn_bwl_struct {
/*Branch with link*/
  int (*func) (struct _insn_bwl_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int BLL: 2; /*Link*/
  unsigned int blo: 25; /**/
} insn_bwl_struct;
typedef struct _insn_bwlth_struct {
/*Branch with link and change to thumb*/
  int (*func) (struct _insn_bwlth_struct *s, proc_state *state);
  unsigned int BLH: 2; /*Exchange*/
  unsigned int blo: 25; /**/
} insn_bwlth_struct;
typedef struct _insn_cpldst_struct {
/*Coprocessor Load Store*/
  int (*func) (struct _insn_cpldst_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int LSP: 2; /*pre-indexed*/
  unsigned int LSU: 2; /*add/sub base '1'=add*/
  unsigned int Cp_N: 2; /*Coprocessor n bit*/
  unsigned int LSW: 2; /*writeback*/
  unsigned int LSL: 2; /*Load|Store '1'=Load*/
  unsigned int rn: 5; /*Register rn*/
  unsigned int crd: 5; /*Coprocessor destination register*/
  unsigned int cpn: 5; /*Coprocessor number*/
  unsigned int of8: 9; /*offset8*/
} insn_cpldst_struct;
typedef struct _insn_cpdp_struct {
/*Coprocessor data processing*/
  int (*func) (struct _insn_cpdp_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int co1: 5; /*Coprocessor op1*/
  unsigned int crn: 5; /*Coprocessor register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int cpn: 5; /*Coprocessor number*/
  unsigned int cp1: 4; /**/
  unsigned int crm: 5; /*Coprocessor register rm*/
} insn_cpdp_struct;
typedef struct _insn_cpr_struct {
/*Coprocessor register transfer*/
  int (*func) (struct _insn_cpr_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int co1: 4; /*Coprocessor op1*/
  unsigned int LSL: 2; /*Load|Store '1'=Load*/
  unsigned int crn: 5; /*Coprocessor register rn*/
  unsigned int rd: 5; /*Destination register rd*/
  unsigned int cpn: 5; /*Coprocessor number*/
  unsigned int cp1: 4; /**/
  unsigned int crm: 5; /*Coprocessor register rm*/
} insn_cpr_struct;
typedef struct _insn_swi_struct {
/*Software interrupt*/
  int (*func) (struct _insn_swi_struct *s, proc_state *state);
  unsigned int c: 5; /*Condition code*/
  unsigned int X: 25; /**/
} insn_swi_struct;
typedef struct _insn_undef_struct {
/*Undef*/
  int (*func) (struct _insn_undef_struct *s, proc_state *state);
  unsigned int X: 25; /**/
} insn_undef_struct;
typedef union _insn_union {
  insn_dp_i_s_struct insn_dp_i_s;
  insn_msr_struct insn_msr;
  insn_mrs_struct insn_mrs;
  insn_bex_struct insn_bex;
  insn_clz_struct insn_clz;
  insn_blx_struct insn_blx;
  insn_dsa_struct insn_dsa;
  insn_brk_struct insn_brk;
  insn_dsm_struct insn_dsm;
  insn_dp_r_s_struct insn_dp_r_s;
  insn_mula_struct insn_mula;
  insn_mull_struct insn_mull;
  insn_swp_struct insn_swp;
  insn_ld1_struct insn_ld1;
  insn_ld2_struct insn_ld2;
  insn_ld3_struct insn_ld3;
  insn_ld4_struct insn_ld4;
  insn_ld5_struct insn_ld5;
  insn_ld6_struct insn_ld6;
  insn_dp_i_struct insn_dp_i;
  insn_undef1_struct insn_undef1;
  insn_misr_struct insn_misr;
  insn_lsio_struct insn_lsio;
  insn_lsro_struct insn_lsro;
  insn_undef2_struct insn_undef2;
  insn_undef3_struct insn_undef3;
  insn_lsm_struct insn_lsm;
  insn_undef4_struct insn_undef4;
  insn_bwl_struct insn_bwl;
  insn_bwlth_struct insn_bwlth;
  insn_cpldst_struct insn_cpldst;
  insn_cpdp_struct insn_cpdp;
  insn_cpr_struct insn_cpr;
  insn_swi_struct insn_swi;
  insn_undef_struct insn_undef;
} insn_union;
 int func_insn_dp_i_s (struct _insn_dp_i_s_struct *s, proc_state *state) {
/*Data Processing immidiate shieft*/
};
int func_insn_msr (struct _insn_msr_struct *s, proc_state *state) {
/*Move status register to register*/
};
int func_insn_mrs (struct _insn_mrs_struct *s, proc_state *state) {
/*Move register to status register*/
};
int func_insn_bex (struct _insn_bex_struct *s, proc_state *state) {
/*Branch / exchange*/
};
int func_insn_clz (struct _insn_clz_struct *s, proc_state *state) {
/*Count leading zero*/
};
int func_insn_blx (struct _insn_blx_struct *s, proc_state *state) {
/*Branch and link /exchange*/
};
int func_insn_dsa (struct _insn_dsa_struct *s, proc_state *state) {
/*Dsp add|sub*/
};
int func_insn_brk (struct _insn_brk_struct *s, proc_state *state) {
/*Breakpoint*/
};
int func_insn_dsm (struct _insn_dsm_struct *s, proc_state *state) {
/*DSP multiply*/
};
int func_insn_dp_r_s (struct _insn_dp_r_s_struct *s, proc_state *state) {
/*Data processing register shieft*/
};
int func_insn_mula (struct _insn_mula_struct *s, proc_state *state) {
/*Multiply and accumulate*/
};
int func_insn_mull (struct _insn_mull_struct *s, proc_state *state) {
/*Multiply long*/
};
int func_insn_swp (struct _insn_swp_struct *s, proc_state *state) {
/*Swap|swap byte*/
};
int func_insn_ld1 (struct _insn_ld1_struct *s, proc_state *state) {
/*Load|Store halfword*/
};
int func_insn_ld2 (struct _insn_ld2_struct *s, proc_state *state) {
/*Load|Store halfword immidiate offset*/
};
int func_insn_ld3 (struct _insn_ld3_struct *s, proc_state *state) {
/*Load|Store two words register offset*/
};
int func_insn_ld4 (struct _insn_ld4_struct *s, proc_state *state) {
/*Load|Store signed halfword/byte register offset*/
};
int func_insn_ld5 (struct _insn_ld5_struct *s, proc_state *state) {
/*Load|Store two words register offset*/
};
int func_insn_ld6 (struct _insn_ld6_struct *s, proc_state *state) {
/*Load|Store signed halfword/byte immidiate offset*/
};
int func_insn_dp_i (struct _insn_dp_i_struct *s, proc_state *state) {
/*Data processing immidiate*/
};
int func_insn_undef1 (struct _insn_undef1_struct *s, proc_state *state) {
/*Undefined instruction*/
};
int func_insn_misr (struct _insn_misr_struct *s, proc_state *state) {
/*Move immidiate to status register*/
};
int func_insn_lsio (struct _insn_lsio_struct *s, proc_state *state) {
/*Load|Store imidiate offset*/
};
int func_insn_lsro (struct _insn_lsro_struct *s, proc_state *state) {
/*Load|Store register offset*/
};
int func_insn_undef2 (struct _insn_undef2_struct *s, proc_state *state) {
/*Undefined instruction2*/
};
int func_insn_undef3 (struct _insn_undef3_struct *s, proc_state *state) {
/*Undefined instruction3*/
};
int func_insn_lsm (struct _insn_lsm_struct *s, proc_state *state) {
/*Load|Store multiple*/
};
int func_insn_undef4 (struct _insn_undef4_struct *s, proc_state *state) {
/*Undefined instruction4*/
};
int func_insn_bwl (struct _insn_bwl_struct *s, proc_state *state) {
/*Branch with link*/
};
int func_insn_bwlth (struct _insn_bwlth_struct *s, proc_state *state) {
/*Branch with link and change to thumb*/
};
int func_insn_cpldst (struct _insn_cpldst_struct *s, proc_state *state) {
/*Coprocessor Load Store*/
};
int func_insn_cpdp (struct _insn_cpdp_struct *s, proc_state *state) {
/*Coprocessor data processing*/
};
int func_insn_cpr (struct _insn_cpr_struct *s, proc_state *state) {
/*Coprocessor register transfer*/
};
int func_insn_swi (struct _insn_swi_struct *s, proc_state *state) {
/*Software interrupt*/
};
int func_insn_undef (struct _insn_undef_struct *s, proc_state *state) {
/*Undef*/
};
unsigned int init_insn_dp_i_s(unsigned int insn, insn_union *s) {
s->insn_dp_i_s.func=func_insn_dp_i_s;
s->insn_dp_i_s.c=((insn>>28)&0xf);
s->insn_dp_i_s.op1=((insn>>21)&0xf);
s->insn_dp_i_s.dps=((insn>>20)&0x1);
s->insn_dp_i_s.rn=((insn>>16)&0xf);
s->insn_dp_i_s.rd=((insn>>12)&0xf);
s->insn_dp_i_s.sha=((insn>>7)&0x1f);
s->insn_dp_i_s.sh=((insn>>5)&0x3);
s->insn_dp_i_s.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_msr(unsigned int insn, insn_union *s) {
s->insn_msr.func=func_insn_msr;
s->insn_msr.c=((insn>>28)&0xf);
s->insn_msr.R=((insn>>22)&0x1);
s->insn_msr.SBO=((insn>>16)&0xf);
s->insn_msr.rd=((insn>>12)&0xf);
s->insn_msr.SBZ=((insn>>8)&0xf);
s->insn_msr.SBZ2=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_mrs(unsigned int insn, insn_union *s) {
s->insn_mrs.func=func_insn_mrs;
s->insn_mrs.c=((insn>>28)&0xf);
s->insn_mrs.R=((insn>>22)&0x1);
s->insn_mrs.msk=((insn>>16)&0xf);
s->insn_mrs.SBO=((insn>>12)&0xf);
s->insn_mrs.SBZ=((insn>>8)&0xf);
s->insn_mrs.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_bex(unsigned int insn, insn_union *s) {
s->insn_bex.func=func_insn_bex;
s->insn_bex.c=((insn>>28)&0xf);
s->insn_bex.SBO=((insn>>8)&0xfff);
s->insn_bex.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_clz(unsigned int insn, insn_union *s) {
s->insn_clz.func=func_insn_clz;
s->insn_clz.c=((insn>>28)&0xf);
s->insn_clz.SBO=((insn>>16)&0xf);
s->insn_clz.rd=((insn>>12)&0xf);
s->insn_clz.SBO2=((insn>>8)&0xf);
s->insn_clz.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_blx(unsigned int insn, insn_union *s) {
s->insn_blx.func=func_insn_blx;
s->insn_blx.c=((insn>>28)&0xf);
s->insn_blx.SBO=((insn>>8)&0xfff);
s->insn_blx.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_dsa(unsigned int insn, insn_union *s) {
s->insn_dsa.func=func_insn_dsa;
s->insn_dsa.c=((insn>>28)&0xf);
s->insn_dsa.dsop=((insn>>21)&0x3);
s->insn_dsa.rn=((insn>>16)&0xf);
s->insn_dsa.rd=((insn>>12)&0xf);
s->insn_dsa.SBZ=((insn>>8)&0xf);
s->insn_dsa.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_brk(unsigned int insn, insn_union *s) {
s->insn_brk.func=func_insn_brk;
s->insn_brk.c=((insn>>28)&0xf);
s->insn_brk.imm=((insn>>8)&0xfff);
s->insn_brk.imm2=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_dsm(unsigned int insn, insn_union *s) {
s->insn_dsm.func=func_insn_dsm;
s->insn_dsm.c=((insn>>28)&0xf);
s->insn_dsm.dsop=((insn>>21)&0x3);
s->insn_dsm.RD=((insn>>16)&0xf);
s->insn_dsm.rn=((insn>>12)&0xf);
s->insn_dsm.rs=((insn>>8)&0xf);
s->insn_dsm.y=((insn>>6)&0x1);
s->insn_dsm.x=((insn>>5)&0x1);
s->insn_dsm.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_dp_r_s(unsigned int insn, insn_union *s) {
s->insn_dp_r_s.func=func_insn_dp_r_s;
s->insn_dp_r_s.c=((insn>>28)&0xf);
s->insn_dp_r_s.op1=((insn>>21)&0xf);
s->insn_dp_r_s.dps=((insn>>20)&0x1);
s->insn_dp_r_s.rn=((insn>>16)&0xf);
s->insn_dp_r_s.rd=((insn>>12)&0xf);
s->insn_dp_r_s.rs=((insn>>8)&0xf);
s->insn_dp_r_s.sh=((insn>>5)&0x3);
s->insn_dp_r_s.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_mula(unsigned int insn, insn_union *s) {
s->insn_mula.func=func_insn_mula;
s->insn_mula.c=((insn>>28)&0xf);
s->insn_mula.MA=((insn>>21)&0x1);
s->insn_mula.MS=((insn>>20)&0x1);
s->insn_mula.rd=((insn>>16)&0xf);
s->insn_mula.rn=((insn>>12)&0xf);
s->insn_mula.rs=((insn>>8)&0xf);
s->insn_mula.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_mull(unsigned int insn, insn_union *s) {
s->insn_mull.func=func_insn_mull;
s->insn_mull.c=((insn>>28)&0xf);
s->insn_mull.MU=((insn>>22)&0x1);
s->insn_mull.MA=((insn>>21)&0x1);
s->insn_mull.MS=((insn>>20)&0x1);
s->insn_mull.rd=((insn>>16)&0xf);
s->insn_mull.rdl=((insn>>12)&0xf);
s->insn_mull.rs=((insn>>8)&0xf);
s->insn_mull.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_swp(unsigned int insn, insn_union *s) {
s->insn_swp.func=func_insn_swp;
s->insn_swp.c=((insn>>28)&0xf);
s->insn_swp.SB=((insn>>22)&0x1);
s->insn_swp.rn=((insn>>16)&0xf);
s->insn_swp.rd=((insn>>12)&0xf);
s->insn_swp.sbz=((insn>>8)&0xf);
s->insn_swp.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_ld1(unsigned int insn, insn_union *s) {
s->insn_ld1.func=func_insn_ld1;
s->insn_ld1.c=((insn>>28)&0xf);
s->insn_ld1.LSP=((insn>>24)&0x1);
s->insn_ld1.LSU=((insn>>23)&0x1);
s->insn_ld1.LSW=((insn>>21)&0x1);
s->insn_ld1.LSL=((insn>>20)&0x1);
s->insn_ld1.rn=((insn>>16)&0xf);
s->insn_ld1.rd=((insn>>12)&0xf);
s->insn_ld1.sbz=((insn>>8)&0xf);
s->insn_ld1.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_ld2(unsigned int insn, insn_union *s) {
s->insn_ld2.func=func_insn_ld2;
s->insn_ld2.c=((insn>>28)&0xf);
s->insn_ld2.LSP=((insn>>24)&0x1);
s->insn_ld2.LSU=((insn>>23)&0x1);
s->insn_ld2.LSW=((insn>>21)&0x1);
s->insn_ld2.LSL=((insn>>20)&0x1);
s->insn_ld2.rn=((insn>>16)&0xf);
s->insn_ld2.rd=((insn>>12)&0xf);
s->insn_ld2.i81=((insn>>8)&0xf);
s->insn_ld2.i82=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_ld3(unsigned int insn, insn_union *s) {
s->insn_ld3.func=func_insn_ld3;
s->insn_ld3.c=((insn>>28)&0xf);
s->insn_ld3.LSP=((insn>>24)&0x1);
s->insn_ld3.LSU=((insn>>23)&0x1);
s->insn_ld3.LSW=((insn>>21)&0x1);
s->insn_ld3.rn=((insn>>16)&0xf);
s->insn_ld3.rd=((insn>>12)&0xf);
s->insn_ld3.i81=((insn>>8)&0xf);
s->insn_ld3.S=((insn>>5)&0x1);
s->insn_ld3.i82=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_ld4(unsigned int insn, insn_union *s) {
s->insn_ld4.func=func_insn_ld4;
s->insn_ld4.c=((insn>>28)&0xf);
s->insn_ld4.LSP=((insn>>24)&0x1);
s->insn_ld4.LSU=((insn>>23)&0x1);
s->insn_ld4.LSW=((insn>>21)&0x1);
s->insn_ld4.rn=((insn>>16)&0xf);
s->insn_ld4.rd=((insn>>12)&0xf);
s->insn_ld4.i81=((insn>>8)&0xf);
s->insn_ld4.H=((insn>>5)&0x1);
s->insn_ld4.i82=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_ld5(unsigned int insn, insn_union *s) {
s->insn_ld5.func=func_insn_ld5;
s->insn_ld5.c=((insn>>28)&0xf);
s->insn_ld5.LSP=((insn>>24)&0x1);
s->insn_ld5.LSU=((insn>>23)&0x1);
s->insn_ld5.LSW=((insn>>21)&0x1);
s->insn_ld5.rn=((insn>>16)&0xf);
s->insn_ld5.rd=((insn>>12)&0xf);
s->insn_ld5.i81=((insn>>8)&0xf);
s->insn_ld5.S=((insn>>5)&0x1);
s->insn_ld5.i82=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_ld6(unsigned int insn, insn_union *s) {
s->insn_ld6.func=func_insn_ld6;
s->insn_ld6.c=((insn>>28)&0xf);
s->insn_ld6.LSP=((insn>>24)&0x1);
s->insn_ld6.LSU=((insn>>23)&0x1);
s->insn_ld6.LSW=((insn>>21)&0x1);
s->insn_ld6.rn=((insn>>16)&0xf);
s->insn_ld6.rd=((insn>>12)&0xf);
s->insn_ld6.i81=((insn>>8)&0xf);
s->insn_ld6.H=((insn>>5)&0x1);
s->insn_ld6.i82=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_dp_i(unsigned int insn, insn_union *s) {
s->insn_dp_i.func=func_insn_dp_i;
s->insn_dp_i.c=((insn>>28)&0xf);
s->insn_dp_i.op1=((insn>>21)&0xf);
s->insn_dp_i.dps=((insn>>20)&0x1);
s->insn_dp_i.rn=((insn>>16)&0xf);
s->insn_dp_i.rd=((insn>>12)&0xf);
s->insn_dp_i.rot=((insn>>8)&0xf);
s->insn_dp_i.dpi=((insn>>0)&0xff);
 return 1;};
 unsigned int init_insn_undef1(unsigned int insn, insn_union *s) {
s->insn_undef1.func=func_insn_undef1;
s->insn_undef1.c=((insn>>28)&0xf);
s->insn_undef1.X2=((insn>>22)&0x1);
s->insn_undef1.X=((insn>>0)&0xfffff);
 return 1;};
 unsigned int init_insn_misr(unsigned int insn, insn_union *s) {
s->insn_misr.func=func_insn_misr;
s->insn_misr.c=((insn>>28)&0xf);
s->insn_misr.R=((insn>>22)&0x1);
s->insn_misr.MSK=((insn>>16)&0xf);
s->insn_misr.SBQ=((insn>>12)&0xf);
s->insn_misr.rot=((insn>>8)&0xf);
s->insn_misr.dpi=((insn>>0)&0xff);
 return 1;};
 unsigned int init_insn_lsio(unsigned int insn, insn_union *s) {
s->insn_lsio.func=func_insn_lsio;
s->insn_lsio.c=((insn>>28)&0xf);
s->insn_lsio.LSP=((insn>>24)&0x1);
s->insn_lsio.LSU=((insn>>23)&0x1);
s->insn_lsio.LSB=((insn>>22)&0x1);
s->insn_lsio.LSW=((insn>>21)&0x1);
s->insn_lsio.LSL=((insn>>20)&0x1);
s->insn_lsio.rn=((insn>>16)&0xf);
s->insn_lsio.rd=((insn>>12)&0xf);
s->insn_lsio.LSI=((insn>>0)&0xfff);
 return 1;};
 unsigned int init_insn_lsro(unsigned int insn, insn_union *s) {
s->insn_lsro.func=func_insn_lsro;
s->insn_lsro.c=((insn>>28)&0xf);
s->insn_lsro.LSP=((insn>>24)&0x1);
s->insn_lsro.LSU=((insn>>23)&0x1);
s->insn_lsro.LSB=((insn>>22)&0x1);
s->insn_lsro.LSW=((insn>>21)&0x1);
s->insn_lsro.LSL=((insn>>20)&0x1);
s->insn_lsro.rn=((insn>>16)&0xf);
s->insn_lsro.rd=((insn>>12)&0xf);
s->insn_lsro.sha=((insn>>7)&0x1f);
s->insn_lsro.sh=((insn>>5)&0x3);
s->insn_lsro.rm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_undef2(unsigned int insn, insn_union *s) {
s->insn_undef2.func=func_insn_undef2;
s->insn_undef2.c=((insn>>28)&0xf);
s->insn_undef2.X=((insn>>5)&0xfffff);
s->insn_undef2.X2=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_undef3(unsigned int insn, insn_union *s) {
s->insn_undef3.func=func_insn_undef3;
s->insn_undef3.X=((insn>>0)&0x7ffffff);
 return 1;};
 unsigned int init_insn_lsm(unsigned int insn, insn_union *s) {
s->insn_lsm.func=func_insn_lsm;
s->insn_lsm.c=((insn>>28)&0xf);
s->insn_lsm.LSP=((insn>>24)&0x1);
s->insn_lsm.LSU=((insn>>23)&0x1);
s->insn_lsm.LMS=((insn>>22)&0x1);
s->insn_lsm.LSW=((insn>>21)&0x1);
s->insn_lsm.LSL=((insn>>20)&0x1);
s->insn_lsm.rn=((insn>>16)&0xf);
s->insn_lsm.rgl=((insn>>0)&0xffff);
 return 1;};
 unsigned int init_insn_undef4(unsigned int insn, insn_union *s) {
s->insn_undef4.func=func_insn_undef4;
s->insn_undef4.X=((insn>>0)&0x1ffffff);
 return 1;};
 unsigned int init_insn_bwl(unsigned int insn, insn_union *s) {
s->insn_bwl.func=func_insn_bwl;
s->insn_bwl.c=((insn>>28)&0xf);
s->insn_bwl.BLL=((insn>>24)&0x1);
s->insn_bwl.blo=((insn>>0)&0xffffff);
 return 1;};
 unsigned int init_insn_bwlth(unsigned int insn, insn_union *s) {
s->insn_bwlth.func=func_insn_bwlth;
s->insn_bwlth.BLH=((insn>>24)&0x1);
s->insn_bwlth.blo=((insn>>0)&0xffffff);
 return 1;};
 unsigned int init_insn_cpldst(unsigned int insn, insn_union *s) {
s->insn_cpldst.func=func_insn_cpldst;
s->insn_cpldst.c=((insn>>28)&0xf);
s->insn_cpldst.LSP=((insn>>24)&0x1);
s->insn_cpldst.LSU=((insn>>23)&0x1);
s->insn_cpldst.Cp_N=((insn>>22)&0x1);
s->insn_cpldst.LSW=((insn>>21)&0x1);
s->insn_cpldst.LSL=((insn>>20)&0x1);
s->insn_cpldst.rn=((insn>>16)&0xf);
s->insn_cpldst.crd=((insn>>12)&0xf);
s->insn_cpldst.cpn=((insn>>8)&0xf);
s->insn_cpldst.of8=((insn>>0)&0xff);
 return 1;};
 unsigned int init_insn_cpdp(unsigned int insn, insn_union *s) {
s->insn_cpdp.func=func_insn_cpdp;
s->insn_cpdp.c=((insn>>28)&0xf);
s->insn_cpdp.co1=((insn>>20)&0xf);
s->insn_cpdp.crn=((insn>>16)&0xf);
s->insn_cpdp.rd=((insn>>12)&0xf);
s->insn_cpdp.cpn=((insn>>8)&0xf);
s->insn_cpdp.cp1=((insn>>5)&0x7);
s->insn_cpdp.crm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_cpr(unsigned int insn, insn_union *s) {
s->insn_cpr.func=func_insn_cpr;
s->insn_cpr.c=((insn>>28)&0xf);
s->insn_cpr.co1=((insn>>21)&0x7);
s->insn_cpr.LSL=((insn>>20)&0x1);
s->insn_cpr.crn=((insn>>16)&0xf);
s->insn_cpr.rd=((insn>>12)&0xf);
s->insn_cpr.cpn=((insn>>8)&0xf);
s->insn_cpr.cp1=((insn>>5)&0x7);
s->insn_cpr.crm=((insn>>0)&0xf);
 return 1;};
 unsigned int init_insn_swi(unsigned int insn, insn_union *s) {
s->insn_swi.func=func_insn_swi;
s->insn_swi.c=((insn>>28)&0xf);
s->insn_swi.X=((insn>>0)&0xffffff);
 return 1;};
 unsigned int init_insn_undef(unsigned int insn, insn_union *s) {
s->insn_undef.func=func_insn_undef;
s->insn_undef.X=((insn>>0)&0xffffff);
 return 1;};








unsigned int decode(unsigned int insn, insn_union *s) {
{
switch (((insn>>27)&0x1)) { 
case 0x1:
{
 {
 switch (((insn>>25)&0x3)) { 
 case 0x3:
 {
  {
  switch (((insn>>24)&0x1)) { 
  case 0x1:
  {
   {
   switch (((insn>>28)&0xf)) { 
   case 0xf:
   {return init_insn_undef(insn,s);
   };break;
   }}
   /*default:*/ return init_insn_swi(insn,s);
  };break;
  }}
 };break;
 case 0x1:
 {
  {
  switch (((insn>>24)&0x1)) { 
  case 0x0:
  {
   {
   switch (((insn>>4)&0x1)) { 
   case 0x1:
   {return init_insn_cpr(insn,s);
   };break;
   case 0x0:
   {return init_insn_cpdp(insn,s);
   };break;
   }}
  };break;
  }}
  /*default:*/ return init_insn_cpldst(insn,s);
 };break;
 case 0x2:
 {
  {
  switch (((insn>>28)&0xf)) { 
  case 0xf:
  {return init_insn_bwlth(insn,s);
  };break;
  }}
  /*default:*/ return init_insn_bwl(insn,s);
 };break;
 case 0x0:
 {
  {
  switch (((insn>>28)&0xf)) { 
  case 0xf:
  {return init_insn_undef4(insn,s);
  };break;
  }}
 };break;
 }}
};break;
case 0x0:
{
 {
 switch (((insn>>25)&0x3)) { 
 case 0x3:
 {
  {
  switch (((insn>>4)&0x1)) { 
  case 0x1:
  {return init_insn_undef2(insn,s);
  };break;
  case 0x0:
  {return init_insn_lsro(insn,s);
  };break;
  }}
  /*default:*/ return init_insn_lsm(insn,s);
 };break;
 case 0x1:
 {return init_insn_lsio(insn,s);
 };break;
 case 0x2:
 {
  {
  switch (((insn>>24)&0x1)) { 
  case 0x1:
  {
   {
   switch (((insn>>23)&0x1)) { 
   case 0x0:
   {
    {
    switch (((insn>>21)&0x1)) { 
    case 0x1:
    {
     {
     switch (((insn>>20)&0x1)) { 
     case 0x0:
     {return init_insn_misr(insn,s);
     };break;
     }}
    };break;
    case 0x0:
    {
     {
     switch (((insn>>20)&0x1)) { 
     case 0x0:
     {return init_insn_undef1(insn,s);
     };break;
     }}
    };break;
    }}
   };break;
   }}
  };break;
  }}
  /*default:*/ return init_insn_dp_i(insn,s);
 };break;
 case 0x0:
 {
  {
  switch (((insn>>4)&0x1)) { 
  case 0x1:
  {
   {
   switch (((insn>>7)&0x1)) { 
   case 0x1:
   {
    {
    switch (((insn>>6)&0x1)) { 
    case 0x1:
    {
     {
     switch (((insn>>22)&0x1)) { 
     case 0x1:
     {
      {
      switch (((insn>>20)&0x1)) { 
      case 0x1:
      {return init_insn_ld6(insn,s);
      };break;
      case 0x0:
      {return init_insn_ld5(insn,s);
      };break;
      }}
     };break;
     case 0x0:
     {
      {
      switch (((insn>>20)&0x1)) { 
      case 0x1:
      {return init_insn_ld4(insn,s);
      };break;
      case 0x0:
      {return init_insn_ld3(insn,s);
      };break;
      }}
     };break;
     }}
    };break;
    case 0x0:
    {
     {
     switch (((insn>>5)&0x1)) { 
     case 0x1:
     {
      {
      switch (((insn>>22)&0x1)) { 
      case 0x1:
      {return init_insn_ld2(insn,s);
      };break;
      case 0x0:
      {return init_insn_ld1(insn,s);
      };break;
      }}
     };break;
     case 0x0:
     {
      {
      switch (((insn>>24)&0x1)) { 
      case 0x1:
      {
       {
       switch (((insn>>23)&0x1)) { 
       case 0x0:
       {
        {
        switch (((insn>>21)&0x1)) { 
        case 0x0:
        {
         {
         switch (((insn>>20)&0x1)) { 
         case 0x0:
         {return init_insn_swp(insn,s);
         };break;
         }}
        };break;
        }}
       };break;
       }}
      };break;
      case 0x0:
      {
       {
       switch (((insn>>23)&0x1)) { 
       case 0x1:
       {return init_insn_mull(insn,s);
       };break;
       case 0x0:
       {
        {
        switch (((insn>>22)&0x1)) { 
        case 0x0:
        {return init_insn_mula(insn,s);
        };break;
        }}
       };break;
       }}
      };break;
      }}
     };break;
     }}
    };break;
    }}
   };break;
   case 0x0:
   {
    {
    switch (((insn>>24)&0x1)) { 
    case 0x1:
    {
     {
     switch (((insn>>23)&0x1)) { 
     case 0x0:
     {
      {
      switch (((insn>>20)&0x1)) { 
      case 0x0:
      {
       {
       switch (((insn>>6)&0x1)) { 
       case 0x1:
       {
        {
        switch (((insn>>5)&0x1)) { 
        case 0x1:
        {
         {
         switch (((insn>>22)&0x1)) { 
         case 0x0:
         {
          {
          switch (((insn>>21)&0x1)) { 
          case 0x1:
          {return init_insn_brk(insn,s);
          };break;
          }}
         };break;
         }}
        };break;
        case 0x0:
        {return init_insn_dsa(insn,s);
        };break;
        }}
       };break;
       case 0x0:
       {
        {
        switch (((insn>>22)&0x1)) { 
        case 0x0:
        {
         {
         switch (((insn>>21)&0x1)) { 
         case 0x1:
         {
          {
          switch (((insn>>5)&0x1)) { 
          case 0x1:
          {return init_insn_blx(insn,s);
          };break;
          case 0x0:
          {return init_insn_bex(insn,s);
          };break;
          }}
         };break;
         }}
        };break;
        case 0x1:
        {
         {
         switch (((insn>>21)&0x1)) { 
         case 0x1:
         {
          {
          switch (((insn>>5)&0x1)) { 
          case 0x0:
          {return init_insn_clz(insn,s);
          };break;
          }}
         };break;
         }}
        };break;
        }}
       };break;
       }}
      };break;
      }}
     };break;
     }}
    };break;
    }}
    /*default:*/ return init_insn_dp_r_s(insn,s);
   };break;
   }}
  };break;
  case 0x0:
  {
   {
   switch (((insn>>24)&0x1)) { 
   case 0x1:
   {
    {
    switch (((insn>>23)&0x1)) { 
    case 0x0:
    {
     {
     switch (((insn>>20)&0x1)) { 
     case 0x0:
     {
      {
      switch (((insn>>7)&0x1)) { 
      case 0x1:
      {return init_insn_dsm(insn,s);
      };break;
      case 0x0:
      {
       {
       switch (((insn>>21)&0x1)) { 
       case 0x1:
       {
        {
        switch (((insn>>6)&0x1)) { 
        case 0x0:
        {
         {
         switch (((insn>>5)&0x1)) { 
         case 0x0:
         {return init_insn_mrs(insn,s);
         };break;
         }}
        };break;
        }}
       };break;
       case 0x0:
       {
        {
        switch (((insn>>6)&0x1)) { 
        case 0x0:
        {
         {
         switch (((insn>>5)&0x1)) { 
         case 0x0:
         {return init_insn_msr(insn,s);
         };break;
         }}
        };break;
        }}
       };break;
       }}
      };break;
      }}
     };break;
     }}
    };break;
    }}
   };break;
   }}
   /*default:*/ return init_insn_dp_i_s(insn,s);
  };break;
  }}
 };break;
 }}
 /*default:*/
 {
 switch (((insn>>28)&0xf)) { 
 case 0xf:
 {return init_insn_undef3(insn,s);
 };break;
 }}
};break;
}}

}; 
