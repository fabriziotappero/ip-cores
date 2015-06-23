
typedef struct _proc_state {} proc_state;
typedef struct _insn_ldsb_struct {
/*Load|Store signed byte*/
  int (*func) (struct _insn_ldsb_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldsb_struct;
typedef struct _insn_ldsh_struct {
/*Load|Store signed halfword*/
  int (*func) (struct _insn_ldsh_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldsh_struct;
typedef struct _insn_ldst_ub_struct {
/*Load|Store unsigned byte*/
  int (*func) (struct _insn_ldst_ub_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int ls: 2; /*Load/Store '1'=Store*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldst_ub_struct;
typedef struct _insn_ldst_uh_struct {
/*Load|Store unsigned halfword*/
  int (*func) (struct _insn_ldst_uh_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int ls: 2; /*Load/Store '1'=Store*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldst_uh_struct;
typedef struct _insn_ldst_struct {
/*Load|Store word*/
  int (*func) (struct _insn_ldst_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int ls: 2; /*Load/Store '1'=Store*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldst_struct;
typedef struct _insn_ldst_d_struct {
/*Load|Store doubleword*/
  int (*func) (struct _insn_ldst_d_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int ls: 2; /*Load/Store '1'=Store*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldst_d_struct;
typedef struct _insn_ldst_f_struct {
/*Load|Sore floating point register*/
  int (*func) (struct _insn_ldst_f_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int ls: 2; /*Load/Store '1'=Store*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldst_f_struct;
typedef struct _insn_ldst_df_struct {
/*Load|Sore double floating point register*/
  int (*func) (struct _insn_ldst_df_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int ls: 2; /*Load/Store '1'=Store*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldst_df_struct;
typedef struct _insn_ldst_fsr_struct {
/*Load|Sore floating point state register*/
  int (*func) (struct _insn_ldst_fsr_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int ls: 2; /*Load/Store '1'=Store*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldst_fsr_struct;
typedef struct _insn_stdfq_struct {
/*Store floating point deferred trap queue*/
  int (*func) (struct _insn_stdfq_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_stdfq_struct;
typedef struct _insn_ldst_c_struct {
/*Load|Sore coprocessor register*/
  int (*func) (struct _insn_ldst_c_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int ls: 2; /*Load/Store '1'=Store*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldst_c_struct;
typedef struct _insn_ldst_dc_struct {
/*Load|Sore double coprocessor register*/
  int (*func) (struct _insn_ldst_dc_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int ls: 2; /*Load/Store '1'=Store*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldst_dc_struct;
typedef struct _insn_ldst_csr_struct {
/*Load|Sore double coprocessor state register*/
  int (*func) (struct _insn_ldst_csr_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int ls: 2; /*Load/Store '1'=Store*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldst_csr_struct;
typedef struct _insn_stdcq_struct {
/*Store coprocessor deferred trap queue*/
  int (*func) (struct _insn_stdcq_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_stdcq_struct;
typedef struct _insn_ldstb_struct {
/*Atomic Load-Store unsigned byte*/
  int (*func) (struct _insn_ldstb_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ldstb_struct;
typedef struct _insn_swp_struct {
/*Swap register into memory*/
  int (*func) (struct _insn_swp_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_swp_struct;
typedef struct _insn_sethi_struct {
/*Set upper 22 bits*/
  int (*func) (struct _insn_sethi_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int i22: 23; /*Immidiate 22*/
} insn_sethi_struct;
typedef struct _insn_nop_struct {
/*No op*/
  int (*func) (struct _insn_nop_struct *s, proc_state *state);
  unsigned int x: 23; /**/
} insn_nop_struct;
typedef struct _insn_and_struct {
/*logical and*/
  int (*func) (struct _insn_and_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int cc: 2; /*Modify icc '1'=modify*/
  unsigned int n: 2; /*Not '1'=not*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_and_struct;
typedef struct _insn_or_struct {
/*logical or*/
  int (*func) (struct _insn_or_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int cc: 2; /*Modify icc '1'=modify*/
  unsigned int n: 2; /*Not '1'=not*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_or_struct;
typedef struct _insn_xor_struct {
/*logical xor*/
  int (*func) (struct _insn_xor_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int cc: 2; /*Modify icc '1'=modify*/
  unsigned int n: 2; /*Not '1'=not*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_xor_struct;
typedef struct _insn_sll_struct {
/*shieft left logical*/
  int (*func) (struct _insn_sll_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_sll_struct;
typedef struct _insn_srl_struct {
/*shieft right logical*/
  int (*func) (struct _insn_srl_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_srl_struct;
typedef struct _insn_sra_struct {
/*shieft right arith*/
  int (*func) (struct _insn_sra_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_sra_struct;
typedef struct _insn_sadd_struct {
/*Sub|Add*/
  int (*func) (struct _insn_sadd_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int cc: 2; /*Modify icc '1'=modify*/
  unsigned int xx: 2; /*Use carry '1'=use*/
  unsigned int sa: 2; /*Sub/Add '1'=Sub*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_sadd_struct;
typedef struct _insn_tsadd_struct {
/*Tagged Sub|Add*/
  int (*func) (struct _insn_tsadd_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int sa: 2; /*Sub/Add '1'=Sub*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_tsadd_struct;
typedef struct _insn_tsaddtv_struct {
/*Tagged Sub|Add with trap on overflow*/
  int (*func) (struct _insn_tsaddtv_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int sa: 2; /*Sub/Add '1'=Sub*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_tsaddtv_struct;
typedef struct _insn_mulscc_struct {
/*Multiply*/
  int (*func) (struct _insn_mulscc_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int cc: 2; /*Modify icc '1'=modify*/
  unsigned int sig: 2; /*Signed '1'=Signed*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_mulscc_struct;
typedef struct _insn_divscc_struct {
/*Divide*/
  int (*func) (struct _insn_divscc_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int cc: 2; /*Modify icc '1'=modify*/
  unsigned int sig: 2; /*Signed '1'=Signed*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_divscc_struct;
typedef struct _insn_sv_struct {
/*Save*/
  int (*func) (struct _insn_sv_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_sv_struct;
typedef struct _insn_rest_struct {
/*Restore*/
  int (*func) (struct _insn_rest_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_rest_struct;
typedef struct _insn_bra_struct {
/*Branch on condition*/
  int (*func) (struct _insn_bra_struct *s, proc_state *state);
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int c: 5; /*Condition code*/
  unsigned int d22: 23; /**/
} insn_bra_struct;
typedef struct _insn_fbra_struct {
/*Branch on floating point condition*/
  int (*func) (struct _insn_fbra_struct *s, proc_state *state);
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int c: 5; /*Condition code*/
  unsigned int d22: 23; /**/
} insn_fbra_struct;
typedef struct _insn_cbra_struct {
/*Branch on coprocessor condition*/
  int (*func) (struct _insn_cbra_struct *s, proc_state *state);
  unsigned int a: 2; /*Alternate space '1'=alternate space*/
  unsigned int c: 5; /*Condition code*/
  unsigned int d22: 23; /**/
} insn_cbra_struct;
typedef struct _insn_jmp_struct {
/*Call and link offset*/
  int (*func) (struct _insn_jmp_struct *s, proc_state *state);
  unsigned int d30: 31; /*Offset 30bit*/
} insn_jmp_struct;
typedef struct _insn_jml_struct {
/*Jump and link*/
  int (*func) (struct _insn_jml_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_jml_struct;
typedef struct _insn_ret_struct {
/*Return from trap*/
  int (*func) (struct _insn_ret_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_ret_struct;
typedef struct _insn_trap_struct {
/*Trap on condition code*/
  int (*func) (struct _insn_trap_struct *s, proc_state *state);
  unsigned int rvd: 2; /**/
  unsigned int c: 5; /*Condition code*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int i: 2; /*Select s2i '1'=sim13*/
  unsigned int s2i: 14; /*op2: simm13 or rs2*/
} insn_trap_struct;
typedef struct _insn_rd_struct {
/*Read state registers*/
  int (*func) (struct _insn_rd_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int x: 15; /**/
} insn_rd_struct;
typedef struct _insn_rdp_struct {
/*Read processor state register (rdpsr)*/
  int (*func) (struct _insn_rdp_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int x: 15; /**/
} insn_rdp_struct;
typedef struct _insn_rdw_struct {
/*Read windows invalid mask*/
  int (*func) (struct _insn_rdw_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int x: 15; /**/
} insn_rdw_struct;
typedef struct _insn_rdt_struct {
/*Read trap base register*/
  int (*func) (struct _insn_rdt_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int x: 15; /**/
} insn_rdt_struct;
typedef struct _insn_wd_struct {
/*Write state registers*/
  int (*func) (struct _insn_wd_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int x: 15; /**/
} insn_wd_struct;
typedef struct _insn_wdp_struct {
/*Write processor state register (rdpsr)*/
  int (*func) (struct _insn_wdp_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int x: 15; /**/
} insn_wdp_struct;
typedef struct _insn_wdw_struct {
/*Write windows invalid mask*/
  int (*func) (struct _insn_wdw_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int x: 15; /**/
} insn_wdw_struct;
typedef struct _insn_wdt_struct {
/*Write trap base register*/
  int (*func) (struct _insn_wdt_struct *s, proc_state *state);
  unsigned int rd: 6; /*Destination register*/
  unsigned int rs1: 6; /*Source register 1*/
  unsigned int x: 15; /**/
} insn_wdt_struct;
typedef struct _insn_stbar_struct {
/*Store barrier*/
  int (*func) (struct _insn_stbar_struct *s, proc_state *state);
  unsigned int x: 14; /**/
} insn_stbar_struct;
typedef struct _insn_unimp_struct {
/*Unimplemented*/
  int (*func) (struct _insn_unimp_struct *s, proc_state *state);
  unsigned int rvd: 6; /**/
  unsigned int cst: 23; /**/
} insn_unimp_struct;
typedef union _insn_union {
  insn_ldsb_struct insn_ldsb;
  insn_ldsh_struct insn_ldsh;
  insn_ldst_ub_struct insn_ldst_ub;
  insn_ldst_uh_struct insn_ldst_uh;
  insn_ldst_struct insn_ldst;
  insn_ldst_d_struct insn_ldst_d;
  insn_ldst_f_struct insn_ldst_f;
  insn_ldst_df_struct insn_ldst_df;
  insn_ldst_fsr_struct insn_ldst_fsr;
  insn_stdfq_struct insn_stdfq;
  insn_ldst_c_struct insn_ldst_c;
  insn_ldst_dc_struct insn_ldst_dc;
  insn_ldst_csr_struct insn_ldst_csr;
  insn_stdcq_struct insn_stdcq;
  insn_ldstb_struct insn_ldstb;
  insn_swp_struct insn_swp;
  insn_sethi_struct insn_sethi;
  insn_nop_struct insn_nop;
  insn_and_struct insn_and;
  insn_or_struct insn_or;
  insn_xor_struct insn_xor;
  insn_sll_struct insn_sll;
  insn_srl_struct insn_srl;
  insn_sra_struct insn_sra;
  insn_sadd_struct insn_sadd;
  insn_tsadd_struct insn_tsadd;
  insn_tsaddtv_struct insn_tsaddtv;
  insn_mulscc_struct insn_mulscc;
  insn_divscc_struct insn_divscc;
  insn_sv_struct insn_sv;
  insn_rest_struct insn_rest;
  insn_bra_struct insn_bra;
  insn_fbra_struct insn_fbra;
  insn_cbra_struct insn_cbra;
  insn_jmp_struct insn_jmp;
  insn_jml_struct insn_jml;
  insn_ret_struct insn_ret;
  insn_trap_struct insn_trap;
  insn_rd_struct insn_rd;
  insn_rdp_struct insn_rdp;
  insn_rdw_struct insn_rdw;
  insn_rdt_struct insn_rdt;
  insn_wd_struct insn_wd;
  insn_wdp_struct insn_wdp;
  insn_wdw_struct insn_wdw;
  insn_wdt_struct insn_wdt;
  insn_stbar_struct insn_stbar;
  insn_unimp_struct insn_unimp;
} insn_union;
 int func_insn_ldsb (struct _insn_ldsb_struct *s, proc_state *state) {
/*Load|Store signed byte*/
};
int func_insn_ldsh (struct _insn_ldsh_struct *s, proc_state *state) {
/*Load|Store signed halfword*/
};
int func_insn_ldst_ub (struct _insn_ldst_ub_struct *s, proc_state *state) {
/*Load|Store unsigned byte*/
};
int func_insn_ldst_uh (struct _insn_ldst_uh_struct *s, proc_state *state) {
/*Load|Store unsigned halfword*/
};
int func_insn_ldst (struct _insn_ldst_struct *s, proc_state *state) {
/*Load|Store word*/
};
int func_insn_ldst_d (struct _insn_ldst_d_struct *s, proc_state *state) {
/*Load|Store doubleword*/
};
int func_insn_ldst_f (struct _insn_ldst_f_struct *s, proc_state *state) {
/*Load|Sore floating point register*/
};
int func_insn_ldst_df (struct _insn_ldst_df_struct *s, proc_state *state) {
/*Load|Sore double floating point register*/
};
int func_insn_ldst_fsr (struct _insn_ldst_fsr_struct *s, proc_state *state) {
/*Load|Sore floating point state register*/
};
int func_insn_stdfq (struct _insn_stdfq_struct *s, proc_state *state) {
/*Store floating point deferred trap queue*/
};
int func_insn_ldst_c (struct _insn_ldst_c_struct *s, proc_state *state) {
/*Load|Sore coprocessor register*/
};
int func_insn_ldst_dc (struct _insn_ldst_dc_struct *s, proc_state *state) {
/*Load|Sore double coprocessor register*/
};
int func_insn_ldst_csr (struct _insn_ldst_csr_struct *s, proc_state *state) {
/*Load|Sore double coprocessor state register*/
};
int func_insn_stdcq (struct _insn_stdcq_struct *s, proc_state *state) {
/*Store coprocessor deferred trap queue*/
};
int func_insn_ldstb (struct _insn_ldstb_struct *s, proc_state *state) {
/*Atomic Load-Store unsigned byte*/
};
int func_insn_swp (struct _insn_swp_struct *s, proc_state *state) {
/*Swap register into memory*/
};
int func_insn_sethi (struct _insn_sethi_struct *s, proc_state *state) {
/*Set upper 22 bits*/
};
int func_insn_nop (struct _insn_nop_struct *s, proc_state *state) {
/*No op*/
};
int func_insn_and (struct _insn_and_struct *s, proc_state *state) {
/*logical and*/
};
int func_insn_or (struct _insn_or_struct *s, proc_state *state) {
/*logical or*/
};
int func_insn_xor (struct _insn_xor_struct *s, proc_state *state) {
/*logical xor*/
};
int func_insn_sll (struct _insn_sll_struct *s, proc_state *state) {
/*shieft left logical*/
};
int func_insn_srl (struct _insn_srl_struct *s, proc_state *state) {
/*shieft right logical*/
};
int func_insn_sra (struct _insn_sra_struct *s, proc_state *state) {
/*shieft right arith*/
};
int func_insn_sadd (struct _insn_sadd_struct *s, proc_state *state) {
/*Sub|Add*/
};
int func_insn_tsadd (struct _insn_tsadd_struct *s, proc_state *state) {
/*Tagged Sub|Add*/
};
int func_insn_tsaddtv (struct _insn_tsaddtv_struct *s, proc_state *state) {
/*Tagged Sub|Add with trap on overflow*/
};
int func_insn_mulscc (struct _insn_mulscc_struct *s, proc_state *state) {
/*Multiply*/
};
int func_insn_divscc (struct _insn_divscc_struct *s, proc_state *state) {
/*Divide*/
};
int func_insn_sv (struct _insn_sv_struct *s, proc_state *state) {
/*Save*/
};
int func_insn_rest (struct _insn_rest_struct *s, proc_state *state) {
/*Restore*/
};
int func_insn_bra (struct _insn_bra_struct *s, proc_state *state) {
/*Branch on condition*/
};
int func_insn_fbra (struct _insn_fbra_struct *s, proc_state *state) {
/*Branch on floating point condition*/
};
int func_insn_cbra (struct _insn_cbra_struct *s, proc_state *state) {
/*Branch on coprocessor condition*/
};
int func_insn_jmp (struct _insn_jmp_struct *s, proc_state *state) {
/*Call and link offset*/
};
int func_insn_jml (struct _insn_jml_struct *s, proc_state *state) {
/*Jump and link*/
};
int func_insn_ret (struct _insn_ret_struct *s, proc_state *state) {
/*Return from trap*/
};
int func_insn_trap (struct _insn_trap_struct *s, proc_state *state) {
/*Trap on condition code*/
};
int func_insn_rd (struct _insn_rd_struct *s, proc_state *state) {
/*Read state registers*/
};
int func_insn_rdp (struct _insn_rdp_struct *s, proc_state *state) {
/*Read processor state register (rdpsr)*/
};
int func_insn_rdw (struct _insn_rdw_struct *s, proc_state *state) {
/*Read windows invalid mask*/
};
int func_insn_rdt (struct _insn_rdt_struct *s, proc_state *state) {
/*Read trap base register*/
};
int func_insn_wd (struct _insn_wd_struct *s, proc_state *state) {
/*Write state registers*/
};
int func_insn_wdp (struct _insn_wdp_struct *s, proc_state *state) {
/*Write processor state register (rdpsr)*/
};
int func_insn_wdw (struct _insn_wdw_struct *s, proc_state *state) {
/*Write windows invalid mask*/
};
int func_insn_wdt (struct _insn_wdt_struct *s, proc_state *state) {
/*Write trap base register*/
};
int func_insn_stbar (struct _insn_stbar_struct *s, proc_state *state) {
/*Store barrier*/
};
int func_insn_unimp (struct _insn_unimp_struct *s, proc_state *state) {
/*Unimplemented*/
};
unsigned int init_insn_ldsb(unsigned int insn, insn_union *s) {
s->insn_ldsb.func=func_insn_ldsb;
s->insn_ldsb.rd=((insn>>25)&0x1f);
s->insn_ldsb.a=((insn>>23)&0x1);
s->insn_ldsb.rs1=((insn>>14)&0x1f);
s->insn_ldsb.i=((insn>>13)&0x1);
s->insn_ldsb.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldsh(unsigned int insn, insn_union *s) {
s->insn_ldsh.func=func_insn_ldsh;
s->insn_ldsh.rd=((insn>>25)&0x1f);
s->insn_ldsh.a=((insn>>23)&0x1);
s->insn_ldsh.rs1=((insn>>14)&0x1f);
s->insn_ldsh.i=((insn>>13)&0x1);
s->insn_ldsh.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldst_ub(unsigned int insn, insn_union *s) {
s->insn_ldst_ub.func=func_insn_ldst_ub;
s->insn_ldst_ub.rd=((insn>>25)&0x1f);
s->insn_ldst_ub.a=((insn>>23)&0x1);
s->insn_ldst_ub.ls=((insn>>21)&0x1);
s->insn_ldst_ub.rs1=((insn>>14)&0x1f);
s->insn_ldst_ub.i=((insn>>13)&0x1);
s->insn_ldst_ub.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldst_uh(unsigned int insn, insn_union *s) {
s->insn_ldst_uh.func=func_insn_ldst_uh;
s->insn_ldst_uh.rd=((insn>>25)&0x1f);
s->insn_ldst_uh.a=((insn>>23)&0x1);
s->insn_ldst_uh.ls=((insn>>21)&0x1);
s->insn_ldst_uh.rs1=((insn>>14)&0x1f);
s->insn_ldst_uh.i=((insn>>13)&0x1);
s->insn_ldst_uh.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldst(unsigned int insn, insn_union *s) {
s->insn_ldst.func=func_insn_ldst;
s->insn_ldst.rd=((insn>>25)&0x1f);
s->insn_ldst.a=((insn>>23)&0x1);
s->insn_ldst.ls=((insn>>21)&0x1);
s->insn_ldst.rs1=((insn>>14)&0x1f);
s->insn_ldst.i=((insn>>13)&0x1);
s->insn_ldst.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldst_d(unsigned int insn, insn_union *s) {
s->insn_ldst_d.func=func_insn_ldst_d;
s->insn_ldst_d.rd=((insn>>25)&0x1f);
s->insn_ldst_d.a=((insn>>23)&0x1);
s->insn_ldst_d.ls=((insn>>21)&0x1);
s->insn_ldst_d.rs1=((insn>>14)&0x1f);
s->insn_ldst_d.i=((insn>>13)&0x1);
s->insn_ldst_d.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldst_f(unsigned int insn, insn_union *s) {
s->insn_ldst_f.func=func_insn_ldst_f;
s->insn_ldst_f.rd=((insn>>25)&0x1f);
s->insn_ldst_f.ls=((insn>>21)&0x1);
s->insn_ldst_f.rs1=((insn>>14)&0x1f);
s->insn_ldst_f.i=((insn>>13)&0x1);
s->insn_ldst_f.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldst_df(unsigned int insn, insn_union *s) {
s->insn_ldst_df.func=func_insn_ldst_df;
s->insn_ldst_df.rd=((insn>>25)&0x1f);
s->insn_ldst_df.ls=((insn>>21)&0x1);
s->insn_ldst_df.rs1=((insn>>14)&0x1f);
s->insn_ldst_df.i=((insn>>13)&0x1);
s->insn_ldst_df.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldst_fsr(unsigned int insn, insn_union *s) {
s->insn_ldst_fsr.func=func_insn_ldst_fsr;
s->insn_ldst_fsr.rd=((insn>>25)&0x1f);
s->insn_ldst_fsr.ls=((insn>>21)&0x1);
s->insn_ldst_fsr.rs1=((insn>>14)&0x1f);
s->insn_ldst_fsr.i=((insn>>13)&0x1);
s->insn_ldst_fsr.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_stdfq(unsigned int insn, insn_union *s) {
s->insn_stdfq.func=func_insn_stdfq;
s->insn_stdfq.rd=((insn>>25)&0x1f);
s->insn_stdfq.rs1=((insn>>14)&0x1f);
s->insn_stdfq.i=((insn>>13)&0x1);
s->insn_stdfq.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldst_c(unsigned int insn, insn_union *s) {
s->insn_ldst_c.func=func_insn_ldst_c;
s->insn_ldst_c.rd=((insn>>25)&0x1f);
s->insn_ldst_c.ls=((insn>>21)&0x1);
s->insn_ldst_c.rs1=((insn>>14)&0x1f);
s->insn_ldst_c.i=((insn>>13)&0x1);
s->insn_ldst_c.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldst_dc(unsigned int insn, insn_union *s) {
s->insn_ldst_dc.func=func_insn_ldst_dc;
s->insn_ldst_dc.rd=((insn>>25)&0x1f);
s->insn_ldst_dc.ls=((insn>>21)&0x1);
s->insn_ldst_dc.rs1=((insn>>14)&0x1f);
s->insn_ldst_dc.i=((insn>>13)&0x1);
s->insn_ldst_dc.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldst_csr(unsigned int insn, insn_union *s) {
s->insn_ldst_csr.func=func_insn_ldst_csr;
s->insn_ldst_csr.rd=((insn>>25)&0x1f);
s->insn_ldst_csr.ls=((insn>>21)&0x1);
s->insn_ldst_csr.rs1=((insn>>14)&0x1f);
s->insn_ldst_csr.i=((insn>>13)&0x1);
s->insn_ldst_csr.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_stdcq(unsigned int insn, insn_union *s) {
s->insn_stdcq.func=func_insn_stdcq;
s->insn_stdcq.rd=((insn>>25)&0x1f);
s->insn_stdcq.rs1=((insn>>14)&0x1f);
s->insn_stdcq.i=((insn>>13)&0x1);
s->insn_stdcq.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ldstb(unsigned int insn, insn_union *s) {
s->insn_ldstb.func=func_insn_ldstb;
s->insn_ldstb.rd=((insn>>25)&0x1f);
s->insn_ldstb.a=((insn>>23)&0x1);
s->insn_ldstb.rs1=((insn>>14)&0x1f);
s->insn_ldstb.i=((insn>>13)&0x1);
s->insn_ldstb.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_swp(unsigned int insn, insn_union *s) {
s->insn_swp.func=func_insn_swp;
s->insn_swp.rd=((insn>>25)&0x1f);
s->insn_swp.a=((insn>>23)&0x1);
s->insn_swp.rs1=((insn>>14)&0x1f);
s->insn_swp.i=((insn>>13)&0x1);
s->insn_swp.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_sethi(unsigned int insn, insn_union *s) {
s->insn_sethi.func=func_insn_sethi;
s->insn_sethi.rd=((insn>>25)&0x1f);
s->insn_sethi.i22=((insn>>0)&0x3fffff);
 return 1;};
 unsigned int init_insn_nop(unsigned int insn, insn_union *s) {
s->insn_nop.func=func_insn_nop;
s->insn_nop.x=((insn>>0)&0x3fffff);
 return 1;};
 unsigned int init_insn_and(unsigned int insn, insn_union *s) {
s->insn_and.func=func_insn_and;
s->insn_and.rd=((insn>>25)&0x1f);
s->insn_and.cc=((insn>>23)&0x1);
s->insn_and.n=((insn>>21)&0x1);
s->insn_and.rs1=((insn>>14)&0x1f);
s->insn_and.i=((insn>>13)&0x1);
s->insn_and.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_or(unsigned int insn, insn_union *s) {
s->insn_or.func=func_insn_or;
s->insn_or.rd=((insn>>25)&0x1f);
s->insn_or.cc=((insn>>23)&0x1);
s->insn_or.n=((insn>>21)&0x1);
s->insn_or.rs1=((insn>>14)&0x1f);
s->insn_or.i=((insn>>13)&0x1);
s->insn_or.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_xor(unsigned int insn, insn_union *s) {
s->insn_xor.func=func_insn_xor;
s->insn_xor.rd=((insn>>25)&0x1f);
s->insn_xor.cc=((insn>>23)&0x1);
s->insn_xor.n=((insn>>21)&0x1);
s->insn_xor.rs1=((insn>>14)&0x1f);
s->insn_xor.i=((insn>>13)&0x1);
s->insn_xor.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_sll(unsigned int insn, insn_union *s) {
s->insn_sll.func=func_insn_sll;
s->insn_sll.rd=((insn>>25)&0x1f);
s->insn_sll.rs1=((insn>>14)&0x1f);
s->insn_sll.i=((insn>>13)&0x1);
s->insn_sll.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_srl(unsigned int insn, insn_union *s) {
s->insn_srl.func=func_insn_srl;
s->insn_srl.rd=((insn>>25)&0x1f);
s->insn_srl.rs1=((insn>>14)&0x1f);
s->insn_srl.i=((insn>>13)&0x1);
s->insn_srl.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_sra(unsigned int insn, insn_union *s) {
s->insn_sra.func=func_insn_sra;
s->insn_sra.rd=((insn>>25)&0x1f);
s->insn_sra.rs1=((insn>>14)&0x1f);
s->insn_sra.i=((insn>>13)&0x1);
s->insn_sra.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_sadd(unsigned int insn, insn_union *s) {
s->insn_sadd.func=func_insn_sadd;
s->insn_sadd.rd=((insn>>25)&0x1f);
s->insn_sadd.cc=((insn>>23)&0x1);
s->insn_sadd.xx=((insn>>22)&0x1);
s->insn_sadd.sa=((insn>>21)&0x1);
s->insn_sadd.rs1=((insn>>14)&0x1f);
s->insn_sadd.i=((insn>>13)&0x1);
s->insn_sadd.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_tsadd(unsigned int insn, insn_union *s) {
s->insn_tsadd.func=func_insn_tsadd;
s->insn_tsadd.rd=((insn>>25)&0x1f);
s->insn_tsadd.sa=((insn>>19)&0x1);
s->insn_tsadd.rs1=((insn>>14)&0x1f);
s->insn_tsadd.i=((insn>>13)&0x1);
s->insn_tsadd.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_tsaddtv(unsigned int insn, insn_union *s) {
s->insn_tsaddtv.func=func_insn_tsaddtv;
s->insn_tsaddtv.rd=((insn>>25)&0x1f);
s->insn_tsaddtv.sa=((insn>>19)&0x1);
s->insn_tsaddtv.rs1=((insn>>14)&0x1f);
s->insn_tsaddtv.i=((insn>>13)&0x1);
s->insn_tsaddtv.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_mulscc(unsigned int insn, insn_union *s) {
s->insn_mulscc.func=func_insn_mulscc;
s->insn_mulscc.rd=((insn>>25)&0x1f);
s->insn_mulscc.cc=((insn>>23)&0x1);
s->insn_mulscc.sig=((insn>>19)&0x1);
s->insn_mulscc.rs1=((insn>>14)&0x1f);
s->insn_mulscc.i=((insn>>13)&0x1);
s->insn_mulscc.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_divscc(unsigned int insn, insn_union *s) {
s->insn_divscc.func=func_insn_divscc;
s->insn_divscc.rd=((insn>>25)&0x1f);
s->insn_divscc.cc=((insn>>23)&0x1);
s->insn_divscc.sig=((insn>>19)&0x1);
s->insn_divscc.rs1=((insn>>14)&0x1f);
s->insn_divscc.i=((insn>>13)&0x1);
s->insn_divscc.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_sv(unsigned int insn, insn_union *s) {
s->insn_sv.func=func_insn_sv;
s->insn_sv.rd=((insn>>25)&0x1f);
s->insn_sv.rs1=((insn>>14)&0x1f);
s->insn_sv.i=((insn>>13)&0x1);
s->insn_sv.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_rest(unsigned int insn, insn_union *s) {
s->insn_rest.func=func_insn_rest;
s->insn_rest.rd=((insn>>25)&0x1f);
s->insn_rest.rs1=((insn>>14)&0x1f);
s->insn_rest.i=((insn>>13)&0x1);
s->insn_rest.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_bra(unsigned int insn, insn_union *s) {
s->insn_bra.func=func_insn_bra;
s->insn_bra.a=((insn>>29)&0x1);
s->insn_bra.c=((insn>>25)&0xf);
s->insn_bra.d22=((insn>>0)&0x3fffff);
 return 1;};
 unsigned int init_insn_fbra(unsigned int insn, insn_union *s) {
s->insn_fbra.func=func_insn_fbra;
s->insn_fbra.a=((insn>>29)&0x1);
s->insn_fbra.c=((insn>>25)&0xf);
s->insn_fbra.d22=((insn>>0)&0x3fffff);
 return 1;};
 unsigned int init_insn_cbra(unsigned int insn, insn_union *s) {
s->insn_cbra.func=func_insn_cbra;
s->insn_cbra.a=((insn>>29)&0x1);
s->insn_cbra.c=((insn>>25)&0xf);
s->insn_cbra.d22=((insn>>0)&0x3fffff);
 return 1;};
 unsigned int init_insn_jmp(unsigned int insn, insn_union *s) {
s->insn_jmp.func=func_insn_jmp;
s->insn_jmp.d30=((insn>>0)&0xffffffff);
 return 1;};
 unsigned int init_insn_jml(unsigned int insn, insn_union *s) {
s->insn_jml.func=func_insn_jml;
s->insn_jml.rd=((insn>>25)&0x1f);
s->insn_jml.rs1=((insn>>14)&0x1f);
s->insn_jml.i=((insn>>13)&0x1);
s->insn_jml.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_ret(unsigned int insn, insn_union *s) {
s->insn_ret.func=func_insn_ret;
s->insn_ret.rd=((insn>>25)&0x1f);
s->insn_ret.rs1=((insn>>14)&0x1f);
s->insn_ret.i=((insn>>13)&0x1);
s->insn_ret.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_trap(unsigned int insn, insn_union *s) {
s->insn_trap.func=func_insn_trap;
s->insn_trap.rvd=((insn>>29)&0x1);
s->insn_trap.c=((insn>>25)&0xf);
s->insn_trap.rs1=((insn>>14)&0x1f);
s->insn_trap.i=((insn>>13)&0x1);
s->insn_trap.s2i=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_rd(unsigned int insn, insn_union *s) {
s->insn_rd.func=func_insn_rd;
s->insn_rd.rd=((insn>>25)&0x1f);
s->insn_rd.rs1=((insn>>14)&0x1f);
s->insn_rd.x=((insn>>0)&0x3fff);
 return 1;};
 unsigned int init_insn_rdp(unsigned int insn, insn_union *s) {
s->insn_rdp.func=func_insn_rdp;
s->insn_rdp.rd=((insn>>25)&0x1f);
s->insn_rdp.rs1=((insn>>14)&0x1f);
s->insn_rdp.x=((insn>>0)&0x3fff);
 return 1;};
 unsigned int init_insn_rdw(unsigned int insn, insn_union *s) {
s->insn_rdw.func=func_insn_rdw;
s->insn_rdw.rd=((insn>>25)&0x1f);
s->insn_rdw.rs1=((insn>>14)&0x1f);
s->insn_rdw.x=((insn>>0)&0x3fff);
 return 1;};
 unsigned int init_insn_rdt(unsigned int insn, insn_union *s) {
s->insn_rdt.func=func_insn_rdt;
s->insn_rdt.rd=((insn>>25)&0x1f);
s->insn_rdt.rs1=((insn>>14)&0x1f);
s->insn_rdt.x=((insn>>0)&0x3fff);
 return 1;};
 unsigned int init_insn_wd(unsigned int insn, insn_union *s) {
s->insn_wd.func=func_insn_wd;
s->insn_wd.rd=((insn>>25)&0x1f);
s->insn_wd.rs1=((insn>>14)&0x1f);
s->insn_wd.x=((insn>>0)&0x3fff);
 return 1;};
 unsigned int init_insn_wdp(unsigned int insn, insn_union *s) {
s->insn_wdp.func=func_insn_wdp;
s->insn_wdp.rd=((insn>>25)&0x1f);
s->insn_wdp.rs1=((insn>>14)&0x1f);
s->insn_wdp.x=((insn>>0)&0x3fff);
 return 1;};
 unsigned int init_insn_wdw(unsigned int insn, insn_union *s) {
s->insn_wdw.func=func_insn_wdw;
s->insn_wdw.rd=((insn>>25)&0x1f);
s->insn_wdw.rs1=((insn>>14)&0x1f);
s->insn_wdw.x=((insn>>0)&0x3fff);
 return 1;};
 unsigned int init_insn_wdt(unsigned int insn, insn_union *s) {
s->insn_wdt.func=func_insn_wdt;
s->insn_wdt.rd=((insn>>25)&0x1f);
s->insn_wdt.rs1=((insn>>14)&0x1f);
s->insn_wdt.x=((insn>>0)&0x3fff);
 return 1;};
 unsigned int init_insn_stbar(unsigned int insn, insn_union *s) {
s->insn_stbar.func=func_insn_stbar;
s->insn_stbar.x=((insn>>0)&0x1fff);
 return 1;};
 unsigned int init_insn_unimp(unsigned int insn, insn_union *s) {
s->insn_unimp.func=func_insn_unimp;
s->insn_unimp.rvd=((insn>>25)&0x1f);
s->insn_unimp.cst=((insn>>0)&0x3fffff);
 return 1;};
 



unsigned int decode(unsigned int insn, insn_union *s) {
{
switch (((insn>>30)&0x3)) { 
case 0x0:
{
 {
 switch (((insn>>24)&0x1)) { 
 case 0x0:
 {
  {
  switch (((insn>>23)&0x1)) { 
  case 0x0:
  {
   {
   switch (((insn>>22)&0x1)) { 
   case 0x0:
   {return init_insn_unimp(insn,s);
   };break;
   }}
  };break;
  case 0x1:
  {
   {
   switch (((insn>>22)&0x1)) { 
   case 0x0:
   {return init_insn_bra(insn,s);
   };break;
   }}
  };break;
  }}
 };break;
 case 0x1:
 {
  {
  switch (((insn>>23)&0x1)) { 
  case 0x1:
  {
   {
   switch (((insn>>22)&0x1)) { 
   case 0x1:
   {return init_insn_cbra(insn,s);
   };break;
   case 0x0:
   {return init_insn_fbra(insn,s);
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
    switch (((insn>>25)&0x1f)) { 
    case 0x0:
    {return init_insn_nop(insn,s);
    };break;
    }}
    /*default:*/ return init_insn_sethi(insn,s);
   };break;
   }}
  };break;
  }}
 };break;
 }}
};break;
case 0x1:
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
   switch (((insn>>22)&0x1)) { 
   case 0x1:
   {
    {
    switch (((insn>>21)&0x1)) { 
    case 0x0:
    {
     {
     switch (((insn>>20)&0x1)) { 
     case 0x0:
     {
      {
      switch (((insn>>19)&0x1)) { 
      case 0x0:
      {
       {
       switch (((insn>>25)&0x1f)) { 
       case 0x0:
       {
        {
        switch (((insn>>13)&0x3f)) { 
        case 0x1e:
        {return init_insn_stbar(insn,s);
        };break;
        }}
       };break;
       }}
       /*default:*/ return init_insn_rd(insn,s);
      };break;
      case 0x1:
      {return init_insn_rdp(insn,s);
      };break;
      }}
     };break;
     case 0x1:
     {
      {
      switch (((insn>>19)&0x1)) { 
      case 0x1:
      {return init_insn_rdt(insn,s);
      };break;
      case 0x0:
      {return init_insn_rdw(insn,s);
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
    switch (((insn>>21)&0x1)) { 
    case 0x0:
    {
     {
     switch (((insn>>20)&0x1)) { 
     case 0x1:
     {return init_insn_tsaddtv(insn,s);
     };break;
     case 0x0:
     {return init_insn_tsadd(insn,s);
     };break;
     }}
    };break;
    case 0x1:
    {
     {
     switch (((insn>>20)&0x1)) { 
     case 0x1:
     {
      {
      switch (((insn>>19)&0x1)) { 
      case 0x1:
      {return init_insn_sra(insn,s);
      };break;
      case 0x0:
      {return init_insn_srl(insn,s);
      };break;
      }}
     };break;
     case 0x0:
     {
      {
      switch (((insn>>19)&0x1)) { 
      case 0x1:
      {return init_insn_sll(insn,s);
      };break;
      }}
     };break;
     }}
    };break;
    }}
   };break;
   }}
  };break;
  case 0x1:
  {
   {
   switch (((insn>>22)&0x1)) { 
   case 0x0:
   {
    {
    switch (((insn>>21)&0x1)) { 
    case 0x0:
    {
     {
     switch (((insn>>20)&0x1)) { 
     case 0x1:
     {
      {
      switch (((insn>>19)&0x1)) { 
      case 0x1:
      {return init_insn_wdt(insn,s);
      };break;
      case 0x0:
      {return init_insn_wdw(insn,s);
      };break;
      }}
     };break;
     case 0x0:
     {
      {
      switch (((insn>>19)&0x1)) { 
      case 0x1:
      {return init_insn_wdp(insn,s);
      };break;
      case 0x0:
      {return init_insn_wd(insn,s);
      };break;
      }}
     };break;
     }}
    };break;
    }}
   };break;
   case 0x1:
   {
    {
    switch (((insn>>21)&0x1)) { 
    case 0x0:
    {
     {
     switch (((insn>>20)&0x1)) { 
     case 0x1:
     {
      {
      switch (((insn>>19)&0x1)) { 
      case 0x0:
      {return init_insn_trap(insn,s);
      };break;
      }}
     };break;
     case 0x0:
     {
      {
      switch (((insn>>19)&0x1)) { 
      case 0x1:
      {return init_insn_ret(insn,s);
      };break;
      case 0x0:
      {return init_insn_jml(insn,s);
      };break;
      }}
     };break;
     }}
    };break;
    case 0x1:
    {
     {
     switch (((insn>>20)&0x1)) { 
     case 0x0:
     {
      {
      switch (((insn>>19)&0x1)) { 
      case 0x1:
      {return init_insn_rest(insn,s);
      };break;
      case 0x0:
      {return init_insn_sv(insn,s);
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
  switch (((insn>>20)&0x1)) { 
  case 0x1:
  {
   {
   switch (((insn>>22)&0x1)) { 
   case 0x1:
   {
    {
    switch (((insn>>21)&0x1)) { 
    case 0x1:
    {return init_insn_divscc(insn,s);
    };break;
    case 0x0:
    {return init_insn_mulscc(insn,s);
    };break;
    }}
   };break;
   case 0x0:
   {
    {
    switch (((insn>>19)&0x1)) { 
    case 0x1:
    {return init_insn_xor(insn,s);
    };break;
    case 0x0:
    {return init_insn_or(insn,s);
    };break;
    }}
   };break;
   }}
  };break;
  case 0x0:
  {
   {
   switch (((insn>>19)&0x1)) { 
   case 0x0:
   {return init_insn_sadd(insn,s);
   };break;
   case 0x1:
   {
    {
    switch (((insn>>22)&0x1)) { 
    case 0x0:
    {return init_insn_and(insn,s);
    };break;
    }}
   };break;
   }}
  };break;
  }}
 };break;
 }}
};break;
case 0x2:
{return init_insn_jmp(insn,s);
};break;
case 0x3:
{
 {
 switch (((insn>>24)&0x1)) { 
 case 0x0:
 {
  {
  switch (((insn>>22)&0x1)) { 
  case 0x1:
  {
   {
   switch (((insn>>21)&0x1)) { 
   case 0x1:
   {
    {
    switch (((insn>>20)&0x1)) { 
    case 0x1:
    {
     {
     switch (((insn>>19)&0x1)) { 
     case 0x1:
     {return init_insn_swp(insn,s);
     };break;
     }}
    };break;
    case 0x0:
    {
     {
     switch (((insn>>19)&0x1)) { 
     case 0x1:
     {return init_insn_ldstb(insn,s);
     };break;
     }}
    };break;
    }}
   };break;
   case 0x0:
   {
    {
    switch (((insn>>20)&0x1)) { 
    case 0x1:
    {
     {
     switch (((insn>>19)&0x1)) { 
     case 0x0:
     {return init_insn_ldsh(insn,s);
     };break;
     }}
    };break;
    case 0x0:
    {
     {
     switch (((insn>>19)&0x1)) { 
     case 0x1:
     {return init_insn_ldsb(insn,s);
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
   switch (((insn>>20)&0x1)) { 
   case 0x1:
   {
    {
    switch (((insn>>19)&0x1)) { 
    case 0x1:
    {return init_insn_ldst_d(insn,s);
    };break;
    case 0x0:
    {return init_insn_ldst_uh(insn,s);
    };break;
    }}
   };break;
   case 0x0:
   {
    {
    switch (((insn>>19)&0x1)) { 
    case 0x0:
    {return init_insn_ldst(insn,s);
    };break;
    case 0x1:
    {return init_insn_ldst_ub(insn,s);
    };break;
    }}
   };break;
   }}
  };break;
  }}
 };break;
 case 0x1:
 {
  {
  switch (((insn>>23)&0x1)) { 
  case 0x1:
  {
   {
   switch (((insn>>22)&0x1)) { 
   case 0x0:
   {
    {
    switch (((insn>>20)&0x1)) { 
    case 0x1:
    {
     {
     switch (((insn>>19)&0x1)) { 
     case 0x1:
     {
      {
      switch (((insn>>21)&0x1)) { 
      case 0x1:
      {return init_insn_stdcq(insn,s);
      };break;
      }}
      /*default:*/ return init_insn_ldst_dc(insn,s);
     };break;
     }}
    };break;
    case 0x0:
    {
     {
     switch (((insn>>19)&0x1)) { 
     case 0x1:
     {return init_insn_ldst_csr(insn,s);
     };break;
     case 0x0:
     {return init_insn_ldst_c(insn,s);
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
   switch (((insn>>22)&0x1)) { 
   case 0x0:
   {
    {
    switch (((insn>>20)&0x1)) { 
    case 0x1:
    {
     {
     switch (((insn>>19)&0x1)) { 
     case 0x0:
     {
      {
      switch (((insn>>21)&0x1)) { 
      case 0x1:
      {return init_insn_stdfq(insn,s);
      };break;
      }}
     };break;
     case 0x1:
     {return init_insn_ldst_df(insn,s);
     };break;
     }}
    };break;
    case 0x0:
    {
     {
     switch (((insn>>19)&0x1)) { 
     case 0x1:
     {return init_insn_ldst_fsr(insn,s);
     };break;
     case 0x0:
     {return init_insn_ldst_f(insn,s);
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

return 0;
};

