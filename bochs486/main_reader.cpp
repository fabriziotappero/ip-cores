#include <cstdio>
#include <cstdlib>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "bochs.h"
#include "cpu.h"
#include "iodev/iodev.h"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

typedef unsigned char  uint8;
typedef unsigned short uint16;
typedef unsigned int   uint32;
typedef unsigned long long uint64;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ logfunctions

void logfunctions::panic(const char *fmt, ...) {
    printf("#bochs486_reader::logfunctions::panic(): ");
    
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
    printf("#bochs486_reader::logfunctions::error(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);
    
    printf("\n");
    fflush(stdout);
}
void logfunctions::ldebug(const char *fmt, ...) {
    printf("#bochs486_reader::logfunctions::debug(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);   
    
    printf("\n");
    fflush(stdout);
}
void logfunctions::info(const char *fmt, ...) {
    printf("#bochs486_reader::logfunctions::info(): ");
    
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
printf("#bochs486_reader::bx_param_string_c::text_print()\n");
}
void bx_param_enum_c::text_print(FILE *fp) {
printf("#bochs486_reader::bx_param_enum_c::text_print()\n");
}
void bx_param_bool_c::text_print(FILE *fp) {
printf("#bochs486_reader::bx_param_bool_c::text_print()\n");
}
void bx_param_num_c::text_print(FILE *fp) {
printf("#bochs486_reader::bx_param_num_c::text_print()\n");
}
void bx_list_c::text_print(FILE *fp) {
printf("#bochs486_reader::bx_list_c::text_print()\n");
}
int bx_param_enum_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486_reader::bx_param_enum_c::text_ask()\n");
    return 0;
}
int bx_param_bool_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486_reader::bx_param_bool_c::text_ask()\n");
    return 0;
}
int bx_param_num_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486_reader::bx_param_num_c::text_ask()\n");
    return 0;
}
int bx_param_string_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486_reader::bx_param_string_c::text_ask()\n");
    return 0;
}
int bx_list_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486_reader::bx_list_c::text_ask()\n");
    return 0;
}

bx_list_c *root_param = NULL;

bx_gui_c *bx_gui = NULL;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ cpu

