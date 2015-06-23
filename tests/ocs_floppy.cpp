#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <errno.h>
#include <poll.h>
#include <unistd.h>

//****************************************************************************** E-UAE floppy read
typedef unsigned int uae_u32;
typedef unsigned char uae_u8;
typedef unsigned short uae_u16;

unsigned char mfm_uae[544*2*11];
int mfm_uae_index = 0;
static void mfmcode (uae_u16 *mfm, unsigned int words) {
    uae_u32 lastword = 0;
    while (words--) {
    uae_u32 v = *mfm;
    uae_u32 lv = (lastword << 16) | v;
    uae_u32 nlv = 0x55555555 & ~lv;
    uae_u32 mfmbits = (nlv << 1) & (nlv >> 1);
    *mfm++ = v | mfmbits;
    lastword = v;
    }
}

static void decode_amigados () {
    /* Normal AmigaDOS format track */
    unsigned int tr = 0;
    unsigned int sec;
    int len = 11 * 544 + 0;
    
    for (sec = 0; sec < 11; sec++) {
        uae_u8 secbuf[544];
        uae_u16 mfmbuf[544];
        int i;
        uae_u32 deven, dodd;
        uae_u32 hck = 0, dck = 0;

        secbuf[0] = secbuf[1] = 0x00;
        secbuf[2] = secbuf[3] = 0xa1;
        secbuf[4] = 0xff;
        secbuf[5] = tr;
        secbuf[6] = sec;
        secbuf[7] = 11 - sec;

        for (i = 8; i < 24; i++)
        secbuf[i] = 0;
        
//memset(secbuf+32, 0x00, 512);
srand(1);
for(int i=0; i<512; i++) secbuf[32+i] = rand();

        mfmbuf[0] = mfmbuf[1] = 0xaaaa;
        mfmbuf[2] = mfmbuf[3] = 0x4489;

        deven = ((secbuf[4] << 24) | (secbuf[5] << 16)
             | (secbuf[6] << 8) | (secbuf[7]));
        dodd = deven >> 1;
        deven &= 0x55555555;
        dodd &= 0x55555555;

        mfmbuf[4] = dodd >> 16;
        mfmbuf[5] = dodd;
        mfmbuf[6] = deven >> 16;
        mfmbuf[7] = deven;

        for (i = 8; i < 48; i++)
        mfmbuf[i] = 0xaaaa;
    for (i = 0; i < 512; i += 4) {
        deven = ((secbuf[i + 32] << 24) | (secbuf[i + 33] << 16)
             | (secbuf[i + 34] << 8) | (secbuf[i + 35]));
        dodd = deven >> 1;
        deven &= 0x55555555;
        dodd &= 0x55555555;
        mfmbuf[(i >> 1) + 32] = dodd >> 16;
        mfmbuf[(i >> 1) + 33] = dodd;
        mfmbuf[(i >> 1) + 256 + 32] = deven >> 16;
        mfmbuf[(i >> 1) + 256 + 33] = deven;
    }

    for (i = 4; i < 24; i += 2)
        hck ^= (mfmbuf[i] << 16) | mfmbuf[i + 1];

        deven = dodd = hck;
        dodd >>= 1;
        mfmbuf[24] = dodd >> 16;
        mfmbuf[25] = dodd;
        mfmbuf[26] = deven >> 16;
        mfmbuf[27] = deven;

        for (i = 32; i < 544; i += 2)
        dck ^= (mfmbuf[i] << 16) | mfmbuf[i + 1];

        deven = dodd = dck;
        dodd >>= 1;
        mfmbuf[28] = dodd >> 16;
        mfmbuf[29] = dodd;
        mfmbuf[30] = deven >> 16;
        mfmbuf[31] = deven;
        
        /*
        for(int ii=0; ii<544; ii++) {
            if((ii%16) == 0) printf("\n");
            printf("%04x, ", mfmbuf[ii]);
        }
        printf("\n");
        printf("mfmcode\n");
        */
        mfmcode (mfmbuf + 4, 544 - 4);
        /*
        for(int ii=0; ii<544; ii++) {
            if((ii%16) == 0) printf("\n");
            printf("%04x, ", mfmbuf[ii]);
        }
        printf("\n");
        exit(-1);
        */
        
        for (i = 0; i < 544; i++) {
            mfm_uae[mfm_uae_index+2*i+0] = mfmbuf[i] >> 8;
            mfm_uae[mfm_uae_index+2*i+1] = mfmbuf[i];
        }
        mfm_uae_index += 544*2;
    }
}


