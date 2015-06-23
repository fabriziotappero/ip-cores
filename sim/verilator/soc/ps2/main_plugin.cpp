#include <cstdio>
#include <cstdlib>

#include <dlfcn.h>

#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "Vps2.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "shared_mem.h"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

volatile shared_mem_t *shared_ptr = NULL;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

#define SEND_BUF_LIMIT 5

int kb_send[SEND_BUF_LIMIT];
int kb_send_count = 0;

int mouse_send[SEND_BUF_LIMIT];
int mouse_send_count = 0;

void send_byte(uint8 byte, int *table, int &count) {
    if(count >= SEND_BUF_LIMIT) {
        printf("ERROR: send buffer overflow.\n");
        exit(-1);
    }
    
    int parity = 1;
    for(int i=0; i<8; i++) parity ^= ((byte >> i) & 1);
    int new_byte = byte;
    new_byte |= (parity & 1) << 8;
    
    table[count] = new_byte;
    count++;
}

void kb_send_byte(uint8 byte)    { send_byte(byte, kb_send, kb_send_count); }
void mouse_send_byte(uint8 byte) { send_byte(byte, mouse_send, mouse_send_count); }

//------------------------------------------------------------------------------

void keyboard_controller(uint32 got) {
    if(got == 0xFF) {
        printf("resp: 0xFA, 0xAA\n");
        kb_send_byte(0xFA);
        kb_send_byte(0xAA);
    }
    else {
        printf("resp: 0xFA\n");
        kb_send_byte(0xFA);
    }
}

void mouse_controller(uint32 got) {
    if(got == 0xFF) {
        printf("resp: 0xFA, 0xAA, 0x00\n");
        mouse_send_byte(0xFA);
        mouse_send_byte(0xAA);
        mouse_send_byte(0x00);
    }
    else if(got == 0xF2) {
        printf("resp: 0xFA, 0x00\n");
        mouse_send_byte(0xFA);
        mouse_send_byte(0x00);
    }
    else {
        printf("resp: 0xFA\n");
        mouse_send_byte(0xFA);
    }
}


//------------------------------------------------------------------------------

//0 - wait for ena + 0
//r - wait for !ena
//z - set zero
//o - set one
//c - capture
const char *clk_recv_string = "0 rzo zo zo zo zo zo zo zo zo zo zo zo";
const char *dat_recv_string = " 0   c  c  c  c  c  c  c  c  c  c  czo";

const char *clk_send_string = "zozozozozozozozozozozo";
const char *dat_send_string = "z i i i i i i i i i oo";

