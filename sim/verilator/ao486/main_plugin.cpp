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

#include "shared_mem.h"

//------------------------------------------------------------------------------

volatile shared_mem_t *shared_ptr = NULL;

//------------------------------------------------------------------------------

int main(int argc, char **argv) {
    //map shared memory
    int fd = open("./../../../sim/sim_pc/shared_mem.dat", O_RDWR, S_IRUSR | S_IWUSR);
    
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
    shared_ptr->ao486.starting = STEP_REQ;
    printf("Waiting for startup ack...");
    fflush(stdout);
    while(shared_ptr->ao486.starting != STEP_ACK) {
        usleep(100000);
    }
    printf("done.\n");

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
    
    uint32 ignored_intr_counter = 0;
    
    //--------------------------------------------------------------------------
    
    uint64 cycle = 0;
    
    char irq_txt[256];
    int  irq_delay = 0;
    
    while(!Verilated::gotFinish()) {
        
        //----------------------------------------------------------------------
        if(top->tb_finish_instr) {
            shared_ptr->ao486.instr_counter++;
            
            if(shared_ptr->ao486.stop == STEP_REQ) {
                shared_ptr->ao486.stop = STEP_ACK;
                while(shared_ptr->ao486.stop != STEP_IDLE) {
                    usleep(500);
                }
            }
        }
        
        //---------------------------------------------------------------------- sdram
        
        top->sdram_readdatavalid = 0;
        
        if(top->sdram_read) {
            uint32 address = top->sdram_address & 0x07FFFFFC;
            
            for(uint32 i=0; i<4; i++) {
                sdram_read_data[i] = shared_ptr->mem.ints[(address + i*4)/4];
                
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
            
printf("sdram write: %08x %x %08x %d", address, top->sdram_byteenable, data, sdram_write_count);

            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "mem wr %08x %x %08x\n", address, top->sdram_byteenable, data);
            fclose(fp);

            shared_ptr->ao486.mem_address    = address;
            shared_ptr->ao486.mem_byteenable = top->sdram_byteenable;
            shared_ptr->ao486.mem_is_write   = 1;
            shared_ptr->ao486.mem_data       = data;
            shared_ptr->ao486.mem_step       = STEP_REQ;
            while(shared_ptr->ao486.mem_step != STEP_ACK) {
                fflush(stdout);
                usleep(10);
            }
            shared_ptr->ao486.mem_step = STEP_IDLE;
            
            if(sdram_write_count == 0) {
                sdram_write_address = (address + 4) & 0x07FFFFFC;
                sdram_write_count = top->sdram_burstcount;
            }
            
            if(sdram_write_count > 0) sdram_write_count--;
printf("\n");
        }
        
        //---------------------------------------------------------------------- vga
        
        top->vga_readdatavalid = 0;
        
        if(top->vga_read) {
            vga_read_address = top->vga_address & 0x000FFFFC;

            vga_read_count = top->vga_burstcount;
            vga_read_byteenable = top->vga_byteenable;
printf("vga read: %08x %x %d\n", vga_read_address, vga_read_byteenable, vga_read_count);
        }
        else if(vga_read_count > 0) {
            shared_ptr->ao486.mem_address    = vga_read_address;
            shared_ptr->ao486.mem_byteenable = vga_read_byteenable;
            shared_ptr->ao486.mem_is_write   = 0;
            shared_ptr->ao486.mem_step       = STEP_REQ;
            while(shared_ptr->ao486.mem_step != STEP_ACK) {
                fflush(stdout);
                usleep(10);
            }
            uint32 value = shared_ptr->ao486.mem_data;
            shared_ptr->ao486.mem_step = STEP_IDLE;
            
            top->vga_readdatavalid = 1;
            top->vga_readdata = value;
            
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "mem rd %08x %x %08x\n", vga_read_address, vga_read_byteenable, value);
            fclose(fp);
            
            vga_read_address = (vga_read_address + 4) & 0x000FFFFC;
            vga_read_count--;
printf("\n");
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
            
printf("vga write: %08x %x %08x %d", address, top->sdram_byteenable, data, vga_write_count);
            shared_ptr->ao486.mem_address    = address;
            shared_ptr->ao486.mem_byteenable = top->vga_byteenable;
            shared_ptr->ao486.mem_is_write   = 1;
            shared_ptr->ao486.mem_data       = data;
            shared_ptr->ao486.mem_step       = STEP_REQ;
            while(shared_ptr->ao486.mem_step != STEP_ACK) {
                fflush(stdout);
                usleep(10);
            }
            shared_ptr->ao486.mem_step = STEP_IDLE;
            
            if(vga_write_count == 0) {
                vga_write_address = (address + 4) & 0x07FFFFFC;
                vga_write_count = top->vga_burstcount;
            }
            
            if(vga_write_count > 0) vga_write_count--;
printf("\n", vga_write_count);
        }
        
        //---------------------------------------------------------------------- io
        
        top->avalon_io_readdatavalid = 0;
        
        if(top->avalon_io_read) {
            io_read_address = top->avalon_io_address & 0x0000FFFC;

            io_read_count = 1;
            io_read_byteenable = top->avalon_io_byteenable;
printf("io read: %08x %x %d", io_read_address, io_read_byteenable, io_read_count);
        }
        else if(io_read_count > 0) {
            shared_ptr->ao486.io_address    = io_read_address;
            shared_ptr->ao486.io_byteenable = io_read_byteenable;
            shared_ptr->ao486.io_is_write   = 0;
            shared_ptr->ao486.io_step       = STEP_REQ;
            while(shared_ptr->ao486.io_step != STEP_ACK) {
                fflush(stdout);
                usleep(10);
            }
            uint32 value = shared_ptr->ao486.io_data;
            shared_ptr->ao486.io_step = STEP_IDLE;
            
            FILE *fp = fopen("track.txt", "a");
            fprintf(fp, "io rd %04x %x %08x\n", io_read_address, io_read_byteenable, value);
            fclose(fp);
            
//if(io_read_address == 0x01F0 && io_read_byteenable == 0xF && value == 0x655301c6) shared_ptr->dump_enabled = 1;
            
            top->avalon_io_readdatavalid = 1;
            top->avalon_io_readdata = value;
            
            io_read_count--;
printf("\n");
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
            
printf("io write: %08x %x %08x", (top->avalon_io_address & 0x0000FFFC), top->avalon_io_byteenable, data);
            shared_ptr->ao486.io_address    = top->avalon_io_address & 0x0000FFFC;
            shared_ptr->ao486.io_byteenable = top->avalon_io_byteenable;
            shared_ptr->ao486.io_is_write   = 1;
            shared_ptr->ao486.io_data       = data;
            shared_ptr->ao486.io_step       = STEP_REQ;
            while(shared_ptr->ao486.io_step != STEP_ACK) {
                fflush(stdout);
                usleep(10);
            }
            shared_ptr->ao486.io_step = STEP_IDLE;
printf("\n");
        }
        
        //---------------------------------------------------------------------- interrupt
        
        uint32 vec = shared_ptr->irq_do_vector;
        top->interrupt_vector = vec;
        top->interrupt_do     = (shared_ptr->irq_do == STEP_REQ)? 1 : 0;
        
        if(top->interrupt_done && shared_ptr->irq_done == STEP_IDLE) {
            shared_ptr->irq_done_vector = vec;
            shared_ptr->irq_done = STEP_REQ;
            
            const char *txt = "";
            
            if(shared_ptr->irq_do == STEP_IDLE)     txt = "-spurIDLE";
            else if(shared_ptr->irq_do == STEP_ACK) txt = "-spurACK";
            
            sprintf(irq_txt, "IAC%s 0x%02x at %d\n", txt, vec, shared_ptr->ao486.instr_counter);
            irq_delay = 3;
            
            shared_ptr->irq_do = STEP_ACK;
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
            fprintf(fp, "Exception 0x%02x at %d\n", top->dbg_exc_vector, shared_ptr->ao486.instr_counter);
            fclose(fp);
        }
        
        //----------------------------------------------------------------------
        
        if(shared_ptr->dump_enabled == 0 && fopen("start", "rb") != NULL) shared_ptr->dump_enabled = 1;
        //else if(cycle > 142400000 || shared_ptr->ao486.instr_counter > 7720000) shared_ptr->dump_enabled = 1;
        //else if(shared_ptr->ao486.instr_counter > 712000) shared_ptr->dump_enabled = 1;
        
        //if(shared_ptr->ao486.instr_counter >= 11000000 && shared_ptr->ao486.instr_counter <= 13000000) shared_ptr->dump_enabled = 1;
        //else shared_ptr->dump_enabled = 0;
        
        //12032233
            
        //shared_ptr->dump_enabled = 1;
        
        top->clk = 0;
        top->eval();
        
        if(shared_ptr->dump_enabled) tracer->dump(cycle++);
        
        top->clk = 1;
        top->eval();
        
        if(shared_ptr->dump_enabled) tracer->dump(cycle++);
        
        if((cycle % 10000) == 0) printf("half-cycle: %lld\n", cycle);
        
        //12320000
       
        tracer->flush();
        //usleep(1);
    }
    delete top;
    return 0;
}

