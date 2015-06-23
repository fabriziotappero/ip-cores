#include <cstdio>
#include <cstdlib>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vmain.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

typedef unsigned char  uint8;
typedef unsigned short uint16;
typedef unsigned int   uint32;
typedef unsigned long  uint64;

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
        fprintf(stderr, "#ao486_reader: error opening file: %s\n", name);
        exit(-1);
    }
    
    int int_ret = fseek(fp, 0, SEEK_END);
    if(int_ret != 0) {
        fclose(fp);
        fprintf(stderr, "#ao486_reader: error stat file: %s\n", name);
        exit(-1);
    }
    
    long size = ftell(fp);
    rewind(fp);
    
    int_ret = fread((void *)&check_memory.bytes[byte_location], size, 1, fp);
    if(int_ret != 1) {
        fclose(fp);
        fprintf(stderr, "#ao486_reader: error loading file: %s\n", name);
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

void check_look_ahead_fp() {
    uint64 curr_pos = ftell(check_fp);
    
    char line[256];
    check_read_fp(line);
    check_read_fp(line);
    check_read_fp(line);
    
    int ret = fseek(check_fp, curr_pos, SEEK_SET); 
    if(ret != 0) {
        fprintf(stderr, "#ao486_reader: can not seek reader file.\n");
        exit(-1);
    }
}

uint64 total_size = 0;
uint64 last_percent = 0;

void check_init() {
    if(check_fp == NULL) {
        //const char *filename = "./../backup/run-10/track.txt";
        const char *filename = "./../../../ao486/io_win95pipeline_1.txt";
        
        check_fp = fopen(filename, "rb");
        if(check_fp == NULL) {
            fprintf(stderr, "#ao486_reader: can not open reader file.\n");
            exit(-1);
        }
        
        struct stat st;
        memset(&st, 0, sizeof(struct stat));
        stat(filename, &st);
        total_size = st.st_size;
        fprintf(stderr, "#ao486_reader: total file size: %d\n", total_size);
    }
    
    uint64 curr_pos = ftell(check_fp);
    uint64 curr_percent = curr_pos * 100 / total_size;
    if(curr_percent != last_percent) {
        last_percent = curr_percent;
        fprintf(stderr, "#ao486_reader: %d percent\n", (uint32)last_percent);
    }
    
    if(check_state == 0) { 
        if(check_read_fp(check_line) == false) {
            fprintf(stderr, "#ao486_reader: EOF\n");
            exit(0);
        }
        if(check_read_fp(check_next) == false) {
            check_state = 1;
            return;
        }
        check_state = 2;
    }
    else if(check_state == 1) {
        fprintf(stderr, "#ao486_reader: EOF\n");
        exit(0);
    }
    else if(check_state == 2) {
        memcpy(check_line, check_next, 256);
        
        if(check_read_fp(check_next) == false) {
            check_state = 1;
            return;
        }
        
        check_look_ahead_fp();
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

int main(int argc, char **argv) {
    
    load_file("./../../../sd/bios/bochs_legacy",    0xF0000);
    load_file("./../../../sd/vgabios/vgabios_lgpl", 0xC0000);
    
    {
        FILE *fp = fopen("track.txt", "w");
        fclose(fp);
        
        fp = fopen("interrupt.txt", "w");
        fclose(fp);
    }
    //--------------------------------------------------------------------------
    
    
    Verilated::commandArgs(argc, argv);
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* tracer = new VerilatedVcdC;
    
    Vmain *top = new Vmain();
    top->trace (tracer, 99);
//    tracer->rolloverMB(1000000);
    tracer->open("ao486.vcd");
//tracer->flush();
//return 0;
    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    //--------------------------------------------------------------------------
    
    uint32 sdram_read_count = 0;
    uint32 sdram_read_data[4];
    
    uint32 sdram_write_count = 0;
    uint32 sdram_write_address = 0;
    
    uint32 vga_read_count = 0;
    uint32 vga_read_address = 0;
    uint32 vga_read_byteenable = 0;
    
    uint32 vga_write_count = 0;
    uint32 vga_write_address = 0;
    
    uint32 io_read_count = 0;
    uint32 io_read_address = 0;
    uint32 io_read_byteenable = 0;
    
    uint32 dump_enabled = 0;
    
    //--------------------------------------------------------------------------
    
    uint64 cycle = 0;
    
    char irq_txt[256];
    int  irq_delay = 0;
    
    while(!Verilated::gotFinish()) {
        
        //---------------------------------------------------------------------- sdram
        
        top->sdram_readdatavalid = 0;
        
        if(top->sdram_read) {
            uint32 address = top->sdram_address & 0x07FFFFFC;
            
            for(uint32 i=0; i<4; i++) {
                sdram_read_data[i] = check_memory.ints[(address + i*4)/4];
                
                if(((top->sdram_byteenable >> 0) & 1) == 0) sdram_read_data[i] &= 0xFFFFFF00;
                if(((top->sdram_byteenable >> 1) & 1) == 0) sdram_read_data[i] &= 0xFFFF00FF;
                if(((top->sdram_byteenable >> 2) & 1) == 0) sdram_read_data[i] &= 0xFF00FFFF;
                if(((top->sdram_byteenable >> 3) & 1) == 0) sdram_read_data[i] &= 0x00FFFFFF;
            }
            sdram_read_count = top->sdram_burstcount;
            
//printf("sdram read: %08x %x [%08x %08x %08x %08x]\n", address, top->sdram_byteenable, sdram_read_data[0], sdram_read_data[1], sdram_read_data[2], sdram_read_data[3]);
        }
        else if(sdram_read_count > 0) {
            top->sdram_readdatavalid = 1;
            top->sdram_readdata = sdram_read_data[0];
//printf("r: %08x\n", top->sdram_readdata);
            memmove(sdram_read_data, &sdram_read_data[1], sizeof(sdram_read_data)-sizeof(uint32));
            sdram_read_count--;
        }
        
        if(top->sdram_write) {
            uint32 address = (sdram_write_count > 0)? sdram_write_address : top->sdram_address & 0x07FFFFFC;
            uint32 data = top->sdram_writedata;
            
            if((top->sdram_byteenable & 0x1) == 0) data &= 0xFFFFFF00;
            if((top->sdram_byteenable & 0x2) == 0) data &= 0xFFFF00FF;
            if((top->sdram_byteenable & 0x4) == 0) data &= 0xFF00FFFF;
            if((top->sdram_byteenable & 0x8) == 0) data &= 0x00FFFFFF;
            
printf("mem wr: %08x %x %08x %d\n", address, top->sdram_byteenable, data, sdram_write_count);

            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "mem wr %08x %x %08x\n", address, top->sdram_byteenable, data);
            fclose(fp);
            
            check_mem_wr(address, top->sdram_byteenable, data);
            
            if(sdram_write_count == 0) {
                sdram_write_address = (address + 4) & 0x07FFFFFC;
                sdram_write_count = top->sdram_burstcount;
            }
            
            if(sdram_write_count > 0) sdram_write_count--;
        }
        
        //---------------------------------------------------------------------- vga
        
        top->vga_readdatavalid = 0;
        
        if(top->vga_read) {
            vga_read_address = top->vga_address & 0x000FFFFC;

            vga_read_count = top->vga_burstcount;
            vga_read_byteenable = top->vga_byteenable;
printf("mem rd: %08x %x %d\n", vga_read_address, vga_read_byteenable, vga_read_count);
        }
        else if(vga_read_count > 0) {
            
            uint32 value = check_mem_rd(vga_read_address, vga_read_byteenable);
            
            top->vga_readdatavalid = 1;
            top->vga_readdata = value;
            
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "mem rd %08x %x %08x\n", vga_read_address, vga_read_byteenable, value);
            fclose(fp);
            
            vga_read_address = (vga_read_address + 4) & 0x000FFFFC;
            vga_read_count--;
        }
        
        if(top->vga_write) {
            uint32 address = (vga_write_count > 0)? vga_write_address : top->vga_address & 0x000FFFFC;
            uint32 data = top->vga_writedata;
            
            if((top->vga_byteenable & 0x1) == 0) data &= 0xFFFFFF00;
            if((top->vga_byteenable & 0x2) == 0) data &= 0xFFFF00FF;
            if((top->vga_byteenable & 0x4) == 0) data &= 0xFF00FFFF;
            if((top->vga_byteenable & 0x8) == 0) data &= 0x00FFFFFF;
            
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "mem wr %08x %x %08x\n", address, top->sdram_byteenable, data);
            fclose(fp);
            
printf("mem wr: %08x %x %08x %d\n", address, top->sdram_byteenable, data, vga_write_count);

            check_mem_wr(address, top->vga_byteenable, data);
            
            if(vga_write_count == 0) {
                vga_write_address = (address + 4) & 0x07FFFFFC;
                vga_write_count = top->vga_burstcount;
            }
            
            if(vga_write_count > 0) vga_write_count--;
        }
        
        //---------------------------------------------------------------------- io
        
        top->avalon_io_readdatavalid = 0;
        
        if(top->avalon_io_read) {
            io_read_address = top->avalon_io_address & 0x0000FFFC;

            io_read_count = 1;
            io_read_byteenable = top->avalon_io_byteenable;
printf("io rd: %08x %x %d\n", io_read_address, io_read_byteenable, io_read_count);
        }
        else if(io_read_count > 0) {
            
            uint32 value = check_io_rd(io_read_address, io_read_byteenable);
            
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "io rd %04x %x %08x\n", io_read_address, io_read_byteenable, value);
            fclose(fp);
            
//if(io_read_address == 0x01F0 && io_read_byteenable == 0xF && value == 0x655301c6) shared_ptr->dump_enabled = 1;
            
            top->avalon_io_readdatavalid = 1;
            top->avalon_io_readdata = value;
            
            io_read_count--;
        }
        
        if(top->avalon_io_write) {
            uint32 data = top->avalon_io_writedata;
            
            if((top->avalon_io_byteenable & 0x1) == 0) data &= 0xFFFFFF00;
            if((top->avalon_io_byteenable & 0x2) == 0) data &= 0xFFFF00FF;
            if((top->avalon_io_byteenable & 0x4) == 0) data &= 0xFF00FFFF;
            if((top->avalon_io_byteenable & 0x8) == 0) data &= 0x00FFFFFF;
            
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "io wr %04x %x %08x\n", top->avalon_io_address & 0x0000FFFC, top->avalon_io_byteenable, data);
            fclose(fp);
            
printf("io wr: %08x %x %08x\n", (top->avalon_io_address & 0x0000FFFC), top->avalon_io_byteenable, data);

            check_io_wr(top->avalon_io_address & 0x0000FFFC, top->avalon_io_byteenable, data);
        }
        
        //----------------------------------------------------------------------
        if(top->tb_finish_instr) instr_counter++;
        
