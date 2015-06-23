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
	unsigned long *buf ;
	unsigned long value ;
	unsigned long base ;
	unsigned long base_size ;

	fd = open("/dev/spartan", O_RDWR) ;

	if (fd < 0)
		return fd ;

	buf = (void *)malloc(4) ;

	if (buf == NULL)
		return -1 ;

	// probe driver
	result = ioctl(fd, SPARTAN_IOC_CURRESGET) ;

	if (result > 0)
		printf("Driver reports enabled resource although it was not enabled through ioctl yet\n!") ;

	result = ioctl(fd, SPARTAN_IOC_NUMOFRES) ;
	if (result != 2)
		printf("SDRAM reference design implements 2 BARs, driver reported %d!\n", result) ;

	result = ioctl(fd, SPARTAN_IOC_CURBASE, &base) ;
	if (base)
		printf("Driver reports base address resource selected although it was not yet initialized!\n") ;	

	result = ioctl(fd, SPARTAN_IOC_CURBASEMAP, &base) ;
	
	if (base)
                printf("Driver reports base address remaped although it was not yet initialized!\n") ;     

	result = ioctl(fd, SPARTAN_IOC_CURBASESIZE, &base_size) ;
	if (base_size)
                printf("Driver reports base address range non-zero although it was not yet initialized!\n") ;  

	// activate resource 1
	value = 0x00000001 ;
	result = ioctl(fd, SPARTAN_IOC_CURRESSET, value) ; 

	if (result)
		 printf("Driver reported failure to intialize resource 1 !\n") ;

	// activate resource 2
        value = 0x00000002 ;
        result = ioctl(fd, SPARTAN_IOC_CURRESSET, value) ;
 
        if (result)
                 printf("Driver reported failure to intialize resource 2!\n") ;    

	// check if ioctl returns any meaningful values!
	result = ioctl(fd, SPARTAN_IOC_CURRESGET) ;
 
        if (result != 2)
                printf("Resource 2 was enabled, driver reports resurce %d active!\n", result) ;
  
        result = ioctl(fd, SPARTAN_IOC_CURBASE, &base) ;
        if (!base)
                printf("Driver should report non-zero base address when resource is selected!\n") ;
 	else
		printf("Driver reports SDRAM at address %X\n", base) ;

        result = ioctl(fd, SPARTAN_IOC_CURBASEMAP, &base) ;
 
        if (!base)
                printf("Driver reports zero page base address although resource 2 is supposed to be enabled!\n") ;
 	else
		printf("Driver reports SDRAM at remaped address %X\n", base) ;

        result = ioctl(fd, SPARTAN_IOC_CURBASESIZE, &base_size) ;
        if (!base_size)
                printf("Driver reports zero base address range although resource is supposed to be enabled\n") ;     
	else
		printf("Driver reports SDRAM size %li\n", base_size) ;

	value  = 0x00000001 ;
	*(buf) = value ;
	while ((result = write(fd, buf, 4)) > 0)
	{
		value = value + 1 ;
		*(buf) = value ;
	}
	
	printf("%li writes succesfull!\n", value-1) ;

	// go back to start of image
	value = lseek(fd, 0, 0) ;
	if (result != 0)
	{
		printf("Seek didn't reset offset to 0i\n") ;
		return -1 ;
	}
	value = 0x00000001 ;
        while ((result = read(fd, buf, 4)) > 0)
        {
		if (value != *buf)
			printf("Expected value was %X, actually read value was %X\n", value, *buf) ;

                value = value + 1 ;
        }         

	printf("%li reads done!\n", value-1) ;
	close(fd) ;
	return result ;	
}