void proceed_ps2(int &index, int &waiting, int &wait_limit, int &recv_byte, bool &is_recv, bool &clk_hold, int &clk_hold_value, bool &dat_hold, int &dat_hold_value, int &send_count, bool recv_start,
    bool recv_start_zero, bool recv_release, bool recv_dat_start_zero, int &sending_byte, int receiving_byte, bool is_mouse)
{
    waiting++;
    if(waiting == wait_limit) {
        waiting = 0;
        wait_limit = 50;
        
        if(recv_start) {
            is_recv = true;
            index = 0;
        }
        
        clk_hold = false;
        dat_hold = false;
        
        if(is_recv || send_count > 0) {
        
            bool clk_continue = false;
            switch(is_recv? clk_recv_string[index] : clk_send_string[index]) {
                case ' ':
                    clk_continue = true;
                    break;
                case '0':
                    if(recv_start_zero) clk_continue = true;
                    break;
                case 'r':
                    if(recv_release) clk_continue = true;
                    break;
                case 'z':
                    clk_continue = true;
                    clk_hold_value = 0;
                    clk_hold = true;
                    break;
                case 'o':
                    clk_continue = true;
                    clk_hold_value = 1;
                    clk_hold = true;
                    break;
                default:
                    printf("ERROR: unknown val.\n");
                    exit(-1);
            }
            
            bool dat_continue = false;
            switch(is_recv? dat_recv_string[index] : dat_send_string[index]) {
                case ' ':
                    dat_continue = true;
                    break;
                case '0':
                    if(recv_dat_start_zero) dat_continue = true;
                    break;
                case 'z':
                    dat_continue = true;
                    dat_hold_value = 0;
                    dat_hold = true;
                    break;
                case 'o':
                    dat_continue = true;
                    dat_hold_value = 1;
                    dat_hold = true;
                    break;
                case 'i':
                    dat_continue = true;
                    dat_hold_value = sending_byte & 1;
                    dat_hold = true;
                    sending_byte >>= 1;
                    break;
                case 'c':
                    dat_continue = true;
                    recv_byte <<= 1;
                    recv_byte |= receiving_byte & 1;
                    break;
                default:
                    printf("ERROR: unknown val.\n");
                    exit(-1);
            }
        
            if(clk_continue && dat_continue) index++;
            
            if(is_recv && index == strlen(clk_recv_string)) {
                index = 0;
                is_recv = false;
                
                int byte = 0;
                for(int i=0; i<8; i++) byte |= ((recv_byte >> (9-i)) & 1) << i;
                int parity = 0;
                for(int i=0; i<9; i++) parity ^= ((recv_byte >> (9-i)) & 1);
                int stop = recv_byte & 1;
                int start = (recv_byte >> 10) & 1;
                printf("Recv: is_mouse %d, start: %x, byte: %02x, parity: %x, stop: %x\n", is_mouse, start, byte, parity, stop);
                
                wait_limit = 50000;
                
                if(is_mouse) mouse_controller(byte);
                else         keyboard_controller(byte);
            }
            
            if(is_recv == false && index == strlen(clk_send_string)) {
                index = 0;
                is_recv = false;
                
                if(is_mouse) {
                    for(int i=0; i<SEND_BUF_LIMIT-1; i++) mouse_send[i] = mouse_send[i+1];
                    mouse_send_count--;
                }
                else {
                    for(int i=0; i<SEND_BUF_LIMIT-1; i++) kb_send[i] = kb_send[i+1];
                    kb_send_count--;
                }
            }
        }   
    }
    
    if(index == 0) {
        clk_hold = true;
        clk_hold_value = 1;
            
        dat_hold = true;
        dat_hold_value = 1;
    }
}


//------------------------------------------------------------------------------

