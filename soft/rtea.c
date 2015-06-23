#define KEY     (256/32)
#define ROUND   ((32 + KEY*4) - 1)

unsigned int    a, b, c;

unsigned int    key[KEY] = {
    0xddeeff00, 0x99aabbcc,
    0x55667788, 0x11223344
};

void crypt() {
    char r;

    for (r=0; r <= ROUND; r++) {
        c = b;
        b = b + (a + ((b<<6)^(b>>8)) + key[r % KEY] + r);
        a = c;
        printf("%02i %08lX %08lX\n", r, a, b);
    }
}

void decrypt() {
    char r;

    for (r = ROUND; r>=0; r--) {
        c = a;
        a = b - (a + ((a<<6)^(a>>8)) + key[r % KEY] + r);
        b = c;
        printf("%02i %08lX %08lX\n", r, a, b);
    }
}

int main() {

    memset(key, 0 , sizeof(key));

    a = 0x12345678;
    b = 0x11112222;

    printf(">>>\n");
    crypt();

    a = 0x12345678;
    b = 0x11112222;

    printf("<<<\n");
    decrypt();

    return 0;
}