//****************************************************************************** E-UAE floppy read

int ans_to_tb[2];
int ans_from_tb[2];
int pid;
static void ans_prepare_pipe() {
    /* Pipe. */
    if(pipe(ans_to_tb) == -1) {
        printf("Error: to pipe() failed.\n");
        exit(-1);
    }
    if(pipe(ans_from_tb) == -1) {
        printf("Error: from pipe() failed.\n");
        exit(-1);
    }

    /* Fork */
    if((pid = fork()) == -1) {
        printf("Error: fork() failed.\n");
        exit(-1);
    }

    /* Child */
    if(pid == 0) {
        close(0);
        dup2(ans_to_tb[0], 0);
        close(ans_to_tb[0]);
        
        close(1);
        dup2(ans_from_tb[1], 1);
        close(ans_from_tb[1]);

        /* Execute */
        int result;
        result = execl("/home/alek/aktualne/aoOCS/aoOCS/tb_ocs_floppy", "/home/alek/aktualne/aoOCS/aoOCS/tb_ocs_floppy", (char *)0);
        printf("EXECL failed: %d, %s\n", result, strerror(errno));
        exit(-1);
    }
}
enum port_t {
    REGISTER,
    FL_MTR_N,
    FL_SEL_N,
    FL_SIDE_N,
    FL_DIR,
    FL_STEP_N,
    STEP
};
static void ans_write_register(enum port_t port, unsigned int adr, unsigned short val) {
    if(pid == 0) {
        ans_prepare_pipe();
    }
    char line[256];
    if(port == REGISTER) {
        if( (adr % 4) == 1 || (adr % 4) == 3 ) {
            printf("Error: unaligned write register: %08h\n", adr);
            exit(-1);
        }
        int sel = 0, value = 0;
        if( (adr % 4) == 0 ) { sel = 0xc; value = val << 16; }
        if( (adr % 4) == 2 ) { sel = 0x3; value = val; }
        
        sprintf(line, "write register: adr=%x, sel=%x, val=%x\n", adr, sel, value);
    }
    else if(port == FL_MTR_N)   sprintf(line, "fl_mtr_n=%x\n", val);
    else if(port == FL_SEL_N)   sprintf(line, "fl_sel_n=%x\n", val);
    else if(port == FL_SIDE_N)  sprintf(line, "fl_side_n=%x\n", val);
    else if(port == FL_DIR)     sprintf(line, "fl_dir=%x\n", val);
    else if(port == FL_STEP_N)  sprintf(line, "fl_step_n=%x\n", val);
    else if(port == STEP)       sprintf(line, "step=%x\n", val);
    
    printf("WRITING: %s\n", line);
    if( write(ans_to_tb[1], line, strlen(line) ) != (int)strlen(line) ) {
        printf("Error writing to tb.\n");
        exit(-1);
    }
}

unsigned char mfm[544*2*11];
unsigned int lget(unsigned int adr) {
    printf("lget: %08x\n", adr);
    
    if(adr == 0x10001000) return 2; // sd status read
    
    if(adr >= 0x1008D800 && adr <= 0x1008D800 + 11*512 - 4) {
        unsigned char buf[512];
        srand(1);
        for(int i=0; i<512; i++) buf[i] = rand();
        
        adr -= 0x1008D800;
        adr %= 512;
        return buf[adr+3] | (buf[adr+2] << 8) | (buf[adr+1] << 16) | (buf[adr+0] << 24);
    }
    
    if(adr >= 0x1008EE00 && adr <= 0x1008EE00 + sizeof(mfm) - 4) {
        adr -= 0x1008EE00;
        unsigned int val = 0;
        val |= mfm[adr+0]<<24;
        val |= mfm[adr+1]<<16;
        val |= mfm[adr+2]<<8;
        val |= mfm[adr+3]<<0;
        return val;
    }
    
    getchar();
    exit(-1);
    return 0;
}

unsigned char mfm_dma[12700];
void wput(unsigned int adr, unsigned short val) {
    printf("wput: %08x <- %04hx\n", adr, val);
    
    if(adr >= 0x800 && adr <= 0x800 + sizeof(mfm_dma) -2) {
        adr -= 0x800;
        mfm_dma[adr+0] = val>>8;
        mfm_dma[adr+1] = val;
        return;
    }
    getchar();
    exit(-1);
}

