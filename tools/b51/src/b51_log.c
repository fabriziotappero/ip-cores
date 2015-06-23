

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

#include "b51_cpu.h"
#include "b51_log.h"


static FILE *log_con_fp = NULL;
static FILE *log_sw_fp = NULL;

extern bool log_init(const char *sw_log_file, const char *con_log_file){
    if(sw_log_file != NULL){
        log_sw_fp = fopen(sw_log_file, "w");
        if(log_sw_fp==NULL){
            perror("Error opening log file");
            return false;
        }
    }
    else{
        /* NULL argument: do not log */
        log_sw_fp = NULL; /* stdout; */
    }

    if(con_log_file != NULL){
        log_con_fp = fopen(con_log_file, "w");
        if(log_con_fp==NULL){
            perror("Error opening console log file");
            return false;
        }
    }
    else{
        /* NULL argument: Redirect to host console */
        log_con_fp = stdout;
    }

    return true;
}

extern void log_close(void){
    if(log_sw_fp!=NULL){
        fclose(log_sw_fp);
        log_sw_fp = NULL;
    }
    if(log_con_fp!=NULL){
        fclose(log_con_fp);
        log_con_fp = NULL;
    }
}


extern void log_baseline(log51_t *log, uint16_t pc, uint8_t sp, uint8_t a, uint8_t psw){
    log->pc = pc;
    log->psw = psw;
    log->sp = sp;
    log->a = a;
}

extern void log_idata(log51_t *log, uint8_t addr, uint8_t value){
    if(log_sw_fp!=NULL){
        fprintf(log_sw_fp, "(%04X) [%02X] = %02X\n", log->pc, addr, value);
    }
}

extern void log_xdata(log51_t *log, uint16_t addr, uint8_t value){
    if(log_sw_fp!=NULL){
        fprintf(log_sw_fp, "(%04X) <%04X> = %02X\n", log->pc, addr, value);
    }
}

extern void log_sfr(log51_t *log, uint8_t addr, uint8_t value){
    if(log_sw_fp!=NULL){
        fprintf(log_sw_fp, "(%04X) SFR[%02X] = %02X\n", log->pc, addr, value);
    }
}

extern bool log_jump(log51_t *log, uint16_t addr){
    if(log_sw_fp!=NULL){
        fprintf(log_sw_fp, "(%04X) PC = %04X\n", log->pc, addr);
    }
    return (log->pc == addr);
}

extern void log_unimplemented(log51_t *log, uint8_t opcode){
    if(log_sw_fp!=NULL){
        fprintf(log_sw_fp, "(%04X) UNIMPLEMENTED: %02X\n", log->pc, opcode);
    }
    printf("\n(%04X) UNIMPLEMENTED: %02X\n", log->pc, opcode);
}

extern void log_reg16(log51_t *log, const char *msg, uint16_t value){
    if(log_sw_fp!=NULL){
        fprintf(log_sw_fp, "(%04X) %s = %04X\n", log->pc, msg, value);
    }
}

extern void log_status(log51_t *log, uint8_t sp, uint8_t a, uint8_t psw){
    /* Order of checks & log messages matches light52_tb_pkg */
    if(log_sw_fp!=NULL){
        if(sp != log->sp){
            fprintf(log_sw_fp, "(%04X) SP = %02X\n", log->pc, sp);
        }
        if(a != log->a){
            fprintf(log_sw_fp, "(%04X) A = %02X\n", log->pc, a);
        }
        if((psw) != (log->psw)){
            fprintf(log_sw_fp, "(%04X) PSW = %02X\n",
                    log->pc, psw);
        }
    }
}


extern void log_con_output(char c){
    if(log_con_fp!=NULL){
        fprintf(log_con_fp, "%c", c);
    }
}
