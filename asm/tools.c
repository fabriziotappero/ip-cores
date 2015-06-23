

#include<string.h>
#include <stdio.h>
#include <stdlib.h>
#include <search.h>


unsigned int address = 0;
unsigned int hex = 0;
unsigned int addr_table[10000]={0};

int hash_init()
{
	return hcreate(100);
}

void add_label(char *key, unsigned int addr)
{
	ENTRY e, *ep;

	//printf("<%s> added\n", key);
	e.key = key;
	e.data = (void *) addr;
	hsearch(e, ENTER);
}

unsigned int get_label(char *key)
{
	ENTRY e, *ep;

	e.key = key;
	ep = hsearch(e, FIND);

	if(ep) {
		//printf("<%s> found\n", key);
		return (unsigned int) ep->data;
	} else {
		//printf("<%s> not found\n", key);
		return 0;
	}
}

unsigned int get_abs_label(char *key)
{
	return get_label(key)+0x40;
}


char * str_toupper(char *s) 
{
	char *str = s;

	while(*s) {
	  	if(isalpha(*s)) *s = toupper(*s);
	  	s++;
	  }

	return str;
}

void xprintf(int val) 
{
	int i;
	if(hex==1) printf("%04x,\n", val);
	else if(hex==2) {
		for(i=0;i<16;i++){
			printf("%c", '0'+!!(val&0x8000));
			val=val<<1;
		}
		printf(",\n");
	}
	else printf("%c%c", val, (val>>8));
}

/*
void hash_add(char *key, char *data)
{
	ENTRY e, *ep;

	e.key = key;
	e.data = (void *) data;
	hsearch(e, ENTER);
}


char * hash_get(char *key)
{
	ENTRY e, *ep;

	e.key = key;
	ep = hsearch(e, FIND);

	return (char *) ep->data;
}

char * macro_insert(char *a)
{
	char *s = malloc(100);
	
	sprintf(s, "MACRO %s -- MACRO\n", a );

	return s;
}

*/

int check_imm(char *imm, int *val, int lo, int hi)
{
	int shiftcount = 0;
	//char *ret = malloc(100);
	int mrx=0;

	if(imm[0]=='0' && imm[1]=='x') {
		mrx = sscanf(imm, "%x", val);
//		printf("ox: %d", mrx);
	}

	if(!mrx) {
		mrx = sscanf(imm, "%d", val); 
//		printf("val: %s -> %d",imm, mrx);
	}
	
	if(mrx){
		if(*val>=lo && *val<=hi) return 0;
		else return 1;
	} 
	
	
	return 2;
}

/*
char *ari_to_bin(char *s)
{
	char *tmp = malloc(100);
	
	str_toupper(s);
	
	if(!strcmp(s, "ADD")) return "0000";
	if(!strcmp(s, "SUB")) return "0001";
	if(!strcmp(s, "ADD")) return "0000";
	if(!strcmp(s, "ADD")) return "0000";
	if(!strcmp(s, "ADD")) return "0000";
	if(!strcmp(s, "ADD")) return "0000";
	if(!strcmp(s, "ADD")) return "0000";
	if(!strcmp(s, "ADD")) return "0000";

} */





