#include <cstdio>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

int main() {
    int index=0;
    char buf[65536];
    char name[256];
    
    int flags = fcntl(0, F_GETFL);
    fcntl(0, F_SETFL, flags | O_NONBLOCK);
    
    while(true) {
	snprintf(name, 256, "out_%03d.txt", index);
	FILE *fp = fopen(name, "wb");
	
	int count = 0;
	while(true) {
	    int rd = fread(buf, 1, sizeof(buf), stdin);
	    if(rd > 0) {
		//printf("%d\n", rd);
		fwrite(buf, 1, rd, fp);
		fflush(fp);
		count += rd;
	    }
	    else {
		fflush(fp);
		usleep(10);
		//fclose(fp);
	    }
	    if(count > 10000000) break;
	}
	fclose(fp);
	index++;
	if(index == 1000) index = 0;
    }

    return 0;
}