if(instr_counter >= 77020000) dump_enabled = 1;
//11490000
        //---------------------------------------------------------------------- interrupt
        
        top->interrupt_vector = check_next_irq_vector;
        top->interrupt_do     = (instr_counter == check_next_irq_at)? 1 : 0;
        
        if(top->interrupt_done) {
            sprintf(irq_txt, "IAC 0x%02x at %d\n", check_next_irq_vector, instr_counter);
            irq_delay = 3;
        }
        else if(irq_delay > 0) {
            if(irq_delay == 1) {
                FILE *fp = fopen("track.txt", "a");
                fprintf(fp, irq_txt);
                fclose(fp);

                fp = fopen("interrupt.txt", "a");
                fprintf(fp, irq_txt);
                fclose(fp);
            }
            
            irq_delay--;
        }
        
        //---------------------------------------------------------------------- exception
        
        if(top->dbg_exc) {
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "Exception 0x%02x at %d\n", top->dbg_exc_vector, instr_counter);
            fclose(fp);
        }
        
        //----------------------------------------------------------------------
        
        if(dump_enabled == 0 && fopen("start", "rb") != NULL) dump_enabled = 1;
        
        top->clk = 0;
        top->eval();
        
        if(dump_enabled) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        
        if(dump_enabled) tracer->dump(cycle++);
        
        tracer->flush();
        
if(instr_counter >= 77026000) { fprintf(stderr, "#ao486_reader: test finished.\n"); exit(0); }
//11491275
        //usleep(1);
    }
    delete top;
    return 0;
}