void BX_CPU_C::enter_system_management_mode(void) {
printf("#bochs486_reader: enter_system_management_mod()\n");
}
void BX_CPU_C::init_SMRAM(void) {
printf("#bochs486_reader: init_SMRAM()\n");
}
void BX_CPU_C::debug(bx_address offset) {
printf("#bochs486_reader: debug(offset=%08x)\n", offset);
}
void BX_CPU_C::debug_disasm_instruction(bx_address offset) {
printf("#bochs486_reader: debug_disasm_instruction(offset=%08x)\n", offset);
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ pc_system

void bx_pc_system_c::countdownEvent(void) {
}
bx_pc_system_c::bx_pc_system_c() {
}
int bx_pc_system_c::Reset(unsigned type) {
    printf("#bochs486_reader: bx_pc_system_c::Reset(%d) unimplemented.\n", type);
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

const char *choices[] = { "0_choice", NULL };
    
class bochs486_sim : public bx_simulator_interface_c {

    bx_param_bool_c *get_param_bool(const char *pname, bx_param_c *base) {
        if(strcmp(pname, BXPN_CPUID_LIMIT_WINNT) == 0)      return new bx_param_bool_c(  NULL, "b0", "", "", 0);
        if(strcmp(pname, BXPN_CPUID_SSE4A) == 0)            return new bx_param_bool_c(  NULL, "b1", "", "", 0);
        if(strcmp(pname, BXPN_CPUID_SEP) == 0)              return new bx_param_bool_c(  NULL, "b2", "", "", 0);
        if(strcmp(pname, BXPN_CPUID_XSAVE) == 0)            return new bx_param_bool_c(  NULL, "b3", "", "", 0);
        if(strcmp(pname, BXPN_CPUID_XSAVEOPT) == 0)         return new bx_param_bool_c(  NULL, "b4", "", "", 0);
        if(strcmp(pname, BXPN_CPUID_AES) == 0)              return new bx_param_bool_c(  NULL, "b5", "", "", 0);
        if(strcmp(pname, BXPN_CPUID_MOVBE) == 0)            return new bx_param_bool_c(  NULL, "b6", "", "", 0);
        if(strcmp(pname, BXPN_CPUID_SMEP) == 0)             return new bx_param_bool_c(  NULL, "b7", "", "", 0);
        if(strcmp(pname, BXPN_RESET_ON_TRIPLE_FAULT) == 0)  return new bx_param_bool_c(  NULL, "b8", "", "", 0);
        return NULL;
    }
    bx_param_string_c *get_param_string(const char *pname, bx_param_c *base) {
        if(strcmp(pname, BXPN_VENDOR_STRING) == 0) return new bx_param_string_c(NULL, "s0", "", "", "GeniuneAO486");
        if(strcmp(pname, BXPN_BRAND_STRING) == 0)  return new bx_param_string_c(NULL, "s1", "", "", "ao486                                           ");
        return NULL;
    }
    bx_param_enum_c *get_param_enum(const char *pname, bx_param_c *base) {
        if(strcmp(pname, BXPN_CPU_MODEL) == 0)  return new bx_param_enum_c(  NULL, "e0", "", "", choices, 0);
        if(strcmp(pname, BXPN_CPUID_SSE) == 0)  return new bx_param_enum_c(  NULL, "e1", "", "", choices, 0);
        return NULL;
    }
    bx_param_num_c *get_param_num(const char *pname, bx_param_c *base) {
        if(strcmp(pname, BXPN_CPUID_STEPPING) == 0)  return new bx_param_num_c(   NULL, "n0", "", "", 0xB,0xB,0xB);
        if(strcmp(pname, BXPN_CPUID_MODEL) == 0)     return new bx_param_num_c(   NULL, "n1", "", "", 0x5,0x5,0x5);
        if(strcmp(pname, BXPN_CPUID_FAMILY) == 0)    return new bx_param_num_c(   NULL, "n2", "", "", 0x4,0x4,0x4);
        if(strcmp(pname, BXPN_CPUID_LEVEL) == 0)     return new bx_param_num_c(   NULL, "n3", "", "", 0x4,0x4,0x4);
        return NULL;
    }
};

//------------------------------------------------------------------------------

FILE *check_fp = NULL;

char check_line[256];
char check_next[256];
int check_state = 0;
/*
0 - both empty
1 - EOF is next
2 - both full; line will be used
*/

uint32 check_next_irq_at = 0;
uint32 check_next_irq_vector = 0;

union memory_t {
    uint8  bytes [134217728];
    uint16 shorts[67108864];
    uint32 ints  [33554432];
};
memory_t check_memory;

uint32 instr_counter = 0;

void load_file(const char *name, int byte_location) {
    FILE *fp = fopen(name, "rb");
    if(fp == NULL) {
        fprintf(stderr, "#bochs486_reader: error opening file: %s\n", name);
        exit(-1);
    }
    
    int int_ret = fseek(fp, 0, SEEK_END);
    if(int_ret != 0) {
        fclose(fp);
        fprintf(stderr, "#bochs486_reader: error stat file: %s\n", name);
        exit(-1);
    }
    
    long size = ftell(fp);
    rewind(fp);
    
    int_ret = fread((void *)&check_memory.bytes[byte_location], size, 1, fp);
    if(int_ret != 1) {
        fclose(fp);
        fprintf(stderr, "#bochs486_reader: error loading file: %s\n", name);
        exit(-1);
    }
    fclose(fp);
}

bool check_read_fp(char *line) {
    while(true) {
        char *endoffile = fgets(line, 256, check_fp);
        if(endoffile == NULL) return false;
printf("line: %s\n", line);
        uint32 val1 = 0, val2 = 0;
        int scan_ret = sscanf(line, "Exception 0x%x at %x", &val1, &val2);
        if(scan_ret == 2) {
            //ignore
            continue;
        }
        
        val1 = val2 = 0;
        scan_ret = sscanf(line, "IAC 0x%x at %d", &val1, &val2);
        if(scan_ret == 2) {
            check_next_irq_vector = val1;
            check_next_irq_at     = val2;
            
            continue;
        }
        break;
    }
    return true;
}

uint64 total_size = 0;
uint64 last_percent = 0;

void check_init() {
    if(check_fp == NULL) {
        //const char *filename = "./../backup/run-10/track.txt";
        const char *filename = "./../ao486/io_win95pipeline_1_bochs.txt";
        
        check_fp = fopen(filename, "rb");
        if(check_fp == NULL) {
            fprintf(stderr, "#bochs486_reader: can not open reader file.\n");
            exit(-1);
        }
        
        struct stat st;
        memset(&st, 0, sizeof(struct stat));
        stat(filename, &st);
        total_size = st.st_size;
        fprintf(stderr, "#bochs486_reader: total file size: %d\n", total_size);
    }
    
    uint64 curr_pos = ftell(check_fp);
    uint64 curr_percent = curr_pos * 100 / total_size;
    if(curr_percent != last_percent) {
        last_percent = curr_percent;
        fprintf(stderr, "#bochs486_reader: %d percent\n", (uint32)last_percent);
    }
    
    if(check_state == 0) { 
        if(check_read_fp(check_line) == false) {
            fprintf(stderr, "#bochs486_reader: EOF\n");
            exit(0);
        }
        if(check_read_fp(check_next) == false) {
            check_state = 1;
            return;
        }
        check_state = 2;
    }
    else if(check_state == 1) {
        fprintf(stderr, "#bochs486_reader: EOF\n");
        exit(0);
    }
    else if(check_state == 2) {
        memcpy(check_line, check_next, 256);
        
        if(check_read_fp(check_next) == false) {
            check_state = 1;
            return;
        }
        check_state = 2;
    }
}

uint32 check_io_rd(uint32 address, uint32 byteenable) {
    check_init();
    
    uint32 io_addr = 0, io_byteena = 0, io_data = 0;
    int scan_ret = sscanf(check_line, "io rd %x %x %x", &io_addr, &io_byteena, &io_data);
    
    if(scan_ret == 3) {
        if(address != io_addr) {
            fprintf(stderr, "#check_io_rd MISMATCH:%s != l:%04x %x\n", check_line, address, byteenable);
            exit(-1);
        }
        if(byteenable != io_byteena) {
            fprintf(stderr, "#check_io_rd MISMATCH:%s != l:%04x %x\n", check_line, address, byteenable);
            exit(-1);
        }
    }
    else {
        fprintf(stderr, "#check_io_rd MISMATCH: f:%s != l:%04x %x\n", check_line, address, byteenable);
        exit(-1);
    }
    return io_data;
}

void check_io_wr(uint32 address, uint32 byteenable, uint32 data) {
    check_init();

    uint32 io_addr = 0, io_byteena = 0, io_data = 0;
    int scan_ret = sscanf(check_line, "io wr %x %x %x", &io_addr, &io_byteena, &io_data);
    
    if(scan_ret == 3) {
        if(((byteenable>>0) & 1) == 0) { data &= 0xFFFFFF00; io_data &= 0xFFFFFF00; }
        if(((byteenable>>1) & 1) == 0) { data &= 0xFFFF00FF; io_data &= 0xFFFF00FF; }
        if(((byteenable>>2) & 1) == 0) { data &= 0xFF00FFFF; io_data &= 0xFF00FFFF; }
        if(((byteenable>>3) & 1) == 0) { data &= 0x00FFFFFF; io_data &= 0x00FFFFFF; }
        
        if(address != io_addr) {
            fprintf(stderr, "#check_io_wr MISMATCH:%s | %04x %x %08x\n", check_line, address, byteenable, data);
            exit(-1);
        }
        if(byteenable != io_byteena) {
            fprintf(stderr, "#check_io_wr MISMATCH:%s | %04x %x %08x\n", check_line, address, byteenable, data);
            exit(-1);
        }
        if(data != io_data) {
            fprintf(stderr, "#check_io_wr MISMATCH:%s | %04x %x %08x\n", check_line, address, byteenable, data);
            exit(-1);
        } 
    }
    else {
        fprintf(stderr, "#check_io_wr MISMATCH:%s | %04x %x %08x\n", check_line, address, byteenable, data);
        exit(-1);
    }
}

void check_mem_wr(uint32 address, uint32 byteenable, uint32 data) {
    check_init();
    
    uint32 mem_addr = 0, mem_byteena = 0, mem_data = 0;
    int scan_ret = sscanf(check_line, "mem wr %x %x %x", &mem_addr, &mem_byteena, &mem_data);
    
    if(scan_ret == 3) {
        if(((byteenable>>0) & 1) == 0) { data &= 0xFFFFFF00; mem_data &= 0xFFFFFF00; }
        if(((byteenable>>1) & 1) == 0) { data &= 0xFFFF00FF; mem_data &= 0xFFFF00FF; }
        if(((byteenable>>2) & 1) == 0) { data &= 0xFF00FFFF; mem_data &= 0xFF00FFFF; }
        if(((byteenable>>3) & 1) == 0) { data &= 0x00FFFFFF; mem_data &= 0x00FFFFFF; }
        
        if(address != mem_addr) {
            fprintf(stderr, "#check_mem_wr MISMATCH:%s != l:%08x %x %08x\n", check_line, address, byteenable, data);
            exit(-1);
        }
        if(byteenable != mem_byteena) {
            fprintf(stderr, "#check_mem_wr MISMATCH:%s != l:%08x %x %08x\n", check_line, address, byteenable, data);
            exit(-1);
        }
        if(data != mem_data) {
            fprintf(stderr, "#check_mem_wr MISMATCH:%s != l:%08x %x %08x\n", check_line, address, byteenable, data);
            exit(-1);
        }
        
        for(uint32 i=0; i<4; i++) {
            if(byteenable & 1) {
                check_memory.bytes[address + i] = data & 0xFF;
            }
            byteenable >>= 1;
            data >>= 8;
        }
    }
    else {
        fprintf(stderr, "#check_io_wr MISMATCH:%s != l:%08x %x %08x\n", check_line, address, byteenable, data);
        exit(-1);
    }
}

uint32 check_mem_rd(uint32 address, uint32 byteenable) {
    check_init();
    
    uint32 mem_addr = 0, mem_byteena = 0, mem_data = 0;
    int scan_ret = sscanf(check_line, "mem rd %x %x %x", &mem_addr, &mem_byteena, &mem_data);
    
    if(scan_ret == 3) {
        if(address != mem_addr) {
            fprintf(stderr, "#check_mem_rd MISMATCH:%s != l:%08x %x\n", check_line, address, byteenable);
            exit(-1);
        }
        if(byteenable != mem_byteena) {
            fprintf(stderr, "#check_mem_rd MISMATCH:%s != l:%08x %x\n", check_line, address, byteenable);
            exit(-1);
        }
    }
    else {
        fprintf(stderr, "#check_mem_rd MISMATCH:%s != l:%04x %x\n", check_line, address, byteenable);
        exit(-1);
    }
    return mem_data;
}

//------------------------------------------------------------------------------

bx_simulator_interface_c *SIM;

BOCHSAPI BX_CPU_C bx_cpu;
int interrupt_vector;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ devices

class bochs486_pic : public bx_pic_stub_c {
    Bit8u IAC(void) { bx_cpu.clear_INTR(); return interrupt_vector & 0xFF; }
};

int is_io_ignored(Bit16u address, Bit32u byteena) {

    bool read_ff =
            (address >= 0x0010 && address < 0x0020)     ||         
            (address == 0x0020 && (byteena & 0x3) == 0) ||
            (address >= 0x0024 &&  address < 0x0040)    ||
            (address >= 0x0044 &&  address < 0x0060)    ||
            (address >= 0x0068 &&  address < 0x0070)    ||
            (address == 0x0070 && (byteena & 0x3) == 0) ||
            (address >= 0x0074 &&  address < 0x0080)    ||
            (address == 0x00A0 && (byteena & 0x3) == 0) ||
            (address >= 0x00A4 &&  address < 0x00C0)    ||
            (address >= 0x00E0 &&  address < 0x01F0)    ||
            (address >= 0x01F8 &&  address < 0x0220)    ||
            (address >= 0x0230 &&  address < 0x0388)    ||
            (address == 0x0388 && (byteena & 0x3) == 0) ||
            (address >= 0x038C &&  address < 0x03B0)    ||
            (address >= 0x03E0 &&  address < 0x03F0)    ||
            (address >= 0x03F8 &&  address < 0x8888)    ||
            (address >= 0x8890);
    
    bool read_ff_part =
            (address == 0x0020) ||
            (address == 0x0070) ||
            (address == 0x00A0) ||
            (address == 0x0388);
    
    if(read_ff)         return 1;
    if(read_ff_part)    return 2;
    return 0;
}

  Bit32u BX_CPP_AttrRegparmN(2)
bx_devices_c::inp(Bit16u addr, unsigned io_len) {
//printf("#bochs486_pc:inp(%04x, %d)\n", addr, io_len);
    // read aligned to 4 bytes, with byteena
    
    bool two_reads = (addr & 0x3) + io_len > 4;
    
    Bit16u   addr1    = addr & 0xFFFC;
    unsigned byteena1 = (io_len == 1)? 0x1 : (io_len == 2)? 0x3 : (io_len == 3)? 0x7 : 0xF;
    byteena1 = ((addr & 0x3) == 0)? byteena1 : ((addr & 0x3) == 1)? byteena1 << 1 : ((addr & 0x3) == 2)? byteena1 << 2 : byteena1 << 3;
    
    Bit16u   addr2    = (addr + 4) & 0xFFFC;
    unsigned byteena2 = (byteena1 >> 4) & 0xF;
    
    //-------------------------------------------------------------------------- first read
    int int_ret = is_io_ignored(addr1, byteena1 & 0xF);
    unsigned int data1 = 0xFFFFFFFF;
    
    if(int_ret == 0 || int_ret == 2) {
        data1 = ((int_ret == 2)? 0xFFFF0000 : 0x00000000) | check_io_rd(addr1, byteena1 & 0xF);
    }
    //-------------------------------------------------------------------------- second read
    unsigned long long data = data1;
//printf("#bochs486_pc:inp() read_one %d\n", two_reads);
    if(two_reads) {
        int_ret = is_io_ignored(addr2, byteena2 & 0xF);
        unsigned int data2 = 0xFFFFFFFF;
        
        if(int_ret == 0 || int_ret == 2) {
            data2 = ((int_ret == 2)? 0xFFFF0000 : 0x00000000) | check_io_rd(addr2, byteena2 & 0xF);
        }
        data = ((unsigned long long)data2 << 32) | data1;
    }
    
    while((byteena1 & 1) == 0) {
        byteena1 >>= 1;
        data >>= 8;
    }
    Bit32u ret_val = (io_len == 1)? (data & 0xFFL) : (io_len == 2)? (data & 0xFFFFL) : (io_len == 3)? (data & 0xFFFFFFL) : (data & 0xFFFFFFFFL);
printf("#bochs486_pc:inp(%04x, %d, =%08x)\n", addr, io_len, ret_val);    
    return ret_val;
}

  void BX_CPP_AttrRegparmN(3)
bx_devices_c::outp(Bit16u addr, Bit32u value, unsigned io_len) {
printf("#bochs486_pc:outp(%04x, %d, %08x)\n", addr, io_len, value);
    // write aligned to 4 bytes, with byteena
    
    bool two_writes = (addr & 0x3) + io_len > 4;
    
    Bit16u   addr1    = addr & 0xFFFC;
    unsigned byteena1 = (io_len == 1)? 0x1 : (io_len == 2)? 0x3 : (io_len == 3)? 0x7 : 0xF;
    byteena1 = ((addr & 0x3) == 0)? byteena1 : ((addr & 0x3) == 1)? byteena1 << 1 : ((addr & 0x3) == 2)? byteena1 << 2 : byteena1 << 3;
    
    Bit16u   addr2    = (addr + 4) & 0xFFFC;
    unsigned byteena2 = (byteena1 >> 4) & 0xF;
    
    if(io_len == 1) value &= 0x000000FF;
    if(io_len == 2) value &= 0x0000FFFF;
    if(io_len == 3) value &= 0x00FFFFFF;
    
    Bit64u value_full = ((addr & 0x3) == 0)? (Bit64u)value : ((addr & 0x3) == 1)? ((Bit64u)value << 8) : ((addr & 0x3) == 2)? ((Bit64u)value << 16) : ((Bit64u)value << 24);
    Bit32u value1 = value_full;
    Bit32u value2   = (value_full >> 32);
    
    //-------------------------------------------------------------------------- first write
    int int_ret = is_io_ignored(addr1, byteena1 & 0xF);
    
    if(int_ret == 0 || int_ret == 2) {
        check_io_wr(addr1, byteena1 & 0xF, value1);
    }
//printf("#bochs486_pc:outp() write_one %d\n", two_writes);
    //-------------------------------------------------------------------------- second write
    
    if(two_writes) {
        int_ret = is_io_ignored(addr2, byteena2 & 0xF);
        
        if(int_ret == 0 || int_ret == 2) {
            check_io_wr(addr2, byteena2 & 0xF, value2);
        }
    }
//printf("#bochs486_pc:outp() write_two\n");
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

void BX_MEM_C::writePhysicalPage(BX_CPU_C *cpu, bx_phy_address addr, unsigned len, void *data) {
printf("#bochs486_reader: writePhysicalPage: addr=%08x, len=%d ", addr, len);
for(unsigned i=0; i<len; i++) printf("%02x ", ((uint8 *)data)[i]); printf("\n");

    addr &= 0x07FFFFFF;
    
    if(len > 4) {
        printf("#bochs486_pc: writePhysicalPage() with len = %d\n", len);
        exit(-1);
    }
    
    bool two_writes = (addr & 0x3) + len > 4;
    
    Bit32u   addr1    = addr & 0xFFFFFFFC;
    unsigned byteena1 = (len == 1)? 0x1 : (len == 2)? 0x3 : (len == 3)? 0x7 : 0xF;
    byteena1 = ((addr & 0x3) == 0)? byteena1 : ((addr & 0x3) == 1)? byteena1 << 1 : ((addr & 0x3) == 2)? byteena1 << 2 : byteena1 << 3;
    
    Bit32u   addr2    = (addr + 4) & 0xFFFFFFFC;
    unsigned byteena2 = (byteena1 >> 4) & 0xF;
    
    Bit32u value = ((unsigned int *)data)[0];
    if(len == 1) value &= 0x000000FF;
    if(len == 2) value &= 0x0000FFFF;
    if(len == 3) value &= 0x00FFFFFF;
    
    Bit64u value_full = ((addr & 0x3) == 0)? (Bit64u)value : ((addr & 0x3) == 1)? ((Bit64u)value << 8) : ((addr & 0x3) == 2)? ((Bit64u)value << 16) : ((Bit64u)value << 24);
    Bit32u value1 = value_full;
    Bit32u value2   = (value_full >> 32);
    
    //-------------------------------------------------------------------------- first write
    check_mem_wr(addr1, byteena1 & 0xF, value1);
    
//printf("#bochs486_pc: writePhysicalPage: write_one, %d\n", two_writes);
    if(two_writes) {
        //---------------------------------------------------------------------- second write
        check_mem_wr(addr2, byteena2 & 0xF, value2);
    }  
//printf("#bochs486_pc: writePhysicalPage: write_two\n");
}

void BX_MEM_C::readPhysicalPage(BX_CPU_C *cpu, bx_phy_address addr, unsigned len, void *data) {
printf("#bochs486_pc: readPhysicalPage: addr=%08x, len=%d\n", addr, len);

        if(addr >= 0xFFFFF000) addr &= 0x000FFFFF;
        addr &= 0x07FFFFFF;

    if(len == 4096) {
        if((addr & 3) != 0) {
            printf("#bochs486_pc: readPhysicalPage() with len = 4096 and addr not aligned to 4.\n");
            exit(-1);
        }
        
        if(addr >= 0xA0000 && addr <= 0xBFFFF) {
            printf("#bochs486_pc: readPhysicalPage() with len = 4096 and addr in vga buffer.\n");
            fflush(stdout);
            exit(-1);
        }
        
        memcpy((unsigned char *)data, (void *)(check_memory.bytes + addr), len);
        return;
    }
    
    //check if read crosses line boundry (16 bytes)
    if( ((addr) & 0xFFFFFFF0) != ((addr + len - 1) & 0xFFFFFFF0) ) {
        unsigned char *ptr = (unsigned char*)data;
        readPhysicalPage(cpu, addr,             (addr | 0xF) - addr + 1,       ptr);
        readPhysicalPage(cpu, (addr | 0xF) + 1, len - (addr | 0xF) + addr - 1, ptr + ((addr | 0xF) - addr + 1));
        return;
    }
    
    if(addr < 0xA0000 || addr > 0xBFFFF) {
        memcpy((unsigned char *)data, (void *)(check_memory.bytes + addr), len);
uint32 *val = (uint32 *)data;
printf("read: %08x %08x\n", val[0], (len > 4)? val[1] : 0);
        return;
    }
//printf("#bochs486_pc: readPhysicalPage: vga read.\n");    
    bool two_reads   = ((addr & 0x3) + len > 4) && ((addr & 0x3) + len <= 8);
    bool three_reads = ((addr & 0x3) + len > 8);
    
    Bit32u   addr1    = addr & 0xFFFFFFFC;
    unsigned byteena1 = (len == 1)? 0x1 : (len == 2)? 0x3 : (len == 3)? 0x7 : 0xF;
    byteena1 = ((addr & 0x3) == 0)? byteena1 : ((addr & 0x3) == 1)? byteena1 << 1 : ((addr & 0x3) == 2)? byteena1 << 2 : byteena1 << 3;
    
    Bit32u   addr2    = (addr + 4) & 0xFFFFFFFC;
    Bit32u   addr3    = (addr + 8) & 0xFFFFFFFC;
    
    if(two_reads || three_reads) byteena1 = 0xF;
    byteena1 &= 0xF;
    
    //-------------------------------------------------------------------------- first read
    unsigned int data_read[3] = { 0,0,0 };
    
    data_read[0] = check_mem_rd(addr1, byteena1 & 0xF);
    
    if(two_reads || three_reads) {
        //---------------------------------------------------------------------- second read
        data_read[1] = check_mem_rd(addr2, 0xF);
        
        if(three_reads) {
            //------------------------------------------------------------------ third read
            data_read[2] = check_mem_rd(addr3, 0xF);
        }
    }
    
    unsigned char *ptr = (unsigned char *)data_read;
    
    for(int i=0; i<(addr & 0x3); i++) ptr++;
    
    memcpy((unsigned char *)data, ptr, len);
}

Bit8u *BX_MEM_C::getHostMemAddr(BX_CPU_C *cpu, bx_phy_address addr, unsigned rw) {
//printf("#bochs486_pc: getHostMemAddr: addr=%08x, rw=%d\n", addr, rw);
    
    if(addr >= 0xA0000 && addr < 0xC0000) return NULL;
    if(rw != BX_EXECUTE) return NULL;
    
    if(addr >= 0xFFFFF000) addr &= 0x000FFFFF;
    addr &= 0x07FFFFFF;
    
    return (Bit8u *)(check_memory.bytes + addr);
}
BX_MEM_C::BX_MEM_C() {
}
BX_MEM_C::~BX_MEM_C() {
}

BOCHSAPI BX_MEM_C bx_mem;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ interrupt

void print_segment(bx_segment_reg_t *seg, const char *prefix) {
    
    printf("%s: %04x ",    prefix, seg->selector.value);
    printf("val: %01x ",   seg->cache.valid & 1);
    printf("rpl: %01hhx ", seg->selector.rpl);
    printf("base: %08x ",  seg->cache.u.segment.base);
    printf("limit: %08x ", (seg->cache.u.segment.g)? seg->cache.u.segment.limit_scaled >> 12 : seg->cache.u.segment.limit_scaled);
    printf("g: %01x ",     seg->cache.u.segment.g);
    printf("d_b: %01x ",   seg->cache.u.segment.d_b);
    printf("avl: %01x ",   seg->cache.u.segment.avl);
    printf("p: %01x ",     seg->cache.p);
    printf("dpl: %01x ",   seg->cache.dpl);
    printf("s: %01x ",     seg->cache.segment);
    printf("type: %01x\n", seg->cache.type);
}

void output_cpu_state() {
    printf("eax: %08x ", bx_cpu.get_reg32(BX_32BIT_REG_EAX));
    printf("ebx: %08x ", bx_cpu.get_reg32(BX_32BIT_REG_EBX));
    printf("ecx: %08x ", bx_cpu.get_reg32(BX_32BIT_REG_ECX));
    printf("edx: %08x ", bx_cpu.get_reg32(BX_32BIT_REG_EDX));
    printf("esi: %08x ", bx_cpu.get_reg32(BX_32BIT_REG_ESI));
    printf("edi: %08x ", bx_cpu.get_reg32(BX_32BIT_REG_EDI));
    printf("ebp: %08x ", bx_cpu.get_reg32(BX_32BIT_REG_EBP));
    printf("esp: %08x\n", bx_cpu.get_reg32(BX_32BIT_REG_ESP));
    
    printf("eip: %08x\n", bx_cpu.gen_reg[BX_32BIT_REG_EIP].dword.erx);
    
    printf("cflag:  %01x ", bx_cpu.getB_CF());
    printf("pflag:  %01x ", bx_cpu.getB_PF());
    printf("aflag:  %01x ", bx_cpu.getB_AF());
    printf("zflag:  %01x ", bx_cpu.getB_ZF());
    printf("sflag:  %01x ", bx_cpu.getB_SF());
    printf("tflag:  %01x ", bx_cpu.getB_TF()&1);
    printf("iflag:  %01x ", bx_cpu.getB_IF()&1);
    printf("dflag:  %01x ", bx_cpu.getB_DF()&1);
    printf("oflag:  %01x ", bx_cpu.getB_OF()&1);
    printf("iopl:   %01x ", bx_cpu.get_IOPL()&3);
    printf("ntflag: %01x ", bx_cpu.getB_NT()&1);
    printf("rflag:  %01x ", bx_cpu.getB_RF()&1);
    printf("vmflag: %01x ", bx_cpu.getB_VM()&1);
    printf("acflag: %01x ", bx_cpu.getB_AC()&1);
    printf("idflag: %01x\n", bx_cpu.getB_ID()&1);
    
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_CS]), "cs");
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_DS]), "ds");
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_ES]), "es");
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_FS]), "fs");
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_GS]), "gs");
    print_segment(&(bx_cpu.sregs[BX_SEG_REG_SS]), "ss");
    print_segment(&(bx_cpu.ldtr), "ldtr");
    print_segment(&(bx_cpu.tr),   "tr");
    
    printf("gdtr_base:  %08x ", bx_cpu.gdtr.base);
    printf("gdtr_limit: %02x\n", bx_cpu.gdtr.limit & 0xFFFF);
    
    printf("idtr_base:  %08x ", bx_cpu.idtr.base);
    printf("idtr_limit: %02x\n", bx_cpu.idtr.limit & 0xFFFF);
    
    printf("cr0_pe: %01x ", bx_cpu.cr0.get_PE() & 1);
    printf("cr0_mp: %01x ", bx_cpu.cr0.get_MP() & 1);
    printf("cr0_em: %01x ", bx_cpu.cr0.get_EM() & 1);
    printf("cr0_ts: %01x ", bx_cpu.cr0.get_TS() & 1);
    printf("cr0_ne: %01x ", bx_cpu.cr0.get_NE() & 1);
    printf("cr0_wp: %01x ", bx_cpu.cr0.get_WP() & 1);
    printf("cr0_am: %01x ", bx_cpu.cr0.get_AM() & 1);
    printf("cr0_nw: %01x ", bx_cpu.cr0.get_NW() & 1);
    printf("cr0_cd: %01x ", bx_cpu.cr0.get_CD() & 1);
    printf("cr0_pg: %01x\n", bx_cpu.cr0.get_PG() & 1);
    
    printf("cr2: %08x ", bx_cpu.cr2);
    printf("cr3: %08x\n", bx_cpu.cr3);
    
    printf("dr0: %08x ", bx_cpu.dr[0]);
    printf("dr1: %08x ", bx_cpu.dr[1]);
    printf("dr2: %08x ", bx_cpu.dr[2]);
    printf("dr3: %08x ", bx_cpu.dr[3]);
    
    printf("dr6: %08x ", bx_cpu.dr6.val32);
    printf("dr7: %08x\n", bx_cpu.dr7.val32);
    
    fflush(stdout);
}

