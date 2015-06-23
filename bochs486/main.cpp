#include <cstdio>
#include <cstdlib>

#include "bochs.h"
#include "cpu.h"
#include "iodev/iodev.h"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

int test_type;

bool load_segment(bx_segment_reg_t *seg, const char *prefix, char *name, unsigned long long value) {
    
    if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "cache_valid:") == 0) { seg->cache.valid = value & 1; }
    
    else if( (strncmp(name, "cs:", 3) == 0   && strcmp(prefix, "cs_") == 0) ||
             (strncmp(name, "ds:", 3) == 0   && strcmp(prefix, "ds_") == 0) ||
             (strncmp(name, "es:", 3) == 0   && strcmp(prefix, "es_") == 0) ||
             (strncmp(name, "fs:", 3) == 0   && strcmp(prefix, "fs_") == 0) ||
             (strncmp(name, "gs:", 3) == 0   && strcmp(prefix, "gs_") == 0) ||
             (strncmp(name, "ss:", 3) == 0   && strcmp(prefix, "ss_") == 0) ||
             (strncmp(name, "ldtr:", 5) == 0 && strcmp(prefix, "ldtr_") == 0) ||
             (strncmp(name, "tr:", 3) == 0   && strcmp(prefix, "tr_") == 0) )
    {
        seg->selector.value = value & 0xFFFF;
        seg->selector.index = value >> 3;
        seg->selector.ti    = (value >> 2) & 1;
        seg->selector.rpl   = value & 3;
    }
    else if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "rpl:") == 0)   { seg->selector.rpl = value & 3; }
    else if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "base:") == 0)  { seg->cache.u.segment.base = value & 0xFFFFFFFF; }
    else if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "limit:") == 0) {
        seg->cache.u.segment.limit_scaled = value & 0xFFFFF;
        if(seg->cache.u.segment.g) seg->cache.u.segment.limit_scaled = (seg->cache.u.segment.limit_scaled << 12) | 0xFFF;
    }
    else if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "g:") == 0) {
        seg->cache.u.segment.g = value & 1;
        if(seg->cache.u.segment.g) seg->cache.u.segment.limit_scaled = (seg->cache.u.segment.limit_scaled << 12) | 0xFFF;
    }
    else if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "d_b:")  == 0)  { seg->cache.u.segment.d_b = value & 1; }
    else if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "avl:")  == 0)  { seg->cache.u.segment.avl = value & 1; }
    else if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "p:")    == 0)  { seg->cache.p             = value & 1; }
    else if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "dpl:")  == 0)  { seg->cache.dpl           = value & 3; }
    else if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "s:")    == 0)  { seg->cache.segment       = value & 1; }
    else if(strncmp(name, prefix, strlen(prefix)) == 0 && strcmp(name+strlen(prefix), "type:") == 0)  { seg->cache.type          = value & 15; }
    else return false;
    
    return true;
}
    
