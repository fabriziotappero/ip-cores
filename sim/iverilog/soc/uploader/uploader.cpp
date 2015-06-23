#include <cstdio>
#include <cstdlib>
#include <cstring>

void crc32(unsigned char *ptr, unsigned int *crc_output) {
    static unsigned char crc[32];

    if(ptr != NULL && crc_output != NULL) return;

    if(ptr == NULL && crc_output == NULL) {
        for(int i=0; i<32; i++) crc[i] = 1;
        return;
    }

    if(ptr == NULL && crc_output != NULL) {
        *crc_output = 0;
        for(int i=0; i<32; i++) {
            (*crc_output) |= crc[i] << (31-i);
        }
        (*crc_output) = ~(*crc_output);
        return;
    }

    unsigned char in[8];
    for(int j=0; j<8; j++) in[j] = ((*ptr) >> j) & 1;

    unsigned char new_crc[32];

    new_crc[31] = in[2] ^ crc[23] ^ crc[29];
    new_crc[30] = in[0] ^ in[3] ^ crc[22] ^ crc[28] ^ crc[31];
    new_crc[29] = in[0] ^ in[1] ^ in[4] ^ crc[21] ^ crc[27] ^ crc[30] ^ crc[31];
    new_crc[28] = in[1] ^ in[2] ^ in[5] ^ crc[20] ^ crc[26] ^ crc[29] ^ crc[30];
    new_crc[27] = in[0] ^ in[2] ^ in[3] ^ in[6] ^ crc[19] ^ crc[25] ^ crc[28] ^ crc[29] ^ crc[31];
    new_crc[26] = in[1] ^ in[3] ^ in[4] ^ in[7] ^ crc[18] ^ crc[24] ^ crc[27] ^ crc[28] ^ crc[30];
    new_crc[25] = in[4] ^ in[5] ^ crc[17] ^ crc[26] ^ crc[27];
    new_crc[24] = in[0] ^ in[5] ^ in[6] ^ crc[16] ^ crc[25] ^ crc[26] ^ crc[31];
    new_crc[23] = in[1] ^ in[6] ^ in[7] ^ crc[15] ^ crc[24] ^ crc[25] ^ crc[30];
    new_crc[22] = in[7] ^ crc[14] ^ crc[24];
    new_crc[21] = in[2] ^ crc[13] ^ crc[29];
    new_crc[20] = in[3] ^ crc[12] ^ crc[28];
    new_crc[19] = in[0] ^ in[4] ^ crc[11] ^ crc[27] ^ crc[31];
    new_crc[18] = in[0] ^ in[1] ^ in[5] ^ crc[10] ^ crc[26] ^ crc[30] ^ crc[31];
    new_crc[17] = in[1] ^ in[2] ^ in[6] ^ crc[9] ^ crc[25] ^ crc[29] ^ crc[30];
    new_crc[16] = in[2] ^ in[3] ^ in[7] ^ crc[8] ^ crc[24] ^ crc[28] ^ crc[29];
    new_crc[15] = in[0] ^ in[2] ^ in[3] ^ in[4] ^ crc[7] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[31];
    new_crc[14] = in[0] ^ in[1] ^ in[3] ^ in[4] ^ in[5] ^ crc[6] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30] ^ crc[31];
    new_crc[13] = in[0] ^ in[1] ^ in[2] ^ in[4] ^ in[5] ^ in[6] ^ crc[5] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[30] ^ crc[31];
    new_crc[12] = in[1] ^ in[2] ^ in[3] ^ in[5] ^ in[6] ^ in[7] ^ crc[4] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[30];
    new_crc[11] = in[3] ^ in[4] ^ in[6] ^ in[7] ^ crc[3] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28];
    new_crc[10] = in[2] ^ in[4] ^ in[5] ^ in[7] ^ crc[2] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29];
    new_crc[9] = in[2] ^ in[3] ^ in[5] ^ in[6] ^ crc[1] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29];
    new_crc[8] = in[3] ^ in[4] ^ in[6] ^ in[7] ^ crc[0] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28];
    new_crc[7] = in[0] ^ in[2] ^ in[4] ^ in[5] ^ in[7] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[29] ^ crc[31];
    new_crc[6] = in[0] ^ in[1] ^ in[2] ^ in[3] ^ in[5] ^ in[6] ^ crc[25] ^ crc[26] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
    new_crc[5] = in[0] ^ in[1] ^ in[2] ^ in[3] ^ in[4] ^ in[6] ^ in[7] ^ crc[24] ^ crc[25] ^ crc[27] ^ crc[28] ^ crc[29] ^ crc[30] ^ crc[31];
    new_crc[4] = in[1] ^ in[3] ^ in[4] ^ in[5] ^ in[7] ^ crc[24] ^ crc[26] ^ crc[27] ^ crc[28] ^ crc[30];
    new_crc[3] = in[0] ^ in[4] ^ in[5] ^ in[6] ^ crc[25] ^ crc[26] ^ crc[27] ^ crc[31];
    new_crc[2] = in[0] ^ in[1] ^ in[5] ^ in[6] ^ in[7] ^ crc[24] ^ crc[25] ^ crc[26] ^ crc[30] ^ crc[31];
    new_crc[1] = in[0] ^ in[1] ^ in[6] ^ in[7] ^ crc[24] ^ crc[25] ^ crc[30] ^ crc[31];
    new_crc[0] = in[1] ^ in[7] ^ crc[24] ^ crc[30];

    memcpy(crc, new_crc, sizeof(crc));
}