uint32 seg_word_1(bx_segment_reg_t *seg) {
    return  (seg->cache.u.segment.base & 0xFF000000) |
            (seg->cache.u.segment.g?   0x00800000 : 0x00) |
            (seg->cache.u.segment.d_b? 0x00400000 : 0x00) |
            (seg->cache.u.segment.avl? 0x00100000 : 0x00) |
            (((seg->cache.u.segment.limit_scaled >> (seg->cache.u.segment.g? 12 : 0)) << 16) & 0xF) |
            (seg->cache.p?   0x00008000 : 0x0) |
            ((seg->cache.dpl & 0x3) << 13) |
            ((seg->cache.segment & 0x1) << 12) |
            ((seg->cache.type & 0xF) << 8) |
            ((seg->cache.u.segment.base >> 16) & 0xFF);
}

uint32 seg_word_2(bx_segment_reg_t *seg) {
    return ((seg->cache.u.segment.base & 0xFFFF) << 16) |
           ((seg->cache.u.segment.limit_scaled >> (seg->cache.u.segment.g? 12 : 0)) & 0xFFFF);
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ instrument

bool bochs486_skip_rep_finish = false;


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


//uint32 check_next_irq_at = 0;
//uint32 check_next_irq_vector = 0;

bool intr_pending = false;
bool double_exception = false;

void bx_instr_interrupt(unsigned cpu, unsigned vector, unsigned type, bx_bool push_error, Bit16u error_code) {
    
    bochs486_skip_rep_finish = false;
    if(type == BX_EXTERNAL_INTERRUPT) intr_pending = false;
    
    if(type == BX_HARDWARE_EXCEPTION || type == BX_EXTERNAL_INTERRUPT) {
        printf("bx_instr_interrupt(%d): %02x at %d\n", type, vector, instr_counter);
        if(double_exception == false) instr_counter++;
        else {
            fprintf(stderr, "double exception: type: %d\n", type);
        }
        double_exception = true;
        
        if(instr_counter == check_next_irq_at) {
            interrupt_vector = check_next_irq_vector;
printf("raise_INTR(): %02x at %d\n", interrupt_vector, instr_counter);
            bx_cpu.raise_INTR();
            intr_pending = true;
        }
        else if(intr_pending && check_next_irq_at == 0) {
printf("clear_INTR() at %d\n", instr_counter);
            bx_cpu.clear_INTR();
            intr_pending = false;
        }
    }
}

void instr_after_execution() {
    
    instr_counter++;
    
bx_cpu.TLB_flush();
    
    if(instr_counter > 0) {
        output_cpu_state();
    }
//if(instr_counter > 11491275) exit(0);
    
    if(instr_counter == check_next_irq_at) {
        interrupt_vector = check_next_irq_vector;
printf("raise_INTR(): %02x at %d\n", interrupt_vector, instr_counter);
        bx_cpu.raise_INTR();
        intr_pending = true;
    }
    else if(intr_pending && check_next_irq_at == 0) {
printf("clear_INTR() at %d\n", instr_counter);
        bx_cpu.clear_INTR();
        intr_pending = false;
    }
    
}

void bx_instr_before_execution(unsigned cpu, bxInstruction_c *i) {
    double_exception = false;
//printf("cs: %04x eip: %08x len: %d op: %02x\n", bx_cpu.sregs[BX_SEG_REG_CS].selector.value, bx_cpu.gen_reg[BX_32BIT_REG_EIP].dword.erx, i->ilen(), i->bochs486_opcode);
   
}

void bx_instr_after_execution(unsigned cpu, bxInstruction_c *i) {
//printf("AFT cs: %04x eip: %08x len: %d op: %02x\n", bx_cpu.sregs[BX_SEG_REG_CS].selector.value, bx_cpu.gen_reg[BX_32BIT_REG_EIP].dword.erx, i->ilen(), i->bochs486_opcode);    
        
    if(bochs486_skip_rep_finish) {
        printf("#bx_instr_after_execution: bochs486_skip_rep_finished at %d\n", instr_counter);
        bochs486_skip_rep_finish = false;
        return;
    }
    
printf("#instr: %02x %d\n", i->bochs486_opcode, instr_counter);
    instr_after_execution();
}
void bx_instr_repeat_iteration(unsigned cpu, bxInstruction_c *i) {
    bochs486_skip_rep_finish = true;
    
printf("#repeat: %d\n", instr_counter);
    instr_after_execution();
}
void bx_instr_hlt(unsigned cpu) {
    instr_after_execution();
}    

void bx_instr_mwait(unsigned cpu, bx_phy_address addr, unsigned len, Bit32u flags) { }

// memory trace callbacks from CPU, len=1,2,4 or 8
void bx_dbg_lin_memory_access(unsigned cpu, bx_address lin, bx_phy_address phy, unsigned len, unsigned pl, unsigned rw, Bit8u *data) {
}
void bx_dbg_phy_memory_access(unsigned cpu, bx_phy_address phy, unsigned len, unsigned rw, unsigned attr, Bit8u *data) {
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ main

int main(int argc, char **argv) {
    
    load_file("./../sd/bios/bochs_legacy",    0xF0000);
    load_file("./../sd/vgabios/vgabios_lgpl", 0xC0000);
    
    bx_pc_system.a20_mask = 0xFFFFFFFF;

    SIM = new bochs486_sim();

    bx_cpu.initialize();
    bx_cpu.reset(BX_RESET_HARDWARE);
    
    printf("START\n");
    bx_cpu.gen_reg[BX_32BIT_REG_EDX].dword.erx = 0x0000045b; //after reset EDX value
    instr_counter++; //ao486 has extra instruction at 0xFFFFFFF0
    
    bx_cpu.async_event = 0;
    bx_cpu.handleCpuModeChange();

    bx_cpu.cpu_loop();
    
    printf("#bochs486_pc: finishing.\n");
        
    return 0;
}