void lput(unsigned int adr, unsigned int val) {
    printf("lput: %08x <- %08x\n", adr, val);
    
    if(adr == 0x10001000 || adr == 0x10001004 || adr == 0x10001008 || adr == 0x1000100C) return;
    
    if(adr >= 0x1008EE00 && adr <= 0x1008EE00 + sizeof(mfm) - 4) {
        adr -= 0x1008EE00;
        mfm[adr+0] = val>>24;
        mfm[adr+1] = val>>16;
        mfm[adr+2] = val>>8;
        mfm[adr+3] = val;
        return;
    }
    getchar();
    exit(-1);
}
void print_mfm() {
    for(int i=0; i<sizeof(mfm); i++) {
        if((i%32) == 0) printf("\n");
        printf("%02x, ", mfm[i]);
    }
    printf("\n");
    printf("MFM UAE\n");
    decode_amigados();
    for(int i=0; i<sizeof(mfm_uae); i++) {
        if((i%32) == 0) printf("\n");
        printf("%02x, ", mfm_uae[i]);
    }
    printf("\n");
}

bool poll_tb() {
    struct pollfd p;
    p.fd = ans_from_tb[0];
    p.events = POLLIN;
    int result = poll(&p, 1, 100);
    if(result == -1) {
        printf("poll error: %d\n", result);
        exit(-1);
    }
    if(result == 0) return false;
    return true;
}

int main(int argc, char **argv) {
    memset(mfm, 0xFF, sizeof(mfm));
    memset(mfm_dma, 0xFF, sizeof(mfm_dma));
    
    if(pid == 0) {
        ans_prepare_pipe();
    }
    
    char line[256];
    
    int result;
    unsigned int adr;
    unsigned int sel;
    unsigned int val;
    
    ans_write_register(FL_MTR_N, 0, 0);
    ans_write_register(FL_SIDE_N, 0, 1);
    ans_write_register(FL_SEL_N, 0, 0xE);
    
    ans_write_register(REGISTER, 0x022, 0x800);
    ans_write_register(REGISTER, 0x024, 0x8000 | (12600/2));
    ans_write_register(REGISTER, 0x024, 0x8000 | (12600/2));
    ans_write_register(REGISTER, 0x07E, 0x4489);
    
    int count=0, step_count=0;
    while(1) {
        count++;
        
        if(count == 120000) {
            print_mfm();
            
            printf("DMA\n");
            printf("aa, aa, aa, aa, 44, 89, ");
            for(int i=6; i<sizeof(mfm_dma)+6; i++) {
                if((i%32) == 0) printf("\n");
                printf("%02hhx, ", mfm_dma[i-6]);
            }
            exit(0);
        }
        
        memset(line, 0, sizeof(line));
        int i=0;
        while(1) {
            if(poll_tb() == false) {
                ans_write_register(STEP, 0, 1);
                step_count = 0;
                continue;
            }
            
            result = read(ans_from_tb[0], line+i, 1);
            if(result == -1) {
                printf("Error: read == -1\n");
                exit(-1);
            }
            if(line[i] == '\n') {
                line[i] = '\0';
                break;
            }
            i++;
        }
printf("GOT: %s\n", line);
        
        if(strcmp(line, "done") == 0) {
            printf("READ: done\n");
            print_mfm();
            exit(0);
        }
        else if(sscanf(line, "read memory: adr=%x", &adr) == 1) {
            //printf("READ: read memory: adr=%x\n", adr);
            
            sprintf(line, "memory: adr=%x, val=%x\n", adr, lget(adr));
            printf("WRITING: %s\n", line);
            if( write(ans_to_tb[1], line, strlen(line)) != (int)strlen(line) ) {
                printf("Error writing to tb.\n");
                exit(-1);
            }
            printf("done\n");
        }
        else if(sscanf(line, "write memory: adr=%x, sel=%x, val=%x", &adr, &sel, &val) == 3) {
            if(sel == 0xF) lput(adr, val);
            else {
                if((sel&0xC) == 0xC) wput(adr, (val>>16)&0xFFFF);
                if((sel&0x3) == 0x3) wput(adr+2, val&0xFFFF);
            }
            
            if(sel != 0xF && sel != 0xC && sel != 0x3) {
                printf("Error: unknown sel: %x\n", sel);
                exit(-1);
            }
            //printf("READ: write memory: adr=%x, sel=%x, val=%x\n", adr, sel, val);
        }
        if(step_count < 5) {  
            ans_write_register(STEP, 0, 1);
            step_count++;
        }
                
        printf("count: %d\n", count);
    }
    
    
    return 0;
}
