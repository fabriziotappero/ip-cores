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

#include "shared_mem.h"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

volatile shared_mem_t *shared_ptr = NULL;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ logfunctions

void logfunctions::panic(const char *fmt, ...) {
    printf("#bochs486_pc::logfunctions::panic(): ");
    
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
    printf("#bochs486_pc::logfunctions::error(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);
    
    printf("\n");
    fflush(stdout);
}
void logfunctions::ldebug(const char *fmt, ...) {
    printf("#bochs486_pc::logfunctions::debug(): ");
    
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);   
    
    printf("\n");
    fflush(stdout);
}
void logfunctions::info(const char *fmt, ...) {
    printf("#bochs486_pc::logfunctions::info(): ");
    
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
printf("#bochs486_pc::bx_param_string_c::text_print()\n");
}
void bx_param_enum_c::text_print(FILE *fp) {
printf("#bochs486_pc::bx_param_enum_c::text_print()\n");
}
void bx_param_bool_c::text_print(FILE *fp) {
printf("#bochs486_pc::bx_param_bool_c::text_print()\n");
}
void bx_param_num_c::text_print(FILE *fp) {
printf("#bochs486_pc::bx_param_num_c::text_print()\n");
}
void bx_list_c::text_print(FILE *fp) {
printf("#bochs486_pc::bx_list_c::text_print()\n");
}
int bx_param_enum_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486_pc::bx_param_enum_c::text_ask()\n");
    return 0;
}
int bx_param_bool_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486_pc::bx_param_bool_c::text_ask()\n");
    return 0;
}
int bx_param_num_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486_pc::bx_param_num_c::text_ask()\n");
    return 0;
}
int bx_param_string_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486_pc::bx_param_string_c::text_ask()\n");
    return 0;
}
int bx_list_c::text_ask(FILE *fpin, FILE *fpout) {
printf("#bochs486_pc::bx_list_c::text_ask()\n");
    return 0;
}

bx_list_c *root_param = NULL;

bx_gui_c *bx_gui = NULL;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ cpu