void initialize() {
    printf("start_input: 0\n");
    printf("\n");
    fflush(stdout);
    
    bool do_loop = true;
    
    char name[256];
    unsigned long long value;
    
    while(do_loop) {
    
        fscanf(stdin, "%s", name);
        fscanf(stdin, "%x", &value);

        if     (strcmp(name, "quit:") == 0)      { exit(0); }
        else if(strcmp(name, "continue:") == 0)  { do_loop = false; }
        
        else if(strcmp(name, "test_type:") == 0) { test_type = value; }
        
        else if(strcmp(name, "eax:") == 0)       { bx_cpu.set_reg32(BX_32BIT_REG_EAX, value); }
        else if(strcmp(name, "ebx:") == 0)       { bx_cpu.set_reg32(BX_32BIT_REG_EBX, value); }
        else if(strcmp(name, "ecx:") == 0)       { bx_cpu.set_reg32(BX_32BIT_REG_ECX, value); }
        else if(strcmp(name, "edx:") == 0)       { bx_cpu.set_reg32(BX_32BIT_REG_EDX, value); }
        else if(strcmp(name, "esi:") == 0)       { bx_cpu.set_reg32(BX_32BIT_REG_ESI, value); }
        else if(strcmp(name, "edi:") == 0)       { bx_cpu.set_reg32(BX_32BIT_REG_EDI, value); }
        else if(strcmp(name, "ebp:") == 0)       { bx_cpu.set_reg32(BX_32BIT_REG_EBP, value); }
        else if(strcmp(name, "esp:") == 0)       { bx_cpu.set_reg32(BX_32BIT_REG_ESP, value); }
        
        else if(strcmp(name, "eip:") == 0)       { bx_cpu.gen_reg[BX_32BIT_REG_EIP].dword.erx = value; }
        
        else if(strcmp(name, "cflag:") == 0)     { bx_cpu.set_CF(value); }
        else if(strcmp(name, "pflag:") == 0)     { bx_cpu.set_PF(value); }
        else if(strcmp(name, "aflag:") == 0)     { bx_cpu.set_AF(value); }
        else if(strcmp(name, "zflag:") == 0)     { bx_cpu.set_ZF(value); }
        else if(strcmp(name, "sflag:") == 0)     { bx_cpu.set_SF(value); }
        else if(strcmp(name, "tflag:") == 0)     { bx_cpu.set_TF(value); }
        else if(strcmp(name, "iflag:") == 0)     { bx_cpu.set_IF(value); }
        else if(strcmp(name, "dflag:") == 0)     { bx_cpu.set_DF(value); }
        else if(strcmp(name, "oflag:") == 0)     { bx_cpu.set_OF(value); }
        else if(strcmp(name, "iopl:") == 0)      { bx_cpu.set_IOPL(value); }
        else if(strcmp(name, "ntflag:") == 0)    { bx_cpu.set_NT(value); }
        else if(strcmp(name, "rflag:") == 0)     { bx_cpu.set_RF(value); }
        else if(strcmp(name, "vmflag:") == 0)    { bx_cpu.set_VM(value); }
        else if(strcmp(name, "acflag:") == 0)    { bx_cpu.set_AC(value); }
        else if(strcmp(name, "idflag:") == 0)    { bx_cpu.set_ID(value); }
        
        else if(load_segment(&(bx_cpu.sregs[BX_SEG_REG_CS]), "cs_", name, value)) { }
        else if(load_segment(&(bx_cpu.sregs[BX_SEG_REG_DS]), "ds_", name, value)) { }
        else if(load_segment(&(bx_cpu.sregs[BX_SEG_REG_ES]), "es_", name, value)) { }
        else if(load_segment(&(bx_cpu.sregs[BX_SEG_REG_FS]), "fs_", name, value)) { }
        else if(load_segment(&(bx_cpu.sregs[BX_SEG_REG_GS]), "gs_", name, value)) { }
        else if(load_segment(&(bx_cpu.sregs[BX_SEG_REG_SS]), "ss_", name, value)) { }
        else if(load_segment(&(bx_cpu.ldtr), "ldtr_", name, value)) { }
        else if(load_segment(&(bx_cpu.tr),   "tr_",   name, value)) { }
        
        else if(strcmp(name, "gdtr_base:") == 0) { bx_cpu.gdtr.base  = value & 0xFFFFFFFF; }
        else if(strcmp(name, "gdtr_limit:") == 0){ bx_cpu.gdtr.limit = value & 0xFFFF; }
        
        else if(strcmp(name, "idtr_base:") == 0) { bx_cpu.idtr.base  = value & 0xFFFFFFFF; }
        else if(strcmp(name, "idtr_limit:") == 0){ bx_cpu.idtr.limit = value & 0xFFFF; }
        
        else if(strcmp(name, "cr0_pe:") == 0) { bx_cpu.cr0.set_PE(value & 1); }
        else if(strcmp(name, "cr0_mp:") == 0) { bx_cpu.cr0.set_MP(value & 1); }
        else if(strcmp(name, "cr0_em:") == 0) { bx_cpu.cr0.set_EM(value & 1); }
        else if(strcmp(name, "cr0_ts:") == 0) { bx_cpu.cr0.set_TS(value & 1); }
        else if(strcmp(name, "cr0_ne:") == 0) { bx_cpu.cr0.set_NE(value & 1); }
        else if(strcmp(name, "cr0_wp:") == 0) { bx_cpu.cr0.set_WP(value & 1); }
        else if(strcmp(name, "cr0_am:") == 0) { bx_cpu.cr0.set_AM(value & 1); }
        else if(strcmp(name, "cr0_nw:") == 0) { bx_cpu.cr0.set_NW(value & 1); }
        else if(strcmp(name, "cr0_cd:") == 0) { bx_cpu.cr0.set_CD(value & 1); }
        else if(strcmp(name, "cr0_pg:") == 0) { bx_cpu.cr0.set_PG(value & 1); }
        
        else if(strcmp(name, "cr2:") == 0)    { bx_cpu.cr2 = value & 0xFFFFFFFF; }
        else if(strcmp(name, "cr3:") == 0)    { bx_cpu.cr3 = value & 0xFFFFFFFF; }
        
        else if(strcmp(name, "dr0:") == 0)    { bx_cpu.dr[0] = value & 0xFFFFFFFF; }
        else if(strcmp(name, "dr1:") == 0)    { bx_cpu.dr[1] = value & 0xFFFFFFFF; }
        else if(strcmp(name, "dr2:") == 0)    { bx_cpu.dr[2] = value & 0xFFFFFFFF; }
        else if(strcmp(name, "dr3:") == 0)    { bx_cpu.dr[3] = value & 0xFFFFFFFF; }
        
        else if(strcmp(name, "dr6:") == 0)    { bx_cpu.dr6.val32 = (bx_cpu.dr6.val32 & 0xffff0ff0) | (value & 0x0000f00f); }
        else if(strcmp(name, "dr7:") == 0)    { bx_cpu.dr7.val32 = value | 0x00000400; }
        
        else {
            printf("#bochs486: unknown input: %s %x\n", name, value);
            exit(-1);
        }
    }
}

void print_segment(bx_segment_reg_t *seg, const char *prefix) {
    
    printf("%s_cache_valid: %01x\n",   prefix, seg->cache.valid & 1);
    printf("%s:             %04x\n",   prefix, seg->selector.value);
    printf("%s_rpl:         %01hhx\n", prefix, seg->selector.rpl);
    
    printf("%s_base:        %08x\n",   prefix, seg->cache.u.segment.base);
    printf("%s_limit:       %08x\n",   prefix, (seg->cache.u.segment.g)? seg->cache.u.segment.limit_scaled >> 12 : seg->cache.u.segment.limit_scaled);
    printf("%s_g:           %01x\n",   prefix, seg->cache.u.segment.g);
    printf("%s_d_b:         %01x\n",   prefix, seg->cache.u.segment.d_b);
    printf("%s_avl:         %01x\n",   prefix, seg->cache.u.segment.avl);
    printf("%s_p:           %01x\n",   prefix, seg->cache.p);
    printf("%s_dpl:         %01x\n",   prefix, seg->cache.dpl);
    printf("%s_s:           %01x\n",   prefix, seg->cache.segment);
    printf("%s_type:        %01x\n",   prefix, seg->cache.type);
}

