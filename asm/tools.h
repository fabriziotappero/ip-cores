
typedef struct myvals {
  int num;
  int addr;
  char *str;
} myval;


extern unsigned int address;
extern unsigned int hex;

void xprintf(int val);
char * str_toupper(char *s);

int hash_init();
void add_label(char *key, unsigned int addr);
unsigned int get_label(char *key);unsigned int get_abs_label(char *key);
void read_labels(FILE *f);

