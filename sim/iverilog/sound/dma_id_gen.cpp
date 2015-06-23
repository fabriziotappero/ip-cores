#include <cstdio>

static int E2_incr_table[4][9] = {
  {  0x01, -0x02, -0x04,  0x08, -0x10,  0x20,  0x40, -0x80, -106 },
  { -0x01,  0x02, -0x04,  0x08,  0x10, -0x20,  0x40, -0x80,  165 },
  { -0x01,  0x02,  0x04, -0x08,  0x10, -0x20, -0x40,  0x80, -151 },
  {  0x01, -0x02,  0x04, -0x08, -0x10,  0x20, -0x40,  0x80,   90 }
};

int get_value(int count, int input) {
    int ret = 0;
    for (int i = 0; i < 8; i++) {
        if ((input >> i) & 0x01) ret += E2_incr_table[count % 4][i];
    }
    ret += E2_incr_table[count % 4][8];
    
    return ret;
}

int main() {
    FILE *fp = fopen("dsp_dma_identification_rom.hex", "wb");
    
    for(int count=0; count<4; count++) {
        for(int input=0; input<256; input++) {
            int ret = get_value(count, input);
            fprintf(fp, "%d%d%d%d%d%d%d%d\n", (ret & 0x80)?1:0, (ret & 0x40)?1:0, (ret & 0x20)?1:0, (ret & 0x10)?1:0, (ret & 0x08)?1:0, (ret & 0x04)?1:0, (ret & 0x02)?1:0, (ret & 0x01)?1:0 );
        }
    }
    
    fclose(fp);
    return 0;
}