void output_cpu_state() {
    printf("start_output: 0\n");
    
    //used only in verilog testbench
    printf("tb_wr_cmd_last: 0\n");
    printf("tb_can_ignore:  0\n");
    
    printf("eax: %08x\n", bx_cpu.get_reg32(BX_32BIT_REG_EAX));
    printf("ebx: %08x\n", bx_cpu.get_reg32(BX_32BIT_REG_EBX));
    printf("ecx: %08x\n", bx_cpu.get_reg32(BX_32BIT_REG_ECX));
    printf("edx: %08x\n", bx_cpu.get_reg32(BX_32BIT_REG_EDX));
    printf("esi: %08x\n", bx_cpu.get_reg32(BX_32BIT_REG_ESI));
    printf("edi: %08x\n", bx_cpu.get_reg32(BX_32BIT_REG_EDI));
    printf("ebp: %08x\n", bx_cpu.get_reg32(BX_32BIT_REG_EBP));
    printf("esp: %08x\n", bx_cpu.get_reg32(BX_32BIT_REG_ESP));
    
    printf("eip: %08x\n", bx_cpu.gen_reg[BX_32BIT_REG_EIP].dword.erx);
    
    printf("cflag:  %01x\n", bx_cpu.getB_CF());
    printf("pflag:  %01x\n", bx_cpu.getB_PF());
    printf("aflag:  %01x\n", bx_cpu.getB_AF());
    printf("zflag:  %01x\n", bx_cpu.getB_ZF());
    printf("sflag:  %01x\n", bx_cpu.getB_SF());
    printf("tflag:  %01x\n", bx_cpu.getB_TF()&1);
    printf("iflag:  %01x\n", bx_cpu.getB_IF()&1);
    printf("dflag:  %01x\n", bx_cpu.getB_DF()&1);
    printf("oflag:  %01x\n", bx_cpu.getB_OF()&1);
    printf("iopl:   %01x\n", bx_cpu.get_IOPL()&3);
    printf("ntflag: %01x\n", bx_cpu.getB_NT()&1);
    printf("rflag:  %01x\n", bx_cpu.getB_RF()&1);
    printf("vmflag: %01x\n", bx_cpu.getB_VM()&1);
    printf("acflag: %01x\n", bx_cpu.getB_AC()&1);
    printf("idflag: %01x\n", bx_cpu.getB_ID()&1);
    
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_CS]), "cs");
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_DS]), "ds");
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_ES]), "es");
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_FS]), "fs");
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_GS]), "gs");
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_SS]), "ss");
    print_segment(&(bx_cpu.ldtr), "ldtr");
    print_segment(&(bx_cpu.tr),   "tr");
    
    printf("gdtr_base:  %08x\n", bx_cpu.gdtr.base);
    printf("gdtr_limit: %02x\n", bx_cpu.gdtr.limit & 0xFFFF);
    
    printf("idtr_base:  %08x\n", bx_cpu.idtr.base);
    printf("idtr_limit: %02x\n", bx_cpu.idtr.limit & 0xFFFF);
    
    printf("cr0_pe: %01x\n", bx_cpu.cr0.get_PE() & 1);
    printf("cr0_mp: %01x\n", bx_cpu.cr0.get_MP() & 1);
    printf("cr0_em: %01x\n", bx_cpu.cr0.get_EM() & 1);
    printf("cr0_ts: %01x\n", bx_cpu.cr0.get_TS() & 1);
    printf("cr0_ne: %01x\n", bx_cpu.cr0.get_NE() & 1);
    printf("cr0_wp: %01x\n", bx_cpu.cr0.get_WP() & 1);
    printf("cr0_am: %01x\n", bx_cpu.cr0.get_AM() & 1);
    printf("cr0_nw: %01x\n", bx_cpu.cr0.get_NW() & 1);
    printf("cr0_cd: %01x\n", bx_cpu.cr0.get_CD() & 1);
    printf("cr0_pg: %01x\n", bx_cpu.cr0.get_PG() & 1);
    
    printf("cr2: %08x\n", bx_cpu.cr2);
    printf("cr3: %08x\n", bx_cpu.cr3);
    
    printf("dr0: %08x\n", bx_cpu.dr[0]);
    printf("dr1: %08x\n", bx_cpu.dr[1]);
    printf("dr2: %08x\n", bx_cpu.dr[2]);
    printf("dr3: %08x\n", bx_cpu.dr[3]);
    
    printf("dr6: %08x\n", bx_cpu.dr6.val32);
    printf("dr7: %08x\n", bx_cpu.dr7.val32);
    
    printf("\n");
    fflush(stdout);
}


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ logfunctions