/*
    uint32 interrupt_vector;
    uint64 interrupt_timestamp;
    uint32 interrupt_valid;
    
    ----
    
    VL_IN8(clk,0,0);
    VL_IN8(rst_n,0,0);
    
    VL_IN8(interrupt_do,0,0);
    VL_IN8(interrupt_vector,7,0);
    VL_OUT8(interrupt_done,0,0);
    
    VL_OUT8(avalon_io_byteenable,3,0);
    VL_OUT8(avalon_io_read,0,0);
    VL_IN8(avalon_io_readdatavalid,0,0);
    VL_OUT8(avalon_io_write,0,0);
    VL_IN8(avalon_io_waitrequest,0,0);
    VL_OUT16(avalon_io_address,15,0);
    VL_IN(avalon_io_readdata,31,0);
    VL_OUT(avalon_io_writedata,31,0);
    
    VL_OUT8(sdram_byteenable,3,0);
    VL_OUT8(sdram_read,0,0);
    VL_OUT8(sdram_write,0,0);
    VL_OUT8(sdram_burstcount,2,0);
    VL_OUT(sdram_address,31,0);
    VL_OUT(sdram_writedata,31,0);
    VL_IN8(sdram_waitrequest,0,0);
    VL_IN8(sdram_readdatavalid,0,0);
    VL_IN(sdram_readdata,31,0);
    
    VL_OUT8(vga_byteenable,3,0);
    VL_OUT8(vga_read,0,0);
    VL_OUT8(vga_write,0,0);
    VL_IN8(vga_waitrequest,0,0);
    VL_IN8(vga_readdatavalid,0,0);
    VL_OUT8(vga_burstcount,2,0);
    VL_OUT(vga_address,31,0);
    VL_IN(vga_readdata,31,0);
    VL_OUT(vga_writedata,31,0);
*/
