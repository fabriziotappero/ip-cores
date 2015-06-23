

#include<stdio.h>
#include <search.h>

#define RDLINE() fgets(line, 1024, stdin)

#define STATE_MACRO 1
#define STATE_ENDM 2
#define STATE_USEM 3


char line[1024];
char *p;

char buffer[10000];


void get_params(char *p, char names[12][256]) {
	int newname = 0;
	int i=0, j=0;

	if(!p) return;

	memset(names, 0, 12*256);

	while(*p) {

		if(isalnum(*p)) {
			newname = 1;
			names[i][j++] = *p;
		} else {
			if(newname==1) {
				names[i][j] = 0;
				j=0;
				i++;
			}
			newname = 0;
		}

		p++;
	}
}


char *dollarfy(char *srci, char names[12][256])
{
	int i=2;
	char *dest, *src, *h;
	char *pd, *ps;

	src = malloc(strlen(srci) + 12);
	dest = malloc(strlen(srci) + 12);
	strcpy(src, srci);
	
	while(names[i][0]) {
		pd = dest;
		ps = src;

		while(*ps) {
			if(*ps=='\\') 
				if(!strncmp(++ps, names[i], strlen(names[i]))) {
					while(*ps && isalnum(*ps++));
					ps--;
					*pd++ = '$';
					*pd++ = ('0' + i-2);
					*pd = ' ';
				} else ps--;
			*pd = *ps;			
			pd++;
			ps++;
		}
		*pd = 0;
		i++;
		h = src;
		src = dest; 
		dest = h;
	}
	
	free(dest);
	return src;
}


int hash_macros()
{	
	int state=0;
	char *p;
	buffer[0] = 0;
	ENTRY e, *ep;
	char name[128];
	char parm[12][256];
	
	if(!RDLINE()) return 1;


	while(1) {
		if(p = strstr(line, ".macro")) {
			sscanf(line, " .macro %s ", name);
			get_params(p, parm);
			if(!RDLINE()) return 1;
			state = STATE_MACRO;
		}
		else if(p = strstr(line, ".endm")) state = STATE_ENDM;
		else if(p = strstr(line, ".usem")) {
			state = STATE_USEM;
			sscanf(line, " .usem %s ", name);
		}
		
		switch(state) {
			case STATE_MACRO: strcat(buffer, line); break;
			case STATE_ENDM: 
				p = dollarfy(buffer, parm);
				e.key = strdup(name);
				e.data = (void *) p;
				hsearch(e, ENTER);
				state = 0; buffer[0] = 0;
				break;
			case STATE_USEM: 
				e.key = strdup(name);
				ep = hsearch(e, FIND);
				if(ep) printf((char *) ep->data);
				state = 0; buffer[0] = 0;
				break;
			default: printf(line);
		}
		if(!RDLINE()) return 1;
	}		
}


int main(int argc, char **argv)
{

  hcreate(100);

  hash_macros();


}
