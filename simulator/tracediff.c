#include <stdio.h>

/*  Simple program to find differences between hwemulator 
    execution path and execution path of the accual cpu */

int main(char argc, char** argv) {
    char logbuffer[6];
    char emubuffer[6];
    int lognumber = 0;
    int emunumber = 0;
    if ( argc != 4 ) {
	printf("Illegal number of arguments\n");
	printf("Usage: %s logtrace emutrace entrypoint\n",argv[0]);
	return -1;
    }
    
    
    FILE* logtrace = fopen(argv[1],"r");
    FILE* emutrace = fopen(argv[2],"r");
    
    if ( logtrace == NULL || emutrace == NULL) {
	printf("fopen failed\n");
	fclose(logtrace);
	fclose(emutrace);
	return -1;
    }

    printf("Searching for %s\n", argv[3]);
    // Lets find our entry point
    while ( fgets(logbuffer,6,logtrace) != NULL ) {
	    lognumber++;
	    if ( strncmp(logbuffer,argv[3],4) == 0 ) {
		break;
	    }
    }
    while ( fgets(emubuffer,6,emutrace) != NULL ) {
	    emunumber++;
	    if ( strncmp(emubuffer,argv[3],4) == 0 ) {
		break;
	    }
    }
    printf("Found entry points:\nLEVAL:%sEMU:%s",logbuffer,emubuffer);
    printf("Tracing\n");
    while( fgets(logbuffer,6,logtrace) != NULL && fgets(emubuffer,6,emutrace) != NULL) {
	emunumber++;
	lognumber++;
	if ( strcmp( logbuffer, emubuffer) != 0 ) {
	    printf("Different path: \nLEVAL:%d %sEMU:%d %s",lognumber, logbuffer,emunumber,emubuffer);
	    break;
	}
    }

    fclose(logtrace);
    fclose(emutrace);
}