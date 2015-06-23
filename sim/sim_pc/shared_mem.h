
#ifndef __SHARED_MEM_H
#define __SHARED_MEM_H

typedef unsigned char  uint8;
typedef unsigned short uint16;
typedef unsigned int   uint32;
typedef unsigned long  uint64;

union memory_t {
    uint8  bytes [134217728];
    uint16 shorts[67108864];
    uint32 ints  [33554432];
};

enum step_t {
    STEP_IDLE = 0,
    STEP_REQ  = 1,
    STEP_ACK  = 2
};

struct processor_t {
    step_t starting;
    uint32 instr_counter;
    
    step_t stop;
    
    uint32 io_address;
    uint32 io_data;
    uint32 io_byteenable;
    uint32 io_is_write;
    step_t io_step;
    
    uint32 mem_address;
    uint32 mem_data;
    uint32 mem_byteenable;
    uint32 mem_is_write;
    step_t mem_step;
};

struct shared_mem_t {
    
    processor_t bochs486_pc;
    processor_t ao486;
    
    processor_t combined;
    
    uint32 dump_enabled;
    
    uint32 interrupt_vector;
    uint32 interrupt_at_counter;
    
    step_t bochsDevs_starting;
    step_t bochsDevs_stop;
    
    step_t hdd_irq_step;
    step_t pit_irq_step;
    step_t rtc_irq_step;
    step_t floppy_irq_step;
    step_t keyboard_irq_step;
    step_t mouse_irq_step;
    
    uint32 irq_do_vector;
    step_t irq_do;
    
    uint32 irq_done_vector;
    step_t irq_done;
    
    memory_t mem;
};


#endif //__SHARED_MEM_H