int main(int argc, char *argv[]) {
    if(argc != 3) {
        printf("Invalid argument. Call %s with <filename> <start offset in decimal>.\n", argv[0]);
        return -1;
    }
    
    stdout = freopen(NULL, "wb", stdout);
    
    if(stdout == NULL) {
        printf("Error: can not reopen stdout.\n");
        return -1;
    }
    
    FILE *fp = fopen(argv[1], "rb");
    if(fp == NULL) {
        perror("fopen() failed");
        return -1;
    }
    
    int int_ret = fseek(fp, 0, SEEK_END);
    if(int_ret != 0) {
        perror("fseek() failed");
        fclose(fp);
        return -1;
    }
    
    int size = ftell(fp);
    if(size < 0) {
        perror("ftell() failed");
        fclose(fp);
        return -1;
    }
    
    rewind(fp);
    
    unsigned char *buf = new unsigned char[size];
    if(buf == NULL) {
        printf("new[] failed.\n");
        fclose(fp);
        return -1;
    }
    
    int_ret = fread(buf, size, 1, fp);
    if(int_ret != 1) {
        perror("fread() failed.\n");
        fclose(fp);
        delete buf;
        return -1;
    }
    
    unsigned char cmd = 0x00;
    unsigned int  offset = atoi(argv[2]);
    unsigned int  crc = 0;

    crc32(NULL, NULL);
    for(int i=0; i<size; i++) crc32(buf + i, NULL);
    crc32(NULL, &crc);
    
    int_ret = fwrite(&cmd, sizeof(cmd), 1, stdout);
    if(int_ret != 1) {
        perror("fwrite() failed");
        fclose(fp);
        delete buf;
        return -1;
    }
    
    int_ret = fwrite(&offset, sizeof(offset), 1, stdout);
    if(int_ret != 1) {
        perror("fwrite() failed");
        fclose(fp);
        delete buf;
        return -1;
    }
    
    int_ret = fwrite(&size, sizeof(size), 1, stdout);
    if(int_ret != 1) {
        perror("fwrite() failed");
        fclose(fp);
        delete buf;
        return -1;
    }
    
    int_ret = fwrite(buf, size, 1, stdout);
    if(int_ret != 1) {
        perror("fwrite() failed");
        fclose(fp);
        delete buf;
        return -1;
    }
    
    int_ret = fwrite(&crc, sizeof(crc), 1, stdout);
    if(int_ret != 1) {
        perror("fwrite() failed");
        fclose(fp);
        delete buf;
        return -1;
    }
    
    fclose(fp);
    delete buf;
    
    return 0;
}