int main(int argc, char **argv) {
    
    //map shared memory
    int fd = open("./../../../sim_pc/shared_mem.dat", O_RDWR, S_IRUSR | S_IWUSR);
    
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
    
    Verilated::commandArgs(argc, argv);
    
    Verilated::traceEverOn(true);
    VerilatedVcdC* tracer = new VerilatedVcdC;
    
    Vps2 *top = new Vps2();
    top->trace (tracer, 99);
    //tracer->rolloverMB(1000000);
    tracer->open("ps2.vcd");
    
    //reset
    top->clk = 0; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 1; top->eval();
    top->clk = 1; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 0; top->eval();
    top->clk = 0; top->rst_n = 1; top->eval();
    
    bool dump = false;
    uint64 cycle = 0;
    bool read_cycle = false;
    
    printf("ps2 main_plugin.cpp\n");
    
    //keyboard
    int  kb_index = 0;
    int  kb_waiting = 0;
    int  kb_wait_limit = 50;
    int  kb_recv_byte = 0;
    bool kb_is_recv = false;
    
    bool kb_clk_hold = false;
    int  kb_clk_hold_value = 0;
    bool kb_dat_hold = false;
    int  kb_dat_hold_value = 0;
    
    //mouse
    int  ms_index = 0;
    int  ms_waiting = 0;
    int  ms_wait_limit = 50;
    int  ms_recv_byte = 0;
    bool ms_is_recv = false;
    
    bool ms_clk_hold = false;
    int  ms_clk_hold_value = 0;
    bool ms_dat_hold = false;
    int  ms_dat_hold_value = 0;
    
    int a20_last = 1;
    
    while(!Verilated::gotFinish()) {
        
        //test
        /*
        top->io_address = 0;
        top->io_write = 0;
        if(first_run == 0) {
            top->io_write = 1;
            top->io_writedata = 0xFA;
            
            first_run = 1;
        }
        */
        
        proceed_ps2(kb_index, kb_waiting, kb_wait_limit, kb_recv_byte, kb_is_recv, kb_clk_hold, kb_clk_hold_value, kb_dat_hold, kb_dat_hold_value, kb_send_count,
            top->v__DOT__ps2_kbclk_ena && top->v__DOT__ps2_kbclk_out == 0 && kb_is_recv == false,
            top->v__DOT__ps2_kbclk_ena && top->v__DOT__ps2_kbclk_out == 0,
            top->v__DOT__ps2_kbclk_ena == 0,
            top->v__DOT__ps2_kbdat_ena && top->v__DOT__ps2_kbdat_out == 0,
            kb_send[0],
            top->v__DOT__ps2_kbdat_out,
            false);
        
        proceed_ps2(ms_index, ms_waiting, ms_wait_limit, ms_recv_byte, ms_is_recv, ms_clk_hold, ms_clk_hold_value, ms_dat_hold, ms_dat_hold_value, mouse_send_count,
            top->v__DOT__ps2_mouseclk_ena && top->v__DOT__ps2_mouseclk_out == 0 && ms_is_recv == false,
            top->v__DOT__ps2_mouseclk_ena && top->v__DOT__ps2_mouseclk_out == 0,
            top->v__DOT__ps2_mouseclk_ena == 0,
            top->v__DOT__ps2_mousedat_ena && top->v__DOT__ps2_mousedat_out == 0,
            mouse_send[0],
            top->v__DOT__ps2_mousedat_out,
            true);
        
        /*
        uint32 combined.io_address;
        uint32 combined.io_data;
        uint32 combined.io_byteenable;
        uint32 combined.io_is_write;
        step_t combined.io_step;
        
        //io slave 0x60-0x67
        input       [2:0]       io_address,
        input                   io_read,
        output reg  [7:0]       io_readdata,
        input                   io_write,
        input       [7:0]       io_writedata,
        
        //io slave 0x90-0x9F
        input       [3:0]       sysctl_address,
        input                   sysctl_read,
        output reg  [7:0]       sysctl_readdata,
        input                   sysctl_write,
        input       [7:0]       sysctl_writedata,
        */
        
        top->io_read      = 0;
        top->io_write     = 0;
        
        top->sysctl_read  = 0;
        top->sysctl_write = 0;
        
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write &&
            ((shared_ptr->combined.io_address == 0x0060 && ((shared_ptr->combined.io_byteenable >> 1) & 1) == 0) || shared_ptr->combined.io_address == 0x0064))
        {
            if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                printf("Vps2 0x60: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                exit(-1);
            }

            top->io_address    = (shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x0064 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x0064 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x0064 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                                                                                                             7;
                                 
            top->io_writedata  = (shared_ptr->combined.io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                 (shared_ptr->combined.io_byteenable == 2)?     (shared_ptr->combined.io_data >> 8) & 0xFF :
                                 (shared_ptr->combined.io_byteenable == 4)?     (shared_ptr->combined.io_data >> 16) & 0xFF :
                                                                                (shared_ptr->combined.io_data >> 24) & 0xFF;
            top->io_read  = 0;
            top->io_write = 1;
            
            shared_ptr->combined.io_step = STEP_ACK;
        }
        
        if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write &&
            (shared_ptr->combined.io_address == 0x0090 || shared_ptr->combined.io_address == 0x0094 || shared_ptr->combined.io_address == 0x0098 || shared_ptr->combined.io_address == 0x009C))
        {
            if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                printf("Vps2 0x90: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                exit(-1);
            }

            top->sysctl_address= (shared_ptr->combined.io_address == 0x0090 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x0090 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x0090 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x0090 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x0094 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x0094 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x0094 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                 (shared_ptr->combined.io_address == 0x0094 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                 (shared_ptr->combined.io_address == 0x0098 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                 (shared_ptr->combined.io_address == 0x0098 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                 (shared_ptr->combined.io_address == 0x0098 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                 (shared_ptr->combined.io_address == 0x0098 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                 (shared_ptr->combined.io_address == 0x009C && shared_ptr->combined.io_byteenable == 1)?     12 :
                                 (shared_ptr->combined.io_address == 0x009C && shared_ptr->combined.io_byteenable == 2)?     13 :
                                 (shared_ptr->combined.io_address == 0x009C && shared_ptr->combined.io_byteenable == 4)?     14 :
                                                                                                                             15;
                                 
            top->sysctl_writedata = (shared_ptr->combined.io_byteenable == 1)?     shared_ptr->combined.io_data & 0xFF :
                                    (shared_ptr->combined.io_byteenable == 2)?     (shared_ptr->combined.io_data >> 8) & 0xFF :
                                    (shared_ptr->combined.io_byteenable == 4)?     (shared_ptr->combined.io_data >> 16) & 0xFF :
                                                                                   (shared_ptr->combined.io_data >> 24) & 0xFF;
            top->sysctl_read  = 0;
            top->sysctl_write = 1;
            
            shared_ptr->combined.io_step = STEP_ACK;
        }
        
        
        if(read_cycle == false) {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 &&
                ((shared_ptr->combined.io_address == 0x0060 && ((shared_ptr->combined.io_byteenable >> 1) & 1) == 0) || shared_ptr->combined.io_address == 0x0064))
            {
                if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                    printf("Vps2 0x60: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                    exit(-1);
                }
                
                top->io_address= (shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x0060 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x0064 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x0064 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x0064 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                                                                                                             7;
                top->io_writedata  = 0;
                
                top->io_read  = 1;
                top->io_write = 0;
                
                read_cycle = true;
            }
            
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 &&
                (shared_ptr->combined.io_address == 0x0090 || shared_ptr->combined.io_address == 0x0094 || shared_ptr->combined.io_address == 0x0098 || shared_ptr->combined.io_address == 0x009C))
            {
                if(shared_ptr->combined.io_byteenable != 1 && shared_ptr->combined.io_byteenable != 2 && shared_ptr->combined.io_byteenable != 4 && shared_ptr->combined.io_byteenable != 8) {
                    printf("Vps2 0x90: combined.io_byteenable invalid: %x\n", shared_ptr->combined.io_byteenable);
                    exit(-1);
                }
                
                top->sysctl_address= (shared_ptr->combined.io_address == 0x0090 && shared_ptr->combined.io_byteenable == 1)?     0 :
                                 (shared_ptr->combined.io_address == 0x0090 && shared_ptr->combined.io_byteenable == 2)?     1 :
                                 (shared_ptr->combined.io_address == 0x0090 && shared_ptr->combined.io_byteenable == 4)?     2 :
                                 (shared_ptr->combined.io_address == 0x0090 && shared_ptr->combined.io_byteenable == 8)?     3 :
                                 (shared_ptr->combined.io_address == 0x0094 && shared_ptr->combined.io_byteenable == 1)?     4 :
                                 (shared_ptr->combined.io_address == 0x0094 && shared_ptr->combined.io_byteenable == 2)?     5 :
                                 (shared_ptr->combined.io_address == 0x0094 && shared_ptr->combined.io_byteenable == 4)?     6 :
                                 (shared_ptr->combined.io_address == 0x0094 && shared_ptr->combined.io_byteenable == 8)?     7 :
                                 (shared_ptr->combined.io_address == 0x0098 && shared_ptr->combined.io_byteenable == 1)?     8 :
                                 (shared_ptr->combined.io_address == 0x0098 && shared_ptr->combined.io_byteenable == 2)?     9 :
                                 (shared_ptr->combined.io_address == 0x0098 && shared_ptr->combined.io_byteenable == 4)?     10 :
                                 (shared_ptr->combined.io_address == 0x0098 && shared_ptr->combined.io_byteenable == 8)?     11 :
                                 (shared_ptr->combined.io_address == 0x009C && shared_ptr->combined.io_byteenable == 1)?     12 :
                                 (shared_ptr->combined.io_address == 0x009C && shared_ptr->combined.io_byteenable == 2)?     13 :
                                 (shared_ptr->combined.io_address == 0x009C && shared_ptr->combined.io_byteenable == 4)?     14 :
                                                                                                                             15;
                top->sysctl_writedata  = 0;
                
                top->sysctl_read  = 1;
                top->sysctl_write = 0;
                
                read_cycle = true;
            }
        }
        else {
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 &&
                ((shared_ptr->combined.io_address == 0x0060 && ((shared_ptr->combined.io_byteenable >> 1) & 1) == 0) || shared_ptr->combined.io_address == 0x0064))
            {
                uint32 val = top->io_readdata;
                
                if(shared_ptr->combined.io_byteenable & 1) val <<= 0;
                if(shared_ptr->combined.io_byteenable & 2) val <<= 8;
                if(shared_ptr->combined.io_byteenable & 4) val <<= 16;
                if(shared_ptr->combined.io_byteenable & 8) val <<= 24;
                
                shared_ptr->combined.io_data = val;
                    
                read_cycle = false;
                shared_ptr->combined.io_step = STEP_ACK;
            }
            
            if(shared_ptr->combined.io_step == STEP_REQ && shared_ptr->combined.io_is_write == 0 &&
                (shared_ptr->combined.io_address == 0x0090 || shared_ptr->combined.io_address == 0x0094 || shared_ptr->combined.io_address == 0x0098 || shared_ptr->combined.io_address == 0x009C))
            {
                uint32 val = top->sysctl_readdata;
                
                if(shared_ptr->combined.io_byteenable & 1) val <<= 0;
                if(shared_ptr->combined.io_byteenable & 2) val <<= 8;
                if(shared_ptr->combined.io_byteenable & 4) val <<= 16;
                if(shared_ptr->combined.io_byteenable & 8) val <<= 24;
                
                shared_ptr->combined.io_data = val;
                    
                read_cycle = false;
                shared_ptr->combined.io_step = STEP_ACK;
            }
        }
        
        
        //----------------------------------------------------------------------
        
        shared_ptr->keyboard_irq_step = (top->irq_keyb)?  STEP_REQ : STEP_IDLE;
        shared_ptr->mouse_irq_step    = (top->irq_mouse)? STEP_REQ : STEP_IDLE;
        
        //----------------------------------------------------------------------
        
        if(top->speaker_61h_read) {
            printf("ERROR: speaker_61h_read not zero !\n");
            exit(-1);
        }
        
        if(top->speaker_61h_write) {
            printf("ERROR: speaker_61h_write not zero !\n");
            exit(-1);
        }
        
        if(top->output_a20_enable != a20_last) {
            printf("WARNING: output_a20_enable: %d\n", top->output_a20_enable);
            a20_last = top->output_a20_enable;
        }
        
        if(top->output_reset_n == 0) {
            printf("ERROR: output_a20_enable not one !\n");
            exit(-1);
        }
        
        //----------------------------------------------------------------------
        
        if(kb_clk_hold) top->ps2_kbclk    = kb_clk_hold_value;
        if(kb_dat_hold) top->ps2_kbdat    = kb_dat_hold_value;
        if(ms_clk_hold) top->ps2_mouseclk = ms_clk_hold_value;
        if(ms_dat_hold) top->ps2_mousedat = ms_dat_hold_value;
        
        top->clk = 0;
        top->eval();
        
        if(kb_clk_hold) top->ps2_kbclk    = kb_clk_hold_value;
        if(kb_dat_hold) top->ps2_kbdat    = kb_dat_hold_value;
        if(ms_clk_hold) top->ps2_mouseclk = ms_clk_hold_value;
        if(ms_dat_hold) top->ps2_mousedat = ms_dat_hold_value;
        
        cycle++; if(dump) tracer->dump(cycle);
        
        
        top->clk = 1;
        top->eval();
        
        if(kb_clk_hold) top->ps2_kbclk    = kb_clk_hold_value;
        if(kb_dat_hold) top->ps2_kbdat    = kb_dat_hold_value;
        if(ms_clk_hold) top->ps2_mouseclk = ms_clk_hold_value;
        if(ms_dat_hold) top->ps2_mousedat = ms_dat_hold_value;
        
        cycle++; if(dump) tracer->dump(cycle);
        
        tracer->flush();
        
        usleep(1);
    }
    tracer->close();
    delete tracer;
    delete top;
    
    return 0;
}

//------------------------------------------------------------------------------

/*
module ps2(
    input                   clk,
    input                   rst_n,
    
    output reg              irq_keyb,
    output reg              irq_mouse,
    
    //io slave 0x60-0x67
    input       [2:0]       io_address,
    input                   io_read,
    output reg  [7:0]       io_readdata,
    input                   io_write,
    input       [7:0]       io_writedata,
    
    //io slave 0x90-0x9F
    input       [3:0]       sysctl_address,
    input                   sysctl_read,
    output reg  [7:0]       sysctl_readdata,
    input                   sysctl_write,
    input       [7:0]       sysctl_writedata,
    
    //speaker port 61h
    output                  speaker_61h_read,
    input       [7:0]       speaker_61h_readdata,
    output                  speaker_61h_write,
    output      [7:0]       speaker_61h_writedata,
    
    //output port
    output reg              output_a20_enable,
    output reg              output_reset_n,
    
    //ps2 keyboard
    inout                   ps2_kbclk,
    inout                   ps2_kbdat,
    
    //ps2 mouse
    inout                   ps2_mouseclk,
    inout                   ps2_mousedat
);
*/
