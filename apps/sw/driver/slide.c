#include <sys/types.h>        
#include <sys/stat.h>        
#include <fcntl.h>  
#include <malloc.h>
#include <unistd.h>
#include <stdio.h>
#include <spartan_kint.h>
#include <sys/ioctl.h>

int main()
{
	int result ;
	int fd ;
	int i = 0;
	char buff[640*480] ;
	int palette[256] ;
	int c;
	unsigned long value ;

	fd = open("/dev/spartan", O_RDWR) ;

	if (fd < 0) {
		printf("Error: Opening device /dev/spartan\n");
		return fd ;
	}

	while (i < 54) {
                c = getchar();
                if (c == EOF)
                        error("Early end-of-file.");
                if ((i == 0) && (c != 0x42))
                        error("Not BMP format.");
                if ((i == 1) && (c != 0x4d))
                        error("Not BMP format.");
                if ((i == 2) && (c != 0x38))
                        error("Not 8-bit BMP format.");
                if ((i == 10) && (c != 0x36))
                        error("Not limited to 64 colors (6 bits).");
                if ((i == 11) && (c != 0x01))
                        error("Not limited to 64 colors (6 bits).");
                if ((i == 18) && (c != 0x80))
                        error("Not 640 pixels horizontal resolution.");
                if ((i == 19) && (c != 0x02))
                        error("Not 640 pixels horizontal resolution.");
                if ((i == 22) && (c != 0xe0))
                        error("Not 480 pixels vertical resolution.");
                if ((i == 23) && (c != 0x01))
                        error("Not 480 pixels vertical resolution.");
                i++;
        }

	// activate resource 2
        value = 0x00000002 ;
        result = ioctl(fd, SPARTAN_IOC_CURRESSET, value) ;

       	/* Set palette */
        lseek(fd, SPARTAN_CRT_PALETTE_BASE, 0);

	while (i < 310) {
                if (c == EOF)
                        error("Early end-of-file.");
	
		palette[(i - 54)/4] = ((getchar() >> 4) << 12) | ((getchar() >> 4) << 8) | ((getchar() >> 4) << 4);

printf("%.4x\n", palette[(i - 54)/4]);
	getchar();
              	i+=4;
        }

	while (i < 307510) { 
		buff[sizeof(buff) - (i - 310)] =  (char)getchar();
		i++;
	}
	
	if(write(fd, palette, 0x400) != 0x400) {
               	printf("Error writing device /dev/spartan\n");
               	return -1;
       	}

	ioctl(fd, SPARTAN_IOC_SET_VIDEO_BUFF, buff) ;
	
	close(fd);
	return 0;
}