void BX_CPU_C::enter_system_management_mode(void) {
printf("#bochs486_pc: enter_system_management_mod()\n");
}
void BX_CPU_C::init_SMRAM(void) {
printf("#bochs486_pc: init_SMRAM()\n");
}
void BX_CPU_C::debug(bx_address offset) {
printf("#bochs486_pc: debug(offset=%08x)\n", offset);
}
void BX_CPU_C::debug_disasm_instruction(bx_address offset) {
printf("#bochs486_pc: debug_disasm_instruction(offset=%08x)\n", offset);
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------ pc_system

void bx_pc_system_c::countdownEvent(void) {
}
bx_pc_system_c::bx_pc_system_c() {
}
int bx_pc_system_c::Reset(unsigned type) {
    printf("#bochs486_pc: bx_pc_system_c::Reset(%d) unimplemented.\n", type);
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
        shared_ptr->bochs486_pc.io_address    = addr1;
        shared_ptr->bochs486_pc.io_byteenable = byteena1 & 0xF;
        shared_ptr->bochs486_pc.io_is_write   = 0;
        shared_ptr->bochs486_pc.io_step       = STEP_REQ;
        while(shared_ptr->bochs486_pc.io_step != STEP_ACK) {
            fflush(stdout);
            usleep(10);
        }
        data1 = ((int_ret == 2)? 0xFFFF0000 : 0x00000000) | shared_ptr->bochs486_pc.io_data;
        
        FILE *fp = fopen("track.txt", "a");
        fprintf(fp, "io rd %04x %x %08x\n", addr1, byteena1 & 0xF, data1);
        fclose(fp);
        
        shared_ptr->bochs486_pc.io_step = STEP_IDLE;
    }
    //-------------------------------------------------------------------------- second read
    unsigned long long data = data1;
//printf("#bochs486_pc:inp() read_one %d\n", two_reads);
    if(two_reads) {
        int_ret = is_io_ignored(addr2, byteena2 & 0xF);
        unsigned int data2 = 0xFFFFFFFF;
        
        if(int_ret == 0 || int_ret == 2) {
            shared_ptr->bochs486_pc.io_address    = addr2;
            shared_ptr->bochs486_pc.io_byteenable = byteena2 & 0xF;
            shared_ptr->bochs486_pc.io_is_write   = 0;
            shared_ptr->bochs486_pc.io_step       = STEP_REQ;
            while(shared_ptr->bochs486_pc.io_step != STEP_ACK) {
                fflush(stdout);
                usleep(10);
            }
            data2 = ((int_ret == 2)? 0xFFFF0000 : 0x00000000) | shared_ptr->bochs486_pc.io_data;
            
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "io rd %04x %x %08x\n", addr2, byteena2 & 0xF, data2);
            fclose(fp);
            
            shared_ptr->bochs486_pc.io_step = STEP_IDLE;
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
        shared_ptr->bochs486_pc.io_address    = addr1;
        shared_ptr->bochs486_pc.io_byteenable = byteena1 & 0xF;
        shared_ptr->bochs486_pc.io_is_write   = 1;
        shared_ptr->bochs486_pc.io_data       = value1;
        shared_ptr->bochs486_pc.io_step       = STEP_REQ;
        while(shared_ptr->bochs486_pc.io_step != STEP_ACK) {
            fflush(stdout);
            usleep(10);
        }
        
        FILE *fp = fopen("track.txt", "a");
        fprintf(fp, "io wr %04x %x %08x\n", addr1, byteena1 & 0xF, value1);
        fclose(fp);
        
        shared_ptr->bochs486_pc.io_step = STEP_IDLE;
    }
//printf("#bochs486_pc:outp() write_one %d\n", two_writes);
    //-------------------------------------------------------------------------- second write
    
    if(two_writes) {
        int_ret = is_io_ignored(addr2, byteena2 & 0xF);
        
        if(int_ret == 0 || int_ret == 2) {
            shared_ptr->bochs486_pc.io_address    = addr2;
            shared_ptr->bochs486_pc.io_byteenable = byteena2 & 0xF;
            shared_ptr->bochs486_pc.io_is_write   = 1;
            shared_ptr->bochs486_pc.io_data       = value2;
            shared_ptr->bochs486_pc.io_step       = STEP_REQ;
            while(shared_ptr->bochs486_pc.io_step != STEP_ACK) {
                fflush(stdout);
                usleep(10);
            }
            
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "io wr %04x %x %08x\n", addr2, byteena2 & 0xF, value2);
            fclose(fp);
            
            shared_ptr->bochs486_pc.io_step = STEP_IDLE;
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
printf("#bochs486_pc: writePhysicalPage: addr=%08x, len=%d ", addr, len);
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
    shared_ptr->bochs486_pc.mem_address    = addr1;
    shared_ptr->bochs486_pc.mem_byteenable = byteena1 & 0xF;
    shared_ptr->bochs486_pc.mem_is_write   = 1;
    shared_ptr->bochs486_pc.mem_data       = value1;
    shared_ptr->bochs486_pc.mem_step       = STEP_REQ;
    while(shared_ptr->bochs486_pc.mem_step != STEP_ACK) {
        fflush(stdout);
        usleep(10);
    }
    
    FILE *fp = fopen("track.txt", "a");
    fprintf(fp, "mem wr %08x %x %08x\n", addr1, byteena1 & 0xF, value1);
    fclose(fp);
    
    shared_ptr->bochs486_pc.mem_step = STEP_IDLE;

//printf("#bochs486_pc: writePhysicalPage: write_one, %d\n", two_writes);
    if(two_writes) {
        //---------------------------------------------------------------------- second write
        shared_ptr->bochs486_pc.mem_address    = addr2;
        shared_ptr->bochs486_pc.mem_byteenable = byteena2 & 0xF;
        shared_ptr->bochs486_pc.mem_is_write   = 1;
        shared_ptr->bochs486_pc.mem_data       = value2;
        shared_ptr->bochs486_pc.mem_step       = STEP_REQ;
        while(shared_ptr->bochs486_pc.mem_step != STEP_ACK) {
            fflush(stdout);
            usleep(10);
        }
        
        FILE *fp = fopen("track.txt", "a");
        fprintf(fp, "mem wr %08x %x %08x\n", addr2, byteena2 & 0xF, value2);
        fclose(fp);
        
        shared_ptr->bochs486_pc.mem_step = STEP_IDLE;
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
            fflush(stdout); while(1) { ; }
            exit(-1);
        }
        
        memcpy((unsigned char *)data, (void *)(shared_ptr->mem.bytes + addr), len);
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
        memcpy((unsigned char *)data, (void *)(shared_ptr->mem.bytes + addr), len);
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
    
    shared_ptr->bochs486_pc.mem_address    = addr1;
    shared_ptr->bochs486_pc.mem_byteenable = byteena1 & 0xF;
    shared_ptr->bochs486_pc.mem_is_write   = 0;
    shared_ptr->bochs486_pc.mem_step       = STEP_REQ;
    while(shared_ptr->bochs486_pc.mem_step != STEP_ACK) {
        fflush(stdout);
        usleep(10);
    }
    data_read[0] = shared_ptr->bochs486_pc.mem_data;
    
    FILE *fp = fopen("track.txt", "a");
    fprintf(fp, "mem rd %08x %x %08x\n", addr1, byteena1 & 0xF, data_read[0]);
    fclose(fp);
    
    shared_ptr->bochs486_pc.mem_step = STEP_IDLE;
    
    if(two_reads || three_reads) {
        //---------------------------------------------------------------------- second read
        shared_ptr->bochs486_pc.mem_address    = addr2;
        shared_ptr->bochs486_pc.mem_byteenable = 0xF;
        shared_ptr->bochs486_pc.mem_is_write   = 0;
        shared_ptr->bochs486_pc.mem_step       = STEP_REQ;
        while(shared_ptr->bochs486_pc.mem_step != STEP_ACK) {
            fflush(stdout);
            usleep(10);
        }
        data_read[1] = shared_ptr->bochs486_pc.mem_data;
        
        FILE *fp = fopen("track.txt", "a");
        fprintf(fp, "mem rd %08x %x %08x\n", addr2, 0xF, data_read[1]);
        fclose(fp);
        
        shared_ptr->bochs486_pc.mem_step = STEP_IDLE;
        
        if(three_reads) {
            //------------------------------------------------------------------ third read
            shared_ptr->bochs486_pc.mem_address    = addr3;
            shared_ptr->bochs486_pc.mem_byteenable = 0xF;
            shared_ptr->bochs486_pc.mem_is_write   = 0;
            shared_ptr->bochs486_pc.mem_step       = STEP_REQ;
            while(shared_ptr->bochs486_pc.mem_step != STEP_ACK) {
                fflush(stdout);
                usleep(10);
            }
            data_read[2] = shared_ptr->bochs486_pc.mem_data;
            
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "mem rd %08x %x %08x\n", addr3, 0xF, data_read[2]);
            fclose(fp);
            
            shared_ptr->bochs486_pc.mem_step = STEP_IDLE;
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
    
    return (Bit8u *)(shared_ptr->mem.bytes + addr);
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

void output_for_verilator() {

    FILE *fp = fopen("./../rtl/ao486/startup_from_sim.v", "wb");
    
    fprintf(fp, "`define STARTUP_EAX   32'h%08x\n", bx_cpu.get_reg32(BX_32BIT_REG_EAX));
    fprintf(fp, "`define STARTUP_EBX   32'h%08x\n", bx_cpu.get_reg32(BX_32BIT_REG_EBX));
    fprintf(fp, "`define STARTUP_ECX   32'h%08x\n", bx_cpu.get_reg32(BX_32BIT_REG_ECX));
    fprintf(fp, "`define STARTUP_EDX   32'h%08x\n", bx_cpu.get_reg32(BX_32BIT_REG_EDX));
    fprintf(fp, "`define STARTUP_EBP   32'h%08x\n", bx_cpu.get_reg32(BX_32BIT_REG_EBP));
    fprintf(fp, "`define STARTUP_ESP   32'h%08x\n", bx_cpu.get_reg32(BX_32BIT_REG_ESP));
    fprintf(fp, "`define STARTUP_ESI   32'h%08x\n", bx_cpu.get_reg32(BX_32BIT_REG_ESI));
    fprintf(fp, "`define STARTUP_EDI   32'h%08x\n", bx_cpu.get_reg32(BX_32BIT_REG_EDI));
    
    fprintf(fp, "`define STARTUP_CR0_PE 1'b%d\n", bx_cpu.cr0.get_PE() & 1);
    fprintf(fp, "`define STARTUP_CR0_MP 1'b%d\n", bx_cpu.cr0.get_MP() & 1);
    fprintf(fp, "`define STARTUP_CR0_EM 1'b%d\n", bx_cpu.cr0.get_EM() & 1);
    fprintf(fp, "`define STARTUP_CR0_TS 1'b%d\n", bx_cpu.cr0.get_TS() & 1);
    fprintf(fp, "`define STARTUP_CR0_NE 1'b%d\n", bx_cpu.cr0.get_NE() & 1);
    fprintf(fp, "`define STARTUP_CR0_WP 1'b%d\n", bx_cpu.cr0.get_WP() & 1);
    fprintf(fp, "`define STARTUP_CR0_AM 1'b%d\n", bx_cpu.cr0.get_AM() & 1);
    fprintf(fp, "`define STARTUP_CR0_NW 1'b%d\n", bx_cpu.cr0.get_NW() & 1);
    fprintf(fp, "`define STARTUP_CR0_CD 1'b%d\n", bx_cpu.cr0.get_CD() & 1);
    fprintf(fp, "`define STARTUP_CR0_PG 1'b%d\n", bx_cpu.cr0.get_PG() & 1);
    
    fprintf(fp, "`define STARTUP_CR2 32'h%08x\n", bx_cpu.cr2);
    fprintf(fp, "`define STARTUP_CR3 32'h%08x\n", bx_cpu.cr3);

    fprintf(fp, "`define STARTUP_CFLAG  1'b%d\n", bx_cpu.getB_CF());
    fprintf(fp, "`define STARTUP_PFLAG  1'b%d\n", bx_cpu.getB_PF());
    fprintf(fp, "`define STARTUP_AFLAG  1'b%d\n", bx_cpu.getB_AF());
    fprintf(fp, "`define STARTUP_ZFLAG  1'b%d\n", bx_cpu.getB_ZF());
    fprintf(fp, "`define STARTUP_SFLAG  1'b%d\n", bx_cpu.getB_SF());
    fprintf(fp, "`define STARTUP_OFLAG  1'b%d\n", bx_cpu.getB_OF()&1);
    fprintf(fp, "`define STARTUP_TFLAG  1'b%d\n", bx_cpu.getB_TF()&1);
    fprintf(fp, "`define STARTUP_IFLAG  1'b%d\n", bx_cpu.getB_IF()&1);
    fprintf(fp, "`define STARTUP_DFLAG  1'b%d\n", bx_cpu.getB_DF()&1);
    fprintf(fp, "`define STARTUP_IOPL   2'd%d\n", bx_cpu.get_IOPL()&3);
    fprintf(fp, "`define STARTUP_NTFLAG 1'b%d\n", bx_cpu.getB_NT()&1);
    fprintf(fp, "`define STARTUP_VMFLAG 1'b%d\n", bx_cpu.getB_VM()&1);
    fprintf(fp, "`define STARTUP_ACFLAG 1'b%d\n", bx_cpu.getB_AC()&1);
    fprintf(fp, "`define STARTUP_IDFLAG 1'b%d\n", bx_cpu.getB_ID()&1);
    fprintf(fp, "`define STARTUP_RFLAG  1'b%d\n", bx_cpu.getB_RF()&1);

    fprintf(fp, "`define STARTUP_GDTR_BASE  32'h%08x\n", bx_cpu.gdtr.base);
    fprintf(fp, "`define STARTUP_GDTR_LIMIT 16'h%04x\n", bx_cpu.gdtr.limit & 0xFFFF);
    
    fprintf(fp, "`define STARTUP_IDTR_BASE  32'h%08x\n", bx_cpu.idtr.base);
    fprintf(fp, "`define STARTUP_IDTR_LIMIT 16'h%04x\n", bx_cpu.idtr.limit & 0xFFFF);

    fprintf(fp, "`define STARTUP_DR0 32'h%08x\n", bx_cpu.dr[0]);
    fprintf(fp, "`define STARTUP_DR1 32'h%08x\n", bx_cpu.dr[1]);
    fprintf(fp, "`define STARTUP_DR2 32'h%08x\n", bx_cpu.dr[2]);
    fprintf(fp, "`define STARTUP_DR3 32'h%08x\n", bx_cpu.dr[3]);
    
    fprintf(fp, "`define STARTUP_DR6_BREAKPOINTS 4'h%01x\n", bx_cpu.dr6.val32 & 0xF);
    fprintf(fp, "`define STARTUP_DR6_B12         1'b%01x\n", (bx_cpu.dr6.val32 >> 12) & 0x1);
    fprintf(fp, "`define STARTUP_DR6_BD          1'b%01x\n", (bx_cpu.dr6.val32 >> 13) & 0x1);
    fprintf(fp, "`define STARTUP_DR6_BS          1'b%01x\n", (bx_cpu.dr6.val32 >> 14) & 0x1);
    fprintf(fp, "`define STARTUP_DR6_BT          1'b%01x\n", (bx_cpu.dr6.val32 >> 15) & 0x1);
    fprintf(fp, "`define STARTUP_DR7            32'h%08x\n", bx_cpu.dr7.val32);
    
    fprintf(fp, "`define STARTUP_ES   16'h%04x\n", bx_cpu.sregs[BX_SEG_REG_ES].selector.value);
    fprintf(fp, "`define STARTUP_DS   16'h%04x\n", bx_cpu.sregs[BX_SEG_REG_DS].selector.value);
    fprintf(fp, "`define STARTUP_SS   16'h%04x\n", bx_cpu.sregs[BX_SEG_REG_SS].selector.value);
    fprintf(fp, "`define STARTUP_FS   16'h%04x\n", bx_cpu.sregs[BX_SEG_REG_FS].selector.value);
    fprintf(fp, "`define STARTUP_GS   16'h%04x\n", bx_cpu.sregs[BX_SEG_REG_GS].selector.value);
    fprintf(fp, "`define STARTUP_CS   16'h%04x\n", bx_cpu.sregs[BX_SEG_REG_CS].selector.value);
    fprintf(fp, "`define STARTUP_LDTR 16'h%04x\n", bx_cpu.ldtr.selector.value);
    fprintf(fp, "`define STARTUP_TR   16'h%04x\n", bx_cpu.tr.selector.value);
    
    fprintf(fp, "`define STARTUP_ES_RPL   2'd%d\n", bx_cpu.sregs[BX_SEG_REG_ES].selector.rpl);
    fprintf(fp, "`define STARTUP_DS_RPL   2'd%d\n", bx_cpu.sregs[BX_SEG_REG_DS].selector.rpl);
    fprintf(fp, "`define STARTUP_SS_RPL   2'd%d\n", bx_cpu.sregs[BX_SEG_REG_SS].selector.rpl);
    fprintf(fp, "`define STARTUP_FS_RPL   2'd%d\n", bx_cpu.sregs[BX_SEG_REG_FS].selector.rpl);
    fprintf(fp, "`define STARTUP_GS_RPL   2'd%d\n", bx_cpu.sregs[BX_SEG_REG_GS].selector.rpl);
    fprintf(fp, "`define STARTUP_CS_RPL   2'd%d\n", bx_cpu.sregs[BX_SEG_REG_CS].selector.rpl);
    fprintf(fp, "`define STARTUP_LDTR_RPL 2'd%d\n", bx_cpu.ldtr.selector.rpl);
    fprintf(fp, "`define STARTUP_TR_RPL   2'd%d\n", bx_cpu.tr.selector.rpl);
    
    fprintf(fp, "`define STARTUP_ES_CACHE   64'h%08x%08x\n", seg_word_1(&(bx_cpu.sregs[BX_SEG_REG_ES])), seg_word_2(&(bx_cpu.sregs[BX_SEG_REG_ES])));
    fprintf(fp, "`define STARTUP_DS_CACHE   64'h%08x%08x\n", seg_word_1(&(bx_cpu.sregs[BX_SEG_REG_DS])), seg_word_2(&(bx_cpu.sregs[BX_SEG_REG_DS])));
    fprintf(fp, "`define STARTUP_SS_CACHE   64'h%08x%08x\n", seg_word_1(&(bx_cpu.sregs[BX_SEG_REG_SS])), seg_word_2(&(bx_cpu.sregs[BX_SEG_REG_SS])));
    fprintf(fp, "`define STARTUP_FS_CACHE   64'h%08x%08x\n", seg_word_1(&(bx_cpu.sregs[BX_SEG_REG_FS])), seg_word_2(&(bx_cpu.sregs[BX_SEG_REG_FS])));
    fprintf(fp, "`define STARTUP_GS_CACHE   64'h%08x%08x\n", seg_word_1(&(bx_cpu.sregs[BX_SEG_REG_GS])), seg_word_2(&(bx_cpu.sregs[BX_SEG_REG_GS])));
    fprintf(fp, "`define STARTUP_CS_CACHE   64'h%08x%08x\n", seg_word_1(&(bx_cpu.sregs[BX_SEG_REG_CS])), seg_word_2(&(bx_cpu.sregs[BX_SEG_REG_CS])));
    fprintf(fp, "`define STARTUP_LDTR_CACHE 64'h%08x%08x\n", seg_word_1(&(bx_cpu.ldtr)),                 seg_word_2(&(bx_cpu.ldtr)));
    fprintf(fp, "`define STARTUP_TR_CACHE   64'h%08x%08x\n", seg_word_1(&(bx_cpu.tr)),                   seg_word_2(&(bx_cpu.tr)));
    
    fprintf(fp, "`define STARTUP_ES_VALID   1'b%d\n", bx_cpu.sregs[BX_SEG_REG_ES].cache.valid & 1);
    fprintf(fp, "`define STARTUP_DS_VALID   1'b%d\n", bx_cpu.sregs[BX_SEG_REG_DS].cache.valid & 1);
    fprintf(fp, "`define STARTUP_SS_VALID   1'b%d\n", bx_cpu.sregs[BX_SEG_REG_SS].cache.valid & 1);
    fprintf(fp, "`define STARTUP_FS_VALID   1'b%d\n", bx_cpu.sregs[BX_SEG_REG_FS].cache.valid & 1);
    fprintf(fp, "`define STARTUP_GS_VALID   1'b%d\n", bx_cpu.sregs[BX_SEG_REG_GS].cache.valid & 1);
    fprintf(fp, "`define STARTUP_CS_VALID   1'b%d\n", bx_cpu.sregs[BX_SEG_REG_CS].cache.valid & 1);
    fprintf(fp, "`define STARTUP_LDTR_VALID 1'b%d\n", bx_cpu.ldtr.cache.valid & 1);
    fprintf(fp, "`define STARTUP_TR_VALID   1'b%d\n", bx_cpu.tr.cache.valid & 1);
    
    fprintf(fp, "`define STARTUP_EIP 32'h%08x\n", bx_cpu.gen_reg[BX_32BIT_REG_EIP].dword.erx);
    
    fprintf(fp, "`define STARTUP_PREFETCH_LIMIT  32'h%08x\n",
            (bx_cpu.sregs[BX_SEG_REG_CS].cache.u.segment.limit_scaled >> (bx_cpu.sregs[BX_SEG_REG_CS].cache.u.segment.g? 12 : 0)) - bx_cpu.gen_reg[BX_32BIT_REG_EIP].dword.erx + 1);
    fprintf(fp, "`define STARTUP_PREFETCH_LINEAR 32'h%08x\n",
            bx_cpu.sregs[BX_SEG_REG_CS].cache.u.segment.base + bx_cpu.gen_reg[BX_32BIT_REG_EIP].dword.erx);
    
    fflush(fp);
    fclose(fp);
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


bool intr_pending = false;

void bx_instr_interrupt(unsigned cpu, unsigned vector, unsigned type, bx_bool push_error, Bit16u error_code) {
    
    bochs486_skip_rep_finish = false;
    if(type == BX_EXTERNAL_INTERRUPT) intr_pending = false;
    
    if(type == BX_HARDWARE_EXCEPTION || type == BX_EXTERNAL_INTERRUPT) {
        printf("bx_instr_interrupt(%d): %02x at %d\n", type, vector, shared_ptr->bochs486_pc.instr_counter);
        shared_ptr->bochs486_pc.instr_counter++;
        
        if(type != BX_EXTERNAL_INTERRUPT) {
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "Exception 0x%02x at %x\n", vector, shared_ptr->bochs486_pc.instr_counter);
            fclose(fp);
        }
        
        if(shared_ptr->bochs486_pc.instr_counter == shared_ptr->interrupt_at_counter) {
            interrupt_vector = shared_ptr->interrupt_vector;
            
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "IAC 0x%02x at %x\n", vector, shared_ptr->bochs486_pc.instr_counter);
            fclose(fp);
            
printf("raise_INTR(): %02x at %d\n", interrupt_vector, shared_ptr->bochs486_pc.instr_counter);
            bx_cpu.raise_INTR();
            intr_pending = true;
        }
        else if(intr_pending && shared_ptr->interrupt_at_counter == 0) {
printf("clear_INTR() at %d\n", shared_ptr->bochs486_pc.instr_counter);
            bx_cpu.clear_INTR();
            intr_pending = false;
        }
    }
}

void instr_after_execution() {
    
    shared_ptr->bochs486_pc.instr_counter++;
    
bx_cpu.TLB_flush();
    
    if(shared_ptr->dump_enabled) {
        output_cpu_state();
    }
    
    if(shared_ptr->bochs486_pc.instr_counter == shared_ptr->interrupt_at_counter) {
        interrupt_vector = shared_ptr->interrupt_vector;
        
        FILE *fp = fopen("track.txt", "a");
        fprintf(fp, "IAC 0x%02x at %x\n", interrupt_vector, shared_ptr->bochs486_pc.instr_counter);
        fclose(fp);
        
printf("raise_INTR(): %02x at %d\n", interrupt_vector, shared_ptr->bochs486_pc.instr_counter);
        bx_cpu.raise_INTR();
        intr_pending = true;
    }
    else if(intr_pending && shared_ptr->interrupt_at_counter == 0) {
printf("clear_INTR() at %d\n", shared_ptr->bochs486_pc.instr_counter);
        bx_cpu.clear_INTR();
        intr_pending = false;
    }
    
    if(shared_ptr->bochs486_pc.stop == STEP_REQ && bochs486_skip_rep_finish == false) {
        printf("stopping...\n");
        output_cpu_state();
        fflush(stdout);
        
        output_for_verilator();
        
        shared_ptr->bochs486_pc.stop = STEP_ACK;
        while(shared_ptr->bochs486_pc.stop != STEP_IDLE) {
            usleep(500);
        }
    }
}

void bx_instr_before_execution(unsigned cpu, bxInstruction_c *i) {
    
//printf("cs: %04x eip: %08x len: %d op: %02x\n", bx_cpu.sregs[BX_SEG_REG_CS].selector.value, bx_cpu.gen_reg[BX_32BIT_REG_EIP].dword.erx, i->ilen(), i->bochs486_opcode);
   
}

void bx_instr_after_execution(unsigned cpu, bxInstruction_c *i) {
//printf("AFT cs: %04x eip: %08x len: %d op: %02x\n", bx_cpu.sregs[BX_SEG_REG_CS].selector.value, bx_cpu.gen_reg[BX_32BIT_REG_EIP].dword.erx, i->ilen(), i->bochs486_opcode);    
        
    if(bochs486_skip_rep_finish) {
        printf("#bx_instr_after_execution: bochs486_skip_rep_finished at %d\n", shared_ptr->bochs486_pc.instr_counter);
        bochs486_skip_rep_finish = false;
        return;
    }
    
printf("#instr: %02x %d\n", i->bochs486_opcode, shared_ptr->bochs486_pc.instr_counter);

    instr_after_execution();
}
void bx_instr_repeat_iteration(unsigned cpu, bxInstruction_c *i) {
    bochs486_skip_rep_finish = true;
    
printf("#repeat: %d\n", shared_ptr->bochs486_pc.instr_counter);
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
    
    //map shared memory
    int fd = open("./../sim/sim_pc/shared_mem.dat", O_RDWR, S_IRUSR | S_IWUSR);
    
    if(fd == -1) {
        perror("open() failed for shared_mem.dat");
        return -1;
    }
    
    shared_ptr = (shared_mem_t *)mmap(NULL, sizeof(shared_mem_t), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    
    if(shared_ptr == MAP_FAILED) {
        perror("mmap() failed");
        close(fd);
        return -2;
    }
    
    //wait for ack
    shared_ptr->bochs486_pc.starting = STEP_REQ;
    printf("Waiting for startup ack...");
    fflush(stdout);
    while(shared_ptr->bochs486_pc.starting != STEP_ACK) {
        usleep(100000);
    }
    printf("done.\n");
    
    
    
    bx_pc_system.a20_mask = 0xFFFFFFFF;

    SIM = new bochs486_sim();

    bx_cpu.initialize();
    bx_cpu.reset(BX_RESET_HARDWARE);
    
    printf("START\n");
    bx_cpu.gen_reg[BX_32BIT_REG_EDX].dword.erx = 0x0000045b; //after reset EDX value
    shared_ptr->bochs486_pc.instr_counter++; //ao486 has extra instruction at 0xFFFFFFF0
    
    bx_cpu.async_event = 0;
    bx_cpu.handleCpuModeChange();

    bx_cpu.cpu_loop();
    
    printf("#bochs486_pc: finishing.\n");
    
    munmap((void *)shared_ptr, sizeof(shared_mem_t));
    close(fd);
    
    return 0;
}