void logfunctions::panic(const char *fmt, ...) {
    printf("#bochs486::logfunctions::panic(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);
    
    printf("\n");
    fflush(stdout);
    
    if(strstr(fmt, "exception with no resolution") != NULL) {
        printf("start_shutdown: 0\n");
        printf("\n");
        fflush(stdout);
        exit(0);
    }
    else {
        exit(-1);
    }
}
void logfunctions::error(const char *fmt, ...) {
    printf("#bochs486::logfunctions::error(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);
    
    printf("\n");
    fflush(stdout);
}
void logfunctions::ldebug(const char *fmt, ...) {
    printf("#bochs486::logfunctions::debug(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);   
    
    printf("\n");
    fflush(stdout);
}
void logfunctions::info(const char *fmt, ...) {
    printf("#bochs486::logfunctions::info(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);   
    
    printf("\n");
    fflush(stdout);
}
void logfunctions::put(const char *n, const char *p) {
}
logfunctions::logfunctions() {
}
logfunctions::~logfunctions() {
}

static logfunctions theLog;
logfunctions *pluginlog         = &theLog;
logfunctions *siminterface_log  = &theLog;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ menu

void bx_param_string_c::text_print(FILE *fp) {
printf("#bochs486::bx_param_string_c::text_print()\n");
}
void bx_param_enum_c::text_print(FILE *fp) {
printf("#bochs486::bx_param_enum_c::text_print()\n");
}
void bx_param_bool_c::text_print(FILE *fp) {
printf("#bochs486::bx_param_bool_c::text_print()\n");
}
void bx_param_num_c::text_print(FILE *fp) {
printf("#bochs486::bx_param_num_c::text_print()\n");
}
void bx_list_c::text_print(FILE *fp) {
printf("#bochs486::bx_list_c::text_print()\n");
}
int bx_param_enum_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486::bx_param_enum_c::text_ask()\n");
    return 0;
}
int bx_param_bool_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486::bx_param_bool_c::text_ask()\n");
    return 0;
}
int bx_param_num_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486::bx_param_num_c::text_ask()\n");
    return 0;
}
int bx_param_string_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486::bx_param_string_c::text_ask()\n");
    return 0;
}
int bx_list_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486::bx_list_c::text_ask()\n");
    return 0;
}

bx_list_c *root_param = NULL;

bx_gui_c *bx_gui = NULL;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ cpu

