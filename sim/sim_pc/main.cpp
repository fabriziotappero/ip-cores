#include <cstdio>
#include <cstring>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "shared_mem.h"

volatile shared_mem_t *shared_ptr = NULL;

int load_file(const char *name, int byte_location) {
    FILE *fp = fopen(name, "rb");
    if(fp == NULL) {
        return -1;
    }
    
    int int_ret = fseek(fp, 0, SEEK_END);
    if(int_ret != 0) {
        fclose(fp);
        return -2;
    }
    
    long size = ftell(fp);
    rewind(fp);
    
    int_ret = fread((void *)&shared_ptr->mem.bytes[byte_location], size, 1, fp);
    if(int_ret != 1) {
        fclose(fp);
        return -3;
    }
    fclose(fp);
    
    return 0;
}

int main(int argc, char **argv) {
    
    int int_ret;
    
    //open file with truncate
    FILE *fp = fopen("shared_mem.dat", "wb");
    if(fp == NULL) {
        perror("Can not truncate file shared_mem.dat");
        return -1;
    }
    uint8 *buf = new uint8[sizeof(shared_mem_t)];
    memset(buf, 0, sizeof(shared_mem_t));
    
    int_ret = fwrite(buf, sizeof(shared_mem_t), 1, fp);
    delete buf;
    if(int_ret != 1) {
        perror("Can not zero-fill file shared_mem.dat");
        fclose(fp);
        return -2;
    }
    fclose(fp);
    
    int fd = open("shared_mem.dat", O_RDWR, S_IRUSR | S_IWUSR);
    
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
    
    //load bios
    int_ret = load_file("./../../sd/bios/bochs_legacy", 0xF0000);
    if(int_ret != 0) {
        perror("Can not load bios file");
        return -3;
    }
    
    //load vgabios
    int_ret = load_file("./../../sd/vgabios/vgabios_lgpl", 0xC0000);
    if(int_ret != 0) {
        perror("Can not load bios file");
        return -3;
    }
    
    //--------------------------------------------------------------------------
    
/*
    while(true) {
        if(shared_ptr->bochs486_pc.starting == STEP_REQ) {
            printf("Starting bochs486_pc.\n");
            shared_ptr->bochs486_pc.starting = STEP_ACK;
            break;
        }
    }  
*/
    while(true) {
        if(shared_ptr->ao486.starting == STEP_REQ) {
            printf("Starting ao486.\n");
            shared_ptr->ao486.starting = STEP_ACK;
            break;
        }
    }

/*
    while(true) {
        if(shared_ptr->bochsDevs_starting == STEP_REQ) {
            printf("Starting bochsDevs.\n");
            shared_ptr->bochsDevs_starting = STEP_ACK;
            break;
        }
    }
*/
    //--------------------------------------------------------------------------
    
    uint32 ctrl_io_read  = 0;
    uint32 ctrl_io_write = 0;
    
    uint32 ctrl_mem_read  = 0;
    uint32 ctrl_mem_write = 0;
    
    uint32 bochs486_pc_only = 0;
    uint32 ao486_only = 1;
    
    FILE *fp_stop = NULL;
    uint32 bochs486_stopped = 0;
    
    FILE *debug_fp = fopen("output.txt", "w");
    
    while(true) {
        
        //---------------------------------------------------------------------- stop control
        
        if(bochs486_stopped == 0) {
            if(fp_stop == NULL) fp_stop = fopen("ctrl_stop.do", "rb");
            if(fp_stop != NULL) {
                
                if(shared_ptr->bochs486_pc.stop == STEP_IDLE) {
                    shared_ptr->bochs486_pc.stop = STEP_REQ;
                }
                
                if(shared_ptr->bochs486_pc.stop == STEP_ACK) {
                    if(shared_ptr->bochs486_pc.instr_counter <= shared_ptr->interrupt_at_counter + 10) {
                        printf("Stop failed ..\n");
                        shared_ptr->bochs486_pc.stop = STEP_IDLE;
                        usleep(100000);
                    }
                    else {
                        printf("Stop ok.\n");
                        fclose(fp_stop);
                        fp_stop = NULL;
                        bochs486_stopped = 1;
                    }
                }
            }
        }
        if(bochs486_stopped == 1) {
            if(fp_stop == NULL) fp_stop = fopen("ctrl_stop.do", "rb");
            if(fp_stop != NULL) {
                fclose(fp_stop);
                fp_stop = NULL;
            }
            else {
                bochs486_stopped = 0;
                
                //wait for ack from ao486
                shared_ptr->ao486.instr_counter = shared_ptr->bochs486_pc.instr_counter;
                
                while(true) {
                    if(shared_ptr->ao486.starting == STEP_REQ) {
                        printf("Starting ao486.\n");
                        shared_ptr->ao486.starting = STEP_ACK;
                        break;
                    }
                }
                
                shared_ptr->bochs486_pc.stop = STEP_IDLE;
                
                bochs486_pc_only = 0; 
            }
            
        }
        
        //---------------------------------------------------------------------- control io read
        
        if(ctrl_io_read == 0) {
            if( (bochs486_pc_only && shared_ptr->bochs486_pc.io_step == STEP_REQ && shared_ptr->bochs486_pc.io_is_write == 0) ||
                (ao486_only       && shared_ptr->ao486.io_step == STEP_REQ       && shared_ptr->ao486.io_is_write == 0) || (
                shared_ptr->ao486.io_step == STEP_REQ && shared_ptr->bochs486_pc.io_step == STEP_REQ && shared_ptr->ao486.io_is_write == 0 &&
                    shared_ptr->ao486.io_address    == shared_ptr->bochs486_pc.io_address &&
                    shared_ptr->ao486.io_byteenable == shared_ptr->bochs486_pc.io_byteenable &&
                    shared_ptr->ao486.io_is_write   == shared_ptr->bochs486_pc.io_is_write &&
                    shared_ptr->ao486.io_step       == shared_ptr->bochs486_pc.io_step ) )
            {
                ctrl_io_read = 1;
                
                shared_ptr->combined.io_address    = (ao486_only)? shared_ptr->ao486.io_address : shared_ptr->bochs486_pc.io_address;
                shared_ptr->combined.io_byteenable = (ao486_only)? shared_ptr->ao486.io_byteenable : shared_ptr->bochs486_pc.io_byteenable;
                shared_ptr->combined.io_is_write   = 0;
                shared_ptr->combined.io_step       = STEP_REQ;
            }
        }
        
        if(ctrl_io_read == 1) {
            if(shared_ptr->combined.io_address == 0x888C) {
                ctrl_io_read = 0;
                
                if(bochs486_pc_only == 0) {
                    shared_ptr->ao486.io_data = 0xFFFFFFFF;
                    shared_ptr->ao486.io_step = STEP_ACK;
                }
                if(ao486_only == 0) {
                    shared_ptr->bochs486_pc.io_data = 0xFFFFFFFF;
                    shared_ptr->bochs486_pc.io_step = STEP_ACK;
                }
            }
            else if(shared_ptr->combined.io_step == STEP_ACK && shared_ptr->combined.io_is_write == 0) {
                ctrl_io_read = 0;
                
                if(bochs486_pc_only == 0) {
                    shared_ptr->ao486.io_data = shared_ptr->combined.io_data;
                    shared_ptr->ao486.io_step = STEP_ACK;
                }
                if(ao486_only == 0) {
                    shared_ptr->bochs486_pc.io_data = shared_ptr->combined.io_data;
                    shared_ptr->bochs486_pc.io_step = STEP_ACK;
                }
            }
        }
        
        //---------------------------------------------------------------------- control io write
        
        if(ctrl_io_write == 0) {
            if( (bochs486_pc_only && shared_ptr->bochs486_pc.io_step == STEP_REQ && shared_ptr->bochs486_pc.io_is_write == 1) ||
                (ao486_only       && shared_ptr->ao486.io_step == STEP_REQ       && shared_ptr->ao486.io_is_write == 1) || (
                shared_ptr->ao486.io_step == STEP_REQ && shared_ptr->bochs486_pc.io_step == STEP_REQ && shared_ptr->ao486.io_is_write == 1 &&
                    shared_ptr->ao486.io_address    == shared_ptr->bochs486_pc.io_address &&
                    shared_ptr->ao486.io_data       == shared_ptr->bochs486_pc.io_data &&
                    shared_ptr->ao486.io_byteenable == shared_ptr->bochs486_pc.io_byteenable &&
                    shared_ptr->ao486.io_is_write   == shared_ptr->bochs486_pc.io_is_write &&
                    shared_ptr->ao486.io_step       == shared_ptr->bochs486_pc.io_step ) )
            {
                ctrl_io_write = 1;
                
                shared_ptr->combined.io_address    = (ao486_only)? shared_ptr->ao486.io_address : shared_ptr->bochs486_pc.io_address;
                shared_ptr->combined.io_data       = (ao486_only)? shared_ptr->ao486.io_data : shared_ptr->bochs486_pc.io_data;
                shared_ptr->combined.io_byteenable = (ao486_only)? shared_ptr->ao486.io_byteenable : shared_ptr->bochs486_pc.io_byteenable;
                shared_ptr->combined.io_is_write   = 1;
                shared_ptr->combined.io_step       = STEP_REQ;
            }
        }
        
        if(ctrl_io_write == 1) {
            if(shared_ptr->combined.io_address == 0x8888) {
                fprintf(debug_fp, "%c", shared_ptr->combined.io_data & 0xFF);
                fflush(debug_fp);
                
                ctrl_io_write = 0;
                
                if(bochs486_pc_only == 0) shared_ptr->ao486.io_step = STEP_ACK;
                if(ao486_only == 0)       shared_ptr->bochs486_pc.io_step = STEP_ACK;
            }
            else if(shared_ptr->combined.io_step == STEP_ACK && shared_ptr->combined.io_is_write == 1) {
                ctrl_io_write = 0;
                
                if(bochs486_pc_only == 0) shared_ptr->ao486.io_step = STEP_ACK;
                if(ao486_only == 0)       shared_ptr->bochs486_pc.io_step = STEP_ACK;
            }
        }
    
        //---------------------------------------------------------------------- control mem read
        
        if(ctrl_mem_read == 0) {
            if( (bochs486_pc_only && shared_ptr->bochs486_pc.mem_step == STEP_REQ && shared_ptr->bochs486_pc.mem_is_write == 0) ||
                (ao486_only       && shared_ptr->ao486.mem_step == STEP_REQ       && shared_ptr->ao486.mem_is_write == 0) || (
                shared_ptr->ao486.mem_step == STEP_REQ && shared_ptr->bochs486_pc.mem_step == STEP_REQ && shared_ptr->ao486.mem_is_write == 0 &&
                    shared_ptr->ao486.mem_address    == shared_ptr->bochs486_pc.mem_address &&
                    shared_ptr->ao486.mem_byteenable == shared_ptr->bochs486_pc.mem_byteenable &&
                    shared_ptr->ao486.mem_is_write   == shared_ptr->bochs486_pc.mem_is_write &&
                    shared_ptr->ao486.mem_step       == shared_ptr->bochs486_pc.mem_step ) )
            {
                ctrl_mem_read = 1;
                
                shared_ptr->combined.mem_address    = (ao486_only)? shared_ptr->ao486.mem_address : shared_ptr->bochs486_pc.mem_address;
                shared_ptr->combined.mem_byteenable = (ao486_only)? shared_ptr->ao486.mem_byteenable : shared_ptr->bochs486_pc.mem_byteenable;
                shared_ptr->combined.mem_is_write   = 0;
                shared_ptr->combined.mem_step       = STEP_REQ;
            }
        }
        
        if(ctrl_mem_read == 1) {
            if(shared_ptr->combined.mem_step == STEP_ACK && shared_ptr->combined.mem_is_write == 0) {
                ctrl_mem_read = 0;
                
                if(bochs486_pc_only == 0) {
                    shared_ptr->ao486.mem_data = shared_ptr->combined.mem_data;
                    shared_ptr->ao486.mem_step = STEP_ACK;
                }
                if(ao486_only == 0) {
                    shared_ptr->bochs486_pc.mem_data = shared_ptr->combined.mem_data;
                    shared_ptr->bochs486_pc.mem_step = STEP_ACK;
                } 
            }
        }
        
        //---------------------------------------------------------------------- control mem write
        
        if(ctrl_mem_write == 0) {
            if( (bochs486_pc_only && shared_ptr->bochs486_pc.mem_step == STEP_REQ && shared_ptr->bochs486_pc.mem_is_write == 1) ||
                (ao486_only       && shared_ptr->ao486.mem_step == STEP_REQ       && shared_ptr->ao486.mem_is_write == 1) || (
                shared_ptr->ao486.mem_step == STEP_REQ && shared_ptr->bochs486_pc.mem_step == STEP_REQ && shared_ptr->ao486.mem_is_write == 1 &&
                    shared_ptr->ao486.mem_address    == shared_ptr->bochs486_pc.mem_address &&
                    shared_ptr->ao486.mem_data       == shared_ptr->bochs486_pc.mem_data &&
                    shared_ptr->ao486.mem_byteenable == shared_ptr->bochs486_pc.mem_byteenable &&
                    shared_ptr->ao486.mem_is_write   == shared_ptr->bochs486_pc.mem_is_write &&
                    shared_ptr->ao486.mem_step       == shared_ptr->bochs486_pc.mem_step ) )
            {
                ctrl_mem_write = 1;
                
                shared_ptr->combined.mem_address    = (ao486_only)? shared_ptr->ao486.mem_address : shared_ptr->bochs486_pc.mem_address;
                shared_ptr->combined.mem_data       = (ao486_only)? shared_ptr->ao486.mem_data : shared_ptr->bochs486_pc.mem_data;
                shared_ptr->combined.mem_byteenable = (ao486_only)? shared_ptr->ao486.mem_byteenable : shared_ptr->bochs486_pc.mem_byteenable;
                shared_ptr->combined.mem_is_write   = 1;
                shared_ptr->combined.mem_step       = STEP_REQ;
            }
        }
        
        if(ctrl_mem_write == 1) {
            if(shared_ptr->combined.mem_step == STEP_ACK && shared_ptr->combined.mem_is_write == 1) {
                ctrl_mem_write = 0;
                
                if(bochs486_pc_only == 0) shared_ptr->ao486.mem_step = STEP_ACK;
                if(ao486_only == 0)       shared_ptr->bochs486_pc.mem_step = STEP_ACK;
            }
        }
        
        //---------------------------------------------------------------------- combined mem write
        
        if(shared_ptr->combined.mem_step == STEP_REQ && shared_ptr->combined.mem_is_write) {
            uint32 address = shared_ptr->combined.mem_address;
            if(address < 0xA0000 || address >= 0xC0000) {
                for(uint32 i=0; i<4; i++) {
                    if(shared_ptr->combined.mem_byteenable & 1) {
                        shared_ptr->mem.bytes[address + i] = shared_ptr->combined.mem_data & 0xFF;
//printf("[%08x] = %02x\n", address + i, shared_ptr->combined.mem_data & 0xFF);
                    }
                    shared_ptr->combined.mem_byteenable >>= 1;
                    shared_ptr->combined.mem_data >>= 8;
                }
                shared_ptr->combined.mem_step = STEP_ACK;
            }
        }
        
        //----------------------------------------------------------------------
        
        usleep(10);
    }
    
    munmap((void *)shared_ptr, sizeof(shared_mem_t));
    close(fd);
    
    return 0;
}