void BX_CPU_C::enter_system_management_mode(void) {
printf("#bochs486: enter_system_management_mod()\n");
}
void BX_CPU_C::init_SMRAM(void) {
printf("#bochs486: init_SMRAM()\n");
}
void BX_CPU_C::debug(bx_address offset) {
printf("#bochs486: debug(offset=%08x)\n", offset);
}
void BX_CPU_C::debug_disasm_instruction(bx_address offset) {
printf("#bochs486: debug_disasm_instruction(offset=%08x)\n", offset);
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ pc_system

void bx_pc_system_c::countdownEvent(void) {
}
bx_pc_system_c::bx_pc_system_c() {
}
int bx_pc_system_c::Reset(unsigned type) {
    printf("#bochs486: bx_pc_system_c::Reset(%d) unimplemented.\n", type);
    std::exit(-1);
}

bx_pc_system_c bx_pc_system;

const char* cpu_mode_string(unsigned cpu_mode) {
  static const char *cpu_mode_name[] = {
     "real mode",
     "v8086 mode",
     "protected mode",
     "compatibility mode",
     "long mode",
     "unknown mode"
  };

  if(cpu_mode >= 5) cpu_mode = 5;
  return cpu_mode_name[cpu_mode];
}

bx_param_string_c        *param_vendor_string;
bx_param_string_c        *param_brand_string;
bx_param_bool_c          *param_bool_false;
bx_param_enum_c          *param_enum_zero;
bx_param_num_c           *param_stepping, *param_model, *param_family;
bx_param_num_c           *param_cpulevel_for_cpuid;

class bochs486_sim : public bx_simulator_interface_c {

    bx_param_bool_c *get_param_bool(const char *pname, bx_param_c *base) {
        if(strcmp(pname, BXPN_CPUID_LIMIT_WINNT) == 0)      return param_bool_false;
        if(strcmp(pname, BXPN_CPUID_SSE4A) == 0)            return param_bool_false;
        if(strcmp(pname, BXPN_CPUID_SEP) == 0)              return param_bool_false;
        if(strcmp(pname, BXPN_CPUID_XSAVE) == 0)            return param_bool_false;
        if(strcmp(pname, BXPN_CPUID_XSAVEOPT) == 0)         return param_bool_false;
        if(strcmp(pname, BXPN_CPUID_AES) == 0)              return param_bool_false;
        if(strcmp(pname, BXPN_CPUID_MOVBE) == 0)            return param_bool_false;
        if(strcmp(pname, BXPN_CPUID_SMEP) == 0)             return param_bool_false;
        if(strcmp(pname, BXPN_RESET_ON_TRIPLE_FAULT) == 0)  return param_bool_false;
        return NULL;
    }
    bx_param_string_c *get_param_string(const char *pname, bx_param_c *base) {
        if(strcmp(pname, BXPN_VENDOR_STRING) == 0) return param_vendor_string;
        if(strcmp(pname, BXPN_BRAND_STRING) == 0)  return param_brand_string;
        return NULL;
    }
    bx_param_enum_c *get_param_enum(const char *pname, bx_param_c *base) {
        if(strcmp(pname, BXPN_CPU_MODEL) == 0)  return param_enum_zero;
        if(strcmp(pname, BXPN_CPUID_SSE) == 0)  return param_enum_zero;
        return NULL;
    }
    bx_param_num_c *get_param_num(const char *pname, bx_param_c *base) {
        if(strcmp(pname, BXPN_CPUID_STEPPING) == 0)  return param_stepping;
        if(strcmp(pname, BXPN_CPUID_MODEL) == 0)     return param_model;
        if(strcmp(pname, BXPN_CPUID_FAMILY) == 0)    return param_family;
        if(strcmp(pname, BXPN_CPUID_LEVEL) == 0)     return param_cpulevel_for_cpuid;
        return NULL;
    }
};

bx_simulator_interface_c *SIM;

BOCHSAPI BX_CPU_C bx_cpu;
int interrupt_vector;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ devices

class bochs486_pic : public bx_pic_stub_c {
    Bit8u IAC(void) { bx_cpu.clear_INTR(); return interrupt_vector & 0xFF; }
    
};

  Bit32u BX_CPP_AttrRegparmN(2)
bx_devices_c::inp(Bit16u addr, unsigned io_len) {
    // read aligned to 4 bytes, with byteena
    
    bool two_reads = (addr & 0x3) + io_len > 4;
    
    Bit16u   addr1    = addr & 0xFFFC;
    unsigned byteena1 = (io_len == 1)? 0x1 : (io_len == 2)? 0x3 : (io_len == 3)? 0x7 : 0xF;
    byteena1 = ((addr & 0x3) == 0)? byteena1 : ((addr & 0x3) == 1)? byteena1 << 1 : ((addr & 0x3) == 2)? byteena1 << 2 : byteena1 << 3;
    
    Bit16u   addr2    = (addr + 4) & 0xFFFC;
    unsigned byteena2 = (byteena1 >> 4) & 0xF;
    
    printf("start_io_read: 0\n");
    printf("address: %04hx\n", addr1);
    printf("byteena: %02x\n",  byteena1 & 0xF);
    printf("can_ignore: 0\n");
    printf("\n");
    fflush(stdout);
    
    unsigned int data1 = 0;
    fscanf(stdin, "%x", &data1);
    
    unsigned long long data = data1;
    
    if(two_reads) {
        printf("start_io_read: 0\n");
        printf("address: %04hx\n", addr2);
        printf("byteena: %02x\n",  byteena2);
        printf("can_ignore: 0\n");
        printf("\n");
        fflush(stdout);
        
        unsigned int data2 = 0;
        fscanf(stdin, "%x", &data2);
        
        data = ((unsigned long long)data2 << 32) | data1;
    }
    
    while((byteena1 & 1) == 0) {
        byteena1 >>= 1;
        data >>= 8;
    }
    
    return (io_len == 1)? (data & 0xFF) : (io_len == 2)? (data & 0xFFFF) : (io_len == 3)? (data & 0xFFFFFF) : (data & 0xFFFFFFFF);
    
}

  void BX_CPP_AttrRegparmN(3)
bx_devices_c::outp(Bit16u addr, Bit32u value, unsigned io_len) {
    // write aligned to 4 bytes, with byteena
    
    bool two_writes = (addr & 0x3) + io_len > 4;
    
    Bit16u   addr1    = addr & 0xFFFC;
    unsigned byteena1 = (io_len == 1)? 0x1 : (io_len == 2)? 0x3 : (io_len == 3)? 0x7 : 0xF;
    byteena1 = ((addr & 0x3) == 0)? byteena1 : ((addr & 0x3) == 1)? byteena1 << 1 : ((addr & 0x3) == 2)? byteena1 << 2 : byteena1 << 3;
    
    Bit16u   addr2    = (addr + 4) & 0xFFFC;
    unsigned byteena2 = (byteena1 >> 4) & 0xF;
    
    Bit64u value_full = ((addr & 0x3) == 0)? (Bit64u)value : ((addr & 0x3) == 1)? ((Bit64u)value << 8) : ((addr & 0x3) == 2)? ((Bit64u)value << 16) : ((Bit64u)value << 24);
    Bit32u value1 = value_full;
    Bit32u value2   = (value_full >> 32);
    
    printf("start_io_write: 0\n");
    printf("address: %04hx\n", addr1);
    printf("data:    %08x\n",  value1);
    printf("byteena: %02x\n",  byteena1 & 0xF);
    printf("can_ignore: 0\n");
    
    printf("\n");
    fflush(stdout);
    
    if(two_writes) {
        printf("start_io_write: 0\n");
        printf("address: %04hx\n", addr2);
        printf("data:    %08x\n",  value2);
        printf("byteena: %02x\n",  byteena2);
        printf("can_ignore: 0\n");
        
        printf("\n");
        fflush(stdout);
    }    
}
bx_devices_c::bx_devices_c() {
    pluginPicDevice = new bochs486_pic();
}
bx_devices_c::~bx_devices_c() {
}

bx_devices_c bx_devices;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ memory

struct bochs486_page_t {
    Bit8u page_buf[4096*2];
    Bit8u *page;
    bx_phy_address paddr;
    struct bochs486_page_t *next;
};
struct bochs486_page_t *bochs486_pages = NULL;

void BX_MEM_C::writePhysicalPage(BX_CPU_C *cpu, bx_phy_address addr, unsigned len, void *data) {
printf("#bochs486: writePhysicalPage: addr=%08x, len=%d\n", addr, len);
    
    if(len > 4) {
        printf("#bochs486: writePhysicalPage() with len = %d\n", len);
        exit(-1);
    }
    
    bool two_writes = (addr & 0x3) + len > 4;
    
    Bit32u   addr1    = addr & 0xFFFFFFFC;
    unsigned byteena1 = (len == 1)? 0x1 : (len == 2)? 0x3 : (len == 3)? 0x7 : 0xF;
    byteena1 = ((addr & 0x3) == 0)? byteena1 : ((addr & 0x3) == 1)? byteena1 << 1 : ((addr & 0x3) == 2)? byteena1 << 2 : byteena1 << 3;
    
    Bit32u   addr2    = (addr + 4) & 0xFFFFFFFC;
    unsigned byteena2 = (byteena1 >> 4) & 0xF;
    
    Bit32u value = ((unsigned int *)data)[0];
    
    Bit64u value_full = ((addr & 0x3) == 0)? (Bit64u)value : ((addr & 0x3) == 1)? ((Bit64u)value << 8) : ((addr & 0x3) == 2)? ((Bit64u)value << 16) : ((Bit64u)value << 24);
    Bit32u value1 = value_full;
    Bit32u value2   = (value_full >> 32);
    
    printf("start_write: 0\n");
    printf("address: %08x\n",  addr1);
    printf("data:    %08x\n",  value1);
    printf("byteena: %02x\n",  byteena1 & 0xF);
    printf("can_ignore: 0\n");
    
    printf("\n");
    fflush(stdout);
    
    if(two_writes) {
        printf("start_write: 0\n");
        printf("address: %08x\n",  addr2);
        printf("data:    %08x\n",  value2);
        printf("byteena: %02x\n",  byteena2);
        printf("can_ignore: 0\n");
        
        printf("\n");
        fflush(stdout);
    }    
    
    //update host memory pages
    unsigned char *ptr = (unsigned char *)data;
    
    struct bochs486_page_t *page_ptr = bochs486_pages;
    while(page_ptr != NULL) {
        if(page_ptr->paddr == (addr & 0xFFFFF000) && page_ptr->page != NULL) {
            for(int i=0; i<len; i++) page_ptr->page[(addr & 0xFFF) + i] = ptr[i];
        }
        page_ptr = page_ptr->next;
    }
}

void BX_MEM_C::readPhysicalPage(BX_CPU_C *cpu, bx_phy_address addr, unsigned len, void *data) {
printf("#bochs486: readPhysicalPage: addr=%08x, len=%d\n", addr, len);
    
    if(len == 4096) {
        if((addr & 3) != 0) {
            printf("#bochs486: readPhysicalPage() with len = 4096 and addr not aligned to 4.");
            exit(-1);
        }
        
        unsigned int *ptr = (unsigned int*)data;
        
        for(unsigned i=0; i<len; i+=4) {
            printf("start_read_code: 0\n");
            printf("address: %08x\n", addr);
            printf("byteena: F\n");
            printf("\n");
            fflush(stdout);

            fscanf(stdin, "%x", &(ptr[i/4]));
            
            addr += 4;
        }
        return;
    }
    
    //check if read crosses line boundry (16 bytes)
    if( ((addr) & 0xFFFFFFF0) != ((addr + len - 1) & 0xFFFFFFF0) ) {
        unsigned char *ptr = (unsigned char*)data;
        readPhysicalPage(cpu, addr,             (addr | 0xF) - addr + 1,       ptr);
        readPhysicalPage(cpu, (addr | 0xF) + 1, len - (addr | 0xF) + addr - 1, ptr + ((addr | 0xF) - addr + 1));
        return;
    }
    
    bool two_reads   = ((addr & 0x3) + len > 4) && ((addr & 0x3) + len <= 8);
    bool three_reads = ((addr & 0x3) + len > 8);
    
    Bit32u   addr1    = addr & 0xFFFFFFFC;
    unsigned byteena1 = (len == 1)? 0x1 : (len == 2)? 0x3 : (len == 3)? 0x7 : 0xF;
    byteena1 = ((addr & 0x3) == 0)? byteena1 : ((addr & 0x3) == 1)? byteena1 << 1 : ((addr & 0x3) == 2)? byteena1 << 2 : byteena1 << 3;
    
    Bit32u   addr2    = (addr + 4) & 0xFFFFFFFC;
    Bit32u   addr3    = (addr + 8) & 0xFFFFFFFC;
    
    if(two_reads || three_reads) byteena1 = 0xF;
    byteena1 &= 0xF;
    printf("start_read: 0\n");
    printf("address: %08x\n", addr1);
    printf("byteena: %02x\n", byteena1);
    printf("can_ignore: 0\n");
    
    printf("\n");
    fflush(stdout);
    
    unsigned int data_read[3] = { 0,0,0 };
    fscanf(stdin, "%x", &data_read[0]);
    
    if(two_reads || three_reads) {
        printf("start_read: 0\n");
        printf("address: %08x\n", addr2);
        printf("byteena: F\n");
        printf("can_ignore: 0\n");
    
        printf("\n");
        fflush(stdout);
        
        unsigned int data2 = 0;
        fscanf(stdin, "%x", &data_read[1]);
        
        if(three_reads) {
            printf("start_read: 0\n");
            printf("address: %08x\n", addr3);
            printf("byteena: F\n");
            printf("can_ignore: 0\n");
    
            printf("\n");
            fflush(stdout);
            
            unsigned int data3 = 0;
            fscanf(stdin, "%x", &data_read[2]);
        }
    }
    
    unsigned char *ptr = (unsigned char *)data_read;
    
    for(int i=0; i<(addr & 0x3); i++) ptr++;
    
    memcpy((unsigned char *)data, ptr, len);
    
//ptr = (unsigned char *)data;
//for(int i=0; i<len; i++) printf("#R[%d]: %hhx\n", i, ptr[i]);
}

Bit8u *BX_MEM_C::getHostMemAddr(BX_CPU_C *cpu, bx_phy_address addr, unsigned rw) {
printf("#bochs486: getHostMemAddr: addr=%08x, rw=%d\n", addr, rw);

    // find page
    struct bochs486_page_t *ptr = bochs486_pages;
    
    while(ptr != NULL) {
        if(ptr->paddr == addr) {
printf("#bochs486: getHostMemAddr: hostPtr[old]: %p\n", ptr->page);
            return ptr->page;
        }
        
        if(ptr->next != NULL) ptr = ptr->next;
        else break;
    }
    
    // create new page
    struct bochs486_page_t *new_page = new struct bochs486_page_t();
    new_page->paddr = addr;
    new_page->next = NULL;
    
    // find address at 4096 boundry
    new_page->page = new_page->page_buf;
    while( ( ((unsigned long long)new_page->page) % 4096) != 0 ) new_page->page++;
    
    readPhysicalPage(cpu, addr, 4096, new_page->page);

    // link new page
    if(bochs486_pages == NULL) {
        bochs486_pages = new_page;
    }
    else {
        ptr->next = new_page;
    }
    
printf("#bochs486: getHostMemAddr: hostPtr[new]: %p\n", new_page->page);
    return new_page->page;
}
BX_MEM_C::BX_MEM_C() {
}
BX_MEM_C::~BX_MEM_C() {
}

BOCHSAPI BX_MEM_C bx_mem;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ interrupt

bool bochs486_skip_rep_finish = false;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ instrument

int instruction_count = 0;

int bochs486_rep;
int bochs486_seg;
int bochs486_lock;
int bochs486_as32;
int bochs486_os32;
int bochs486_cmd_len;

void bx_instr_init_env(void) { }
void bx_instr_exit_env(void) { }

void bx_instr_debug_promt() { }
void bx_instr_debug_cmd(const char *cmd) { }

void bx_instr_cnear_branch_taken(unsigned cpu, bx_address branch_eip, bx_address new_eip) { }
void bx_instr_cnear_branch_not_taken(unsigned cpu, bx_address branch_eip) { }
void bx_instr_ucnear_branch(unsigned cpu, unsigned what, bx_address branch_eip, bx_address new_eip) { }
void bx_instr_far_branch(unsigned cpu, unsigned what, Bit16u new_cs, bx_address new_eip) { }

void bx_instr_opcode(unsigned cpu, bxInstruction_c *i, const Bit8u *opcode, unsigned len, bx_bool is32, bx_bool is64) { }

void bx_instr_exception(unsigned cpu, unsigned vector, unsigned error_code) { }
void bx_instr_hwinterrupt(unsigned cpu, unsigned vector, Bit16u cs, bx_address eip) { }

void bx_instr_tlb_cntrl(unsigned cpu, unsigned what, bx_phy_address new_cr3) { }
void bx_instr_cache_cntrl(unsigned cpu, unsigned what) { }
void bx_instr_prefetch_hint(unsigned cpu, unsigned what, unsigned seg, bx_address offset) { }
void bx_instr_clflush(unsigned cpu, bx_address laddr, bx_phy_address paddr) { }

void bx_instr_initialize(unsigned cpu) { }
void bx_instr_exit(unsigned cpu) { }
void bx_instr_reset(unsigned cpu, unsigned type) { }

void bx_instr_inp(Bit16u addr, unsigned len) { }
void bx_instr_inp2(Bit16u addr, unsigned len, unsigned val) { }
void bx_instr_outp(Bit16u addr, unsigned len, unsigned val) { }

void bx_instr_lin_access(unsigned cpu, bx_address lin, bx_address phy, unsigned len, unsigned rw) { }
void bx_instr_phy_access(unsigned cpu, bx_address phy, unsigned len, unsigned rw) { }

void bx_instr_wrmsr(unsigned cpu, unsigned addr, Bit64u value) { }



void bx_instr_interrupt(unsigned cpu, unsigned vector, unsigned type, bx_bool push_error, Bit16u error_code) {
    
    bochs486_skip_rep_finish = false;
    
    if(type != 4 && type != 5 && type != 6) { //BX_SOFTWARE_INTERRUPT; BX_PRIVILEGED_SOFTWARE_INTERRUPT; BX_SOFTWARE_EXCEPTION
        
printf("#bochs486: bx_instr_interrupt(), test_type: %d, type: %d, vector: %02x\n", test_type, type, vector); fflush(stdout);
        
        int is_interrupt = 0;
        if(type == 0) is_interrupt = 1; // BX_EXTERNAL_INTERRUPT
        
        if(is_interrupt) {
            printf("start_interrupt: 0\n");
        }
        else {
            printf("start_exception: 0\n");
            printf("push_error: %01x\n",      push_error);
            printf("error_code: %04x\n",      error_code);
        }
        printf("vector: %02x\n", vector);
        printf("\n");
        fflush(stdout);
        
        output_cpu_state();
        
        if(test_type == 0) exit(0);
        
        instruction_count++;
        if(test_type > 0 && instruction_count == test_type) exit(0);
    }
}

void instr_after_execution() {
    printf("#bochs486: instr_after_execution()\n"); fflush(stdout);
    
    printf("start_completed: 0\n");
    printf("rep:      %x\n", bochs486_rep);
    printf("seg:      %x\n", bochs486_seg);
    printf("lock:     %x\n", bochs486_lock);
    printf("os32:     %x\n", bochs486_os32);
    printf("as32:     %x\n", bochs486_as32);
    printf("consumed: %x\n", bochs486_cmd_len);
    printf("\n");
    fflush(stdout);
    
    output_cpu_state();
    
    instruction_count++;
    if(test_type > 0 && instruction_count == test_type) exit(0);
    
    //interrupt
    printf("start_check_interrupt: 0\n");
    printf("\n");
    fflush(stdout);
    
    fscanf(stdin, "%x", &interrupt_vector);
    
printf("#bochs486_check_interrupt: %x\n", interrupt_vector);
    if(interrupt_vector != 0x100) {
        bx_cpu.raise_INTR();
    }
    else bx_cpu.clear_INTR();
}

void bx_instr_before_execution(unsigned cpu, bxInstruction_c *i) {
    bochs486_rep     = i->bochs486_rep;   // 0-none, 2-0xF2, 3-0xF3
    bochs486_seg     = i->seg() & 0x7;            // 0-5
    bochs486_lock    = (i->bochs486_lock)? 1 : 0;
    bochs486_as32    = (i->as32L())?  1 : 0;
    bochs486_os32    = (i->os32L())?  1 : 0;
    bochs486_cmd_len = i->ilen();
    
printf("#instr: %02x, async_event: %x\n", i->bochs486_opcode, bx_cpu.async_event);
    
    printf("#start_decoded:\n");
    printf("#decoded_rep:      %x\n", bochs486_rep);
    printf("#decoded_seg:      %x\n", bochs486_seg);
    printf("#decoded_lock:     %x\n", bochs486_lock);
    printf("#decoded_os32:     %x\n", bochs486_os32);
    printf("#decoded_as32:     %x\n", bochs486_as32);
    printf("#decoded_consumed: %x\n", bochs486_cmd_len);
    printf("\n");
    fflush(stdout);
}
void bx_instr_after_execution(unsigned cpu, bxInstruction_c *i) {
    if(bochs486_skip_rep_finish) {
        printf("#bx_instr_after_execution: bochs486_skip_rep_finished\n");
        bochs486_skip_rep_finish = false;
        return;
    }
    
    //patch XCHG
    if((i->bochs486_modregrm >> 6) != 3 && (i->bochs486_opcode == 0x86 || i->bochs486_opcode == 0x87)) bochs486_lock = 1;
    
    instr_after_execution();
}
void bx_instr_repeat_iteration(unsigned cpu, bxInstruction_c *i) {
    bochs486_skip_rep_finish = true;
    
    instr_after_execution();
}

void bx_instr_hlt(unsigned cpu) {
    instr_after_execution();
    
    //if(test_type == 0) exit(0);
}
void bx_instr_mwait(unsigned cpu, bx_phy_address addr, unsigned len, Bit32u flags) { }

// memory trace callbacks from CPU, len=1,2,4 or 8
void bx_dbg_lin_memory_access(unsigned cpu, bx_address lin, bx_phy_address phy, unsigned len, unsigned pl, unsigned rw, Bit8u *data) {
    if(rw == BX_READ) {
printf("#bochs486: bx_dbg_lin_memory_access() read redirect.\n");
        Bit8u buf[8];
        bx_mem.readPhysicalPage(NULL, phy, len, buf);
        
        bool read_ok = true;
        for(int i=0; i<len; i++) if(data[i] != buf[i]) read_ok = false;
        
        if(read_ok == false) {
printf("#bochs486: bx_dbg_lin_memory_access() read mismatch: lin=%08x, phy=%08x, len=%d, pl=%d, rw=%d\n", lin, phy, len, pl, rw);
            for(int i=0; i<len; i++) {
                printf("#%d: %02hhx --- %02hhx\n", i, data[i], buf[i]);
            }
            exit(-1);
        }
    }
    if(rw == BX_WRITE) {
printf("#bochs486: bx_dbg_lin_memory_access() write redirect: phy=%08x, len=%d\n", phy, len);
        bx_mem.writePhysicalPage(NULL, phy, len, data);
    }
}
void bx_dbg_phy_memory_access(unsigned cpu, bx_phy_address phy, unsigned len, unsigned rw, unsigned attr, Bit8u *data) {
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ main

int main(int argc, char **argv) {
    
    bx_pc_system.a20_mask = 0xFFFFFFFF;

    SIM = new bochs486_sim();

    const char *choices[] = { "0_choice", NULL };
    
    param_vendor_string      = new bx_param_string_c(NULL, "1_name", "1_label", "1_descr", "GeniuneAO486");
    param_brand_string       = new bx_param_string_c(NULL, "2_name", "2_label", "2_descr", "ao486                                           ");
    param_bool_false         = new bx_param_bool_c(  NULL, "3_name", "3_label", "3_descr", 0);
    param_enum_zero          = new bx_param_enum_c(  NULL, "4_name", "4_label", "4_descr", choices, 0);
    param_stepping           = new bx_param_num_c(   NULL, "5_name", "5_label", "5_descr", 0xB,0xB,0xB);
    param_model              = new bx_param_num_c(   NULL, "6_name", "6_label", "6_descr", 0x5,0x5,0x5);
    param_family             = new bx_param_num_c(   NULL, "7_name", "7_label", "7_descr", 0x4,0x4,0x4);
    param_cpulevel_for_cpuid = new bx_param_num_c(   NULL, "8_name", "8_label", "8_descr", 0x4,0x4,0x4);  

    bx_cpu.initialize();
    bx_cpu.reset(BX_RESET_HARDWARE);
    
    printf("START\n");
    
    initialize();

    bx_cpu.async_event = 0;
    bx_cpu.handleCpuModeChange();

    output_cpu_state();
    bx_cpu.cpu_loop();
    
    printf("#bochs486: finishing.\n");
    return 0;
}
